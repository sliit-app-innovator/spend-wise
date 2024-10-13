import 'package:spend_wise/dto/user.dart';

class SessionContext {
  UserDto userData = UserDto(
      firstName: '',
      lastName: 'lastName',
      username: 'usrname',
      password: '',
      email: ''); // Make it nullable if you want to initialize it later

  List<String> incomeSourceType = ['Select', 'Salary', 'Invetment', 'Interest', 'Insurence Claim'];
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

  // Private constructor
  SessionContext._privateConstructor();

  // Single instance of SessionContext
  static final SessionContext _instance = SessionContext._privateConstructor();

  // Factory method to return the same instance
  factory SessionContext() {
    return _instance;
  }

  // Method to update user data
  void updateUserData({required UserDto userData}) {
    this.userData = userData; // Correct the parameter reference
  }

  bool expenseType(String source) {
    return expenseSourceType.contains(source);
  }
}
