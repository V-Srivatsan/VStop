import 'package:flutter/material.dart';
import 'package:vstop/lib/store.dart';
import 'package:vstop/lib/data/sem.dart';
import 'package:vstop/lib/data/timetable.dart';
import 'timetable/logic.dart' show ScheduleClass;

import 'package:vstop/theme.dart' as theme;
import 'package:vstop/screens/splash/index.dart' as splash;


double getOverall(Semester? sem) {
  if (sem == null) return 0;
  int present = 0, total = 0;

  for (var entry in Timetable(sem.code).getCourses()) {
    present += entry.present.length;
    total += entry.present.length + entry.absent.length;
  }

  if (total == 0) return 0;
  return 100 * present/total;
}

class Overview extends StatelessWidget {
  final Semester? sem; final ScheduleClass? next;
  const Overview(this.sem, this.next, {super.key});

  @override
  Widget build(BuildContext context) {

    final isDark = Theme.of(context).brightness == .dark;
    final amber = isDark ? theme.VStopColors.darkAmber : theme.VStopColors.lightAmber;
    final teal = isDark ? theme.VStopColors.darkTeal : theme.VStopColors.lightTeal;
    final text = isDark ? Colors.white : Colors.black;

    final start = next == null ? '' :
      "${next!.start.inHours.toString().padLeft(2, '0')}:${next!.start.inMinutes.remainder(60).toString().padLeft(2, '0')}";

    return Column(
      mainAxisSize: .min, crossAxisAlignment: .stretch, spacing: 10,
      children: [
        IntrinsicHeight(child: Row(
          mainAxisAlignment: .spaceBetween, spacing: 10,
          crossAxisAlignment: .stretch,
          children: [
            DisplayCard(
              color: teal, label: "Attendance",
              child: Text(
                "${getOverall(sem).toStringAsFixed(2)}%",
                style: Theme.of(context).textTheme.headlineSmall?.copyWith(color: text)
              )
            ),
            DisplayCard(
              color: amber, label: "Next Class",
              child: Column(
                mainAxisSize: .min, crossAxisAlignment: .stretch,
                children: [
                  Text(start, style: Theme.of(context).textTheme.bodyLarge?.copyWith(color: text)),
                  Text(next?.entry.venue! ?? '', style: Theme.of(context).textTheme.bodyMedium?.copyWith(color: amber, fontWeight: .bold)),
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


class DisplayCard extends StatelessWidget {
  final Color color;
  final String label;
  final Widget child;
  const DisplayCard({super.key, required this.color, required this.label, required this.child});

  @override
  Widget build(BuildContext context) {
    return Expanded(child: Card(
      child: Container(
        decoration: BoxDecoration(
          border: .fromLTRB(left: .new(color: color, width: 5))
        ),
        child: Padding(
          padding: .all(10),
          child: Center(child: Column(
            mainAxisAlignment: .center, mainAxisSize: .min,
            crossAxisAlignment: .stretch, spacing: 10,
            children: [Text(label, style: Theme.of(context).textTheme.labelMedium), child],
          )),
        ),
      ),
    ));
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
            content: ConstrainedBox(
                constraints: BoxConstraints(maxWidth: .maxFinite, maxHeight: size.height * 0.3),
                child: ListView(
                    shrinkWrap: true,
                    children: SemStore.getSems().map((sem) => Card(
                      child: ListTile(
                        title: Text(sem.name),
                        onTap: () {
                          PrefStore.setSem(sem.code);
                          Navigator.of(context).pushAndRemoveUntil(
                              MaterialPageRoute(builder: (c) => splash.Screen()),
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
