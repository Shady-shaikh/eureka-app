import 'dart:async';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:eureka/global_helper.dart';
import 'package:eureka/fragments/daysplan/outlets.dart';
import 'package:eureka/timer.dart';
import 'package:eureka/location.dart';
import 'package:eureka/util/constants.dart' as constants;

void main() {
  runApp(MaterialApp(home: BeatsPage()));
}

class BeatsPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Day's Plan"),
        centerTitle: true,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: BeatsList(),
    );
  }
}

class BeatsList extends StatefulWidget {
  @override
  _BeatsListState createState() => _BeatsListState();
}

class _BeatsListState extends State<BeatsList> {
  bool isDataLoaded = false;
  final globalHelper = GlobalHelper();
  List<Map<String, dynamic>> beats = [];
  List<Map<String, dynamic>> daysPlan = [];

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

  void initializeData() async {
    try {
      final response = await globalHelper.get_daily_beats();
      if (mounted) {
        setState(() {
          beats = List<Map<String, dynamic>>.from(response['beats']);
          daysPlan = List<Map<String, dynamic>>.from(response['days_plan']);
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
    return Column(
      children: [
        if (!isDataLoaded)
          Center(child: CircularProgressIndicator())
        else if (beats.isEmpty)
          Center(
            child:
                Text('No plans available.', style: TextStyle(fontSize: 16.0)),
          )
        else
          Expanded(
            child: ListView.builder(
              padding: EdgeInsets.all(16.0),
              itemCount: beats.length,
              itemBuilder: (context, index) {
                final beat = beats[index]['get_beat'];
                final isStart = daysPlan.any((day) =>
                    day['beat_id'].toString() == beat['beat_id'].toString() &&
                    day['is_start'].toString() == '1');
                final isSkipped = daysPlan.any((day) =>
                    day['beat_id'].toString() == beat['beat_id'].toString() &&
                    day['is_skip'].toString() == '1');

                return BeatCard(
                  beatName: beat['beat_name'],
                  onStartPressed: isSkipped
                      ? null
                      : () async {
                          var sharedPref =
                              await SharedPreferences.getInstance();
                          var user_id = sharedPref.getInt('user_id');
                          var postedData = {
                            'user_id': user_id,
                            'beat_id': beat['beat_id'],
                            'is_start': 1
                          };
                          // Outlet is not completed, perform start action
                          if (isStart != 1) {
                            await globalHelper.update_days_plan(postedData);
                          }

                          // final response =
                          //     await globalHelper.get_outlets(beat['beat_id']);
                          Navigator.push(
                              context,
                              MaterialPageRoute(
                                  // settings: RouteSettings(arguments: response),
                                  builder: (context) =>
                                      OutletsPage(beat_id: beat['beat_id'])));
                        },
                  onSkipPressed: isStart || isSkipped
                      ? null
                      : () => _showSkipDialog(
                          context, beat['beat_name'], beat['beat_id']),
                );
              },
            ),
          ),
      ],
    );
  }

  void _showSkipDialog(
      BuildContext context, String beatName, int beat_id) async {
    String skipReason = '';
    await showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Skip : $beatName'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              TextField(
                onChanged: (value) => skipReason = value,
                decoration: InputDecoration(hintText: 'Enter reason'),
              ),
            ],
          ),
          actions: [
            ElevatedButton(
              onPressed: () async {
                var sharedPref = await SharedPreferences.getInstance();
                var user_id = sharedPref.getInt('user_id');
                var postedData = {
                  'user_id': user_id,
                  'beat_id': beat_id,
                  'is_skip': 1,
                  'skip_reason': skipReason
                };

                showDialog(
                  context: context,
                  builder: (BuildContext context) =>
                      Center(child: CircularProgressIndicator()),
                );
                var res = await globalHelper.update_days_plan(postedData);

                if (res['success'] != null) {
                  constants.Notification(res['success']);
                  Navigator.pop(context);
                  Navigator.pop(context);
                } else if (res['error'] != null) {
                  constants.Notification(res['error']);
                  Navigator.pop(context);
                }
              },
              child: Text('Skip'),
            ),
          ],
        );
      },
    );
  }
}

class BeatCard extends StatelessWidget {
  final String beatName;
  final VoidCallback? onStartPressed;
  final VoidCallback? onSkipPressed;

  BeatCard({required this.beatName, this.onStartPressed, this.onSkipPressed});

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: EdgeInsets.only(bottom: 16.0),
      child: ListTile(
        title: Text(beatName),
        trailing: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (onStartPressed != null)
              ElevatedButton(onPressed: onStartPressed!, child: Text('Start')),
            if (onSkipPressed != null) SizedBox(width: 8.0),
            if (onSkipPressed != null)
              ElevatedButton(onPressed: onSkipPressed!, child: Text('Skip')),
            if (onSkipPressed == null && onStartPressed == null)
              SizedBox(width: 8.0),
            if (onSkipPressed == null && onStartPressed == null)
              Text('Skipped'),
          ],
        ),
      ),
    );
  }
}
