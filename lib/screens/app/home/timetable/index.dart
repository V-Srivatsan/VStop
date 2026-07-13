import 'package:flutter/material.dart';
import 'package:vstop/lib/db.dart';
import 'package:vstop/lib/store.dart';
import 'schedule.dart';

import 'logic.dart';

class Screen extends StatefulWidget {
  const Screen({super.key});

  @override
  State<Screen> createState() => _ScreenState();
}

class _ScreenState extends State<Screen> {

  List<TimetableEntry> classes = [];

  @override
  void initState() {
    super.initState();
    () async {
      final timetable = Timetable(await PrefStore.getSem());
      setState(() { classes = timetable.getCourses(); });
    }();
  }

  @override
  Widget build(BuildContext context) {

    final schedules = DAYS.map((d) => getSchedule(classes, d.$1));
    final weekday = getTodayWeekday();

    return DefaultTabController(
      length: 5, initialIndex: weekday == null ? 0 : weekday - DateTime.monday,
      child: Scaffold(
      appBar: AppBar(
        title: Text("Timetable"),
        bottom: TabBar(tabs: DAYS.map((i) => Tab(text: i.$2)).toList()),
      ),
      body: SafeArea(child: TabBarView(children: schedules.map((schedule) =>
          Padding(
              padding: .symmetric(horizontal: 20, vertical: 10),
              child: Schedule(schedule, scrollable: true)
          ),
      ).toList()))
    ));
  }
}

const DAYS = [
  (DateTime.monday, "MON"), (DateTime.tuesday, "TUE"), (DateTime.wednesday, "WED"),
  (DateTime.thursday, "THU"), (DateTime.friday, "FRI"),
];
