import 'package:flutter/material.dart';
import 'package:flutter/material.dart';
import 'package:spend_wise/background/flutter_sync.dart';
import 'package:spend_wise/dto/user.dart';
import 'package:spend_wise/main.dart';
import 'package:spend_wise/model/user_configs_repository_firebase.dart';
import 'package:spend_wise/model/user_repository.dart';
import 'package:spend_wise/session/session_context.dart';

class ProfilePage extends StatefulWidget {
  const ProfilePage({super.key});

  @override
  _ProfilePageState createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'User Profile',
      theme: ThemeData(
        primarySwatch: Colors.brown,
        visualDensity: VisualDensity.adaptivePlatformDensity,
      ),
      home: UserProfilePage(),
    );
  }
}

class UserProfilePage extends StatefulWidget {
  @override
  _UserProfilePageState createState() => _UserProfilePageState();
}

class _UserProfilePageState extends State<UserProfilePage> {
  bool _isCurrentPasswordHidden = true;
  bool _isPasswordHidden = true;
  final _formKey = GlobalKey<FormState>();
  final UserRepository userRepository = UserRepository();
  final FirebaseUserConfigsRepository userFirebaseRepo = FirebaseUserConfigsRepository();
  final TextEditingController _firstNameController = TextEditingController();
  final TextEditingController _lastNameController = TextEditingController();
  final TextEditingController _userIdController = TextEditingController();
  final TextEditingController _currentPasswordController = TextEditingController();
  final TextEditingController _newPasswordController = TextEditingController();
  final TextEditingController _confirmPasswordController = TextEditingController(); // Confirm password controller
  final TextEditingController _emailController = TextEditingController();

  @override
  void initState() {
    super.initState();
  }

