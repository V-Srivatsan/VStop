import 'dart:math';
import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';

import 'logic.dart' as logic;

class NormalChart extends StatelessWidget {
  late final double avg, point; final int total = 100;
  late final double sd;
  NormalChart({super.key, required double avg, required double point, required double total}) {
    sd = logic.estimateSD(avg/total);
    this.point = point * 100 / total;
    this.avg = avg * 100 / total;
  }

  List<FlSpot> getSpots(double avg, double sd, double point) {
    List<FlSpot> spots = [];
    for (var i in Iterable.generate(total+1, (i) => i * 1.0)) {
      if (i >= point && i - point < 1) spots.add(FlSpot(point, logic.normal(avg, sd, point)));
      spots.add(FlSpot(i, logic.normal(avg, sd, i)));
    }
    return spots;
  }

  @override
  Widget build(BuildContext context) {

    final lspots = getSpots(avg, sd-2, point),
      spots = getSpots(avg, sd, point),
      hspots = getSpots(avg, sd+4, point);

    final colorScheme = Theme.of(context).colorScheme;
    final dotData = FlDotData(show: true, checkToShowDot: (spot, _) => spot.x == point);

    return LineChart(LineChartData(
      lineTouchData: LineTouchData(enabled: false),
      gridData: FlGridData(drawHorizontalLine: false),
      titlesData: FlTitlesData(rightTitles: AxisTitles(), leftTitles: AxisTitles(), topTitles: AxisTitles()),
      lineBarsData: [
        LineChartBarData(
          spots: lspots, isCurved: true, dotData: dotData,
          color: point >= avg ? colorScheme.secondary : colorScheme.error,
        ),
        LineChartBarData(spots: spots, dotData: dotData, isCurved: true, color: colorScheme.primary),
        LineChartBarData(
          spots: hspots, dotData: dotData, isCurved: true,
          color: point <= avg ? colorScheme.secondary : colorScheme.error
        ),
      ],
    ));
  }
}
