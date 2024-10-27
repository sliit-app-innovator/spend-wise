import 'package:flutter/material.dart';
import 'package:spend_wise/pages/add_transaction_page.dart';
import 'package:spend_wise/model/transaction_repository.dart';
import 'package:spend_wise/dto/mothly_transaction_summary_view.dart';
import 'package:spend_wise/session/session_context.dart';
import 'package:spend_wise/utils/Widgets/rows/details_record.dart';
import 'package:spend_wise/utils/Widgets/rows/summary_record.dart';
import 'package:spend_wise/utils/colors.dart';

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
    TransactionRepository().getMonthlyTransactionSummary(SessionContext().userData.username); // Fetch transactions
    setState(() {
      //totalExp = 100;
      //totalInc = 1000;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: FutureBuilder<MonthlyTransactionSummary>(
        future: TransactionRepository().getMonthlyTransactionSummary(SessionContext().userData.username),
        builder: (BuildContext context, AsyncSnapshot<MonthlyTransactionSummary> snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return CircularProgressIndicator();
          } else if (snapshot.hasError) {
            return Text('Error: ${snapshot.error}');
          } else if (snapshot.hasData) {
            final MonthlyTransactionSummary summary = snapshot.data!;
            List<Widget> recentTxns = [];
            List<Widget> summaryViews = [];
            double totalExp = 0;
            double totalInc = 0;
            double balance = 0;
            String currency = SessionContext().getCurrency();

            for (int i = 0; i < summary.trasactions.length && i < 10; i++) {
              recentTxns.add(
                DetailedRecord(
                    id: summary.trasactions[i].id.toString(),
                    source: summary.trasactions[i].source,
                    type: summary.trasactions[i].type,
                    note: summary.trasactions[i].description,
                    datetime: summary.trasactions[i].txnTime,
                    amount: summary.trasactions[i].amount,
                    currency: SessionContext().getCurrency(),
                    attchementUrl: summary.trasactions[i].attachmentUrl,
                    iconPath: (summary.trasactions[i].type == 'Income' ? 'assets/images/income.png' : 'assets/images/expense.png'),
                    viewIcon: (summary.trasactions[i].type == 'Income'
                        ? Icon(Icons.get_app_rounded, color: Colors.brown)
                        : Icon(Icons.upload_outlined, color: Colors.brown))),
              );
            }

            summary.expensesMap.forEach((key, value) {
              print('Category: $key, Amount: $value');
              summaryViews.add(SummaryRecord(source: key, amount: value));
            });

            totalExp = summary.totalExpense;
            totalInc = summary.totalIncome;
            balance = totalInc - totalExp;

            TextStyle balanceStyle = TextStyle(color: Color.fromARGB(255, 6, 250, 18), fontSize: 32, fontWeight: FontWeight.bold);
            if (balance < 0) {
              balanceStyle = TextStyle(color: const Color.fromARGB(255, 255, 19, 2), fontSize: 32, fontWeight: FontWeight.bold);
            }

            return Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 10.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Balance Card
                  Container(
                    padding: const EdgeInsets.all(20),
                    decoration: BoxDecoration(
                      color: AppColors.BOX_DECORATION_COLOR,
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
                          style: balanceStyle,
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
                              'Expense   ${totalExp.toStringAsFixed(2)}',
                              style: TextStyle(color: Colors.white70),
                            ),
                            Spacer(),
                            Icon(Icons.credit_card, color: Colors.white),
                          ],
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 30),
                  // Analytics
                  Container(
                    width: double.infinity,
                    padding: EdgeInsets.all(10.0), // Add padding around the text
                    //  color: Color(0xFFD6C4A8), // Light brown color
                    decoration: BoxDecoration(
                      color: const Color.fromARGB(255, 240, 215, 206),
                      borderRadius: BorderRadius.circular(15),
                    ),
                    child: const Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          'Monthly Summary',
                          style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
                        ),
                        Icon(Icons.summarize_outlined, color: AppColors.TABLE_HEADER_COLOR),
                      ],
                    ),
                  ),
                  Expanded(
                    child: ListView(
                      children: summaryViews,
                    ),
                  ),
                  const SizedBox(height: 20),
                  // Transactions
                  Container(
                    width: double.infinity,
                    padding: EdgeInsets.all(10.0), // Add padding around the text
                    //  color: Color(0xFFD6C4A8), // Light brown color
                    decoration: BoxDecoration(
                      color: const Color.fromARGB(255, 240, 215, 206),
                      borderRadius: BorderRadius.circular(15),
                    ),
                    child: const Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          'Recent Transactions',
                          style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
                        ),
                        Icon(Icons.list_alt_outlined, color: AppColors.TABLE_HEADER_COLOR),
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
}
