import 'package:flutter/material.dart';
import 'drafts.dart';
import 'planner/index.dart';

class Screen extends StatelessWidget {
  const Screen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("FFCS Planner")),
      body: DefaultTabController(length: 2, child: Column(
        children: [
          TabBar(tabs: [ Tab(text: "Drafts"), Tab(text: "Planner") ]),
          Expanded(child: Padding(
            padding: .symmetric(vertical: 10),
            child: TabBarView(
              physics: NeverScrollableScrollPhysics(),
              children: [
                Drafts(),
                Padding(padding: .symmetric(horizontal: 20), child: Planner()),
              ]
            )
          ))
        ],
      ))
    );
  }
}