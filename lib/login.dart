// ignore_for_file: prefer_const_constructors, unused_local_variable, use_build_context_synchronously, non_constant_identifier_names, avoid_init_to_null, prefer_typing_uninitialized_variables

import 'dart:async';

import 'package:eureka/dashboard.dart';
import 'package:flutter/material.dart';
import 'package:eureka/global_helper.dart';
import 'package:eureka/splash_screen.dart';
import 'package:eureka/util/constants.dart' as constants;
import 'package:eureka/util/components/reset_password_dialog.dart';
import 'package:shared_preferences/shared_preferences.dart';

class Login extends StatefulWidget {
  const Login({super.key});

  @override
  State<Login> createState() => _LoginState();
}

class _LoginState extends State<Login> {
  GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();
  final TimerController timerController = TimerController();
  var username = TextEditingController();
  var password = TextEditingController();

  GlobalHelper globalHelper = GlobalHelper();
  Map<String, dynamic>? companies;

  bool isPasswordValid = false;
  bool _obscureText = true;
  // String selectedCompany = '';
  // var company = [];

  @override
  void initState() {
    super.initState();
    timerController.startPeriodic(Duration(seconds: 10), () {
      if (mounted) {
        initializeData();
      }
    });
    initializeData();
  }

  void initializeData() {
    // _loadCompanies();
  }

