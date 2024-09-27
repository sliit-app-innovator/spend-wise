import 'package:flutter/material.dart';
import 'package:spend_wise/pages/add_transaction_page.dart';
import 'package:spend_wise/dto/transaction.dart';
import 'package:spend_wise/pages/transaction_page.dart';
import 'package:spend_wise/model/transaction_repository.dart';
import 'package:spend_wise/utils/colors.dart';

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
                  tx.amount,
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
                  const SizedBox(height: 5),
                  // Transactions
                  Container(
                    width: double.infinity,
                    padding:
                        EdgeInsets.all(16.0), // Add padding around the text
                    //  color: Color(0xFFD6C4A8), // Light brown color
                    decoration: BoxDecoration(
                      color: const Color.fromARGB(255, 240, 215, 206),
                      borderRadius: BorderRadius.circular(15),
                    ),
                    child: const Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          'This Month Transactions',
                          style: TextStyle(
                              fontWeight: FontWeight.bold, fontSize: 18),
                        ),
                        Icon(Icons.list_alt_outlined,
                            color: AppColors.TABLE_HEADER_COLOR),
                      ],
                    ),
                  ),

                  //const SizedBox(height: 10),
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
    );
  }

  Widget transactionItem(String source, String datetime, double amount,
      String currency, iconPath) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 10.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.end,
        children: [
          CircleAvatar(
              radius: 20,
              child: Padding(
                padding: EdgeInsets.all(10),
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
          Text('${amount.toStringAsFixed(2)}    ',
              style: const TextStyle(fontWeight: FontWeight.bold)),
          IconButton(
            icon: Icon(Icons.get_app_rounded, color: Colors.brown),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                    builder: (context) => const TransactionPage()),
              );
            },
          )
        ],
      ),
    );
  }
}
