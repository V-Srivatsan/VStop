import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:vstop/lib/data/calendar.dart';
import 'package:vstop/lib/data/assignments.dart';
import 'package:vstop/widgets/calendar.dart';


class Calendar extends StatefulWidget {
  final Map<String, CalendarEntry> entries;
  final Map<String, List<ExamEntry>> exams;
  final Map<String, List<Assignment>> assignments;
  final void Function(String?) onSelect;
  const Calendar({ super.key, required this.entries, required this.exams, required this.assignments, required this.onSelect });

  @override
  State<Calendar> createState() => _CalendarState();
}

class _CalendarState extends State<Calendar> {

  int month = 0, year = 0;
  int? selected; final DateTime now = DateTime.now();

  @override
  void initState() {
    month = now.month; year = now.year; selected = now.day;
    super.initState();
  }

  @override
  Widget build(BuildContext context) {

    final currMonth = month == now.month && year == now.year;

    return Column(
      mainAxisSize: .min,
      children: [

        Row(
          mainAxisSize: .min, spacing: 5,
          children: [

            IconButton(
              onPressed: () => setState(() {
                selected = null; month--;
                if (month == 0) { month = 12; year--; }
                widget.onSelect(null);
              }),
              icon: Icon(Icons.chevron_left)
            ),
            Text(DateFormat("MMM yyyy").format(DateTime(year, month, 1))),
            IconButton(
              onPressed: () => setState(() {
                selected = null; month++;
                if (month == 13) { month = 1; year++; }
                widget.onSelect(null);
              }),
              icon: Icon(Icons.chevron_right)
            )

          ],
        ),

        CalendarBuilder(month: month, year: year, builder: (s) {
          final day = int.tryParse(s);
          final key = DateFormat("yyyyMMdd").format(DateTime(year, month, day ?? 1));
          final isToday = currMonth && day == now.day;

          return day == null ? SizedBox(
            width: 35, height: 35,
            child: Center(child: Text(s)),
          ) : Container(
            width: 35, height: 35,
            decoration: BoxDecoration(
              shape: .circle,
              color: isToday ? Theme.of(context).colorScheme.primary : null,
              border: selected == null || selected != day ? null :
                .all(color: Theme.of(context).colorScheme.secondary, width: 2)
            ),
            child: InkWell(
              onTap: () {
                setState(() => selected = day);
                widget.onSelect(key);
              },
              borderRadius: .circular(50),
              child: Column(
                mainAxisSize: .min, mainAxisAlignment: .center,
                children: [
                  Text(s, style: TextStyle(color: isToday ? Colors.black : null)),

                  Row(
                    mainAxisSize: .min, spacing: 2.5,
                    children: () {
                      return [
                        if (widget.entries[key] != null && widget.entries[key]!.entryType != .exam)
                          Badge(backgroundColor: (
                            widget.entries[key]!.entryType == .instructional ?
                              Theme.of(context).colorScheme.primary : Theme.of(context).colorScheme.secondary
                          )),

                        if (widget.exams[key] != null)
                          Badge(backgroundColor: Theme.of(context).colorScheme.error),

                        if (widget.assignments[key] != null) Badge()

                      ];
                    }(),
                  )
                ],
              )
            ),
          );
        })

      ],
    );
  }
}
