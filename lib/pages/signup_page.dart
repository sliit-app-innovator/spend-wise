import 'package:flutter/material.dart';
import 'package:spend_wise/dto/user.dart';
import 'package:spend_wise/main.dart';
import 'package:spend_wise/model/user_repository.dart';

class SignupPage extends StatefulWidget {
  @override
  _SignupPage createState() => _SignupPage();
}

class _SignupPage extends State<SignupPage> {
  bool _isPasswordHidden = true;
  final _formKey = GlobalKey<FormState>();
  final UserRepository userRepository = UserRepository();
  final TextEditingController _firstNameController = TextEditingController();
  final TextEditingController _lastNameController = TextEditingController();
  final TextEditingController _userIdController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final TextEditingController _confirmPasswordController =
      TextEditingController(); // Confirm password controller
  final TextEditingController _emailController = TextEditingController();

  @override
  void dispose() {
    _passwordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    String _firstName = '';
    String _lastName = '';
    String _userId = '';
    String _password = '';
    String _email = '';
    // UserDto userDto = new UserDto();
    return Scaffold(
      appBar: AppBar(
        title: const Text('Spend Wise Registration'),
        backgroundColor: Colors.brown[400],
        foregroundColor: Colors.white,
      ),
      backgroundColor: const Color.fromARGB(255, 172, 109, 78),
      body: Center(
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
                      const Text(
                        'Spend Wise Sign Up',
                        style: TextStyle(
                          fontSize: 30,
                          color: Colors.brown,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 30),
                      TextFormField(
                        controller: _firstNameController,
                        decoration: InputDecoration(
                          labelText: 'First Name',
                          labelStyle: TextStyle(color: Colors.brown),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(10),
                            borderSide: BorderSide(color: Colors.brown),
                          ),
                          prefixIcon:
                              Icon(Icons.perm_identity, color: Colors.brown),
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
                          prefixIcon:
                              Icon(Icons.perm_identity, color: Colors.brown),
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
                          String pattern =
                              r'^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,4}$';
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
                          prefixIcon:
                              Icon(Icons.perm_identity, color: Colors.brown),
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
                        controller: _passwordController,
                        decoration: InputDecoration(
                            labelText: 'Password',
                            labelStyle: TextStyle(color: Colors.brown),
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(10),
                              borderSide: BorderSide(color: Colors.brown),
                            ),
                            prefixIcon: Icon(Icons.lock, color: Colors.brown),
                            suffixIcon: IconButton(
                              icon: Icon(
                                _isPasswordHidden
                                    ? Icons.visibility_off
                                    : Icons.visibility,
                                color: Colors.brown,
                              ),
                              onPressed: () {
                                setState(() {
                                  _isPasswordHidden =
                                      !_isPasswordHidden; // Toggle the password visibility
                                });
                              },
                            )),
                        obscureText: _isPasswordHidden,
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
                                _isPasswordHidden
                                    ? Icons.visibility_off
                                    : Icons.visibility,
                                color: Colors.brown,
                              ),
                              onPressed: () {
                                setState(() {
                                  _isPasswordHidden =
                                      !_isPasswordHidden; // Toggle the password visibility
                                });
                              },
                            )),
                        obscureText: _isPasswordHidden,
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Confirm your password';
                          } else if (value != _passwordController.text) {
                            return 'Password are not match';
                          }
                          return null;
                        },
                        onSaved: (value) {
                          //  password = value!;
                        },
                      ),
                      SizedBox(height: 30),
                      ElevatedButton(
                        onPressed: () {
                          //   _login();
                          if (_formKey.currentState!.validate()) {
                            UserDto userDto = UserDto(
                                firstName: _firstNameController.text,
                                lastName: _lastNameController.text,
                                username: _userIdController.text,
                                password: _passwordController.text,
                                email: _emailController.text);
                            _register(userDto);
                          } else {
                            // If the form is invalid, display validation errors
                            print('Form is invalid');
                          }
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.brown,
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(
                              horizontal: 40, vertical: 15),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10),
                          ),
                        ),
                        child: const Text(
                          'Sign up',
                          style: TextStyle(
                            fontSize: 18,
                            color: Colors.white,
                          ),
                        ),
                      ),
                      SizedBox(height: 20),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  void _register(UserDto userDto) async {
    if (_formKey.currentState!.validate()) {
      String userId = _userIdController.text;

      try {
        await userRepository.getUser(userId);
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
            content: Text('User already exists'),
            backgroundColor: Colors.red,
            duration: Duration(seconds: 3)));
      } catch (e) {
        if (e.toString().contains('User not found')) {
          try {
            await userRepository.getUserByEmail(_emailController.text);
            ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
                content: Text('Email Address already exists'),
                backgroundColor: Colors.red,
                duration: Duration(seconds: 3)));
          } catch (e) {
            if (e.toString().contains('Email not found')) {
              _registerNewUser(userDto);
            } else {
              print(e.toString());
            }
          }
        } else {
          print(e.toString());
        }
      }
    }
  }

  void _registerNewUser(UserDto userDto) async {
    await userRepository.registerUser(userDto);
    print("Registration successful.. ");
    ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
        content: Text('Registration successful. Sign in with your credentials'),
        backgroundColor: Colors.green,
        duration: Duration(seconds: 2)));
    await Future.delayed(const Duration(seconds: 2));
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => Login()),
    );
  }
}
