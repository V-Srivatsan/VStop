import 'package:flutter/material.dart';
import 'package:vstop/lib/data/timetable.dart';

class AttendanceTile extends StatelessWidget {
  final TimetableEntry entry; final double thres;
  const AttendanceTile(this.entry, {super.key, required this.thres });

  @override
  Widget build(BuildContext context) {

    return Card(child: ListTile(
      title: Text(entry.course.target!.name),
      leading: Icon(entry.isLab ? Icons.science : Icons.book),
      trailing: Stack(
        alignment: .center,
        children: [
          CircularProgressIndicator(
            value: entry.percentage, constraints: .tight(Size(50, 50)),
            color: entry.percentage >= thres ? null : Theme.of(context).colorScheme.error,
          ),
          Text("${(entry.percentage * 100).round()}%"),
        ],
      ),
      onTap: () {
        showModalBottomSheet(context: context, builder: (_) => Padding(
          padding: .symmetric(horizontal: 20, vertical: 10),
          child: SafeArea(child: Column(
            mainAxisSize: .min, crossAxisAlignment: .stretch, spacing: 10,
            children: [

              Row(
                mainAxisAlignment: .spaceBetween,
                children: [
                  Expanded(child: Text(entry.course.target!.name, style: Theme.of(context).textTheme.titleLarge)),
                  Text("${entry.present.length} / ${entry.present.length + entry.absent.length}")
                ],
              ),

              AttendanceView(entry.present, entry.absent)
            ],
          )),
        ));
      },
    ));
  }
}


class AttendanceView extends StatefulWidget {
  final List<String> present, absent;
  const AttendanceView(this.present, this.absent, {super.key});

  @override
  State<AttendanceView> createState() => _AttendanceViewState();
}

class _AttendanceViewState extends State<AttendanceView> {

  late final int minMonth, minYear, maxMonth, maxYear;
  int month = 0, year = 0;
  Map<String, bool> attendance = {};

  DateTime _parseDate(String s) => DateTime.parse(s.endsWith('.') ? s.substring(0, s.length-1) : s);

  @override
  void initState() {
    super.initState();
    final lastEntry = _parseDate(
      widget.present.isEmpty ? widget.absent.first :
      widget.absent.isEmpty ? widget.present.first :
      widget.present.first.compareTo(widget.absent.first) < 0 ? widget.absent.first : widget.present.first
    ), firstEntry = _parseDate(
      widget.present.isEmpty ? widget.absent.last :
      widget.absent.isEmpty ? widget.present.last :
      widget.present.last.compareTo(widget.absent.last) > 0 ? widget.absent.last : widget.present.last
    );
    month = maxMonth = lastEntry.month; year = maxYear = lastEntry.year;
    minMonth = firstEntry.month; minYear = firstEntry.year;

    for (var p in widget.present) attendance[p] = true;
    for (var a in widget.absent) attendance[a] = false;
  }

  @override
  Widget build(BuildContext context) {

    List<List<String>> rows = [["M", "T", "W", "T", "F", "S", "S"]];
    final success = Theme.of(context).colorScheme.primary,
      warning = Theme.of(context).colorScheme.error;

    DateTime curr = DateTime(year, month);
    while (curr.month == month) {
      if (curr.weekday == DateTime.monday || rows.length == 1)
        rows.add(List.filled(7, ''));

      rows[rows.length-1][curr.weekday - DateTime.monday] = curr.day.toString();
      curr = curr.add(Duration(days: 1));
    }

    return Column(
      mainAxisSize: .min, spacing: 5,
      children: [

        Row(
          mainAxisSize: .min,
          children: [
            IconButton(
              onPressed: year == minYear && month == minMonth ? null : () {
                if (month == 1) year--;
                setState(() => month = month == 1 ? 12 : month-1);
              },
              icon: Icon(Icons.chevron_left)
            ),
            Text("${MONTHS[month-1]} $year"),
            IconButton(
              onPressed: year == maxYear && month == maxMonth ? null : () {
                if (month == 12) year++;
                setState(() => month = month == 12 ? 1 : month+1);
              },
              icon: Icon(Icons.chevron_right)
            ),
          ],
        ),

        Column(
          mainAxisSize: .min, spacing: 2.5,
          children: [
            for (var row in rows)
              Row(
                mainAxisAlignment: .spaceBetween,
                children: row.map((day) {
                  final key = year.toString() + month.toString().padLeft(2, '0') + day.padLeft(2, '0');
                  bool? present = attendance[key];

                  return Expanded(child: Container(
                    width: 25, height: 25,
                    decoration: BoxDecoration(
                      shape: .circle,
                      color: present == null ? Colors.transparent : present ? success : warning,
                      border: attendance['$key.'] == true ? .all(color: success) : null
                    ),
                    child: Center(child: Text(
                      day, textAlign: .center,
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: present == null ? null : present ? Colors.black : Colors.white
                      ),
                    )),
                  ));
                }).toList()
              )
          ],
        )

      ],
    );
  }
}

const MONTHS = ["Jan", "Feb", "Mar", "Apr", "May", "Jun", "Jul", "Aug", "Sep", "Oct", "Nov", "Dec"];