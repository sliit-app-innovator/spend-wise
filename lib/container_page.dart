import 'dart:async';

import 'package:flutter/material.dart';
import 'package:spend_wise/dto/user.dart';
import 'package:spend_wise/main.dart';
import 'package:spend_wise/pages/profile.dart';
import 'package:spend_wise/pages/settings.dart';
import 'package:spend_wise/session/session_context.dart';
import 'package:spend_wise/utils/colors.dart';
import 'pages/home_page.dart';
import 'pages/transaction_history_page.dart';
import 'pages/transactions_page.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:workmanager/workmanager.dart';
import 'package:spend_wise/background/flutter_sync.dart';

class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  _MyAppState createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  File? _imageFile;
  final ImagePicker _picker = ImagePicker();
  int _selectedIndex = 0;
  Timer? _inactivityTimer;
  final Duration _logoutTime = Duration(minutes: 60); // Set your timeout duration here

  @override
  void initState() {
    super.initState();
    _loadProfileImage();
    _startInactivityTimer();
    if (SessionContext().useBackup()) {
      print(" >>>>>>>>>>>>>>>>> Triggering Background Task.....");
      backupSqliteToFirebase();
      Workmanager().initialize(callbackDispatcher, isInDebugMode: true);
      Workmanager().registerPeriodicTask(
        "txnBackup", // Unique task name
        "TransactionFirebaseBackup", // Task name
        frequency: const Duration(minutes: 15), // Frequency of the backup
      );
    } else {
      print("User is not enabnled for backup");
    }
  }

  @override
  void dispose() {
    _inactivityTimer?.cancel(); // Cancel the timer when the widget is disposed
    super.dispose();
  }

  // Function to start or reset the inactivity timer
  void _startInactivityTimer() {
    // If the timer is already running, cancel it
    if (_inactivityTimer != null) {
      _inactivityTimer!.cancel();
    }

    // Start a new timer
    _inactivityTimer = Timer(_logoutTime, () {
      _navigateToLogout();
    });
  }

  // Function to navigate to the logout page
  void _navigateToLogout() {
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (context) => Login()),
    );
  }

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
      HomePage();
    });
  }

  // Method to pick image from gallery
  Future<void> _pickImage() async {
    final pickedFile = await _picker.pickImage(source: ImageSource.gallery);
    if (pickedFile != null) {
      setState(() {
        _imageFile = File(pickedFile.path);
      });
      _saveProfileImage(pickedFile.path);
    }
  }

  // Save the image path to shared preferences
  Future<void> _saveProfileImage(String imagePath) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    prefs.setString('profile_image', imagePath);
  }

  // Load the image path from shared preferences
  Future<void> _loadProfileImage() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String? imagePath = prefs.getString('profile_image');
    if (imagePath != null) {
      setState(() {
        _imageFile = File(imagePath);
      });
    }
  }

  static List<Widget> pages = <Widget>[
    HomePage(),
    TransactionsPage(userData: UserDto(firstName: '', lastName: '', username: '', password: '', email: '')),
    TransactionHistoryPage(),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Spend Wise'),
        backgroundColor: AppColors.APP_ABR_COLOR,
        foregroundColor: Colors.white,
        actions: [
          IconButton(
            onPressed: () {},
            icon: const Icon(Icons.notifications, color: Colors.black),
          ),
        ],
      ),
      drawer: getLeftMenu(context, _imageFile),
      body: pages[_selectedIndex], // Your selected page// Show the FAB only on the HomePage
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _selectedIndex,
        onTap: _onItemTapped,
        items: const <BottomNavigationBarItem>[
          BottomNavigationBarItem(
            icon: Icon(Icons.home),
            label: 'Home',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.list_alt_outlined),
            label: 'Transactions',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.history),
            label: 'History',
          ),
        ],
      ),
    );
  }

  Drawer getLeftMenu(BuildContext context, File? imageFile) {
    SessionContext session = SessionContext();
    String userDisplayLabel = '${session.userData.firstName} ${session.userData.lastName}';

    return Drawer(
        child: Container(
      color: const Color.fromARGB(255, 243, 238, 235), // Light brown background for the drawer body
      child: ListView(
        padding: EdgeInsets.zero,
        children: <Widget>[
          DrawerHeader(
            decoration: const BoxDecoration(
              color: Colors.brown,
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Stack(
                  children: [
                    CircleAvatar(
                      radius: 40,
                      backgroundImage:
                          imageFile != null ? FileImage(imageFile) : const AssetImage('assets/images/aviator.webp') as ImageProvider,
                    ),
                    Positioned(
                      bottom: 0,
                      right: 0,
                      child: IconButton(
                        icon: const Icon(Icons.edit),
                        onPressed: _pickImage, // Trigger image selection
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 10),
                Text(
                  userDisplayLabel,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 20,
                  ),
                ),
              ],
            ),
          ),
          ListTile(
            leading: const Icon(Icons.home),
            title: const Text('Home'),
            onTap: () {
              Navigator.pop(context);
              setState(() {
                _selectedIndex = 0;
              });
              // Navigator.pop(context); // Close the drawer
            },
          ),
          ListTile(
            leading: const Icon(Icons.person),
            title: const Text('Profile'),
            onTap: () {
              Navigator.pop(context);
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => UserProfilePage()),
              );
            },
          ),
          ListTile(
            leading: const Icon(Icons.credit_card),
            title: const Text('Payments'),
            onTap: () {
              Navigator.pop(context);
              setState(() {
                _selectedIndex = 1;
              });
            },
          ),
          ListTile(
            leading: const Icon(Icons.history),
            title: const Text('Transaction History'),
            onTap: () {
              Navigator.pop(context);
              setState(() {
                _selectedIndex = 2;
              });
              // Navigator.pop(context);
            },
          ),
          ListTile(
            leading: const Icon(Icons.settings),
            title: const Text('Settings'),
            onTap: () {
              Navigator.pop(context);
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => UserSettingsPage()),
              );
            },
          ),
          const Divider(),
          ListTile(
            leading: const Icon(Icons.logout),
            title: const Text('Logout'),
            onTap: () {
              Navigator.pushReplacement(
                context,
                MaterialPageRoute(builder: (context) => Login()),
              );
            },
          ),
        ],
      ),
    ));
  }
}
