import 'package:flutter/material.dart';
import 'package:vstop/widgets/display_card.dart';

import 'logic.dart' as logic;

class Results extends StatelessWidget {
  final void Function(String) updateGrade;
  final double avg, score, total;
  const Results({super.key, required this.avg, required this.score, required this.total, required this.updateGrade});

  @override
  Widget build(BuildContext context) {

    final colorScheme = Theme.of(context).colorScheme;
    final style = Theme.of(context).textTheme.headlineMedium;

    final grades = [
      (
        logic.getGrade(avg, logic.estimateSD(score/total)-2, score, score/total),
        score > avg ? colorScheme.secondary : colorScheme.error,
        "Low SD"
      ),
      (
        logic.getGrade(avg, logic.estimateSD(score/total), score, score/total),
        colorScheme.primary, "Normal SD"
      ),
      (
        logic.getGrade(avg, logic.estimateSD(score/total)+4, score, score/total),
        score > avg ? colorScheme.error : colorScheme.secondary,
        "High SD"
      )
    ];

    return  Column(
      mainAxisSize: .min, spacing: 5,
      children: [
        Row(
          mainAxisAlignment: .spaceBetween, spacing: 15,
          children: [
            for (var estimate in grades)
              DisplayCard(
                label: estimate.$3, color: estimate.$2,
                onTap: () => updateGrade(estimate.$1),
                child: Text(estimate.$1, style: style),
              ),
          ],
        )
      ],
    );
  }
}
