import 'package:flutter/material.dart';
import 'package:vstop/screens/app/index.dart' as app;

import 'logic.dart';

class Screen extends StatefulWidget {
  const Screen({super.key});

  @override
  State<Screen> createState() => _ScreenState();
}

class _ScreenState extends State<Screen> {

  double progress = 0; String step = "";

  @override
  void initState() {
    super.initState();

    syncData((p, msg) {
      if (!mounted) return 0;
      setState(() { progress = p/100.0; step = msg; });
      if (p == 100) Navigator.of(context).pushAndRemoveUntil(
        MaterialPageRoute(builder: (ctx) => app.Screen()),
        (_) => false
      );

      return p;
    });
  }



  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(child: Center(
        child: Padding(
          padding: .symmetric(vertical: 10, horizontal: 20),
          child: Column(
            mainAxisSize: .min, crossAxisAlignment: .stretch, spacing: 10,
            children: [
              Text("Syncing data...", style: Theme.of(context).textTheme.displayMedium, textAlign: .center),
              Text("This may take a while.\nPlease do not close the app.", textAlign: .center),
              SizedBox(),
              LinearProgressIndicator(value: progress),
              Text(step, style: Theme.of(context).textTheme.bodySmall, textAlign: .center)
            ],
          ),
        ),
      )),
    );
  }
}
