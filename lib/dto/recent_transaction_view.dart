class Transaction {
  final String id;
  final String type;
  final String source;
  final double amount;
  final String txnTime;

  Transaction(
      {required this.id,
      required this.type,
      required this.source,
      required this.amount,
      required this.txnTime});

  // Converts User object to a map to store in Firestore
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'type': type,
      'source': source,
      'amount': amount,
      'txnTime': txnTime
    };
  }

  static Transaction fromJson(Map<String, dynamic> json) {
    return Transaction(
        id: json['id'],
        type: json['type'],
        source: json['source'],
        amount: json['amount'],
        txnTime: json['txnTime']);
  }
}
