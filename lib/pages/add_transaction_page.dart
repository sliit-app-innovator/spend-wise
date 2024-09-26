import 'package:flutter/material.dart';
import 'package:spend_wise/dto/transaction.dart';
import 'package:uuid/uuid.dart';
import 'package:intl/intl.dart';
import 'package:spend_wise/model/transaction_repository.dart';

class AddTransactionPage extends StatefulWidget {
  const AddTransactionPage({super.key});

  @override
  _AddExpensesPage createState() => _AddExpensesPage();
}

class _AddExpensesPage extends State<AddTransactionPage> {
  final List<TransactionDto> _transactions = [];
  final _formKey = GlobalKey<FormState>();

  // Form fields
  String _selectedType = 'Select'; // Default type
  String _selectedSourceType = 'Select'; // Default type
  List<String> _selectedSourceTypes = [];
  List<String> incomeSourceType = [
    'Select',
    'Salary',
    'Invetment',
    'Interest',
    'Insurence Claim'
  ];
  List<String> expenseSourceType = [
    'Select',
    'Food & Groceries',
    'Transportation',
    'Rent/Mortgage',
    'Utilities (Electricity, Water, Internet)',
    'Entertainment',
    'Health & Fitness',
    'Insurance',
    'Shopping',
    'Dining Out',
    'Travel',
    'Education',
    'Savings',
    'Investments',
    'Debt Repayment',
    'Subscriptions (e.g., Netflix, Spotify)',
    'Gifts & Donations',
    'Personal Care',
    'Pet Care',
    'Miscellaneous',
    'Emergency Fund'
  ];
  String _description = '';
  double _amount = 0.0;

  // Controller to clear fields
  final TextEditingController _descriptionController = TextEditingController();
  final TextEditingController _amountController = TextEditingController();

  void _addTransaction() async {
    if (_formKey.currentState!.validate()) {
      _formKey.currentState!.save();

      String formattedDate =
          DateFormat('yyyy-MM-dd hh:mm:ss').format(DateTime.now());
      TransactionDto txn = new TransactionDto(
          userId: 'damith',
          type: _selectedType,
          source: _selectedSourceType,
          description: _description,
          amount: _amount,
          txnTime: formattedDate,
          attachmentUrl: "NA");

      await TransactionRepository().insertTransaction(txn);
      setState(() {
        _transactions.add(txn);
      });

      _descriptionController.clear();
      _amountController.clear();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('New Transaction'),
        backgroundColor: Colors.brown[400],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            Form(
              key: _formKey,
              child: Column(
                children: [
                  // Dropdown for Income/Expense selection
                  DropdownButtonFormField<String>(
                    value: _selectedType,
                    onChanged: (String? newValue) {
                      setState(() {
                        _selectedType = newValue!;
                        if (_selectedType == 'Income') {
                          _selectedSourceTypes = incomeSourceType;
                          _selectedSourceType = 'Salary';
                          ;
                        } else if (_selectedType == 'Expense') {
                          _selectedSourceTypes = expenseSourceType;
                          _selectedSourceType = 'Food & Groceries';
                        } else {
                          //    _selectedSourceTypes = [''];
                          _selectedSourceTypes = expenseSourceType;
                        }
                      });
                    },
                    items: ['Select', 'Income', 'Expense'].map((String type) {
                      return DropdownMenuItem<String>(
                        value: type,
                        child: Text(type),
                      );
                    }).toList(),
                    decoration: InputDecoration(labelText: 'Transaction Type'),
                  ),
                  DropdownButtonFormField<String>(
                    value: _selectedSourceType,
                    onChanged: (String? newSourceValue) {
                      setState(() {
                        _selectedSourceType = newSourceValue!;
                      });
                    },
                    items: _selectedSourceTypes.map((String type) {
                      return DropdownMenuItem<String>(
                        value: type,
                        child: Text(type),
                      );
                    }).toList(),
                    decoration: InputDecoration(labelText: 'Source Type'),
                  ),
                  TextFormField(
                    controller: _descriptionController,
                    decoration: InputDecoration(labelText: 'Description'),
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Please enter a description';
                      }
                      return null;
                    },
                    onSaved: (value) {
                      _description = value!;
                    },
                  ),
                  TextFormField(
                    controller: _amountController,
                    decoration: InputDecoration(labelText: 'Amount'),
                    keyboardType: TextInputType.number,
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Please enter an amount';
                      }
                      if (double.tryParse(value) == null) {
                        return 'Please enter a valid number';
                      }
                      return null;
                    },
                    onSaved: (value) {
                      _amount = double.parse(value!);
                    },
                  ),
                  SizedBox(height: 20),
                  ElevatedButton(
                    onPressed: _addTransaction,
                    child: Text('Add Transaction'),
                  ),
                ],
              ),
            ),
            Expanded(
              child: ListView.builder(
                itemCount: _transactions.length,
                itemBuilder: (ctx, index) {
                  return ListTile(
                    title: Text(_transactions[index].source),
                    subtitle: Text(_transactions[index].type),
                    trailing: Text(
                        'LKR ${_transactions[index].amount.toStringAsFixed(2)}'),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
