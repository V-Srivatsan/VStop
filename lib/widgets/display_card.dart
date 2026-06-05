import 'package:flutter/material.dart';
import 'package:vstop/theme.dart';

class DisplayCard extends StatelessWidget {
  final Color color; final String label; final Widget child;
  final void Function()? onTap;
  const DisplayCard({
    super.key, this.onTap,
    this.color = Colors.transparent, required this.label, required this.child,
  });

  @override
  Widget build(BuildContext context) {

    final widget = Container(
      padding: .all(10),
      decoration: BoxDecoration(border: .fromLTRB(left: .new(color: color, width: 5))),
      child: Center(child: Column(
        mainAxisAlignment: .center, mainAxisSize: .min,
        crossAxisAlignment: .stretch, spacing: 10,
        children: [Text(label, style: Theme.of(context).textTheme.labelMedium), child],
      )),
    );

    return Expanded(child: Card(
      child: onTap == null ? widget : InkWell(onTap: onTap, child: widget),
    ));
  }
}