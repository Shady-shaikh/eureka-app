// ignore_for_file: avoid_print

import 'dart:async';
import 'package:eureka/fragments/daysplan/beats.dart';
import 'package:eureka/fragments/outlets/outlets.dart';
import 'package:eureka/global_helper.dart';
import 'package:eureka/splash_screen.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:intl/intl.dart';
void main() => runApp(const MyApp());

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) => const MaterialApp(home: Dashboard());
}

class Dashboard extends StatefulWidget {
  const Dashboard({super.key});

  @override
  DashboardState createState() => DashboardState();
}

class DashboardState extends State<Dashboard> {
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();

  final TimerController timerController = TimerController();
  final globalHelper = GlobalHelper();

  Map<String, dynamic>? dashboardData, user;

  @override
  void initState() {

    super.initState();
    timerController.startPeriodic(const Duration(seconds: 10), () {
      if (mounted) {
        initializeData();
      }
    });
    initializeData();
  }

  void initializeData() async {
    try {
      dashboardData = await globalHelper.get_dashboard_data();
      user = await globalHelper.get_user_data();
      setState(() {});
    } catch (e) {
      print('Error: $e');
    }
  }

  @override
  Widget build(BuildContext context) => Scaffold(
        key: _scaffoldKey,
        appBar: AppBar(
          title: Text(
            'Hello, ${toCamelCase(user?['user']['first_name'] ?? '')}',
            style: TextStyle(fontSize: 20.0), // Adjust the font size
          ),
          actions: [
            Builder(
              builder: (context) => IconButton(
                icon: Icon(Icons.account_circle),
                onPressed: () => Scaffold.of(context).openEndDrawer(),
              ),
            ),
          ],
        ),
        body: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.all(8.0),
            child: Column(
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    DashboardCard(
                        moduleName: 'Outlets',
                        count: dashboardData?['outlets'] ?? 0,
                        onTap: () {
                          Navigator.push(
                              context,
                              MaterialPageRoute(
                                  builder: (context) => Outlets()));
                        }),
                    SizedBox(width: 5),
                    DashboardCard(
                        moduleName: 'Orders',
                        count: dashboardData?['order_bookings'] ?? 0,
                        onTap: () {}),
                  ],
                ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    DashboardCard(
                        moduleName:
                            'Salesman Incentive (${DateFormat('MMMM').format(DateTime.now())})'
                            ' In Rupees',
                        count: dashboardData?['salesman_incentive'] ?? 0,
                        onTap: () {
                          Navigator.push(
                              context,
                              MaterialPageRoute(
                                  builder: (context) => Outlets()));
                        }),
                  ],
                ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Expanded(
                      child: SizedBox(
                        height: 220,
                        // Set a specific height for your DashboardCard
                        child: Padding(
                          padding: const EdgeInsets.all(8.0),
                          child: InkWell(
                            onTap: () {},
                            child: Ink(
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(16.0),
                                border: Border.all(color: Colors.grey),
                              ),
                              padding: EdgeInsets.all(16.0),
                              child: SingleChildScrollView(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      'Top 5 Formats',
                                      style: TextStyle(
                                          fontSize: 18.0,
                                          fontWeight: FontWeight.w400),
                                    ),
                                    Divider(),
                                    SizedBox(height: 8.0),
                                    ListView.builder(
                                      shrinkWrap: true,
                                      itemCount:
                                          dashboardData?['formats']?.length ??
                                              0,
                                      itemBuilder: (context, index) {
                                        return Text(
                                          dashboardData?['formats']![index],
                                          style: TextStyle(
                                            fontSize: 16.0,
                                            fontWeight: FontWeight.w500,
                                          ),
                                        );
                                      },
                                    ),
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
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Expanded(
                      child: SizedBox(
                        height: 250,
                        // Set a specific height for your DashboardCard
                        child: Padding(
                          padding: const EdgeInsets.all(8.0),
                          child: InkWell(
                            onTap: () {},
                            child: Ink(
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(16.0),
                                border: Border.all(color: Colors.grey),
                              ),
                              padding: EdgeInsets.all(16.0),
                              child: SingleChildScrollView(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      'Focus Packs',
                                      style: TextStyle(
                                          fontSize: 16.0,
                                          fontWeight: FontWeight.w400),
                                    ),
                                    Divider(),
                                    SizedBox(height: 8.0),
                                    ListView.builder(
                                      shrinkWrap: true,
                                      itemCount: dashboardData?['focus_pack']
                                              ?.length ??
                                          0,
                                      itemBuilder: (context, index) {
                                        return Text(
                                          dashboardData?['focus_pack']![index],
                                          style: TextStyle(
                                            fontSize: 16.0,
                                            fontWeight: FontWeight.w500,
                                          ),
                                        );
                                      },
                                    ),
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
              ],
            ),
          ),
        ),
        endDrawer: DrawerWidget(
          userName:
              '${toCamelCase(user?['user']['first_name'] ?? '')} ${toCamelCase(user?['user']['last_name'] ?? '')}',
          email: user?['user']['email'] ?? '',
        ),
      );

  @override
  void dispose() {
    timerController.dispose();
    super.dispose();
  }
}

class DashboardCard extends StatelessWidget {
  final String moduleName;
  final int count;
  final VoidCallback onTap;

  DashboardCard({
    required this.moduleName,
    required this.count,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) => Expanded(
        child: SizedBox(
          height: 150, // Set a specific height for your DashboardCard
          child: Padding(
            padding: const EdgeInsets.all(8.0),
            child: InkWell(
              onTap: onTap,
              child: Ink(
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(16.0),
                  border: Border.all(color: Colors.grey),
                ),
                padding: EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      moduleName,
                      style: TextStyle(
                          fontSize: 18.0, fontWeight: FontWeight.w400),
                    ),
                    Divider(),
                    SizedBox(height: 8.0),
                    Text(
                      count.toString(),
                      style: TextStyle(
                          fontSize: 24.0, fontWeight: FontWeight.bold),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      );
}

class DrawerWidget extends StatelessWidget {
  final String userName, email;

  DrawerWidget({required this.userName, required this.email});

  @override
  Widget build(BuildContext context) => Drawer(
        child: Column(
          children: [
            Container(
              height: 150.0,
              child: DrawerHeader(
                child: Row(
                  children: [
                    Row(
                      children: [
                        Icon(Icons.circle_rounded, size: 50.0),
                        SizedBox(width: 10),
                        Text('Eureka',
                            style: TextStyle(
                                fontSize: 20.0, fontWeight: FontWeight.bold)),
                      ],
                    ),
                  ],
                ),
              ),
            ),
            ListTile(
              title: Row(
                children: [
                  Icon(Icons.dashboard),
                  SizedBox(width: 10),
                  Text("Day's Plan"),
                ],
              ),
              onTap: () => Navigator.push(context,
                  MaterialPageRoute(builder: (context) => BeatsPage())),
            ),
            ListTile(
              title: Row(
                children: [
                  Icon(Icons.dashboard),
                  SizedBox(width: 10),
                  Text("Outlets"),
                ],
              ),
              onTap: () => Navigator.push(
                  context, MaterialPageRoute(builder: (context) => Outlets())),
            ),
            Spacer(),
            Divider(),
            ListTile(
              title: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(userName),
                  CircleAvatar(radius: 15.0),
                ],
              ),
              subtitle: Text(email),
              onTap: () {},
            ),
            ListTile(
                title: Row(
                  children: [
                    Icon(Icons.logout),
                    SizedBox(width: 10),
                    Text('Logout'),
                  ],
                ),
                onTap: () async {
                  var sharedPref = await SharedPreferences.getInstance();
                  sharedPref.setBool(SplashScreenState.KEY_LOGIN, false);
                  Navigator.pushAndRemoveUntil(
                    context,
                    MaterialPageRoute(builder: (context) => SplashScreen()),
                    (route) => false,
                  );
                }),
          ],
        ),
      );
}

class TimerController {
  late Timer _timer;

  void startPeriodic(Duration duration, void Function() callback) {
    _timer = Timer.periodic(duration, (timer) {
      callback();
    });
  }

  void dispose() {
    _timer.cancel(); // Cancel the timer before disposing
  }
}

String toCamelCase(String input) => input.isEmpty
    ? input
    : input[0].toUpperCase() + input.substring(1).toLowerCase();
