import 'package:flutter/material.dart';
import 'package:spend_wise/dto/user%20configs.dart';
import 'package:spend_wise/model/user_configs_repository.dart';
import 'package:spend_wise/session/session_context.dart';
import 'package:spend_wise/utils/defults.dart';

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
  String _currencyType = SessionContext().getCurrency();
  bool _enableBackup = SessionContext().useBackup();
  List<String> _incomeTypes = [];
  List<String> _expenseTypes = [];
  final TextEditingController _incomeTypeController = TextEditingController();
  final TextEditingController _expenseTypeController = TextEditingController();
  final TextEditingController _currencyController = TextEditingController();
  UserConfigsRepository userConfRepository = UserConfigsRepository();

  @override
  void initState() {
    super.initState();
    _incomeTypes = SessionContext().getIncomeTypes();
    _expenseTypes = SessionContext().getExpendTypes();
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
        onTap: () {
          FocusScope.of(context).unfocus(); // Dismiss the keyboard when tapping outside
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
                Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    ElevatedButton(
                      onPressed: reset,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.white,
                        foregroundColor: Colors.brown,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8.0), // Rounded corners
                          side: const BorderSide(color: Colors.red), // Border color
                        ),
                        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10), // Button padding
                      ),
                      child: const Text(
                        'Reset',
                        style: TextStyle(color: Colors.brown, fontSize: 16), // Customize the font size if needed
                      ),
                    ),
                    const SizedBox(width: 15),
                    ElevatedButton(
                      onPressed: saveUserSettings,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.brown,
                        foregroundColor: Colors.white,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8.0), // Rounded corners
                          side: const BorderSide(color: Colors.brown), // Border color
                        ),
                        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10), // Button padding
                      ),
                      child: const Text(
                        ' Save  ',
                        style: TextStyle(color: Colors.white, fontSize: 16), // Customize the font size if needed
                      ),
                    )
                  ],
                ),
                ListTile(
                  title: Text('Currency Type'),
                  subtitle: TextField(
                    controller: _currencyController, // Controller for handling the input
                    decoration: InputDecoration(
                      hintText: _currencyType,
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

  void saveUserSettings() {
    List<UserConfigs> configs = [];
    // Set currecny
    configs.add(UserConfigs(
        userId: SessionContext().userData.username,
        name: "currency",
        value: _currencyController.text.isEmpty ? SessionContext().currencyType : _currencyController.text));
    configs.add(UserConfigs(userId: SessionContext().userData.username, name: "useBackup", value: _enableBackup.toString()));
    configs.add(UserConfigs(userId: SessionContext().userData.username, name: "incomeList", value: _incomeTypes.join(',')));
    configs.add(UserConfigs(userId: SessionContext().userData.username, name: "expenseList", value: _expenseTypes.join(',')));
    SessionContext().setUserConfigs(userConfigs: configs);
    userConfRepository.insertConfigs(configs);
    ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Updated Settings Successfully'), backgroundColor: Colors.green, duration: Duration(seconds: 2)));
  }

  void reset() {
    List<UserConfigs> configs = [];
    configs.add(UserConfigs(userId: SessionContext().userData.username, name: "currency", value: AppDefaults().currencyType));
    configs
        .add(UserConfigs(userId: SessionContext().userData.username, name: "useBackup", value: AppDefaults().enableCloudBackup.toString()));
    configs
        .add(UserConfigs(userId: SessionContext().userData.username, name: "incomeList", value: AppDefaults().incomeSourceType.join(',')));
    configs.add(
        UserConfigs(userId: SessionContext().userData.username, name: "expenseList", value: AppDefaults().expenseSourceType.join(',')));
    SessionContext().setUserConfigs(userConfigs: configs);
    userConfRepository.insertConfigs(configs);
    ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
        content: Text('Reset to defualt Settings Successfully'), backgroundColor: Colors.green, duration: Duration(seconds: 2)));
    setState(() {
      _incomeTypes = AppDefaults().incomeSourceType;
      _expenseTypes = AppDefaults().expenseSourceType;
      _currencyType = AppDefaults().currencyType;
      _enableBackup = AppDefaults().enableCloudBackup;
    });
  }
}
