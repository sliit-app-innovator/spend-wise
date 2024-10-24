import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:spend_wise/session/session_context.dart';
import 'package:flutter/material.dart';
import 'package:spend_wise/container_page.dart';
import 'package:spend_wise/pages/add_transaction_page.dart';
import 'package:spend_wise/dto/transaction.dart';
import 'package:spend_wise/pages/home_page.dart';
import 'package:spend_wise/dto/user.dart';
import 'package:spend_wise/model/transaction_repository.dart';
import 'package:spend_wise/session/session_context.dart';
import 'package:spend_wise/utils/Widgets/charts/pie_chart.dart';
import 'package:spend_wise/utils/colors.dart';
import 'dart:io';

class TransactionHistoryPage extends StatefulWidget {
  const TransactionHistoryPage({super.key, use});

  @override
  _TransactionHistoryPageState createState() => _TransactionHistoryPageState();
}

class _TransactionHistoryPageState extends State<TransactionHistoryPage> {
// Variable to store the selected date
  // Controller for the TextField
  TextEditingController _dateController = TextEditingController();
  File? _imageFile;
  // Function to show the date picker
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  TransactionRepository _transactionRepository = TransactionRepository();
  // Controllers for the "From" and "To" date TextFields
  TextEditingController _fromDateController = TextEditingController();
  TextEditingController _toDateController = TextEditingController();
  bool isSwitched = false;
  List<Widget> widgetList = [];
  List<Widget> widgetListTransactions = [];
  List<Widget> widgetListSummary = [];
  List<TransactionDto> transactions = [];
  Map<String, double> expenseChartMap = {};

  // Function to show the date picker and set the selected date
  Future<void> _selectDate(BuildContext context, TextEditingController controller) async {
    DateTime? selectedDate = await showDatePicker(
      context: context,
      initialDate: DateTime.now(), // Initial date in the picker
      firstDate: DateTime(2000), // Earliest date selectable
      lastDate: DateTime(2100), // Latest date selectable
    );

    if (selectedDate != null) {
      // Format the selected date and set it in the text field
      String formattedDate = DateFormat('yyyy-MM-dd').format(selectedDate);
      controller.text = formattedDate;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                // From Date TextField
                Expanded(
                  child: TextField(
                    controller: _fromDateController,
                    decoration: const InputDecoration(
                      labelText: 'From Date',
                      border: OutlineInputBorder(),
                      suffixIcon: Icon(Icons.calendar_today),
                      contentPadding: EdgeInsets.symmetric(vertical: 10.0, horizontal: 12.0), // Adjust padding here
                    ),
                    readOnly: true,
                    onTap: () {
                      _selectDate(context, _fromDateController);
                    },
                  ),
                ),
                SizedBox(width: 16.0), // Spacing between the fields

                // To Date TextField
                Expanded(
                  child: TextField(
                    controller: _toDateController,
                    decoration: const InputDecoration(
                      labelText: 'To Date',
                      border: OutlineInputBorder(),
                      suffixIcon: Icon(Icons.calendar_today),
                      contentPadding: EdgeInsets.symmetric(vertical: 10.0, horizontal: 12.0), // Adjust padding here
                    ),
                    readOnly: true,
                    onTap: () {
                      _selectDate(context, _toDateController);
                    },
                  ),
                ),
              ],
            ),
            SizedBox(height: 15.0), // Spacing between rows

