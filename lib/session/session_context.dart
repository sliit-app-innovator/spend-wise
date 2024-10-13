import 'package:spend_wise/dto/user.dart';

class SessionContext {
  UserDto userData = UserDto(
      firstName: '',
      lastName: 'lastName',
      username: 'usrname',
      password: '',
      email: ''); // Make it nullable if you want to initialize it later

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
}
