import 'package:flutter/material.dart';
import 'package:spend_wise/dto/transaction.dart';
import 'package:intl/intl.dart';
import 'package:spend_wise/model/transaction_repository.dart';
import 'dart:io';
import 'package:image_picker/image_picker.dart';
import 'package:path_provider/path_provider.dart';
import 'package:path/path.dart';
import 'package:spend_wise/utils/colors.dart';

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
    'Utilities',
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
    'Subscriptions',
    'Gifts & Donations',
    'Personal Care',
    'Pet Care',
    'Miscellaneous',
    'Emergency Fund'
  ];
  String _description = '';
  double _amount = 0.0;
  File? _imageFile;
  String attachmentUrl = '';
  final ImagePicker _picker = ImagePicker();

  // Controller to clear fields
  final TextEditingController _descriptionController = TextEditingController();
  final TextEditingController _amountController = TextEditingController();

  void _addTransaction() async {
    if (_formKey.currentState!.validate()) {
      _formKey.currentState!.save();

      String formattedDate =
          DateFormat('yyyy-MM-dd hh:mm:ss.SSS').format(DateTime.now());
      TransactionDto txn = new TransactionDto(
          userId: 'damith',
          type: _selectedType,
          source: _selectedSourceType,
          description: _description,
          amount: _amount,
          txnTime: formattedDate,
          attachmentUrl: attachmentUrl);

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
    return GestureDetector(
        onTap: () {
          FocusScope.of(context)
              .unfocus(); // Dismiss the keyboard when tapping outside
        },
        child: Scaffold(
          appBar: AppBar(
            title: Text('New Transaction'),
            backgroundColor: Colors.brown[400],
            foregroundColor: Colors.white,
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
                            } else {
                              _selectedSourceTypes = expenseSourceType;
                              _selectedSourceType = 'Food & Groceries';
                            }
                          });
                        },
                        items:
                            ['Select', 'Income', 'Expense'].map((String type) {
                          return DropdownMenuItem<String>(
                            value: type,
                            child: Text(type),
                          );
                        }).toList(),
                        decoration: const InputDecoration(
                            labelText: 'Transaction Type'),
                        validator: (value) {
                          if (value == null ||
                              value.isEmpty ||
                              value == 'Select') {
                            return 'Please select  transaction source';
                          }
                          return null;
                        },
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
                        validator: (value) {
                          if (value == null ||
                              value.isEmpty ||
                              value == 'Select') {
                            return 'Please select  transaction source';
                          }
                          return null;
                        },
                      ),
                      TextFormField(
                        controller: _descriptionController,
                        decoration:
                            const InputDecoration(labelText: 'Description'),
                        onSaved: (value) {
                          _description = value!;
                        },
                      ),
                      TextFormField(
                        controller: _amountController,
                        decoration: const InputDecoration(labelText: 'Amount'),
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
                      const SizedBox(height: 20),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.start,
                        children: [
                          ElevatedButton(
                            onPressed: _takePhoto,
                            child: const Text('Take Photo'),
                          ),
                          const SizedBox(width: 20),
                          _imageFile != null
                              ? SizedBox(
                                  width: 40,
                                  height: 40,
                                  child: Image.file(_imageFile!,
                                      fit: BoxFit.cover),
                                )
                              : const Text('Add an attachment (optional)'),
                        ],
                      ),
                      Row(mainAxisAlignment: MainAxisAlignment.end, children: [
                        ElevatedButton(
                          onPressed: _addTransaction,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.brown,
                            foregroundColor: Colors.white,
                            shape: RoundedRectangleBorder(
                              borderRadius:
                                  BorderRadius.circular(8.0), // Rounded corners
                              side: const BorderSide(
                                  color: Colors.brown), // Border color
                            ),
                            padding: const EdgeInsets.symmetric(
                                horizontal: 20, vertical: 15), // Button padding
                          ),
                          child: const Text(
                            'Add Transaction',
                            style: TextStyle(
                                color: Colors.white,
                                fontSize:
                                    16), // Customize the font size if needed
                          ),
                        ),
                      ]),
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
        ));
  }

  // Method to take a photo
  Future<void> _takePhoto() async {
    final XFile? photo = await _picker.pickImage(source: ImageSource.camera);
    if (photo != null) {
      final savedImage = await _saveImageToLocalDirectory(photo);
      attachmentUrl = savedImage.path.toString();
      setState(() {
        _imageFile = savedImage;
      });
    }
  }

  // Method to save the image to a local directory
  Future<File> _saveImageToLocalDirectory(XFile image) async {
    final directory = await getApplicationDocumentsDirectory();
    final String path = directory.path;
    final String fileName = basename(image.path);
    final File localImage = await File(image.path).copy('$path/$fileName');
    return localImage;
  }

  // Method to reload the saved image (if it exists)
  Future<void> _loadSavedImage() async {
    final directory = await getApplicationDocumentsDirectory();
    final String path = directory.path;
    final File savedImage = File('$path/saved_image.jpg');
    if (await savedImage.exists()) {
      setState(() {
        _imageFile = savedImage;
      });
    }
  }
}