  // Future<void> _loadCompanies() async {
  //   try {
  //     companies = await globalHelper.get_companies();
  //     company = companies!['companies'];
  //     setState(() {});
  //   } catch (e) {
  //     print('Error: $e');
  //   }
  // }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: _scaffoldKey,
      appBar: null,
      body: SingleChildScrollView(
        child: Column(
          children: [
            SizedBox(height: 90),
            Image(
              image: AssetImage('assets/splash_bg.png'),
              fit: BoxFit.fitWidth,
              width: MediaQuery.of(context).size.width - 40,
              // height: 250,
            ),
            SizedBox(
              height: 15,
            ),
            Text(
              'Admin Panel',
              style: TextStyle(
                fontSize: 28, // Adjust the font size as needed
                fontWeight: FontWeight.bold, // Make the text bold
                color: constants.mainColor, // Use your primary color
              ),
            ),
            Text(
              'Please fill out the following fields to sign in',
              style: TextStyle(
                fontSize: 14, // Adjust the font size as needed
                color: Colors.grey, // Use a muted color for the description
              ),
            ),
            SizedBox(
              height: 20,
            ),
            Padding(
              padding: const EdgeInsets.all(30.0),
              child: Column(
                children: [
                  TextField(
                    controller: username,
                    decoration: InputDecoration(
                      label: Text('Enter Username'),
                      border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(11),
                          borderSide: BorderSide(color: constants.mainColor)),
                    ),
                    // keyboardType: TextInputType.number,
                  ),
                  SizedBox(
                    height: 10,
                  ),
                  TextField(
                    controller: password,
                    decoration: InputDecoration(
                        label: Text('Enter Password'),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(11),
                          borderSide: BorderSide(color: constants.mainColor),
                        ),
                        suffixIcon: IconButton(
                            onPressed: () {
                              setState(() {
                                _obscureText = !_obscureText;
                              });
                            },
                            icon: Icon(
                                _obscureText
                                    ? Icons.visibility
                                    : Icons.visibility_off,
                                color: Colors.grey))),
                    obscureText: _obscureText,
                  ),

                  // Added dropdown for selecting company
                  SizedBox(
                    height: 10,
                  ),

                  // Container(
                  //   padding: EdgeInsets.all(8),
                  //   decoration: BoxDecoration(
                  //     border: Border.all(color: constants.mainColor),
                  //     borderRadius: BorderRadius.circular(11),
                  //   ),
                  //   child: DropdownButton<String>(
                  //     value: selectedCompany.isEmpty ? null : selectedCompany,
                  //     items: company.map((value) {
                  //       return DropdownMenuItem<String>(
                  //         value: value['company_id'].toString(),
                  //         child: Text(value['name']),
                  //       );
                  //     }).toList(),
                  //     onChanged: (String? newValue) {
                  //       setState(() {
                  //         selectedCompany = newValue ??
                  //             ''; // Handle null case for defaultValue
                  //       });
                  //     },
                  //     underline: Container(),
                  //     isExpanded: true,
                  //     icon: Icon(Icons.arrow_drop_down),
                  //     style: TextStyle(color: constants.mainColor),
                  //     hint: Text('Select Company'),
                  //   ),
                  // ),

                  // SizedBox(
                  //   height: 60,
                  // ),
                  ElevatedButton(
                    onPressed: () async {
                      var hashedPassword = "";

                      String uUsername = username.text.toString();
                      String uPass = password.text;

                      if (uUsername != '' && uPass != '') {
                        showDialog(
                          context: context,
                          builder: (BuildContext context) {
                            return Center(
                              child: CircularProgressIndicator(),
                            );
                          },
                        );

                        // var user_info = await dbHelper?.login(uUsername, uPass);
                        var user_info =
                            await globalHelper.login(uUsername, uPass);

                        if (user_info['error'] != null) {
                          constants.Notification(user_info['error']);
                          passwordCheck(
                              isPasswordValid, user_info['error'], 0, '', '');
                        } else {
                          isPasswordValid = true;
                          var company_id;
                          var user_id;

                          // Check if company_id is already an integer
                          if (user_info['company_id'] is int) {
                            company_id = user_info['company_id'];
                          } else {
                            company_id = int.parse(user_info['company_id']);
                          }

                          // Check if user_id is already an integer
                          if (user_info['user_id'] is int) {
                            user_id = user_info['user_id'];
                          } else {
                            user_id = int.parse(user_info['user_id']);
                          }

                          passwordCheck(isPasswordValid, user_info['success'],
                              company_id, user_info['fy_year'], user_id);
                        }
                      } else {
                        constants.Notification(
                            'Please Fill All Required Fields');
                      }
                    },
                    style: ElevatedButton.styleFrom(
                        foregroundColor: Colors.white,
                        primary: constants
                            .mainColor, // Set the button's background color
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(30)),
                        elevation: 4, // Add some elevation
                        padding: EdgeInsets.only(
                            left: 100, right: 100, top: 15, bottom: 15)),
                    child: Text(
                      'Sign In',
                      style:
                          TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
                    ),
                  ),
                  SizedBox(
                    height: 12,
                  ),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text('Forgot Password?'),
                      SizedBox(
                        width: 5,
                      ),
                      GestureDetector(
                        onTap: () {
                          showDialog(
                            context: context,
                            builder: (BuildContext context) {
                              return ResetPasswordDialog();
                            },
                          );
                        },
                        child: Text(
                          'Reset Password?',
                          style: TextStyle(
                            color: Colors.deepPurpleAccent,
                            decoration: TextDecoration.none,
                          ),
                        ),
                      )
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> passwordCheck(
      isPasswordValid, msg, company_id, fy_year, user_id) async {
    Navigator.pop(context);
    if (isPasswordValid && company_id != 0 && fy_year != '') {
      var sharedPref = await SharedPreferences.getInstance();
      sharedPref.setBool(SplashScreenState.KEY_LOGIN, true);
      sharedPref.setInt('company_id', company_id);
      sharedPref.setString('fy_year', fy_year);
      sharedPref.setInt('user_id', user_id);
      constants.Notification(msg);
      Navigator.pushAndRemoveUntil(
          context,
          MaterialPageRoute(builder: (context) => Dashboard()),
          (route) => false);
    } else {
      // print('Missmatch');
      constants.Notification(msg);
    }
  }

  @override
  void dispose() {
    timerController.dispose();
    super.dispose();
  }
}
