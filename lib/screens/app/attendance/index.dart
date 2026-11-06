import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:vstop/screens/login/form.dart';
import 'package:vstop/widgets/display_card.dart';
import 'tile.dart';

import 'package:vstop/lib/db.dart';
import 'package:vstop/lib/store.dart';
import 'logic.dart' as logic;

class Screen extends StatefulWidget {
  final void Function(List<Widget>) updateActions;
  const Screen(this.updateActions, {super.key});

  @override
  State<Screen> createState() => _ScreenState();
}

class _ScreenState extends State<Screen> {
  
  String sem = ""; int thres = 0;
  List<TimetableEntry> courses = [];
  late final Map<String, int> slots;

  final _sync_key = GlobalKey<RefreshIndicatorState>();

  void getCourses() {
    final lst = Timetable(sem).getCourses().where((e) => !e.percentage.isNaN).toList();
    if (mounted) setState(() => courses = lst);
    else courses = lst;
  }

  Future<void> sync() async {
    final success = await showDialog(context: context, builder: (_) => AlertDialog(
      title: Text("Sync Attendance"),
      content: LoginForm(onAuth: (ctx) async {
        if (ctx.mounted) Navigator.pop(ctx, true);
      })
    ));

    if (success) {
      await Timetable(sem).fetchAttendance();
      getCourses();
    }
  }

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (context.mounted)
        widget.updateActions([IconButton(
          onPressed: () => _sync_key.currentState?.show(),
          icon: Icon(Icons.sync)
        )]);
    });

    () async {
      thres = await PrefStore.getAttThreshold();
      sem = await PrefStore.getSem(); getCourses();
      slots = logic.getSlotCounts(sem);
    }();
  }

  @override
  Widget build(BuildContext context) {

    return Padding(
      padding: .symmetric(horizontal: 20, vertical: 10),
      child: (
        sem.isEmpty ? Center(child: CircularProgressIndicator()) :
        RefreshIndicator(
          key: _sync_key, onRefresh: sync,
          child: CustomScrollView(slivers: [
            SliverToBoxAdapter(child: Column(
              mainAxisSize: .min, crossAxisAlignment: .stretch,
              children: [

                Row(
                  mainAxisAlignment: .spaceBetween, spacing: 10,
                  children: [
                    DisplayCard(
                        label: "OD Used",
                        child: Text(
                            '${courses.fold(0, (prev, e) => prev + e.od_used).toString()} / 40',
                            style: Theme.of(context).textTheme.headlineMedium
                        )
                    ),

                    DisplayCard(
                      label: "Threshold",
                      onTap: () async {
                        final res = await showDialog(context: context, builder: (_) => UpdateThreshold(thres));
                        if (res != null) setState(() => thres = res);
                      },
                      child: Text('$thres%', style: Theme.of(context).textTheme.headlineMedium),
                    )
                  ],
                ),

                SizedBox(height: 15)
              ]
            )),

            SliverList.builder(
              itemCount: courses.length,
              itemBuilder: (_, i) => AttendanceTile(
                  courses[i], thres: thres / 100,
                  skippable: logic.getSkippable(thres / 100, slots, entry: courses[i])
              ),
            )

          ])
        )
      )
    );
  }
}


class UpdateThreshold extends StatelessWidget {
  final int curr;
  UpdateThreshold(this.curr, {super.key});
  final controller = TextEditingController();

  @override
  Widget build(BuildContext context) {
    controller.text = curr.toString();

    return AlertDialog(
      title: Text("Update Threshold"),
      content: TextFormField(
        controller: controller, keyboardType: .number,
        decoration: InputDecoration(label: Text("Threshold %")),
      ),
      actions: [
        OutlinedButton(onPressed: () => Navigator.pop(context), child: Text("Cancel")),
        FilledButton(onPressed: () async {
          int val = double.parse(controller.text).round();
          val = val >= 100 ? 100 : val <= 0 ? 0 : val;
          await PrefStore.setAttThreshold(val);
          if (context.mounted) Navigator.pop(context, val);
        }, child: Text("Update"))
      ],
    );
  }
}
