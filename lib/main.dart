import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:spend_wise/container_page.dart';
import 'package:spend_wise/dto/user_configs.dart';
import 'package:spend_wise/dto/user.dart';
import 'package:spend_wise/model/user_configs_repository.dart';
import 'package:spend_wise/model/user_repository.dart';
import 'package:spend_wise/pages/signup_page.dart';
import 'package:spend_wise/session/session_context.dart';
import 'package:spend_wise/background/flutter_sync.dart';
import 'package:spend_wise/model/user_configs_repository_firebase.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  UserRepository userRepository = UserRepository();
  await userRepository.database;
  await Firebase.initializeApp();
  runApp(Login());
}

class Login extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Login Page',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        primarySwatch: Colors.brown,
      ),
      home: LoginPage(),
    );
  }
}

class LoginPage extends StatefulWidget {
  @override
  _LoginPageState createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final _formKey = GlobalKey<FormState>();
  final FirebaseUserConfigsRepository userFirebaseRepo = FirebaseUserConfigsRepository();
  bool _isPasswordHidden = true;
  final TextEditingController _userIdController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final UserRepository _userRepository = UserRepository();
  final UserConfigsRepository _userConfigsRepository = UserConfigsRepository();
  String userId = '';
  String password = '';

  void _login() async {
    if (_formKey.currentState!.validate()) {
      userId = _userIdController.text;
      password = _passwordController.text;

      try {
        UserDto user = await _userRepository.login(userId, password);
        SessionContext session = SessionContext();
        session.updateUserData(userData: user);
        List<UserConfigs> userConfigs = await _userConfigsRepository.getUserConfigs(user.username);
        session.setUserConfigs(userConfigs: userConfigs);
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => MyApp()),
        );
      } catch (e) {
        if (e.toString().contains('User not found')) {
          UserDto user = UserDto(firstName: '', lastName: '', username: userId, password: password, email: userId);
          UserDto? existingUser = await userFirebaseRepo.existingUser(user);
          if (existingUser != null && existingUser.password == password) {
            _userRepository.registerUser(existingUser);
            SessionContext session = SessionContext();
            session.updateUserData(userData: existingUser);
            List<UserConfigs> userConfigs = await _userConfigsRepository.getUserConfigs(existingUser.username);
            session.setUserConfigs(userConfigs: userConfigs);
            restoreDataFromFirebase(userId);
            Navigator.pushReplacement(
              context,
              MaterialPageRoute(builder: (context) => MyApp()),
            );
          } else {
            ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
                content: Text('Invalid Login. Please try agian'),
                backgroundColor: Color.fromARGB(255, 204, 117, 3),
                duration: Duration(seconds: 3)));
          }
        }
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
        onTap: () {
          FocusScope.of(context).unfocus(); // Dismiss the keyboard when tapping outside
        },
        child: Scaffold(
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
                            'Spend Wise',
                            style: TextStyle(
                              fontSize: 30,
                              color: Colors.brown,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(height: 30),
                          TextFormField(
                            controller: _userIdController,
                            decoration: InputDecoration(
                              labelText: 'Username/Email',
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
                                return 'Please enter your email';
                              }
                              return null;
                            },
                            onSaved: (value) {
                              userId = value!;
                            },
                          ),
                          const SizedBox(height: 20),
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
                                    _isPasswordHidden ? Icons.visibility_off : Icons.visibility,
                                    color: Colors.brown,
                                  ),
                                  onPressed: () {
                                    setState(() {
                                      _isPasswordHidden = !_isPasswordHidden;
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
                              password = value!;
                            },
                          ),
                          const SizedBox(height: 30),
                          ElevatedButton(
                            onPressed: () {
                              _login();
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
                              'Login',
                              style: TextStyle(
                                fontSize: 18,
                                color: Colors.white,
                              ),
                            ),
                          ),
                          SizedBox(height: 20),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              TextButton(
                                onPressed: () {
                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(builder: (context) => SignupPage()),
                                  );
                                },
                                child: const Text(
                                  'Sign up',
                                  style: TextStyle(color: Colors.brown),
                                ),
                              ),
                              TextButton(
                                onPressed: () {
                                  print("Add transaction page naviation");
                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(builder: (context) => SignupPage()),
                                  );
                                },
                                child: const Text(
                                  'Forgot Password?',
                                  style: TextStyle(color: Colors.brown),
                                ),
                              )
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
        ));
  }
}
