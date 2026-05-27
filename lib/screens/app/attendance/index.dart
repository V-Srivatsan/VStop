import 'package:flutter/material.dart';
import 'package:vstop/screens/login/form.dart';
import 'tile.dart';

import 'package:vstop/lib/data/attendance.dart';
import 'package:vstop/lib/data/timetable.dart';
import 'package:vstop/lib/store.dart';

class Screen extends StatefulWidget {
  final void Function(List<Widget>) updateActions;
  const Screen(this.updateActions, {super.key});

  @override
  State<Screen> createState() => _ScreenState();
}

class _ScreenState extends State<Screen> {
  
  String sem = "";
  List<TimetableEntry> courses = [];
  bool syncing = false;

  void getCourses() {
    final lst = Timetable(sem).getCourses();
    if (mounted) setState(() => courses = lst);
    else courses = lst;
  }

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (context.mounted)
        widget.updateActions([
          IconButton(onPressed: () {
            showDialog(context: context, builder: (_) => AlertDialog(
              title: Text("Sync Attendance"),
              content: LoginForm(onAuth: (ctx) async {
                if (ctx.mounted) Navigator.pop(ctx);
                setState(() => syncing = true);

                await fetchAttendance(sem);
                syncing = false;
                getCourses();
              })
            ));
          }, icon: Icon(Icons.sync)),
        ]);
    });

    () async { sem = await PrefStore.getSem(); getCourses(); }();
  }

  @override
  Widget build(BuildContext context) {

    return Padding(
      padding: .symmetric(horizontal: 20, vertical: 10),
      child: (
        sem.isEmpty ? Center(child: CircularProgressIndicator()) :
        syncing ? Center(child: Column(
          mainAxisSize: .min, spacing: 10,
          children: [
            CircularProgressIndicator(),
            Text("Syncing...")
          ],
        )) :
        ListView(children: courses.where((c) => !c.percentage.isNaN).map((c) => AttendanceTile(c)).toList()
        )
      ),
    );
  }
}

