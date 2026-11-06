import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:vstop/screens/login/form.dart';
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

  final _sync_key = GlobalKey<RefreshIndicatorState>();

  void getData() {
    entries = .fromEntries(logic.getEntries().map((e) => MapEntry(e.date, e)));
    exams = {};
    key = DateFormat("yyyyMMdd").format(.now());
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

  Future<void> sync() async {
    final success = await showDialog(context: context, builder: (_) => AlertDialog(
      title: Text("Sync Calendar"),
      content: LoginForm(onAuth: (ctx) => Navigator.pop(ctx, true)),
    ));

    if (success) {
      await logic.syncCalendar();
      getData();
    }
  }

  @override
  void initState() {
    super.initState();
    getData();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Calendar"),
        actions: [
          IconButton(
            onPressed: () => _sync_key.currentState?.show(),
            icon: Icon(Icons.sync)
          )
        ],
      ),
      body: SafeArea(child: Padding(
        padding: .symmetric(horizontal: 20, vertical: 10),
        child: RefreshIndicator(
          key: _sync_key,
          onRefresh: sync,
          child: Column(
            spacing: 20,
            children: [
              Calendar(entries: entries, exams: exams, assignments: assignments, onSelect: (key) => setState(() => this.key = key)),
              Details(entries: entries, exams: exams, assignments: assignments, date: key)
            ],
          ),
        )
      )),
    );
  }
}