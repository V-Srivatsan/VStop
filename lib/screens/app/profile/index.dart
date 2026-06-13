import 'package:flutter/material.dart';
import 'logic.dart' as logic;

import 'screens/calendar/index.dart' as calendar;
import 'screens/courses/index.dart' as courses;
import 'screens/ffcs/index.dart' as ffcs;
import 'screens/privacy.dart' as privacy;

class Screen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return SafeArea(child: SingleChildScrollView(
      child: Padding(
        padding: .symmetric(horizontal: 20, vertical: 10),
        child: Column(
          mainAxisSize: .min, crossAxisAlignment: .stretch, spacing: 15,
          children: [

            Section([
              ListTile(
                title: Text("Calendar"), leading: Icon(Icons.calendar_month),
                onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => calendar.Screen())),
              ),
              Divider(),
              ListTile(
                title: Text("My Courses"), leading: Icon(Icons.book_outlined),
                onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => courses.Screen())),
              ),
              Divider(),
              ListTile(
                title: Text("FFCS Planner"), leading: Icon(Icons.bookmark_outline),
                onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => ffcs.Screen()))
              )
            ]),

            Section([
              ListTile(
                title: Text("Sync Data"), leading: Icon(Icons.sync),
                onTap: () => logic.syncData(context),
              ),
              Divider(),
              ListTile(
                title: Text("Estimate Grades"), leading: Icon(Icons.calculate_outlined),
                trailing: PrefSwitch(getValue: logic.getEstimateGrades, onChanged: logic.setEstimateGrades),
              ),
              Divider(),
              ListTile(
                title: Text("ACE Grading System"), leading: Icon(Icons.grade_outlined),
                trailing: PrefSwitch(getValue: logic.getACEGrading, onChanged: (val) async {
                  await logic.setACEGrading(val);
                  if (context.mounted) showDialog(context: context, builder: (_) => AlertDialog(
                    title: Text("Grading System Changed"),
                    content: Text("Your estimated grades need to be recalculated. Sync your marks in the marks section to update the estimates according to the new system"),
                    actions: [ FilledButton(onPressed: () => Navigator.pop(context), child: Text("Understood")) ],
                  ));
                }),
              )
            ]),

            Section([
              ListTile(
                title: Text("Change Theme"), leading: Icon(Icons.brightness_medium),
                onTap: () => logic.updateTheme(context),
              ),
              Divider(),
              ListTile(
                title: Text("Notification Settings"), leading: Icon(Icons.notifications_outlined),
                onTap: () => logic.notificationSettings(),
              ),
              Divider(),
              ListTile(
                title: Text("Share App"), leading: Icon(Icons.share),
                onTap: () => logic.shareApp(),
              ),
              Divider(),
              ListTile(
                title: Text("Privacy Policy"), leading: Icon(Icons.privacy_tip_outlined),
                onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => privacy.Screen())),
              )
            ]),

            Section([
              ListTile(
                title: Text("Logout", style: TextStyle(color: Colors.white)),
                leading: Icon(Icons.logout, color: Colors.white),
                tileColor: Theme.of(context).colorScheme.error,
                onTap: () => logic.logout(context),
              )
            ]),

            Text("Developed by V Srivatsan", textAlign: .center)

          ],
        ),
      ),
    ));
  }
}


class Section extends StatelessWidget {
  final List<Widget> children;
  const Section(this.children, {super.key});

  @override
  Widget build(BuildContext context) {
    return Card(child: Column(
        mainAxisSize: .min, crossAxisAlignment: .stretch,
        children: children
    ));
  }
}


class PrefSwitch extends StatefulWidget {
  final Future<bool> Function() getValue;
  final Future<void> Function(bool) onChanged;
  const PrefSwitch({super.key, required this.getValue, required this.onChanged });

  @override
  State<PrefSwitch> createState() => _PrefSwitchState();
}

class _PrefSwitchState extends State<PrefSwitch> {

  bool value = false;

  @override
  void initState() {
    super.initState();
    widget.getValue().then((val) => setState(() => value = val));
  }

  @override
  Widget build(BuildContext context) {
    return Switch(value: value, onChanged: (val) async {
      widget.onChanged(val);
      setState(() => value = val);
    });
  }
}
