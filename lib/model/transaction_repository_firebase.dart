import 'package:spend_wise/dto/transaction.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class FirebaseRepository {}

Future<void> saveTransaction(TransactionDto transaction) async {
  CollectionReference transactions =
      FirebaseFirestore.instance.collection('transactions');
  await transactions.add(transaction.toJson());
}

Stream<List<TransactionDto>> getRecentTransactionsStreamold() {
  return FirebaseFirestore.instance.collection('transactions').snapshots().map(
    (snapshot) {
      return snapshot.docs.map((doc) {
        return TransactionDto.fromJson(doc.data() as Map<String, dynamic>);
      }).toList();
    },
  ).handleError((error) {
    // Handle the error by returning an empty list
    print("Error occurred: $error");
    return <TransactionDto>[]; // Return an empty list in case of error
  });
}

Stream<List<TransactionDto>> getRecentTransactionsStream() {
  return FirebaseFirestore.instance
      .collection('transactions')
      .limit(10)
      .orderBy("txnTime", descending: true)
      .snapshots()
      .map(
    (snapshot) {
      return snapshot.docs.map((doc) {
        return TransactionDto.fromJson(doc.data() as Map<String, dynamic>);
      }).toList();
    },
  ).handleError((error) {
    // Handle the error by returning an empty list
    print("Error occurred: $error");
    return <TransactionDto>[]; // Return an empty list in case of error
  });
}

Stream<List<TransactionDto>> getTransactionsForCurrentMonth() {
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
        .map((doc) =>
            TransactionDto.fromJson(doc.data() as Map<String, dynamic>))
        .where((txn) {
      // Parse the string 'txnTime' to DateTime
      DateTime txnDate = DateTime.parse(txn.txnTime);

      // Check if txnDate is within the current month
      return txnDate.isAfter(startOfMonth.subtract(Duration(days: 1))) &&
          txnDate.isBefore(endOfMonth.add(Duration(days: 1)));
    }).toList();
  }).handleError((error) {
    // Handle the error by returning an empty list
    print("Error occurred: $error");
    return <TransactionDto>[]; // Return an empty list in case of error
  });
}
