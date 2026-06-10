import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:vstop/lib/db.dart';
import 'package:vstop/lib/store.dart';

import 'calendar.dart';
import 'details.dart';
import 'logic.dart' as logic;


class Screen extends StatefulWidget {
  const Screen({super.key});

  @override
  State<Screen> createState() => _ScreenState();
}

class _ScreenState extends State<Screen> {

  late final Map<String, CalendarEntry> entries;
  late final Map<String, List<ExamEntry>> exams;
  Map<String, List<Assignment>> assignments = {};
  String? key;

  @override
  void initState() {
    super.initState();
    entries = .fromEntries(logic.getEntries().map((e) => MapEntry(e.date, e)));
    exams = {};
    for (var entry in logic.getExams()) exams.putIfAbsent(entry.date, () => []).add(entry);
    PrefStore.getSem().then((sem) {
      final lst = <String, List<Assignment>>{};
      for (var assignment in AssignmentStore(sem).getAssignments())
        if (!assignment.completed)
          lst.putIfAbsent(DateFormat("yyyyMMdd").format(assignment.deadline), () => []).add(assignment);
      if (context.mounted) setState(() => assignments = lst);
      else assignments = lst;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Calendar"),
        actions: [
          IconButton(
            onPressed: () => logic.syncCalendar(context),
            icon: Icon(Icons.sync)
          )
        ],
      ),
      body: SafeArea(child: Padding(
        padding: .symmetric(horizontal: 20, vertical: 10),
        child: Column(
          spacing: 20,
          children: [

            Calendar(entries: entries, exams: exams, assignments: assignments, onSelect: (key) => setState(() => this.key = key)),
            Details(entries: entries, exams: exams, assignments: assignments, date: key)

          ],
        ),
      )),
    );
  }
}