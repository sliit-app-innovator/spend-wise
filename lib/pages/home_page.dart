import 'package:flutter/material.dart';
import 'package:spend_wise/pages/add_transaction_page.dart';
import 'package:spend_wise/model/transaction_repository.dart';
import 'package:spend_wise/dto/mothly_transaction_summary_view.dart';
import 'package:spend_wise/session/session_context.dart';
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
            String currency = "LKR";

            for (int i = 0; i < summary.trasactions.length && i < 10; i++) {
              recentTxns.add(transactionItem(summary.trasactions[i].source, summary.trasactions[i].txnTime, summary.trasactions[i].amount,
                  currency, summary.trasactions[i].type == 'Income' ? 'assets/images/income.png' : 'assets/images/expense.png'));
            }

            summary.expensesMap.forEach((key, value) {
              print('Category: $key, Amount: $value');
              summaryViews.add(summaryItem(key, value));
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
/*
  List<BarChartGroupData> _generateBarGroups(Map<String, double> dataMap) {
    return List.generate(dataMap.length, (index) {
      final value = dataMap.values.elementAt(index);
      return BarChartGroupData(
        x: index,
        barRods: [
          BarChartRodData(
            toY: value, // The height of the bar
            color: Colors.blue,
            width: 22,
            borderRadius: BorderRadius.circular(4),
          ),
        ],
      );
    });
  }*/

  Color _getRandomColor(String key) {
    return Colors.primaries[key.hashCode % Colors.primaries.length];
  }

  Widget transactionItem(String source, String datetime, double amount, String currency, iconPath) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 10.0),
      child: Row(
        children: [
          CircleAvatar(
              radius: 20,
              child: Padding(
                padding: EdgeInsets.all(10), // Add padding to reduce the image size
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

  Widget summaryItem(String source, double amount) {
    Icon bullet = Icon(Icons.arrow_downward_outlined, color: Colors.green);
    if (SessionContext().expenseType(source)) {
      bullet = Icon(Icons.arrow_upward_outlined, color: Colors.red);
    }
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 10.0),
      child: Row(
        children: [
          bullet,
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                source,
                style: const TextStyle(fontWeight: FontWeight.bold),
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

/*

 BarChart(
                    BarChartData(
                      alignment: BarChartAlignment.spaceAround,
                      barGroups: _generateBarGroups(
                          dataMap), // Method to generate bar groups from Map
                      borderData: FlBorderData(
                        show: false, // Disable the border around the chart
                      ),
                      titlesData: FlTitlesData(
                        bottomTitles: AxisTitles(
                          sideTitles: SideTitles(
                            showTitles: true,
                            getTitlesWidget: (double value, TitleMeta meta) {
                              // Convert index back to category name from the map
                              return Padding(
                                padding:
                                    const EdgeInsets.symmetric(horizontal: 8.0),
                                child:
                                    Text(dataMap.keys.elementAt(value.toInt())),
                              );
                            },
                            reservedSize: 28,
                          ),
                        ),
                        leftTitles: AxisTitles(
                          sideTitles: SideTitles(
                            showTitles: true,
                            interval: 10, // Control the number intervals
                          ),
                        ),
                      ),
                    ),
                  ),*
                  
                  
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
                  )
                  
                  */