import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:vstop/lib/store.dart';
import 'package:vstop/lib/data/sem.dart';
import 'package:vstop/lib/data/timetable.dart';

import 'package:vstop/screens/app/profile/screens/calendar/index.dart' as calendar;

import 'overview.dart';
import 'timetable/logic.dart' as tt_logic;
import 'timetable/index.dart' as all_schedule;
import 'timetable/schedule.dart';


class Screen extends StatefulWidget {
  const Screen({super.key});

  @override
  State<Screen> createState() => _ScreenState();
}

class _ScreenState extends State<Screen> {

  String? user; Semester? sem;
  List<tt_logic.ScheduleClass> classes = [];

  @override
  void initState() {
    super.initState();
    () async {
      final name = await PrefStore.getName();
      final timetable = Timetable(await PrefStore.getSem());
      final weekday = tt_logic.getTodayWeekday();
      final schedule = weekday == null ? <tt_logic.ScheduleClass>[] : tt_logic.getSchedule(timetable.getCourses(), weekday);

      if (!mounted) { user = name; classes = schedule; sem = timetable.sem; }
      else setState(() { user = name; classes = schedule; sem = timetable.sem; });
    }();
  }

  @override
  Widget build(BuildContext context) {

    tt_logic.ScheduleClass? nextClass;
    final now = Duration(hours: DateTime.now().hour, minutes: DateTime.now().minute);
    for (final c in classes) {
      if (c.start > now) {
        nextClass = c;
        break;
      }
    }

    return user == null ? Center(child: CircularProgressIndicator()) :
      SafeArea(child: SingleChildScrollView(
        child: Padding(
          padding: .symmetric(horizontal: 20, vertical: 10),
          child: Column(
            mainAxisSize: .min, crossAxisAlignment: .stretch, spacing: 30,
            children: [

              Column(
                mainAxisSize: .min, crossAxisAlignment: .start,
                children: [
                  Text(
                    "Hey, ${user ?? ''}",
                    style: Theme.of(context).textTheme.headlineMedium,
                  ),

                  TextButton(
                    style: ButtonStyle(padding: .all(.zero)),
                    onPressed: () => Navigator.push(context, MaterialPageRoute(builder: (_) => calendar.Screen())),
                    child: Text(
                      DateFormat("dd MMM, EEEE").format(DateTime.now()),
                      style: Theme.of(context).textTheme.bodyMedium,
                    ),
                  ),
                ],
              ),

              Overview(sem, nextClass),

              Column(
                mainAxisSize: .min, crossAxisAlignment: .stretch,
                children: [
                  Row(
                    mainAxisAlignment: .spaceBetween,
                    children: [
                      Text("Today's Schedule", style: Theme.of(context).textTheme.headlineSmall),
                      TextButton(
                          onPressed: () => Navigator.push(context, MaterialPageRoute(builder: (_) => all_schedule.Screen())),
                          child: Text("View All")
                      )
                    ],
                  ),

                  Schedule(classes)
                ],
              ),
            ],
          ),
        ),
      ));
  }
}
