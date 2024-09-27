import 'package:flutter/material.dart';
import 'package:spend_wise/main.dart';
import 'package:spend_wise/pages/add_transaction_page.dart';
import 'package:spend_wise/dto/transaction.dart';
import 'package:spend_wise/pages/home_page.dart';
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
            ;
            List<Map<String, dynamic>> recentTxns = [];

            transactions.forEach((tx) {
              recentTxns.add({
                'id': tx.id.toString(),
                'widget': transactionItem(
                    tx.id.toString(),
                    tx.source,
                    tx.type,
                    tx.description,
                    tx.txnTime,
                    tx.amount,
                    'LKR',
                    (tx.type == 'Income'
                        ? 'assets/images/income.png'
                        : 'assets/images/expense.png'),
                    (tx.type == 'Income'
                        ? Icon(Icons.get_app_rounded, color: Colors.brown)
                        : Icon(Icons.upload_outlined, color: Colors.brown))),
              });
            });

            List<Widget> widgetList =
                recentTxns.map((txn) => txn['widget'] as Widget).toList();

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
                    child: ListView(children: widgetList),
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

  Widget transactionItem(
      String id,
      String source,
      String type,
      String note,
      String datetime,
      double amount,
      String currency,
      iconPath,
      Icon viewIcon) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 5.0, horizontal: 0),
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
          const SizedBox(width: 10),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                source,
                style: const TextStyle(fontWeight: FontWeight.bold),
              ),
              Text(
                datetime.substring(0, 10),
                style: const TextStyle(color: Colors.grey),
              ),
            ],
          ),
          const Spacer(),
          Text(amount.toStringAsFixed(2),
              style: const TextStyle(fontWeight: FontWeight.bold)),
          IconButton(
            icon: viewIcon,
            onPressed: () {
              showDialog(
                context: context,
                builder: (BuildContext context) {
                  return AlertDialog(
                    titlePadding: EdgeInsets.zero,
                    title: Container(
                      color: Colors.brown,
                      padding: const EdgeInsets.all(16),
                      child: Row(
                        children: [
                          const Icon(Icons.get_app_rounded,
                              color: Colors.white),
                          const SizedBox(width: 8),
                          Expanded(
                            child: Text(
                              source,
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 20,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                    content: Text(
                      'Type : $type\n\nDate : $datetime\n\nNote : $note',
                      style: TextStyle(
                        color: Colors.grey[700], // Message text color
                        fontSize: 16,
                      ),
                    ),
                    actions: [
                      TextButton(
                        onPressed: () {
                          Navigator.of(context).pop(); // Close the dialog
                        },
                        child: const Text(
                          'OK',
                          style: TextStyle(
                              color: Colors.brown), // Button text color
                        ),
                      ),
                    ],
                  );
                },
              );
            },
          ),
          IconButton(
            icon:
                const Icon(Icons.delete_outline_outlined, color: Colors.brown),
            onPressed: () {
              showDialog(
                context: context,
                builder: (BuildContext context) {
                  return AlertDialog(
                    titlePadding:
                        EdgeInsets.zero, // Remove default padding for the title
                    title: Container(
                      color: Colors.brown, // Title bar background color
                      padding: const EdgeInsets.all(
                          16), // Padding for the title text
                      child: const Row(
                        children: [
                          Icon(Icons.warning_amber_rounded,
                              color: Colors.white),
                          SizedBox(width: 8),
                          Expanded(
                            child: Text(
                              'Confirm Delete',
                              style: TextStyle(
                                color: Colors.white, // Title text color
                                fontSize: 20,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                    content: Text(
                      'Are you sure you want to delete this item?',
                      style: TextStyle(
                        color: Colors.grey[700],
                        fontSize: 16,
                      ),
                    ),
                    actions: [
                      TextButton(
                        onPressed: () {
                          Navigator.of(context).pop();
                        },
                        child: const Text(
                          'Cancel',
                          style: TextStyle(color: Colors.brown),
                        ),
                      ),
                      TextButton(
                        onPressed: () {
                          print(TransactionRepository()
                              .deleteTransaction(int.parse(id)));

                          Navigator.of(context).pop();
                          Navigator.pushReplacement(
                            context,
                            MaterialPageRoute(
                              builder: (BuildContext context) =>
                                  MyApp(), // Replace with your page
                            ),
                          );
                        },
                        child: const Text(
                          'Delete',
                          style: TextStyle(color: Colors.red),
                        ),
                      ),
                    ],
                  );
                },
              );
            },
          )
        ],
      ),
    );
  }
}
