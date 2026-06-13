import 'package:flutter/material.dart';
import 'package:vstop/screens/app/profile/screens/ffcs/drafts.dart';

import 'planner/index.dart';

class Screen extends StatelessWidget {
  const Screen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("FFCS Planner")),
      body: DefaultTabController(length: 3, child: Column(
        children: [
          TabBar(tabs: [ Tab(text: "Drafts"), Tab(text: "Planner"), Tab(text: "Reviews") ]),

          Expanded(child: Padding(
            padding: .symmetric(vertical: 10),
            child: TabBarView(
              physics: NeverScrollableScrollPhysics(),
              children: [
                Drafts(),
                Padding(padding: .symmetric(horizontal: 20), child: Planner()),
                Center(child: Text("Coming soon..."))
              ]
            )
          ))
        ],
      ))
    );
  }
}