  void updateUser() {
    UserDto userDto = SessionContext().userData;
    String _password = userDto.password;
    if (_currentPasswordController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Enter your current password'), backgroundColor: Colors.red, duration: Duration(seconds: 3)));
    } else if (_currentPasswordController.text != userDto.password) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
          content: Text('Invalid password. Please enter your current password'),
          backgroundColor: Colors.red,
          duration: Duration(seconds: 3)));
    } else if (_newPasswordController.text.isNotEmpty &&
        _confirmPasswordController.text.isNotEmpty &&
        _newPasswordController.text != _confirmPasswordController.text) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
          content: Text('You new password and password confirmation are not match'),
          backgroundColor: Colors.red,
          duration: Duration(seconds: 3)));
    } else {
      if (_newPasswordController.text.isNotEmpty) {
        _password = _newPasswordController.text;
      }
      UserDto userDtoUpdate = UserDto(
          firstName: _firstNameController.text,
          lastName: _lastNameController.text,
          username: _userIdController.text,
          password: _password,
          email: _emailController.text);
      userDtoUpdate.id = userDto.id;
      UserRepository().updateUser(userDtoUpdate);
      SessionContext().updateUserData(userData: userDtoUpdate);
      FirebaseUserConfigsRepository().updateUser(userDtoUpdate);
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
          content: Text('User account updated successfully'), backgroundColor: Colors.green, duration: Duration(seconds: 3)));
    }
  }

  @override
  Widget build(BuildContext context) {
    UserDto userDto = SessionContext().userData;
    String _firstName = '';
    String _lastName = '';
    String _userId = '';
    String _password = '';
    String _newPassword = '';
    String _email = '';
    _firstNameController.text = userDto.firstName;
    _lastNameController.text = userDto.lastName;
    _userIdController.text = userDto.username;
    _emailController.text = userDto.email;
    print("User File Data Load >>>>>>>>>>>>>>>>>>>>>>>>>>>>" + userDto.toJson().toString());
    return GestureDetector(
        onTap: () {
          FocusScope.of(context).unfocus(); // Dismiss the keyboard when tapping outside
        },
        child: Scaffold(
          backgroundColor: const Color.fromARGB(255, 172, 109, 78),
          appBar: AppBar(
            title: Text('User Profile'),
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
                Center(
                  child: SingleChildScrollView(
                    child: Padding(
                      padding: const EdgeInsets.all(20.0),
                      child: Card(
                        elevation: 5,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(15),
                        ),
                        child: Padding(
                          padding: const EdgeInsets.all(30.0),
                          child: Form(
                            key: _formKey,
                            child: Column(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                const SizedBox(height: 30),
                                TextFormField(
                                  controller: _firstNameController,
                                  //initialValue: _firstName,
                                  decoration: InputDecoration(
                                    labelText: 'First Name',
                                    labelStyle: TextStyle(color: Colors.brown),
                                    border: OutlineInputBorder(
                                      borderRadius: BorderRadius.circular(10),
                                      borderSide: BorderSide(color: Colors.brown),
                                    ),
                                    prefixIcon: Icon(Icons.person, color: Colors.brown),
                                  ),
                                  keyboardType: TextInputType.emailAddress,
                                  validator: (value) {
                                    if (value == null || value.isEmpty) {
                                      return 'Please enter your fist name';
                                    }
                                    return null;
                                  },
                                  onSaved: (value) {
                                    _firstName = value.toString();
                                  },
                                ),
                                const SizedBox(height: 20),
                                TextFormField(
                                  controller: _lastNameController,
                                  decoration: InputDecoration(
                                    labelText: 'Last Name',
                                    labelStyle: TextStyle(color: Colors.brown),
                                    border: OutlineInputBorder(
                                      borderRadius: BorderRadius.circular(10),
                                      borderSide: BorderSide(color: Colors.brown),
                                    ),
                                    prefixIcon: Icon(Icons.person, color: Colors.brown),
                                  ),
                                  keyboardType: TextInputType.emailAddress,
                                  validator: (value) {
                                    if (value == null || value.isEmpty) {
                                      return 'Please enter your last name';
                                    }
                                    return null;
                                  },
                                  onSaved: (value) {
                                    _lastName = value.toString();
                                  },
                                ),
                                SizedBox(height: 20),
                                TextFormField(
                                  controller: _emailController,
                                  decoration: InputDecoration(
                                    labelText: 'Email',
                                    labelStyle: TextStyle(color: Colors.brown),
                                    border: OutlineInputBorder(
                                      borderRadius: BorderRadius.circular(10),
                                      borderSide: BorderSide(color: Colors.brown),
                                    ),
                                    prefixIcon: Icon(Icons.email, color: Colors.brown),
                                  ),
                                  keyboardType: TextInputType.emailAddress,
                                  validator: (value) {
                                    // Basic email pattern for validation
                                    String pattern = r'^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,4}$';
                                    RegExp regex = RegExp(pattern);
                                    if (value == null || value.isEmpty) {
                                      return 'Please enter your email';
                                    } else if (!regex.hasMatch(value)) {
                                      return 'Please enter a valid email address';
                                    }
                                    return null;
                                  },
                                  onSaved: (value) {
                                    _email = value.toString();
                                  },
                                ),
                                SizedBox(height: 20),
                                TextFormField(
                                  controller: _userIdController,
                                  decoration: InputDecoration(
                                    labelText: 'Username',
                                    labelStyle: TextStyle(color: Colors.brown),
                                    border: OutlineInputBorder(
                                      borderRadius: BorderRadius.circular(10),
                                      borderSide: BorderSide(color: Colors.brown),
                                    ),
                                    prefixIcon: Icon(Icons.person, color: Colors.brown),
                                  ),
                                  keyboardType: TextInputType.emailAddress,
                                  validator: (value) {
                                    // Basic email pattern for validation
                                    String pattern = r'^[a-zA-Z0-9]+$';
                                    RegExp regex = RegExp(pattern);
                                    if (value == null || value.isEmpty) {
                                      return 'Please enter your username';
                                    } else if (!regex.hasMatch(value)) {
                                      return 'Please enter a valid username';
                                    }
                                    return null;
                                  },
                                  onSaved: (value) {
                                    _userId = value.toString();
                                  },
                                ),
                                SizedBox(height: 20),
                                TextFormField(
                                  controller: _currentPasswordController,
                                  decoration: InputDecoration(
                                      labelText: 'Current Password',
                                      labelStyle: TextStyle(color: Colors.brown),
                                      border: OutlineInputBorder(
                                        borderRadius: BorderRadius.circular(10),
                                        borderSide: BorderSide(color: Colors.brown),
                                      ),
                                      prefixIcon: Icon(Icons.lock, color: Colors.brown),
                                      suffixIcon: IconButton(
                                        icon: Icon(
                                          _isCurrentPasswordHidden ? Icons.visibility_off : Icons.visibility,
                                          color: Colors.brown,
                                        ),
                                        onPressed: () {
                                          setState(() {
                                            _isCurrentPasswordHidden = !_isCurrentPasswordHidden; // Toggle the password visibility
                                          });
                                        },
                                      )),
                                  obscureText: _isCurrentPasswordHidden,
                                  validator: (value) {
                                    if (value == null || value.isEmpty) {
                                      return 'Please enter your password';
                                    }
                                    return null;
                                  },
                                  onSaved: (value) {
                                    _password = value!;
                                  },
                                ),
                                SizedBox(height: 20),
                                TextFormField(
                                  controller: _newPasswordController,
                                  decoration: InputDecoration(
                                      labelText: 'New Password',
                                      labelStyle: TextStyle(color: Colors.brown),
                                      border: OutlineInputBorder(
                                        borderRadius: BorderRadius.circular(10),
                                        borderSide: BorderSide(color: Colors.brown),
                                      ),
                                      prefixIcon: Icon(Icons.lock, color: Colors.brown),
                                      suffixIcon: IconButton(
                                        icon: Icon(
                                          _isPasswordHidden ? Icons.visibility_off : Icons.visibility,
                                          color: Colors.brown,
                                        ),
                                        onPressed: () {
                                          setState(() {
                                            _isPasswordHidden = !_isPasswordHidden; // Toggle the password visibility
                                          });
                                        },
                                      )),
                                  obscureText: _isPasswordHidden,
                                  validator: (value) {
                                    if (_confirmPasswordController.text.isNotEmpty && (value == null || value.isEmpty)) {
                                      return 'Please enter your new password';
                                    }
                                    return null;
                                  },
                                  onSaved: (value) {
                                    _newPassword = value!;
                                  },
                                ),
                                SizedBox(height: 20),
                                TextFormField(
                                  controller: _confirmPasswordController,
                                  decoration: InputDecoration(
                                      labelText: 'Confirm Password',
                                      labelStyle: TextStyle(color: Colors.brown),
                                      border: OutlineInputBorder(
                                        borderRadius: BorderRadius.circular(10),
                                        borderSide: BorderSide(color: Colors.brown),
                                      ),
                                      prefixIcon: Icon(Icons.lock, color: Colors.brown),
                                      suffixIcon: IconButton(
                                        icon: Icon(
                                          _isPasswordHidden ? Icons.visibility_off : Icons.visibility,
                                          color: Colors.brown,
                                        ),
                                        onPressed: () {
                                          setState(() {
                                            _isPasswordHidden = !_isPasswordHidden; // Toggle the password visibility
                                          });
                                        },
                                      )),
                                  obscureText: _isPasswordHidden,
                                  validator: (value) {
                                    if (_newPasswordController.text.isNotEmpty && (value == null || value.isEmpty)) {
                                      return 'Confirm enter your new password';
                                    } else if (value != _newPasswordController.text) {
                                      return 'Password are not match';
                                    }
                                    return null;
                                  },
                                  onSaved: (value) {
                                    _newPassword = value!;
                                  },
                                ),
                                SizedBox(height: 30),
                                Row(
                                  mainAxisAlignment: MainAxisAlignment.end,
                                  children: [
                                    ElevatedButton(
                                      onPressed: () {
                                        if (_formKey.currentState!.validate()) {
                                          updateUser();
                                        } else {
                                          // If the form is invalid, display validation errors
                                          print('Form is invalid');
                                        }
                                      },
                                      style: ElevatedButton.styleFrom(
                                        backgroundColor: Colors.brown,
                                        foregroundColor: Colors.white,
                                        padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 15),
                                        shape: RoundedRectangleBorder(
                                          borderRadius: BorderRadius.circular(10),
                                        ),
                                      ),
                                      child: const Text(
                                        'Save',
                                        style: TextStyle(
                                          fontSize: 18,
                                          color: Colors.white,
                                        ),
                                      ),
                                    ),
                                  ],
                                )
                              ],
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ));
  }
}
