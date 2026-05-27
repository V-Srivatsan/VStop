import 'package:flutter/material.dart';
import 'package:vstop/screens/app/home/timetable/card.dart';
import 'logic.dart' show ScheduleClass;

class Schedule extends StatelessWidget {
  final List<ScheduleClass> classes;
  final bool scrollable;
  const Schedule(this.classes, {super.key, this.scrollable = false });

  @override
  Widget build(BuildContext context) {
    return ListView(
      shrinkWrap: !scrollable, physics: !scrollable ? NeverScrollableScrollPhysics() : null,
      children: classes.map((e) => TimetableCard(e)).toList(),
    );
  }
}
