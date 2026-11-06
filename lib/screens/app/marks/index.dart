import 'package:flutter/material.dart';
import 'package:vstop/lib/db.dart';
import 'package:vstop/lib/store.dart';
import 'package:vstop/widgets/display_card.dart';
import 'package:vstop/screens/login/form.dart';

import 'logic.dart' as logic;

class Screen extends StatefulWidget {
  final void Function(List<Widget>) updateActions;
  const Screen(this.updateActions, {super.key});

  @override
  State<Screen> createState() => _ScreenState();
}

class _ScreenState extends State<Screen> {

  List<MapEntry<Course, List<TimetableEntry>>> entries = [];
  bool predict = false, aceGrading = false; String sem = "";

  final _sync_key = GlobalKey<RefreshIndicatorState>();

  void refresh() => setState(() => entries = MarkStore(sem).getCourseMap().entries.toList());
  Future<void> sync() async {
    final success = await showDialog(context: context, builder: (ctx) => AlertDialog(
      title: Text("Sync Marks"),
      content: LoginForm(onAuth: (_) => Navigator.pop(ctx, true))
    ));

    if (success) {
      final store = MarkStore(sem);
      await store.fetch();
      await MarkStore.syncToFirestore(store.getCourseMap());
      refresh();
    }
  }

  @override
  void initState() {
    super.initState();
    PrefStore.getSem().then((sem) { this.sem = sem; refresh(); });
    PrefStore.getPredictiveGrades().then((val) => predict = val);
    PrefStore.getACEGrading().then((val) => aceGrading = val);

    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (context.mounted)
        widget.updateActions([
          IconButton(
              onPressed: () => _sync_key.currentState?.show(),
              icon: Icon(Icons.cloud_sync)
          )
        ]);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: .symmetric(horizontal: 15),
      child: RefreshIndicator(
        key: _sync_key, onRefresh: sync,
        child: CustomScrollView(slivers: [
          SliverToBoxAdapter(child: Column(
            mainAxisSize: .min, spacing: 10,
            children: [

              Row(
                mainAxisAlignment: .spaceBetween, spacing: 10,
                children: [

                  DisplayCard(
                    label: predict && entries.any((e) =>
                      e.value.any((e) => e.grade?.contains('*') ?? false)
                    ) ? 'GPA (est)' : "GPA", color: Theme.of(context).colorScheme.primary,
                    child: Text(
                      logic.getGPA(entries, predict).toStringAsFixed(2),
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
              logic.getMarkTile(context,
                course: entries[index].key, entries: entries[index].value,
                predict: predict, aceGrading: aceGrading, refresh: refresh
              )
          )

        ])
      )
    );
  }
}

