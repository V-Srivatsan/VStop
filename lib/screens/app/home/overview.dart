import 'package:flutter/material.dart';
import 'package:vstop/lib/store.dart';
import 'package:vstop/lib/db.dart';
import 'timetable/logic.dart' show ScheduleClass;
import 'package:vstop/screens/app/attendance/logic.dart' show getSlotCounts, getSkippable;

import 'package:vstop/screens/app/index.dart' as app;
import 'package:vstop/widgets/display_card.dart';


class Overview extends StatelessWidget {
  final Semester? sem; final List<ScheduleClass> classes;
  final int thres;
  const Overview(this.sem, this.classes, {super.key, required this.thres});

  (int, int) getOverall(Semester? sem) {
    if (sem == null) return (0, 0);
    int present = 0, total = 0;

    for (var entry in Timetable(sem.code).getCourses()) {
      present += entry.present.length;
      total += entry.present.length + entry.absent.length;
    }

    return (present, total);
  }

  @override
  Widget build(BuildContext context) {

    final text = Theme.of(context).brightness == .dark ? Colors.white : Colors.black;
    final (present, total) = getOverall(sem);
    final skippable = getSkippable(thres/100, getSlotCounts(sem?.code ?? ""), total_present: present, total_absent: total-present);

    ScheduleClass? next;
    final now = DateTime.now(); final time = Duration(hours: now.hour, minutes: now.minute, seconds: now.second);
    for (final cls in classes)
      if (cls.end > time && cls.start - time > Duration(minutes: -10)) {
        next = cls;
        break;
      }


    final start = next == null ? 'Done' :
      "${next.start.inHours.toString().padLeft(2, '0')}:${next.start.inMinutes.remainder(60).toString().padLeft(2, '0')}";

    return Column(
      mainAxisSize: .min, crossAxisAlignment: .stretch, spacing: 10,
      children: [
        IntrinsicHeight(child: Row(
          mainAxisAlignment: .spaceBetween, spacing: 10,
          crossAxisAlignment: .stretch,
          children: [
            DisplayCard(
              color: Theme.of(context).colorScheme.primary,
              label: "Attendance",
              child: Column(
                mainAxisSize: .min, crossAxisAlignment: .start,
                children: [
                  Text(
                      "${(total == 0 ? 0 : 100*present/total).toStringAsFixed(2)}%",
                      style: Theme.of(context).textTheme.headlineSmall?.copyWith(color: text)
                  ),
                  Text(
                    skippable >= 0 ? "Skip: $skippable" : "Unrecoverable",
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(color: (
                      skippable >= 0 ? Theme.of(context).colorScheme.secondary :
                      Theme.of(context).colorScheme.error
                    )),
                  )
                ],
              )
            ),
            DisplayCard(
              color: Theme.of(context).colorScheme.secondary,
              label: next != null && next.start < time ? "Current Class" : "Next Class",
              child: Column(
                mainAxisSize: .min, crossAxisAlignment: .stretch,
                children: [
                  Text(start, style: Theme.of(context).textTheme.bodyLarge?.copyWith(color: text)),
                  Text(
                      next?.entry.venue! ?? 'for today',
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        fontWeight: .bold,
                        color: Theme.of(context).colorScheme.secondary
                      )),
                ],
              )
            )
          ],
        )),

        SemesterChange(sem)
      ],
    );
  }
}

class SemesterChange extends StatelessWidget {
  final Semester? semester;
  const SemesterChange(this.semester, {super.key});

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.sizeOf(context);
    
    return Card(child: ListTile(
      title: Text(semester?.name ?? ''),
      trailing: Icon(Icons.chevron_right),
      onTap: () {
        showDialog(context: context, builder: (ctx) => AlertDialog(
            title: Text("Change Semester"),
            content: SizedBox(
              width: .maxFinite, height: size.height*0.3,
              child: ListView(
                shrinkWrap: true,
                children: SemStore.getSems().map((sem) => Card(
                  child: ListTile(
                    title: Text(sem.name),
                    onTap: () {
                      PrefStore.setSem(sem.code);
                      Navigator.of(context).pushAndRemoveUntil(
                          MaterialPageRoute(builder: (c) => app.Screen()),
                          (_) => false
                      );
                    },
                  )
                )).toList()
              )
            )
        ));
      },
    ));
  }
}
