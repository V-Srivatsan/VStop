import 'package:flutter/material.dart';
import 'mark_tile.dart';

import 'package:vstop/lib/data/marks.dart';
import 'package:vstop/lib/data/timetable.dart';
import 'package:vstop/lib/data/course.dart';
import 'package:vstop/screens/login/form.dart';

void syncMarks(
  BuildContext ctx, String sem,
  void Function(bool, Map<Course, List<TimetableEntry>>) setState
) {

  showDialog(context: ctx, builder: (context) => AlertDialog(
    title: Text("Sync Marks"),
    content: LoginForm(onAuth: (_) async {
      if (context.mounted) Navigator.pop(context);
      setState(true, {});

      await MarkStore(sem).fetch();

      await MarkStore.syncToFirestore(Timetable(sem).getCourses().fold([], (p, e) => p! + e.marks));

      setState(false, MarkStore(sem).getCourseMap());
    }),
  ));
}


Widget getMarkTile(
  BuildContext ctx, Course course,
  List<TimetableEntry> entries, bool predict
) {
  double total = 0, maxTotal = 0;
  List<Widget> children = [];

  for (var e in entries) {
    if (e.marks.isEmpty) continue;
    children.add(Column(
      mainAxisSize: .min,
      children: [
        if (entries.length > 1) Text(
          e.isLab ? "Lab" : "Theory",
          style: Theme.of(ctx).textTheme.titleSmall,
        ),

        ...(e.marks.map((mark) {
          total += mark.score; maxTotal += mark.maxScore;
          return MarkTile(name: mark.title, score: mark.score, maxScore: mark.maxScore);
        }).toList())
      ],
    ));
  }

  final grade = entries.first.grade;
  return MarkTile(
    name: course.name, score: total, maxScore: maxTotal,
    grade: predict || grade == null ? grade : grade.startsWith('*') ? null : grade,
    onTap: maxTotal == 0 ? null : () => showModalBottomSheet(
        context: ctx,
        builder: (_) => Container(
          padding: .symmetric(horizontal: 20, vertical: 10),
          child: SingleChildScrollView(child: Column(
            mainAxisSize: .min, crossAxisAlignment: CrossAxisAlignment.start,
            spacing: 10,
            children: [
              Text(course.name, style: Theme.of(ctx).textTheme.titleLarge),
              Column(mainAxisSize: .min, children: children)
            ],
          )),
        )
    ),
  );
}

double getGPA(List<MapEntry<Course, List<TimetableEntry>>> entries) {
  double points = 0, credits = 0;

  for (var entry in entries) {
    final grade = entry.value.first.grade;
    if (grade == null || grade.startsWith('*')) continue;
    final gp = getGradePoint(entry.value.first.grade);
    if (gp == null) continue;
    credits += entry.key.credits;
    points += entry.key.credits * gp;
  }

  return credits == 0 ? 0 : points/credits;
}

double getCGPA() => CourseStore.getCGPA();