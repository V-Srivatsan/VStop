import 'package:flutter/material.dart';
import 'logic.dart' as logic;

class TimetableCard extends StatelessWidget {
  final logic.ScheduleClass entry;
  const TimetableCard(this.entry, {super.key});

  @override
  Widget build(BuildContext context) {

    final venue = entry.entry.venue!.split("-");

    return Card(child: ListTile(
      title: Text(entry.entry.course.target!.name),
      subtitle: Text(entry.getTime()),
      trailing: ConstrainedBox(
        constraints: .tight(Size(50, 50)),
        child: Column(
          mainAxisSize: .min, mainAxisAlignment: .center,
          children: [ Text(venue.first), Text(venue.last) ],
        ),
      ),
    ));
  }
}
