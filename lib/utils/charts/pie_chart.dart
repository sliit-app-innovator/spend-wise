import 'package:flutter/material.dart';
import 'package:spend_wise/utils/charts/pie_chart_painter.dart';
import 'dart:math';

class PieChart extends StatelessWidget {
  final Map<String, double> dataMap;
  List<Color> colors = [];

  PieChart({required this.dataMap});

  @override
  Widget build(BuildContext context) {
    if (dataMap.isEmpty) {
      return Row(mainAxisAlignment: MainAxisAlignment.center, crossAxisAlignment: CrossAxisAlignment.start, children: []);
    }
    addUniqueRandomColors(colors, dataMap.length);
    double total = dataMap.values.reduce((a, b) => a + b);

    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Pie Chart
        Container(
          width: 200,
          height: 200,
          child: CustomPaint(
            painter: PieChartPainter(dataMap, colors),
          ),
        ),
        SizedBox(width: 16), // Space between chart and legend
        // Legends
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: dataMap.entries.map((entry) {
            int index = dataMap.keys.toList().indexOf(entry.key);
            double percentage = (entry.value / total) * 100;
            return Padding(
              padding: const EdgeInsets.symmetric(vertical: 4.0),
              child: Row(
                children: [
                  Container(
                    width: 16,
                    height: 16,
                    color: colors[index % colors.length],
                  ),
                  SizedBox(width: 8),
                  Text(
                    "${entry.key}: ${percentage.toStringAsFixed(1)}%",
                    style: TextStyle(fontSize: 14),
                  ),
                ],
              ),
            );
          }).toList(),
        ),
      ],
    );
  }

  static addUniqueRandomColors(List<Color> chartColors, int length) {
    for (int i = 0; i < length; i++) {
      chartColors.add(generateRandomColor());
    }
  }

  static Color generateRandomColor() {
    Random random = Random();
    return Color.fromARGB(
      255, // Fully opaque
      random.nextInt(256), // Random value for red (0-255)
      random.nextInt(256), // Random value for green (0-255)
      random.nextInt(256), // Random value for blue (0-255)
    );
  }
}
