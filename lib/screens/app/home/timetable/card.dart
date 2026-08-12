import 'package:flutter/material.dart';
import 'package:vstop/lib/db.dart';
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

class ExamCard extends StatelessWidget {
  final ExamEntry exam;
  const ExamCard(this.exam, {super.key});

  @override
  Widget build(BuildContext context) {
    return Card(
      color: Theme.of(context).colorScheme.error.withAlpha(96),
      child: ListTile(
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
      )
    );
  }
}


class Break extends StatelessWidget {
  final Duration duration;
  const Break(this.duration, {super.key});

  @override
  Widget build(BuildContext context) {
    return
      duration < Duration(minutes: 30) ? SizedBox() :
      Row(children: [
        Expanded(child: Divider()),
        Text("${(duration.inHours).toString().padLeft(2, '0')}h ${(duration.inMinutes % 60).toString().padLeft(2, '0')}m"),
        Expanded(child: Divider())
      ]);
  }
}