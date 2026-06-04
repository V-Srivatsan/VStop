import 'package:flutter/material.dart';
import 'package:vstop/lib/data/course.dart' show Course;
import 'package:vstop/lib/data/timetable.dart';
import 'package:vstop/lib/data/marks.dart';
import 'package:vstop/lib/store.dart';
import 'package:vstop/widgets/display_card.dart';

import 'logic.dart' as logic;

class Screen extends StatefulWidget {
  final void Function(List<Widget>) updateActions;
  const Screen(this.updateActions, {super.key});

  @override
  State<Screen> createState() => _ScreenState();
}

class _ScreenState extends State<Screen> {

  List<MapEntry<Course, List<TimetableEntry>>> entries = [];
  bool syncing = false, predict = false; String sem = "";

  @override
  void initState() {
    super.initState();
    PrefStore.getSem().then((sem) {
      this.sem = sem;
      setState(() => entries = MarkStore(sem).getCourseMap().entries.toList());
    });
    PrefStore.getPredictiveGrades().then((val) => predict = val);

    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (context.mounted)
        widget.updateActions([
          IconButton(
              onPressed: () => logic.syncMarks(
                context, sem,
                (sync, m) => setState(() { syncing = sync; entries = m.entries.toList(); })
              ),
              icon: Icon(Icons.cloud_sync)
          )
        ]);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: .symmetric(horizontal: 15),
      child: syncing ? Center(child: Column(
        mainAxisSize: .min, spacing: 10,
        children: [
          CircularProgressIndicator(),
          Text("Syncing...")
        ],
      )) : CustomScrollView(slivers: [

        SliverToBoxAdapter(child: Column(
          mainAxisSize: .min, spacing: 10,
          children: [

            Row(
              mainAxisAlignment: .spaceBetween, spacing: 10,
              children: [

                DisplayCard(
                  label: "GPA", color: Theme.of(context).colorScheme.primary,
                  child: Text(
                    logic.getGPA(entries).toStringAsFixed(2),
                    style: Theme.of(context).textTheme.headlineSmall,
                  )
                ),

                DisplayCard(
                  label: "CGPA", color: Theme.of(context).colorScheme.secondary,
                  child: Text(
                    logic.getCGPA().toStringAsFixed(2),
                    style: Theme.of(context).textTheme.headlineSmall,
                  ),
                )

              ],
            ),

            SizedBox(height: 10)

          ],
        )),

        SliverList.builder(
          itemCount: entries.length,
          itemBuilder: (context, index) =>
            logic.getMarkTile(context, entries[index].key, entries[index].value, predict)
        )

      ])
    );
  }
}

