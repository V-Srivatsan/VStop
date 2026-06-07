import 'package:flutter/material.dart';
import 'package:vstop/lib/data/calendar.dart';
import 'package:vstop/lib/notification.dart';
import 'package:vstop/lib/store.dart';
import 'package:vstop/screens/login/form.dart';

import 'index.dart' as calendar;

void syncCalendar(BuildContext ctx) {
  showDialog(context: ctx, builder: (_) => AlertDialog(
    title: Text("Sync Calendar"),
    content: LoginForm(onAuth: (context) async {
      final sem = await PrefStore.getSem();
      await Future.wait([AcademicCalendar.fetch(sem), AcademicCalendar.fetchExamSchedule(sem)]);
      await scheduleDailyNotifications(true);
      if (context.mounted) Navigator.pop(context);
      if (ctx.mounted) Navigator.pushReplacement(ctx, MaterialPageRoute(builder: (_) => calendar.Screen()));
    }),
  ));
}

List<CalendarEntry> getEntries() => AcademicCalendar.getEntries();
List<ExamEntry> getExams() => AcademicCalendar.getSchedule();