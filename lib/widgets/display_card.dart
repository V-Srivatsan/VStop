import 'package:flutter/material.dart';
import 'package:vstop/theme.dart';

class DisplayCard extends StatelessWidget {
  final Color color;
  final String label;
  final Widget child;
  const DisplayCard({super.key, this.color = Colors.transparent, required this.label, required this.child});

  @override
  Widget build(BuildContext context) {
    return Expanded(child: Card(
      child: Container(
        decoration: BoxDecoration(
            border: .fromLTRB(left: .new(color: color, width: 5))
        ),
        child: Padding(
          padding: .all(10),
          child: Center(child: Column(
            mainAxisAlignment: .center, mainAxisSize: .min,
            crossAxisAlignment: .stretch, spacing: 10,
            children: [Text(label, style: Theme.of(context).textTheme.labelMedium), child],
          )),
        ),
      ),
    ));
  }
}