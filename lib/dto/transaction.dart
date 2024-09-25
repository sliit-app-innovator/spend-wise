import 'package:cloud_firestore/cloud_firestore.dart';

class Transaction {
  final String id;
  final String userId;
  final String type;
  final String source;
  final String description;
  final double amount;
  final String attachementUrl;
  final String txnTime;

  Transaction(
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

  static Transaction fromJson(Map<String, dynamic> json) {
    return Transaction(
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

Future<void> saveTransaction(Transaction transaction) async {
  CollectionReference transactions =
      FirebaseFirestore.instance.collection('transactions');
  await transactions.add(transaction.toJson());
}

Stream<List<Transaction>> getRecentTransactionsStream() {
  return FirebaseFirestore.instance.collection('transactions').snapshots().map(
    (snapshot) {
      return snapshot.docs.map((doc) {
        return Transaction.fromJson(doc.data() as Map<String, dynamic>);
      }).toList();
    },
  );
}

Stream<List<Transaction>> getMonthlyTransactionsStream() {
  return FirebaseFirestore.instance
      .collection('transactions')
      .limit(10)
      .orderBy("txnTime", descending: true)
      .snapshots()
      .map(
    (snapshot) {
      return snapshot.docs.map((doc) {
        return Transaction.fromJson(doc.data() as Map<String, dynamic>);
      }).toList();
    },
  );
}

Stream<List<Transaction>> getTransactionsForCurrentMonth() {
  // Get current month start and end dates
  DateTime now = DateTime.now();
  DateTime startOfMonth = DateTime(now.year, now.month, 1);
  DateTime endOfMonth = DateTime(now.year, now.month + 1, 0);

  // Return a stream of List<Transaction>
  return FirebaseFirestore.instance
      .collection('transactions')
      .orderBy("txnTime", descending: true)
      .snapshots()
      .map((querySnapshot) {
    // Convert each document to a Transaction object
    return querySnapshot.docs
        .map((doc) => Transaction.fromJson(doc.data() as Map<String, dynamic>))
        .where((txn) {
      // Parse the string 'txnTime' to DateTime
      DateTime txnDate = DateTime.parse(txn.txnTime);

      // Check if txnDate is within the current month
      return txnDate.isAfter(startOfMonth.subtract(Duration(days: 1))) &&
          txnDate.isBefore(endOfMonth.add(Duration(days: 1)));
    }).toList();
  });
}
