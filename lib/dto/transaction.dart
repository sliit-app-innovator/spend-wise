import 'package:cloud_firestore/cloud_firestore.dart';

class TransactionDto {
  final String id;
  final String userId;
  final String type;
  final String source;
  final String description;
  final double amount;
  final String attachementUrl;
  final String txnTime;

  TransactionDto(
      {required this.id,
      required this.userId,
      required this.type,
      required this.source,
      required this.description,
      required this.amount,
      required this.attachementUrl,
      required this.txnTime});

  // Converts User object to a map to store in Firestore
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'userId': userId,
      'type': type,
      'source': source,
      'description': description,
      'amount': amount,
      'attachementUrl': attachementUrl,
      'txnTime': txnTime
    };
  }

  static TransactionDto fromJson(Map<String, dynamic> json) {
    return TransactionDto(
        id: json['id'],
        userId: json['userId'],
        type: json['type'],
        source: json['source'],
        description: json['description'],
        amount: json['amount'],
        attachementUrl: json['attachementUrl'],
        txnTime: json['txnTime']);
  }
}
