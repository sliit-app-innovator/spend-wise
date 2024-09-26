import 'package:flutter/material.dart';
import 'package:spend_wise/pages/add_transaction_page.dart';
import 'package:spend_wise/dto/transaction.dart';
import 'package:spend_wise/model/transaction_repository.dart';

class TransactionsPage extends StatefulWidget {
  const TransactionsPage({super.key});

  @override
  _PaymentsPageState createState() => _PaymentsPageState();
}

class _PaymentsPageState extends State<TransactionsPage> {
  List<Widget> recentTxns = [];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: StreamBuilder<List<TransactionDto>>(
        stream: TransactionRepository()
            .getAllTransactionsStreamSQLLimit(), // Use the stream here
        builder: (BuildContext context,
            AsyncSnapshot<List<TransactionDto>> snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(child: CircularProgressIndicator()); // Loading state
          } else if (snapshot.hasError) {
            return Center(
                child: Text('Error: ${snapshot.error}')); // Error state
          } else if (snapshot.hasData && snapshot.data!.isEmpty) {
            return Center(child: Text('No transactions found.'));
          } else if (snapshot.hasData) {
            List<TransactionDto> transactions = snapshot.data!;
            List<Widget> recentTxns = [];
            transactions.forEach((tx) {
              recentTxns.add(transactionItem(
                  tx.source,
                  tx.txnTime,
                  tx.amount.toString(),
                  'LKR',
                  tx.type == 'Income'
                      ? 'assets/images/income.png'
                      : 'assets/images/expense.png'));
            });

            return ListView(
              children: recentTxns,
              padding: EdgeInsets.all(20.0),
            );
          } else {
            return Center(child: Text('No data available.'));
          }
        },
      ),
    );
  }

  //@override
  Widget build1(BuildContext context) {
    return Scaffold(
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 10.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Transactions
            const Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Recent Transactions',
                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
                ),
              ],
            ),
            const SizedBox(height: 10),
            Expanded(
              child: ListView(
                children: recentTxns,
              ),
            ),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => const AddTransactionPage()),
          );
        },
        backgroundColor: Colors.orange,
        child: Icon(Icons.add),
      ), // Show the FAB only on the HomePage
    );
  }

  Widget transactionItem(String source, String datetime, String amount,
      String currency, iconPath) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 10.0),
      child: Row(
        children: [
          CircleAvatar(
              radius: 20,
              child: Padding(
                padding:
                    EdgeInsets.all(10), // Add padding to reduce the image size
                child: ClipOval(
                  child: Image.asset(
                    iconPath,
                    fit: BoxFit.cover,
                  ),
                ),
              )),
          const SizedBox(width: 20),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                source,
                style: const TextStyle(fontWeight: FontWeight.bold),
              ),
              Text(
                datetime,
                style: const TextStyle(color: Colors.grey),
              ),
            ],
          ),
          const Spacer(),
          Text(
            '$currency $amount',
            style: const TextStyle(fontWeight: FontWeight.bold),
          ),
        ],
      ),
    );
  }
}
