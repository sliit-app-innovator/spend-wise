import 'package:flutter/material.dart';
import 'package:spend_wise/dto/transaction.dart';
import 'package:spend_wise/pages/add_transaction_page.dart';
import 'package:spend_wise/model/transaction_repository.dart';

class HomePage extends StatefulWidget {
  //const HomePage({super.key});
  @override
  _HomePageState createState() => _HomePageState();
}

@override
class _HomePageState extends State<HomePage> {
  List<Widget> recentTxns = [];

  @override
  Widget build(BuildContext context) {
    //   loadTransactions();
    return Scaffold(
      body: StreamBuilder<List<TransactionDto>>(
        stream: getRecentTransactionsStream(), // Use the stream here
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

            return Padding(
              padding:
                  const EdgeInsets.symmetric(horizontal: 20.0, vertical: 10.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Balance Card
                  Container(
                    padding: const EdgeInsets.all(20),
                    decoration: BoxDecoration(
                      color: Colors.brown[300],
                      borderRadius: BorderRadius.circular(15),
                    ),
                    child: const Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Total Balance',
                          style: TextStyle(color: Colors.white, fontSize: 16),
                        ),
                        SizedBox(height: 10),
                        Text(
                          '\$59,765.00',
                          style: TextStyle(
                              color: Colors.white,
                              fontSize: 32,
                              fontWeight: FontWeight.bold),
                        ),
                        SizedBox(height: 10),
                        Row(
                          children: [
                            Text(
                              '2644  7545  3867  1965',
                              style: TextStyle(color: Colors.white70),
                            ),
                            Spacer(),
                            Icon(Icons.credit_card, color: Colors.white),
                          ],
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 20),
                  // Analytics
                  const Text(
                    'Analytics',
                    style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
                  ),
                  const SizedBox(height: 10),

                  const SizedBox(height: 20),
                  // Transactions
                  const Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'Recent Transactions',
                        style: TextStyle(
                            fontWeight: FontWeight.bold, fontSize: 18),
                      ),
                      Text(
                        'View All',
                        style: TextStyle(
                            color: Colors.orange, fontWeight: FontWeight.bold),
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
            );
          } else {
            return Center(child: Text('No data available.'));
          }
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          print("Add transaction page naviation");
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
