import 'package:flutter/material.dart';
import 'home/index.dart' as home;
import 'attendance/index.dart' as attendance;
import 'marks/index.dart' as marks;
import 'profile/index.dart' as profile;

const MENU = [
  ("Dashboard", Icons.dashboard_outlined, Icons.dashboard),
  ("Attendance", Icons.fact_check_outlined, Icons.fact_check),
  ("Marks", Icons.note_alt_outlined, Icons.note_alt),
  ("Profile", Icons.person_2_outlined, Icons.person_2)
];

class Screen extends StatefulWidget {
  const Screen({super.key});

  @override
  State<Screen> createState() => _ScreenState();
}

class _ScreenState extends State<Screen> {

  int idx = 0; List<Widget> actions = [];

  void updateActions(List<Widget> lst) {
    if (mounted) setState(() => actions = lst);
    else actions = lst;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(MENU.map((item)=>item.$1).toList()[idx]),
        actions: actions,
      ),
      body: [
        home.Screen(),
        attendance.Screen(updateActions),
        marks.Screen(updateActions),
        profile.Screen()
      ][idx],
      bottomNavigationBar: BottomNavigationBar(
        onTap: (i) => setState(() { idx = i; actions = []; }), currentIndex: idx,
        items: MENU.indexed.map((item) => BottomNavigationBarItem(
          icon: Icon(idx == item.$1 ? item.$2.$3 : item.$2.$2),
          label: item.$2.$1
        )).toList(),
      ),
    );
  }
}
