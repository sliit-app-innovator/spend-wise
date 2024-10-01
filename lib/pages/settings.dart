import 'package:flutter/material.dart'; //SettingsPage

class SettingsPage extends StatefulWidget {
  const SettingsPage({super.key});

  @override
  _SettingsPageState createState() => _SettingsPageState();
}

class _SettingsPageState extends State<SettingsPage> {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'User Settings',
      theme: ThemeData(
        primarySwatch: Colors.brown,
        visualDensity: VisualDensity.adaptivePlatformDensity,
      ),
      home: UserSettingsPage(),
    );
  }
}

class UserSettingsPage extends StatefulWidget {
  @override
  _UserSettingsPageState createState() => _UserSettingsPageState();
}

class _UserSettingsPageState extends State<UserSettingsPage> {
  String _currencyType = 'USD';
  bool _enableBackup = false;
  List<String> _incomeTypes = ['Salary', 'Bonus', 'Freelance'];
  List<String> _expenseTypes = ['Food', 'Transport', 'Entertainment'];

  final List<String> _availableCurrencies = ['USD', 'EUR', 'GBP', 'INR'];
  final TextEditingController _incomeTypeController = TextEditingController();
  final TextEditingController _expenseTypeController = TextEditingController();
  final TextEditingController _currencyController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
        onTap: () {
          FocusScope.of(context)
              .unfocus(); // Dismiss the keyboard when tapping outside
        },
        child: Scaffold(
          backgroundColor: const Color.fromARGB(255, 243, 243, 243),
          appBar: AppBar(
            title: Text('User Settings'),
            backgroundColor: Colors.brown[400],
            foregroundColor: Colors.white,
            leading: IconButton(
              icon: Icon(Icons.arrow_back),
              onPressed: () {
                Navigator.pop(context); // Navigate back to the previous screen
              },
            ),
          ),
          body: Padding(
            padding: const EdgeInsets.all(16.0),
            child: ListView(
              children: <Widget>[
                // Currency Type
                ListTile(
                  title: Text('Currency Type'),
                  subtitle: TextField(
                    controller:
                        _currencyController, // Controller for handling the input
                    decoration: InputDecoration(
                      hintText: 'Enter Currency Type',
                    ),
                    onChanged: (String newValue) {
                      setState(() {
                        _currencyType = newValue;
                      });
                    },
                  ),
                ),
                const SizedBox(height: 20),
                // Enable Backup Switch
                SwitchListTile(
                  title: Text('Enable Backup'),
                  value: _enableBackup,
                  onChanged: (bool newValue) {
                    setState(() {
                      _enableBackup = newValue;
                    });
                  },
                ),
                const SizedBox(height: 20),
                // Income Types
                ListTile(
                  title: Text('Income Types'),
                  subtitle: Wrap(
                    spacing: 8.0,
                    children: _incomeTypes
                        .map((type) => Chip(
                              label: Text(type),
                              onDeleted: () {
                                setState(() {
                                  _incomeTypes.remove(type);
                                });
                              },
                            ))
                        .toList(),
                  ),
                ),
                const SizedBox(height: 20),
                TextField(
                  controller: _incomeTypeController,
                  decoration: InputDecoration(
                    labelText: 'Add Income Type',
                    suffixIcon: IconButton(
                      icon: Icon(Icons.add),
                      onPressed: () {
                        setState(() {
                          if (_incomeTypeController.text.isNotEmpty) {
                            _incomeTypes.add(_incomeTypeController.text);
                            _incomeTypeController.clear();
                          }
                        });
                      },
                    ),
                  ),
                ),
                const SizedBox(height: 20),
                // Expense Types
                ListTile(
                  title: Text('Expense Types'),
                  subtitle: Wrap(
                    spacing: 8.0,
                    children: _expenseTypes
                        .map((type) => Chip(
                              label: Text(type),
                              onDeleted: () {
                                setState(() {
                                  _expenseTypes.remove(type);
                                });
                              },
                            ))
                        .toList(),
                  ),
                ),
                const SizedBox(height: 20),
                TextField(
                  controller: _expenseTypeController,
                  decoration: InputDecoration(
                    labelText: 'Add Expense Type',
                    suffixIcon: IconButton(
                      icon: Icon(Icons.add),
                      onPressed: () {
                        setState(() {
                          if (_expenseTypeController.text.isNotEmpty) {
                            _expenseTypes.add(_expenseTypeController.text);
                            _expenseTypeController.clear();
                          }
                        });
                      },
                    ),
                  ),
                ),
              ],
            ),
          ),
        ));
  }
}
