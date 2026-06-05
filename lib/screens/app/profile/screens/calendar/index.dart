import 'package:flutter/material.dart';
import 'package:vstop/lib/data/calendar.dart';

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
  String? key;

  @override
  void initState() {
    super.initState();
    entries = .fromEntries(logic.getEntries().map((e) => MapEntry(e.date, e)));
    exams = {};
    for (var entry in logic.getExams()) exams.putIfAbsent(entry.date, () => []).add(entry);
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

            Calendar(entries: entries, exams: exams, onSelect: (key) => setState(() => this.key = key)),
            Details(entries: entries, exams: exams, date: key)

          ],
        ),
      )),
    );
  }
}

// class Calendar extends StatefulWidget {
//   const Calendar({super.key});
//
//   @override
//   State<Calendar> createState() => _CalendarState();
// }
//
// class _CalendarState extends State<Calendar> {
//
//   late final Map<String, CalendarEntry> entries;
//   late final Map<String, List<ExamEntry>> exams;
//   int month = 0, year = 0; String? selected;
//
//   @override
//   void initState() {
//     super.initState();
//     final now = DateTime.now();
//     month = now.month; year = now.year; selected = now.day.toString();
//     entries = .fromEntries(logic.getEntries().map((e) => MapEntry(e.date, e)));
//     exams = {};
//     for (var entry in logic.getExams()) {
//       if (exams[entry.date] == null) exams[entry.date] = [];
//       exams[entry.date]!.add(entry);
//     }
//   }
//
//   bool isToday(String day) {
//     final now = DateTime.now();
//     return (year == now.year && month == now.month && now.day.toString() == day);
//   }
//
//   @override
//   Widget build(BuildContext context) {
//     return Padding(
//       padding: .symmetric(horizontal: 20, vertical: 10),
//       child: Column(
//         spacing: 20,
//         children: [
//
//           Calendar(),
//
//           Expanded(child: ListView(
//             children: () {
//               final res = <Widget>[];
//               if (selected == null) return res;
//
//               final key = '$year${month.toString().padLeft(2, "0")}${selected!.padLeft(2, "0")}';
//               res.add(ListTile(
//                 leading: Text('${selected.toString()}\n${MONTHS[month-1]}', textAlign: .center,),
//                 title: Text(
//                   entries[key]?.comment ?? (exams[key] != null ? "FAT" : "--")
//                 ),
//               ));
//
//               for (var exam in exams[key] ?? <ExamEntry>[])
//                 res.add(Card(child: ListTile(
//                   title: Text(exam.course), trailing: Text(exam.venue.replaceAll('-', '\n')),
//                   subtitle: Text('${exam.from} - ${exam.to}\n${exam.seatNo} (${exam.seatLoc})'),
//                 )));
//
//               return res;
//             }(),
//           ))
//
//
//         ],
//       ),
//     );
//   }
// }
