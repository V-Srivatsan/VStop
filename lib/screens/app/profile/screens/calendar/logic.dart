import 'package:flutter/material.dart';
import 'package:vstop/lib/data/calendar.dart';
import 'package:vstop/screens/login/form.dart';

import 'index.dart' as calendar;

void syncCalendar(BuildContext ctx) {
  showDialog(context: ctx, builder: (_) => AlertDialog(
    title: Text("Sync Calendar"),
    content: LoginForm(onAuth: (context) async {
      await AcademicCalendar.fetch();
      if (context.mounted) Navigator.pop(context);
      if (ctx.mounted) Navigator.push(ctx, MaterialPageRoute(builder: (_) => calendar.Screen()));
    }),
  ));
}

List<CalendarEntry> getEntries() => AcademicCalendar.get();