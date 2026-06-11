import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:vstop/lib/db.dart';

class Details extends StatelessWidget {
  final Map<String, CalendarEntry> entries;
  final Map<String, List<ExamEntry>> exams;
  final Map<String, List<Assignment>> assignments;
  final String? date;
  const Details({super.key, required this.entries, required this.exams, required this.assignments, required this.date });

  @override
  Widget build(BuildContext context) {
    return Expanded(child: ListView(
      children: date == null ? [] : [
        ListTile(
          leading: Text(DateFormat("dd\nMMM").format(DateTime.parse(date!)), textAlign: .center),
          title: Text(entries[date!]?.comment ?? (exams[date!] != null ? "FAT" : "--")),
        ),

        for (var exam in exams[date!] ?? <ExamEntry>[])
          Card(child: ListTile(
            title: Text(exam.course),
            subtitle: Column(
              mainAxisSize: .min, crossAxisAlignment: .start,
              children: [
                Text('${exam.from} - ${exam.to}'),
                Text(
                  '${exam.seatNo} (${exam.seatLoc})',
                  style: Theme.of(context).textTheme.bodySmall
                )
              ],
            ),
            trailing: Text(exam.venue.replaceAll('-', '\n')),
          )),

        if (exams[date!] != null && assignments[date!] != null) Divider(),

        for (var assignment in assignments[date!] ?? <Assignment>[])
          Card(child: ListTile(
            title: Text(assignment.title), trailing: Badge(),
            subtitle: Text("Due: ${DateFormat("hh:mm").format(assignment.deadline)}"),
          )),
      ],
    ));
  }
}
