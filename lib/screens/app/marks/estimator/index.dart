import 'package:flutter/material.dart';
import 'package:vstop/lib/db.dart';
import 'chart.dart';
import 'results.dart';

import 'logic.dart' as logic;

class Screen extends StatefulWidget {
  final List<TimetableEntry> entries; final bool aceGraded;
  const Screen(this.entries, this.aceGraded, {super.key});

  @override
  State<Screen> createState() => _ScreenState();
}

class _ScreenState extends State<Screen> {

  List<(TimetableEntry, List<double>)> marks = [];

  @override
  void initState() {
    super.initState();
    marks = [
      for (var entry in widget.entries)
        (entry, [for (var mark in entry.marks) (mark.maxMark / 2)])
    ];
  }


  @override
  Widget build(BuildContext context) {

    final (scored, avg, total) = logic.getStats(marks, widget.aceGraded);

    return DefaultTabController(length: 2, child: Scaffold(
      appBar: AppBar(title: Text("Grade Estimate")),
      body: SafeArea(child: Padding(
        padding: .symmetric(horizontal: 20, vertical: 10),
        child: Column(
          spacing: 10,
          children: [

            Text(widget.entries.first.course.target!.name, style: Theme.of(context).textTheme.headlineSmall),

            ConstrainedBox(
              constraints: .tight(Size(.infinity, MediaQuery.sizeOf(context).height * 0.3)),
              child: total == 0 ? Center(child: Text("No data present for modelling")) : NormalChart(avg: avg, point: scored, total: total)
            ),

            Results(
              avg: avg, score: scored, total: total,
              updateGrade: (g) => ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(
                logic.setGradeEstimate(marks.map((m) => m.$1).toList(), g)
              ))),
            ),

            Expanded(child: SingleChildScrollView(child: Column(
              mainAxisSize: .min, spacing: 5,
              children: [

                for (var i=0; i < marks.length; i++)
                  ...([
                    if (marks.length > 1)
                      Text(marks[i].$1.isLab ? "Lab" : "Theory", textAlign: .center),

                    for (var (idx, mark) in marks[i].$1.marks.indexed)
                      MarkSlider(mark, value: marks[i].$2[idx], update: (m) => setState(() => marks[i].$2[idx] = m))
                  ])
              ],
            ))),

          ],
        )
      )),
    ));
  }
}



class MarkSlider extends StatelessWidget {
  final Mark mark; final double value; final void Function(double) update;
  const MarkSlider(this.mark, {super.key, required this.value, required this.update});

  @override
  Widget build(BuildContext context) {
    return Card(child: ListTile(
      title: Text(mark.title), isThreeLine: true,
      onTap: () => update(-value),
      subtitle: Slider(
        value: value.abs(), min: 0, max: mark.maxMark,
        label: value.abs().toStringAsFixed(2), showValueIndicator: .onDrag,
        onChanged: value >= 0 ? update : null,
      )
    ));
  }
}


