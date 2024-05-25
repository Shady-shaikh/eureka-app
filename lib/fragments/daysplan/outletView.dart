import 'dart:async';
import 'package:eureka/util/components/OutstandingDialog.dart';
import 'package:flutter/material.dart';
import 'package:eureka/util/components/visibilityDialog.dart';
import 'package:eureka/util/components/sohDialog.dart';
import 'package:eureka/util/components/commentsDialog.dart';
import 'package:eureka/fragments/daysplan/addItemList.dart';
import 'package:eureka/fragments/daysplan/viewOrder.dart';
import 'package:eureka/global_helper.dart';
import 'package:eureka/timer.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:eureka/location.dart';
import 'package:eureka/util/constants.dart' as constants;

class OutletViewPage extends StatefulWidget {
  final String outletName;
  final int beatId;
  final int outletId;

  OutletViewPage(
      {required this.outletName, required this.beatId, required this.outletId});

  @override
  State<OutletViewPage> createState() => _OutletViewPageState();
}

class _OutletViewPageState extends State<OutletViewPage> {
  bool isDataLoaded = false;
  final globalHelper = GlobalHelper();
  List<Map<String, dynamic>> orders = [];

  @override
  void initState() {
    LocationService.checkLocationPermission(context);

    super.initState();
    timerController = TimerController(
      duration: Duration(seconds: constants.refTime),
      callback: initializeData,
    )..startPeriodic();
    initializeData();
  }

  Future<void> initializeData() async {
    try {
      final response = await globalHelper.get_orders(widget.outletId);
      if (mounted) {
        setState(() {
          orders = List<Map<String, dynamic>>.from(response['orders']);
        });
        isDataLoaded = true;
      }
    } catch (e) {
      print('Error: $e');
    } finally {
      await Future.delayed(Duration(seconds: constants.delayedTime));
    }
  }

  @override
  void dispose() {
    timerController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.outletName),
        leading: IconButton(
          icon: Icon(Icons.arrow_back),
          onPressed: () {
            Navigator.pop(context);
          },
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            if (!isDataLoaded)
              Center(child: CircularProgressIndicator())
            else
              Row(
                children: [
                  Expanded(
                    child: ElevatedButton(
                      onPressed: () async {
                        // Handle end call action
                        var sharedPref = await SharedPreferences.getInstance();
                        var user_id = sharedPref.getInt('user_id');
                        var postedData = {
                          'user_id': user_id,
                          'outlet_id': widget.outletId,
                          'beat_id': widget.beatId,
                          'is_submit': 1
                        };

                        showDialog(
                          context: context,
                          builder: (BuildContext context) =>
                              Center(child: CircularProgressIndicator()),
                        );
                        var res = await globalHelper
                            .update_outlet_Selection(postedData);

                        if (res['success'] != null) {
                          constants.Notification(res['success']);
                          Navigator.pop(context);
                          Navigator.pop(context);
                        } else if (res['error'] != null) {
                          constants.Notification(res['error']);
                          Navigator.pop(context);
                        }
                      },
                      child: Text('End Call'),
                    ),
                  ),
                  SizedBox(
                    width: 16,
                  ),
                  Expanded(
                    child: ElevatedButton(
                        onPressed: () {
                          _showSOHDialog(context);
                        },
                        child: Text('SOH')),
                  ),
                ],
              ),
            SizedBox(
              height: 8,
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                ElevatedButton(
                  onPressed: () {
                    _showVisibilityDialog(context);
                  },
                  child: Text(
                    'Visibility',
                    style: TextStyle(fontSize: 10),
                  ),
                ),
                ElevatedButton(
                  onPressed: () {
                    _showOutstandingDialog(context);
                  },
                  child: Text(
                    'Outstanding',
                    style: TextStyle(fontSize: 10),
                  ),
                ),
                ElevatedButton(
                  onPressed: () {
                    _showCommentsDialog(context);
                  },
                  child: Text(
                    'Comments',
                    style: TextStyle(fontSize: 10),
                  ),
                ),
              ],
            ),
            SizedBox(height: 16.0),
            Center(
                child: Text(
              'Orders',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            )),
            SizedBox(height: 16.0),
            Expanded(
              child: ListView.builder(
                itemCount: orders.length, // Replace with your data list length,
                itemBuilder: (context, index) {
                  final order = orders[index];
                  // Replace with your card widget
                  return Card(
                    child: ListTile(
                      title: Text(order['bill_no']),
                      trailing:
                          Text(constants.formatDate(order['bill_date']) ?? ''),
                      onTap: () {
                        // Handle card tap, navigate to another page
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            // settings: RouteSettings(arguments: response),
                            builder: (context) => ViewOrder(
                                outletId: widget.outletId,
                                orderId: order['order_booking_id']),
                          ),
                        );
                      },
                    ),
                  );
                },
              ),
            )
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () async {
          // Handle adding orders action

          final response = await globalHelper.update_order(widget.outletId);

          Navigator.push(
            context,
            MaterialPageRoute(
              // settings: RouteSettings(arguments: response),
              builder: (context) =>
                  // OrderBookingEditPage(
                  //     outletId: widget.outletId, orderId: response['order_id']),
                  AddItemList(
                      outletId: widget.outletId,
                      isOg: false,
                      orderId: response['order_id']),
            ),
          );
        },
        child: Icon(Icons.add),
      ),
    );
  }

  void _showVisibilityDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return VisibilityDialog(outletID: widget.outletId);
      },
    );
  }

  void _showSOHDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return SohDialog(outletID: widget.outletId);
      },
    );
  }

  void _showCommentsDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return CommentsDialog(outletID: widget.outletId);
      },
    );
  }

  void _showOutstandingDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return OutstandingDialog(outletID: widget.outletId);
      },
    );
  }
}

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: BeatsPage(),
    );
  }
}

class BeatsPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Day's Plan"),
        centerTitle: true,
        leading: IconButton(
          icon: Icon(Icons.arrow_back),
          onPressed: () {
            Navigator.pop(context);
          },
        ),
      ),
      body: BeatsList(),
    );
  }
}

class BeatsList extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return OutletViewPage(
      outletName: "Sample Outlet",
      outletId: 0,
      beatId: 0,
    ); // Replace with your data
  }
}
