import 'package:flutter/material.dart';
import 'package:flutter_application_1/screens/tab_screens.dart';
import 'package:animate_do/animate_do.dart';
import 'package:flutter_application_1/constants/colors.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;

class LoginScreen extends StatefulWidget {
  const LoginScreen({Key? key}) : super(key: key);

  @override
  _LoginScreenState createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final TextEditingController emailController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();

  @override
  void dispose() {
    emailController.dispose();
    passwordController.dispose();
    super.dispose();
  }

  Future<void> _login() async {
    String email = emailController.text;
    String password = passwordController.text;

    // Get the value from backend
    try {
      String bassedUrl = "https://3acb-101-53-1-124.ngrok-free.app";
      String request = '$bassedUrl/users/email?email=$email';
      var response = await http.get(Uri.parse(request));
      var data = json.decode(response.body);
      print('--> Data is $data');

      if (response.statusCode == 200) {
        // Save the response data to SharedPreferences
        final prefs = await SharedPreferences.getInstance();
        await prefs.setInt('id', data['id']);
        // await prefs.setString('name', data['name']);
        // await prefs.setString('email', data['email']);
        // await prefs.setString('phone', data['phone']);
        // await prefs.setString('country', data['address']['country']);
        // await prefs.setString('city', data['address']['city']);
        // await prefs.setString('district', data['address']['district']);
        // await prefs.setString('ward', data['address']['ward']);
        await prefs.setString('username', data['username']);
        // await prefs.setDouble('rating', data['rating']);
        // await prefs.setDouble('balance', data['balance']);

        // Also store the credentials if needed
        await prefs.setString('email', email);
        await prefs.setString('password', password);

        // Navigate to the TabScreens
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => const TabScreens()),
        );
      } else {
        throw Exception("Failed to load data");
      }
    } catch (e) {
      print(e.toString());
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SingleChildScrollView(
        child: Container(
          child: Column(
            children: <Widget>[
              SizedBox(
                height: 250,
                child: Center(
                  child: FadeInUp(
                    duration: Duration(milliseconds: 800),
                    child: Text(
                      "Login",
                      style: TextStyle(
                        fontSize: 40,
                        fontWeight: FontWeight.bold,
                        color: AppColors.primaryColor,
                      ),
                    ),
                  ),
                ),
              ),
              Padding(
                padding: EdgeInsets.all(30.0),
                child: Column(
                  children: <Widget>[
                    FadeInUp(
                      duration: Duration(milliseconds: 800),
                      child: Container(
                        padding: EdgeInsets.all(5),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(10),
                          border: Border.all(color: AppColors.primaryColor),
                          boxShadow: [
                            BoxShadow(
                              color: Color.fromRGBO(143, 148, 251, .2),
                              blurRadius: 20.0,
                              offset: Offset(0, 10),
                            ),
                          ],
                        ),
                        child: Column(
                          children: <Widget>[
                            Container(
                              padding: EdgeInsets.all(8.0),
                              decoration: BoxDecoration(
                                border: Border(
                                  bottom:
                                      BorderSide(color: AppColors.primaryColor),
                                ),
                              ),
                              child: TextField(
                                controller: emailController,
                                decoration: InputDecoration(
                                  border: InputBorder.none,
                                  hintText: "Email or Phone number",
                                  hintStyle: TextStyle(color: Colors.grey[700]),
                                ),
                              ),
                            ),
                            Container(
                              padding: EdgeInsets.all(8.0),
                              child: TextField(
                                controller: passwordController,
                                obscureText: true,
                                decoration: InputDecoration(
                                  border: InputBorder.none,
                                  hintText: "Password",
                                  hintStyle: TextStyle(color: Colors.grey[700]),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                    SizedBox(height: 30),
                    FadeInUp(
                      duration: Duration(milliseconds: 800),
                      child: GestureDetector(
                        onTap: _login,
                        child: Container(
                          width: double.infinity,
                          height: 50,
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(10),
                            gradient: LinearGradient(
                              colors: [
                                Color.fromRGBO(0, 103, 105, 1),
                                Color.fromRGBO(0, 103, 105, 1),
                              ],
                            ),
                          ),
                          child: Center(
                            child: Text(
                              "Login",
                              style: TextStyle(
                                color: Colors.white,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                        ),
                      ),
                    ),
                    SizedBox(height: 70),
                    FadeInUp(
                      duration: Duration(milliseconds: 800),
                      child: Text(
                        "Forgot Password?",
                        style: TextStyle(color: AppColors.primaryColor),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
