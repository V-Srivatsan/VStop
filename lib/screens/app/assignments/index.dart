import 'package:flutter/material.dart';
import 'package:vstop/lib/db.dart';
import 'package:vstop/lib/store.dart';

import 'tile.dart';
import 'logic.dart' as logic;

class Screen extends StatefulWidget {
  final void Function(FloatingActionButton?) setFab;
  const Screen(this.setFab, {super.key});

  @override
  State<Screen> createState() => _ScreenState();
}

class _ScreenState extends State<Screen> {

  List<Assignment> pending = [], submitted = [];
  late final String sem;

  void refresh() {
    final lst = AssignmentStore(sem).getAssignments();
    final p = lst.where((a) => !a.completed).toList(), s = lst.where((a) => a.completed).toList();
    if (context.mounted) setState(() { pending = p; submitted = s; });
    else { pending = p; submitted = s; }
  }

  Future<bool> showSnackbar(String text) async {
    ScaffoldMessenger.of(context).clearSnackBars();
    final controller = ScaffoldMessenger.of(context).showSnackBar(SnackBar(
      content: Text(text), duration: Duration(seconds: 2), persist: false,
      action: SnackBarAction(label: "UNDO", onPressed: (){}),
    ));
    return (await controller.closed) != .action;
  }

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (context.mounted) widget.setFab(FloatingActionButton(
        onPressed: () async {
          final assignment = await logic.updateAssignment(context, sem: sem);
          if (assignment == null) return;
          final idx = pending.indexWhere((a) => a.deadline.isAfter(assignment.deadline));
          setState(() { idx == -1 ? pending.add(assignment) : pending.insert(idx, assignment); });
        },
        child: Icon(Icons.add),
      ));
    });
    PrefStore.getSem().then((semCode) { sem = semCode; refresh(); });
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: .symmetric(horizontal: 20),
      child: DefaultTabController(length: 2, child: Column(
        spacing: 10,
        children: [

          TabBar(tabs: [Tab(text: "Pending"), Tab(text: "Submitted")]),
          Expanded(child: TabBarView(
            physics: NeverScrollableScrollPhysics(),
            children: [

              (pending.isEmpty ? Center(child: Text("No pending assignments")) :
                ListView(
                  children: pending.indexed.map((e) {
                    final idx = e.$1, assignment = e.$2;

                    return AssignmentTile(
                      assignment: assignment, direction: .horizontal,
                      start: Icon(Icons.check_circle_outline), end: Icon(Icons.delete_outline),
                      onTap: () async { await logic.updateAssignment(context, assignment: assignment, sem: sem); refresh(); },

                      onDismiss: (dir) async {
                        int alt_idx = -1;
                        final delete = dir == .endToStart;
                        if (!delete) {
                          assignment.completed = true;
                          alt_idx = submitted.indexWhere((a) => a.deadline.isAfter(assignment.deadline));
                          if (alt_idx == -1) alt_idx = submitted.length;
                          submitted.insert(alt_idx, assignment);
                        }
                        setState(() { pending.removeAt(idx); });

                        final success = await showSnackbar(delete ? "Assignment deleted" : "Assignment submitted");
                        if (success) {
                          if (delete) logic.deleteAssignment(assignment);
                          else logic.completeAssignment(assignment);
                        } else {
                          assignment.completed = false;
                          if (!delete) submitted.removeAt(alt_idx);
                          if (context.mounted) setState(() { pending.insert(idx, assignment); });
                        }
                      },
                    );
                  }).toList()
                )
              ),

              (submitted.isEmpty ? Center(child: Text("No submitted assignments")) :
                ListView(
                  children: submitted.indexed.map((e) {
                    final idx = e.$1, assignment = e.$2;

                    return AssignmentTile(
                      assignment: assignment, direction: .horizontal,
                      start: Icon(Icons.undo), end: Icon(Icons.delete_outline),
                      onDismiss: (dir) async {
                        final delete = dir == .endToStart;
                        int alt_idx = -1;

                        if (!delete) {
                          assignment.completed = false;
                          alt_idx = pending.indexWhere((a) => a.deadline.isAfter(assignment.deadline));
                          if (alt_idx == -1) alt_idx = pending.length;
                          pending.insert(alt_idx, assignment);
                        }
                        setState(() { submitted.removeAt(idx); });

                        final success = await showSnackbar(delete ? "Assignment deleted" : "Assignment marked pending");
                        if (success) {
                          if (!delete) logic.completeAssignment(assignment, false);
                          else logic.deleteAssignment(assignment);
                        } else {
                          assignment.completed = true;
                          if (!delete) pending.removeAt(alt_idx);
                          if (context.mounted) setState(() { submitted.insert(idx, assignment); });
                        }
                      },
                    );
                  }).toList(),
                )
              )

            ]
          ))

        ],
      )),
    );
  }
}

