import 'package:flutter/material.dart';
import 'package:vstop/lib/db.dart';
import 'card.dart';
import 'logic.dart' show ScheduleClass;

class Schedule extends StatelessWidget {
  final List<ScheduleClass> classes; final List<ExamEntry> exams;
  final bool scrollable;
  const Schedule(this.classes, {super.key, this.exams = const [], this.scrollable = false });

  @override
  Widget build(BuildContext context) {
    return classes.isEmpty && exams.isEmpty ? Center(child: Text("No classes today")) :
    ListView(
      shrinkWrap: !scrollable, physics: !scrollable ? NeverScrollableScrollPhysics() : null,
      children: classes.isEmpty ?
        exams.map((e) => ExamCard(e)).toList() :
        () {
          final list = <Widget>[];
          Duration? prev;

          for (final c in classes) {
            if (prev != null) list.add(Break(c.start - prev));
            list.add(TimetableCard(c));
            prev = c.end;
          }

          return list;
        }(),
    );
  }
}
