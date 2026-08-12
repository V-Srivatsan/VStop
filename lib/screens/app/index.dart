import 'dart:convert';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:http/http.dart' as http;
import 'package:url_launcher/url_launcher.dart';
import 'package:flutter/material.dart';
import 'home/index.dart' as home;
import 'attendance/index.dart' as attendance;
import 'assignments/index.dart' as assignments;
import 'marks/index.dart' as marks;
import 'profile/index.dart' as profile;

const MENU = [
  ("Dashboard", Icons.dashboard_outlined, Icons.dashboard),
  ("Attendance", Icons.fact_check_outlined, Icons.fact_check),
  ("Assignments", Icons.assignment_outlined, Icons.assignment),
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
  FloatingActionButton? fab;

  void setFab(FloatingActionButton? btn) => setState(() => fab = btn);

  void updateActions(List<Widget> lst) {
    if (mounted) setState(() => actions = lst);
    else actions = lst;
  }

  @override
  void initState() {
    super.initState();
    PackageInfo.fromPlatform().then((info) async {
      try {
        final latest = jsonDecode((await http.get(
            Uri.parse("https://api.github.com/repos/V-Srivatsan/VStop/releases/latest")
        )).body)['tag_name'];

        if (latest != 'v${info.version}' && context.mounted)
          await showDialog(
              context: context, barrierDismissible: false,
              builder: (ctx) => AlertDialog(
                  title: Text("Update Available"),
                  content: Text("A new version of V-Stop is available for download!\n\nPlease update to the latest version for the best experience."),
                  actions: [
                    OutlinedButton(onPressed: () => Navigator.pop(ctx), child: Text("Later")),
                    FilledButton(
                        onPressed: () => launchUrl(Uri.parse("https://github.com/V-Srivatsan/VStop/releases/latest")),
                        child: Text("Download")
                    )
                  ]
              )
          );
      } catch (_) {}
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(MENU.map((item)=>item.$1).toList()[idx]),
        actions: actions,
      ), floatingActionButton: fab,
      body: [
        home.Screen(),
        attendance.Screen(updateActions),
        assignments.Screen(setFab),
        marks.Screen(updateActions),
        profile.Screen()
      ][idx],
      bottomNavigationBar: BottomNavigationBar(
        onTap: (i) => idx == i ? null : setState(() { idx = i; actions = []; fab = null; }), currentIndex: idx,
        items: MENU.indexed.map((item) => BottomNavigationBarItem(
          icon: Icon(idx == item.$1 ? item.$2.$3 : item.$2.$2),
          label: item.$2.$1
        )).toList(),
      ),
    );
  }
}