            // Radio buttons in a row
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                Text(
                  isSwitched ? 'Summary View' : 'Summary View',
                  style: isSwitched ? TextStyle(fontSize: 15, fontWeight: FontWeight.bold) : TextStyle(fontSize: 15),
                ),
                Switch(
                  value: isSwitched,
                  onChanged: (value) {
                    setState(() {
                      isSwitched = value;
                      setState(() {
                        if (transactions.isEmpty) {
                          loadData();
                        }
                        if (isSwitched) {
                          if (widgetListSummary.isEmpty) {
                            processSummary(transactions);
                          }
                          widgetList = widgetListSummary;
                        } else {
                          if (widgetListTransactions.isEmpty) {
                            processTransactionWidgets();
                          }
                          widgetList = widgetListTransactions;
                        }
                      });
                    });
                  },
                  activeTrackColor: const Color.fromARGB(255, 241, 197, 181),
                  activeColor: Colors.brown,
                ),
                const SizedBox(
                  width: 10,
                  height: 5,
                ),
                ElevatedButton(
                  onPressed: _searchTransaction,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.brown,
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8.0), // Rounded corners
                      side: const BorderSide(color: Colors.brown), // Border color
                    ),
                    padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 15), // Button padding
                  ),
                  child: Container(
                    margin: EdgeInsets.all(0.0),
                    child: const Text(
                      'Search',
                      style: TextStyle(color: Colors.white, fontSize: 15), // Customize the font size if needed
                    ),
                  ),
                )
              ],
            ),
            const SizedBox(
              width: 10,
              height: 20,
            ),
            Container(
              width: double.infinity,
              padding: EdgeInsets.all(16.0),
              decoration: BoxDecoration(
                color: const Color.fromARGB(255, 240, 215, 206),
                borderRadius: BorderRadius.circular(15),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    isSwitched ? 'Transaction Summary' : 'Transaction List',
                    style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
                  ),
                  const Icon(Icons.list_alt_outlined, color: AppColors.TABLE_HEADER_COLOR),
                ],
              ),
            ),
            Expanded(
              child: ListView(children: widgetList),
            ),
            const SizedBox(
              width: 10,
              height: 20,
            ),
            Container(
              width: double.infinity,
              padding: EdgeInsets.all(16.0),
              decoration: BoxDecoration(
                color: const Color.fromARGB(255, 240, 215, 206),
                borderRadius: BorderRadius.circular(15),
              ),
              child: const Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    "Your Expenses Summary",
                    style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
                  ),
                  Icon(Icons.list_alt_outlined, color: AppColors.TABLE_HEADER_COLOR),
                ],
              ),
            ),
            const SizedBox(
              width: 10,
              height: 20,
            ),
            Expanded(child: PieChart(dataMap: expenseChartMap))
          ],
        ),
      ),
    );
  }

  void _searchTransaction() async {
    try {
      DateTime from = DateTime.parse(_fromDateController.text);
      DateTime to = DateTime.parse(_toDateController.text);

      if (from.isAfter(to)) {
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
            content: Text('From Date cannot be later than To Date'), backgroundColor: Colors.red, duration: Duration(seconds: 2)));
      } else {
        if (_fromDateController.text == '' || _toDateController.text == '') {
          ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('Please Select Duration'), backgroundColor: Colors.red, duration: Duration(seconds: 2)));
        } else {
          await processResponse();
        }
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Please Select Duration'), backgroundColor: Colors.red, duration: Duration(seconds: 2)));
    }
  }

  Future<void> processResponse() async {
    await loadData();
    processExpenceChartData(transactions);
    if (transactions.isNotEmpty) {
      List<Widget> recentTxns = processTransactionWidgets();
      if (isSwitched) {
        processSummary(transactions);
        setState(() {
          widgetListTransactions = recentTxns;
          widgetList = widgetListSummary;
        });
      } else {
        setState(() {
          widgetListTransactions = recentTxns;
          widgetList = widgetListTransactions;
        });
      }
    } else {
      setState(() {
        widgetList = [];
      });
      ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('No traansaction Available'), backgroundColor: Colors.green, duration: Duration(seconds: 2)));
    }
  }

  List<Widget> processTransactionWidgets() {
    List<Widget> recentTxns = transactions.map((tx) {
      return transactionItem(tx.id.toString(), tx.source, tx.type, tx.description, tx.txnTime, tx.amount, 'LKR', tx.attachmentUrl);
    }).toList();
    return recentTxns;
  }

  Future<void> loadData() async {
    transactions =
        await _transactionRepository.getTransactions(_fromDateController.text, _toDateController.text, SessionContext().userData.username);
  }

  void processSummary(List<TransactionDto> transactions) {
    Map<String, double> summaryMap = {};
    transactions.forEach((item) {
      if (summaryMap.containsKey(item.source)) {
        // If it exists, add the amount to the existing value
        summaryMap[item.source] = summaryMap[item.source]! + item.amount; // Use '!' to assert non-null
      } else {
        // If it doesn't exist, add the new key and amount
        summaryMap[item.source] = item.amount;
      }
    });
    summaryMap.forEach((key, value) {
      print('Category: $key, Amount: $value');
      widgetListSummary.add(summaryItem(key, value));
    });
  }

  void processExpenceChartData(List<TransactionDto> transactions) {
    Map<String, double> chartMap = {};
    transactions.forEach((item) {
      if (chartMap.containsKey(item.source) && SessionContext().expenseType(item.source)) {
        // If it exists, add the amount to the existing value
        chartMap[item.source] = chartMap[item.source]! + item.amount; // Use '!' to assert non-null
      } else if (SessionContext().expenseType(item.source)) {
        // If it doesn't exist, add the new key and amount
        chartMap[item.source] = item.amount;
      }
    });
    setState(() {
      expenseChartMap = chartMap;
    });
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

  Widget transactionItem(
      String id, String source, String type, String note, String datetime, double amount, String currency, String? attchementUrl) {
    Icon bullet = Icon(Icons.arrow_downward_outlined, color: Colors.green);
    if (SessionContext().expenseType(source)) {
      bullet = Icon(Icons.arrow_upward_outlined, color: Colors.red);
    }
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 5.0, horizontal: 0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.end,
        children: [
          bullet,
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
          Text(amount.toStringAsFixed(2), style: const TextStyle(fontWeight: FontWeight.bold)),
          IconButton(
            icon: Icon(Icons.info_outline, color: Colors.brown),
            onPressed: () {
              _loadSavedImage(attchementUrl);
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
                          const Icon(Icons.get_app_rounded, color: Colors.white),
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
                    content: SingleChildScrollView(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Amount : $amount\n\nType : $type\n\nDate : $datetime\n\nNote : $note\n',
                            style: TextStyle(
                              color: Colors.grey[700],
                              fontSize: 16,
                            ),
                          ),
                          SizedBox(
                            width: 200,
                            height: 200,
                            child: _imageFile != null
                                ? Image.file(
                                    _imageFile!,
                                    fit: BoxFit.cover,
                                  )
                                : const Center(child: Text('No image')),
                          )
                        ],
                      ),
                    ),
                    actions: [
                      TextButton(
                        onPressed: () {
                          Navigator.of(context).pop();
                        },
                        child: const Text(
                          'OK',
                          style: TextStyle(color: Colors.brown),
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

  void _loadSavedImage(String? attachemtUrl) async {
    final String path = attachemtUrl.toString();
    final File savedImage = File('$path');
    if (await savedImage.exists()) {
      setState(() {
        _imageFile = savedImage;
      });
    }
  }
}
