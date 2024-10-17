import 'package:flutter/material.dart';
import 'package:spend_wise/session/session_context.dart';
import 'package:spend_wise/utils/Widgets/charts/pie_chart_painter.dart';
import 'dart:math';

class SummaryRecord extends StatelessWidget {
  final String source;
  final double amount;

  SummaryRecord({required this.source, required this.amount});

  @override
  Widget build(BuildContext context) {
    Icon bullet = Icon(Icons.arrow_downward_outlined, color: Colors.green);
    if (SessionContext().expenseType(source)) {
      bullet = Icon(Icons.arrow_upward_outlined, color: Colors.red);
    }
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 10.0),
      child: Row(
        children: [
          bullet,
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                source,
                style: const TextStyle(fontWeight: FontWeight.bold),
              ),
            ],
          ),
          const Spacer(),
          Text(
            amount.toStringAsFixed(2),
            style: const TextStyle(fontWeight: FontWeight.bold),
          ),
        ],
      ),
    );
  }
}
