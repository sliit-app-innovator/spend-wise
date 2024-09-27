import 'package:flutter/material.dart';
import 'package:spend_wise/dto/transaction.dart';
import 'package:spend_wise/pages/add_transaction_page.dart';
import 'package:spend_wise/model/transaction_repository.dart';
import 'package:spend_wise/dto/mothly_transaction_summary_view.dart';
import 'package:fl_chart/fl_chart.dart';

class HomePage extends StatefulWidget {
  //const HomePage({super.key});

  @override
  _HomePageState createState() => _HomePageState();
}

@override
class _HomePageState extends State<HomePage> {
  List<Widget> recentTxns = [];

  @override
  void initState() {
    super.initState();
    loadTransactionsSummary(); // Call loadTransactions when the widget initializes
  }

  // Method to load transactions (can be async if needed)
  void loadTransactionsSummary() {
    DateTime now = DateTime.now();
    TransactionRepository()
        .getMonthlyTransactionSummary(); // Fetch transactions
    setState(() {
      //totalExp = 100;
      //totalInc = 1000;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: FutureBuilder<MonthlyTransactionSummary>(
        future: TransactionRepository().getMonthlyTransactionSummary(),
        builder: (BuildContext context,
            AsyncSnapshot<MonthlyTransactionSummary> snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return CircularProgressIndicator();
          } else if (snapshot.hasError) {
            return Text('Error: ${snapshot.error}');
          } else if (snapshot.hasData) {
            final MonthlyTransactionSummary summary = snapshot.data!;
            List<Widget> recentTxns = [];
            double totalExp = 0;
            double totalInc = 0;
            double balance = 0;
            String currency = "LKR";

            summary.trasactions.forEach((tx) {
              recentTxns.add(transactionItem(
                  tx.source,
                  tx.txnTime,
                  tx.amount,
                  currency,
                  tx.type == 'Income'
                      ? 'assets/images/income.png'
                      : 'assets/images/expense.png'));
            });

            totalExp = summary.totalExpense;
            totalInc = summary.totalIncome;
            balance = totalInc - totalExp;

            final Map<String, double> dataMap = {
              "Food": 40,
              "Rent": 30,
              "Transport": 20,
              "Entertainment": 10,
            };

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
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'Total Balance',
                          style: TextStyle(color: Colors.white, fontSize: 16),
                        ),
                        const SizedBox(height: 10),
                        Text(
                          '$currency ${balance.toStringAsFixed(2)}',
                          style: const TextStyle(
                              color: Colors.white,
                              fontSize: 32,
                              fontWeight: FontWeight.bold),
                        ),
                        const SizedBox(height: 10),
                        Row(
                          children: [
                            Text(
                              'Income   ${totalInc.toStringAsFixed(2)}',
                              style: TextStyle(color: Colors.white70),
                            ),
                            Spacer(),
                            Text(
                              'Expense   ${totalInc.toStringAsFixed(2)}',
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
                  PieChart(
                    PieChartData(
                      sections: dataMap.entries
                          .map(
                            (entry) => PieChartSectionData(
                              title: entry.key,
                              value: entry.value,
                              color: _getRandomColor(entry.key),
                              titleStyle: TextStyle(
                                  fontSize: 16, fontWeight: FontWeight.bold),
                            ),
                          )
                          .toList(),
                      centerSpaceRadius: 50,
                      sectionsSpace: 2,
                    ),
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
            return Text('Error: ${snapshot.error}');
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

  Color _getRandomColor(String key) {
    return Colors.primaries[key.hashCode % Colors.primaries.length];
  }

  Widget transactionItem(String source, String datetime, double amount,
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
            amount.toStringAsFixed(2),
            style: const TextStyle(fontWeight: FontWeight.bold),
          ),
        ],
      ),
    );
  }
}
