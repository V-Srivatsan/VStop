import 'package:flutter/material.dart';

class CalendarBuilder extends StatelessWidget {
  final int month, year; final Widget Function(String) builder;
  final bool expand;
  const CalendarBuilder({super.key, required this.month, required this.year, required this.builder, this.expand = false });

  @override
  Widget build(BuildContext context) {

    final rows = <List<String>>[["S", "M", "T", "W", "T", "F", "S"]];
    DateTime curr = DateTime(year, month);
    while (curr.month == month) {
      if (rows.length == 1 || curr.weekday == DateTime.sunday)
        rows.add(.filled(7, ""));

      rows[rows.length-1][curr.weekday%DateTime.sunday] = curr.day.toString();
      curr = curr.add(Duration(days: 1));
    }

    return Column(
      mainAxisSize: expand ? .max : .min, spacing: 5,
      children: [
        for (var row in rows)
          Row(
            mainAxisAlignment: .spaceBetween, spacing: 5,
            children: [
              for (var date in row)
                builder(date)
            ],
          )
      ],
    );
  }
}

