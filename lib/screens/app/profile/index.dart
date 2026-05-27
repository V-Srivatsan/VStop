import 'package:flutter/material.dart';
import 'package:vstop/theme.dart' as theme;
import 'logic.dart' as logic;

import 'screens/privacy.dart' as privacy;

class Screen extends StatelessWidget {
  const Screen({super.key});

  @override
  Widget build(BuildContext context) {

    final warning = MediaQuery.of(context).platformBrightness == Brightness.dark ?
      theme.VStopColors.darkWarning : theme.VStopColors.lightWarning;

    return SafeArea(child: SingleChildScrollView(
      child: Padding(
        padding: .symmetric(horizontal: 20, vertical: 10),
        child: Column(
          mainAxisSize: .min, crossAxisAlignment: .stretch, spacing: 15,
          children: [

            Section([
              ListTile(
                title: Text("Change Theme"), leading: Icon(Icons.brightness_medium),
                onTap: () => logic.updateTheme(context),
              )
            ]),
            
            Section([
              ListTile(
                title: Text("Share App"), leading: Icon(Icons.share),
                onTap: () => logic.shareApp(),
              ),

              ListTile(
                title: Text("Privacy Policy"), leading: Icon(Icons.privacy_tip_outlined),
                onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => privacy.Screen())),
              )
            ]),

            Section([
              ListTile(
                title: Text("Sync Data"), leading: Icon(Icons.sync),
                onTap: () => logic.syncData(context),
              ),

              ListTile(
                title: Text("Logout", style: TextStyle(color: Colors.white)),
                leading: Icon(Icons.logout, color: Colors.white), tileColor: warning,
                onTap: () => logic.logout(context),
              )
            ]),

            Text("Developed by V Srivatsan")

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
