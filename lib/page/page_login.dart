import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:fridge/controller/global.dart';
import 'package:fridge/controller/auth_service.dart';
import 'package:flutter/services.dart';
import 'dart:convert';

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final TextEditingController _idController = TextEditingController();
  final TextEditingController _pwController = TextEditingController();

  Future<void> _login() async {
    final id = _idController.text.trim();
    final pw = _pwController.text.trim();

    final response = await authenticatedRequest(
      context: context,
      url: Uri.parse('$BASE_URL/auth/login'),
      method: "POST",
      body: {
        "email": id, 
        "password": pw
      },
    );

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      await storage.write(key: 'accessToken', value: data['accessToken']);
      await storage.write(key: 'refreshToken', value: data['refreshToken']);
      Navigator.pushNamed(context, '/main');
    } 
    else {
      _showDialog("Error", "Login failed.");
    }
  }

  void _showDialog(String title, String message) {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: Text(title),
        content: Text(message),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context), 
            child: Text('Ok')
          )
        ],
      ),
    );
  }

  Widget build(BuildContext context) {
    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (didPop, result) async {
        if (!didPop) {
          final shouldExit = await _showExitDialog(context);
          if (shouldExit) {
            SystemNavigator.pop();
          } 
        }
      },
      child: Scaffold(
        backgroundColor: const Color(0xFFFFFFFF),
        appBar: AppBar(
          automaticallyImplyLeading: false,
          backgroundColor: Colors.white,
          foregroundColor: Colors.black,
        ),
        body: Center(
          child: SingleChildScrollView(
          padding: const EdgeInsets.fromLTRB(40.0, 0.0, 40.0, 80.0),
            child: Column(  // HERE
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  "LogIn",
                  style: TextStyle(
                    fontSize: 30,
                    fontWeight: FontWeight.bold,
                  ),                
                ),
                const SizedBox(height: 15.0),
                TextField(
                  controller: _idController,
                  decoration: InputDecoration(labelText: 'ID'),
                ),
                const SizedBox(height: 10.0),
                TextField(
                  controller: _pwController,
                  decoration: InputDecoration(labelText: 'Password'),
                  obscureText: true,
                ),
                const SizedBox(height: 30.0),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    TextButton(
                      onPressed: _showSignUpModal,
                      child: Text('Sign Up'),
                    ),
                    ElevatedButton(
                      onPressed: _login,
                      child: Text('LogIn'),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      )
    );
  }

  Future<bool> _showExitDialog(BuildContext context) async {
    final result = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            SizedBox(height: 40),
            Text('Do you want to exit the app?'),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.of(context).pop(false);
            },
            child: Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.of(context).pop(true);
            },
            child: Text('Exit'),
          ),
        ],
      ),
    );

    return result == true;
  }

  void _showSignUpModal() {
    final _signUpNicknameController = TextEditingController();
    final _signUpIdController = TextEditingController();
    final _signUpPwController = TextEditingController();
    final _signUpPwCheckController = TextEditingController();

    showDialog(
      context: context,
      builder: (context) {
        String idCheckResult = "";
        Color resultColor = Colors.black;

        String pwMatchResult = "";
        Color pwResultColor = Colors.black;

        return StatefulBuilder(
          builder: (context, setState) {
            void checkPasswordMatch() {
              final pw = _signUpPwController.text;
              final pwCheck = _signUpPwCheckController.text;

              if (!mounted) return;
              setState(() {
                if (pwCheck.isEmpty) {
                  pwMatchResult = "";
                } else if (pw == pwCheck) {
                  pwMatchResult = "Match";
                  pwResultColor = Colors.green;
                } else {
                  pwMatchResult = "NOT match.";
                  pwResultColor = Colors.red;
                }
              });
            }

            _signUpPwController.removeListener(checkPasswordMatch);
            _signUpPwCheckController.removeListener(checkPasswordMatch);
            _signUpPwController.addListener(checkPasswordMatch);
            _signUpPwCheckController.addListener(checkPasswordMatch);

            return AlertDialog(
              title: Text("Sign Up"),
              content: SingleChildScrollView(
                child: SizedBox(
                  width: 300,
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const SizedBox(height: 10),
                      TextField(
                        controller: _signUpNicknameController,
                        decoration: const InputDecoration(labelText: 'Nickname'),
                      ),
                      const SizedBox(height: 20),
                      Row(
                        children: [
                          Expanded(
                            child: TextField(
                              controller: _signUpIdController,
                              decoration: InputDecoration(labelText: 'ID'),
                            ),
                          ),
                          const SizedBox(width: 8),
                          ElevatedButton(
                            onPressed: () async {
                              final id = _signUpIdController.text.trim();
                              if (id.isEmpty) {
                                if (!mounted) return;
                                setState(() {
                                  idCheckResult = "Please enter an ID first.";
                                  resultColor = Colors.red;
                                });
                                return;
                              }

                              final checkResponse = await http.get(
                                Uri.parse("$BASE_URL/auth/check-email?email=$id"),
                              );

                              if (checkResponse.statusCode == 200) {
                                if (!mounted) return;
                                setState(() {
                                  idCheckResult = "Available";
                                  resultColor = Colors.green;
                                });
                              } else {
                                if (!mounted) return;
                                setState(() {
                                  idCheckResult = "NOT available";
                                  resultColor = Colors.red;
                                });
                              }
                            },
                            child: const Text("Check"),
                          ),
                        ],
                      ),
                      const SizedBox(height: 6),
                      Align(
                        alignment: Alignment.centerLeft,
                        child: Text(
                          idCheckResult,
                          style: TextStyle(color: resultColor, fontSize: 13),
                        ),
                      ),
                      const SizedBox(height: 10),
                      TextField(
                        controller: _signUpPwController,
                        decoration: InputDecoration(labelText: 'Password'),
                        obscureText: true,
                      ),
                      const SizedBox(height: 20),
                      TextField(
                        controller: _signUpPwCheckController,
                        decoration: InputDecoration(labelText: 'Password Check'),
                        obscureText: true,
                      ),
                      const SizedBox(height: 6),
                      Align(
                        alignment: Alignment.centerLeft,
                        child: Text(
                          pwMatchResult,
                          style: TextStyle(color: pwResultColor, fontSize: 13),
                        ),
                      ), 
                    ],
                  ),
                ),
              ),
              actions: [
                TextButton(
                    onPressed: () => Navigator.pop(context),
                    child: Text("Cancel")),
                ElevatedButton(
                  onPressed: () async {
                    final nickname = _signUpNicknameController.text.trim();
                    final id = _signUpIdController.text.trim();
                    final pw = _signUpPwController.text.trim();
                    final pwCheck = _signUpPwCheckController.text.trim();

                    if (nickname.isEmpty || id.isEmpty || pw.isEmpty || pwCheck.isEmpty) {
                      _showDialog("Error", "Please fill in all input fields.");
                      return;
                    }

                    if (pw != pwCheck) {
                      _showDialog("Error", "Passwords do NOT match.");
                      return;
                    }

                    final response = await http.post(
                      Uri.parse("$BASE_URL/auth/signup"),
                      headers: {"Content-Type": "application/json"},
                      body: jsonEncode({
                        "name": nickname,
                        "email": id,
                        "password": pw
                      }),
                    );

                    if (response.statusCode == 201) {
                      Navigator.pop(context);
                      _showDialog("Success", "Completed. Please login.");
                    } else {
                      _showDialog("Error", "Fail to sign up");
                    }
                  },
                  child: Text("Sign Up"),
                ),
              ],
            );
          },
        );
      },
    );
  }
}