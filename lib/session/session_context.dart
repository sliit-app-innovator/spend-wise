import 'dart:ffi';

import 'package:spend_wise/dto/user%20configs.dart';
import 'package:spend_wise/dto/user.dart';
import 'package:spend_wise/utils/defults.dart';

class SessionContext {
  UserDto userData = UserDto(
      firstName: '',
      lastName: 'lastName',
      username: 'usrname',
      password: '',
      email: ''); // Make it nullable if you want to initialize it later

  List<UserConfigs> userConfigs = [];

  // Setting defult
  List<String> incomeSourceType = AppDefaults().incomeSourceType;
  List<String> expenseSourceType = AppDefaults().expenseSourceType;
  final String currencyType = AppDefaults().currencyType;
  final bool enableCloudBackup = AppDefaults().enableCloudBackup;

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

  void setUserConfigs({required List<UserConfigs> userConfigs}) {
    this.userConfigs = userConfigs;
  }

  bool expenseType(String source) {
    return expenseSourceType.contains(source);
  }

  List<UserConfigs> getUserConfigs() {
    return userConfigs;
  }

  List<String> getIncomeTypes() {
    if (userConfigs.isEmpty) {
      print("KKKKKKKKKKKKKKKk" + incomeSourceType.toString());
      return incomeSourceType;
    } else {
      UserConfigs? targetConfig = userConfigs.firstWhere((config) => config.name == 'incomeList');

      // If the record is found and the value is not null, split the value into a list
      if (targetConfig.value.isNotEmpty) {
        return targetConfig.value.split(',');
      }

      // Return an empty list if the record is not found or value is empty
      return [];
    }
  }

  List<String> getExpendTypes() {
    if (userConfigs.isEmpty) {
      return expenseSourceType;
    } else {
      UserConfigs? targetConfig = userConfigs.firstWhere((config) => config.name == 'expenseList');

      // If the record is found and the value is not null, split the value into a list
      if (targetConfig.value.isNotEmpty) {
        return targetConfig.value.split(',');
      }

      // Return an empty list if the record is not found or value is empty
      return [];
    }
  }

  String getCurrency() {
    if (userConfigs.isEmpty) {
      return currencyType;
    } else {
      UserConfigs? targetConfig = userConfigs.firstWhere((config) => config.name == 'currency');
      return targetConfig.value;
    }
  }

  bool useBackup() {
    if (userConfigs.isEmpty) {
      return enableCloudBackup;
    } else {
      UserConfigs? targetConfig = userConfigs.firstWhere((config) => config.name == 'useBackup');
      return targetConfig.value.toLowerCase() == 'true';
    }
  }

  void reset() {
    userConfigs = [];
    print("CCCCCCCCCCCCCCCCC0" + getIncomeTypes().toString());
  }
}
