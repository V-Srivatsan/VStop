import 'package:flutter/material.dart';
import 'estimator/index.dart' as estimator;
import 'mark_tile.dart';

import 'package:vstop/lib/db.dart';
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

      final store = MarkStore(sem); await store.fetch();
      await MarkStore.syncToFirestore(store.getCourseMap());

      setState(false, store.getCourseMap());
    }),
  ));
}


Widget getMarkTile(BuildContext ctx, {
  required Course course, required List<TimetableEntry> entries,
  required bool predict, required bool aceGrading, required void Function() refresh
}) {
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

        ...(e.marks.map((mark) => MarkTile(mark)).toList())
      ],
    ));
  }

  final grade = entries.first.grade; final score = course.getScore(entries, aceGrading);
  return MarkTile(
    Mark(title: course.name, mark: score.$1, maxMark: score.$2, score: score.$1, maxScore: score.$2),
    grade: predict || grade == null ? grade : grade.startsWith('*') ? null : grade,
    onLongTap: course.getGrading(aceGrading) == .relative ?
      () async {
        await Navigator.push(ctx, MaterialPageRoute(builder: (_) => estimator.Screen(entries, aceGrading)));
        refresh();
      } : null,
    onTap: score.$2 == 0 ? null : () => showModalBottomSheet(
        context: ctx,
        builder: (_) {
          return Container(
            padding: .symmetric(horizontal: 20, vertical: 10),
            child: SingleChildScrollView(child: Column(
              mainAxisSize: .min, crossAxisAlignment: CrossAxisAlignment.start,
              spacing: 10,
              children: [
                Text(course.name, style: Theme.of(ctx).textTheme.titleLarge),
                Column(mainAxisSize: .min, children: children)
              ],
            )),
          );
        }
    ),
  );
}

double getGPA(List<MapEntry<Course, List<TimetableEntry>>> entries, bool predict) {
  double points = 0, credits = 0;

  for (var entry in entries) {
    final grade = entry.value.first.grade;
    if (grade == null || (!predict && grade.startsWith('*'))) continue;
    final gp = getGradePoint(grade.length == 1 ? grade : grade.substring(1));
    if (gp == null) continue;
    credits += entry.key.credits;
    points += entry.key.credits * gp;
  }

  return credits == 0 ? 0 : points/credits;
}

double getCGPA() => CourseStore.getCGPA();