import 'package:spend_wise/dto/transaction.dart';

class MonthlyTransactionSummary {
  final List<TransactionDto> trasactions;
  final double totalIncome;
  final double totalExpense;
  final Map<String, double> expensesMap;

  MonthlyTransactionSummary(
      {required this.trasactions,
      required this.totalIncome,
      required this.totalExpense,
      required this.expensesMap});

  // Converts User object to a map to store in Firestore
  Map<String, dynamic> toJson() {
    return {
      'trasactions': trasactions,
      'totalIncome': totalIncome,
      'totalExpense': totalExpense,
      'expensesMap': expensesMap
    };
  }

  static MonthlyTransactionSummary fromJson(Map<String, dynamic> json) {
    return MonthlyTransactionSummary(
        trasactions: json['trasactions'],
        totalIncome: json['totalIncome'],
        totalExpense: json['totalExpense'],
        expensesMap: json['expensesMap']);
  }
}
