import 'package:flutter/material.dart';
import 'package:vstop/lib/data/marks.dart';
import 'package:vstop/lib/store.dart';

import 'mark_tile.dart';
import 'logic.dart' as logic;

class Screen extends StatefulWidget {
  final void Function(List<Widget>) updateActions;
  const Screen(this.updateActions, {super.key});

  @override
  State<Screen> createState() => _ScreenState();
}

class _ScreenState extends State<Screen> {

  Map<String, List<Mark>> marks = {};
  bool syncing = false;

  @override
  void initState() {
    super.initState();
    PrefStore.getSem().then((sem) {
      final store = MarkStore(sem);
      setState(() => marks = store.getMarks());
    });

    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (context.mounted)
        widget.updateActions([
          IconButton(
              onPressed: () => logic.syncMarks(
                context,
                (sync, m) => setState(() { syncing = sync; marks = m; })
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
      )) : ListView(
        children: marks.values.map((group) {
          final entry = group.first.entry.target!;
          double total = 0, maxTotal = 0;
          List<Widget> children = [];

          for (var mark in group) {
            total += mark.score; maxTotal += mark.maxScore;
            children.add(MarkTile(name: mark.title, score: mark.score, maxScore: mark.maxScore));
          }

          return MarkTile(
            name: entry.course.target!.name,
            score: total, maxScore: maxTotal, grade: entry.grade,

            onTap: () => showModalBottomSheet(
              context: context,
              builder: (_) => Container(
                padding: .symmetric(horizontal: 20, vertical: 10),
                child: SingleChildScrollView(child: Column(
                  mainAxisSize: .min, crossAxisAlignment: CrossAxisAlignment.start,
                  spacing: 10,
                  children: [
                    Text(entry.course.target!.name, style: Theme.of(context).textTheme.titleLarge),
                    ListView(shrinkWrap: true, physics: const NeverScrollableScrollPhysics(), children: children)
                  ],
                )),
              )
            ),
          );
        }).toList(),
      )
    );
  }
}

