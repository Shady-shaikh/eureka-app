import 'dart:async';
import 'package:eureka/util/components/outletDialog.dart';
import 'package:flutter/material.dart';
import 'package:eureka/fragments/daysplan/outletView.dart';
import 'package:eureka/global_helper.dart';
import 'package:eureka/timer.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:eureka/location.dart';
import 'package:eureka/util/constants.dart' as constants;

void main() => runApp(MyApp());

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) => MaterialApp(
        home: OutletsPage(
          beat_id: 0,
        ),
      );
}

class OutletsPage extends StatelessWidget {
  final int beat_id;
  const OutletsPage({required this.beat_id});
  @override
  Widget build(BuildContext context) => Scaffold(
        appBar: AppBar(
          title: Text("Outlet Selection"),
          centerTitle: true,
          leading: IconButton(
            icon: Icon(Icons.arrow_back),
            onPressed: () => Navigator.pop(context),
          ),
        ),
        body: OutletsList(beat_id: beat_id),
      );
}

final GlobalKey<_OutletsListState> outletsListKey =
    GlobalKey<_OutletsListState>();

class OutletsList extends StatefulWidget {
  final int beat_id;
  const OutletsList({required this.beat_id});
  @override
  _OutletsListState createState() => _OutletsListState();
}

class _OutletsListState extends State<OutletsList> {
  bool isDataLoaded = false;
  final globalHelper = GlobalHelper();
  List<Map<String, dynamic>> outlets = [];
  List<Map<String, dynamic>> selectedOutlet = [];

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
      final response = await globalHelper.get_outlets(widget.beat_id);
      if (mounted) {
        setState(() {
          outlets = List<Map<String, dynamic>>.from(response['outlets']);
          selectedOutlet =
              List<Map<String, dynamic>>.from(response['selected_outlet']);
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

  static int isActionSelected(dynamic beat, List<dynamic> selectedOutlet) {
    // Check if is_submit flag is 1 for the same beat and outlet
    // print(selectedOutlet);
    // print(beat);
    bool isSubmitted = selectedOutlet
        .where((day) =>
            day['outlet_id'].toString() ==
                beat['business_partner_id'].toString() &&
            day['beat_id'].toString() == beat['beat_id'].toString())
        .any((day) => day['is_submit'].toString() == '1');

    // If is_submit flag is 1, return 2 (indicating that it is completed)
    if (isSubmitted) {
      return 2;
    } else {
      // If is_submit flag is not 1, check for other actions (start or skip)
      bool isStart = selectedOutlet
          .where((day) =>
              day['outlet_id'].toString() ==
                  beat['business_partner_id'].toString() &&
              day['beat_id'].toString() == beat['beat_id'].toString())
          .any((day) => day['is_start'].toString() == '1');

      bool isSkip = selectedOutlet
          .where((day) =>
              day['outlet_id'].toString() ==
                  beat['business_partner_id'].toString() &&
              day['beat_id'].toString() == beat['beat_id'].toString())
          .any((day) => day['is_skip'].toString() == '1');

      // If is_start is 1, return 1 (indicating that it is started)
      if (isStart) {
        return 1;
      }

      // If is_skip is 1, return 0 (indicating that it is skipped)
      if (isSkip) {
        return -1;
      }

      // If neither is_start nor is_skip is 1, return -1
      return 0;
    }
  }

  void _showOutletDialog(BuildContext context, outletId, latitude, longitude) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return OutletDialog(
          outletID: outletId,
          beatId: widget.beat_id,
          latitude: double.parse(latitude),
          longitude: double.parse(longitude),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        if (!isDataLoaded)
          Center(child: CircularProgressIndicator())
        else if (outlets.isEmpty)
          Center(
              child: Text('No outlets available.',
                  style: TextStyle(fontSize: 16.0)))
        else
          Expanded(
            child: ListView.builder(
              padding: EdgeInsets.all(16.0),
              itemCount: outlets.length,
              itemBuilder: (context, index) {
                final beat = outlets[index];
                return BeatCard(
                  beatName: beat['bp_name'],
                  onStartPressed: () async {
                    if (beat['outlet_image'] == null ||
                        beat['outlet_image'] == '') {
                      _showOutletDialog(
                          context,
                          beat['business_partner_id'],
                          beat['latitude'] != null
                              ? beat['latitude'].toString()
                              : '0.0',
                          beat['longitude'] != null
                              ? beat['longitude'].toString()
                              : '0.0');
                    } else {
                      var flag = isActionSelected(beat, selectedOutlet);
                      // Outlet is not completed, perform start action
                      if (flag != 1) {
                        await _updateSelection(
                            context,
                            beat['business_partner_id'],
                            beat['beat_id'],
                            1,
                            0,
                            '',
                            0);
                      }

                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => OutletViewPage(
                            outletName: beat['bp_name'],
                            outletId: beat['business_partner_id'],
                            beatId: int.parse(beat['beat_id']),
                          ),
                        ),
                      );
                    }
                  },
                  onSkipPressed: () {
                    // Outlet is not completed, show skip dialog
                    _showSkipDialog(
                        context,
                        beat['bp_name'],
                        beat['business_partner_id'],
                        int.parse(beat['beat_id']));
                  },
                  isCompleted: isActionSelected(beat, selectedOutlet),
                );
              },
            ),
          ),
      ],
    );
  }

  Future<void> _updateSelection(BuildContext context, outlet_id, beat_id,
      int action, int skip, String reason, int submit) async {
    var sharedPref = await SharedPreferences.getInstance();
    var user_id = sharedPref.getInt('user_id');
    var postedData = {
      'user_id': user_id,
      'outlet_id': outlet_id,
      'beat_id': beat_id,
      'is_start': action,
      'is_skip': skip,
      'skip_reason': reason,
      'is_submit': submit,
    };
    showDialog(
      context: context,
      builder: (BuildContext context) =>
          Center(child: CircularProgressIndicator()),
    );
    var res = await globalHelper.update_outlet_Selection(postedData);

    if (res['success'] != null) {
      constants.Notification(res['success']);
      Navigator.pop(context);
      Navigator.pop(context);
    } else if (res['error'] != null) {
      constants.Notification(res['error']);
      Navigator.pop(context);
    }
  }

  void _showSkipDialog(
      BuildContext context, String beatName, int outlet_id, int beat_id) async {
    String skipReason = '';

    await showDialog(
      context: context,
      builder: (BuildContext context) => AlertDialog(
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
              await _updateSelection(
                  context, outlet_id, beat_id, 0, 1, skipReason, 0);
            },
            child: Text('Skip'),
          ),
        ],
      ),
    );
  }
}

class BeatCard extends StatelessWidget {
  final String beatName;
  final VoidCallback? onStartPressed;
  final VoidCallback? onSkipPressed;
  final int isCompleted;

  BeatCard({
    required this.beatName,
    this.onStartPressed,
    this.onSkipPressed,
    required this.isCompleted,
  });

  @override
  Widget build(BuildContext context) => Card(
        margin: EdgeInsets.only(bottom: 16.0),
        child: ListTile(
          title: Text(beatName),
          trailing: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              if (isCompleted == 0 || isCompleted == 1)
                ElevatedButton(onPressed: onStartPressed, child: Text('Start')),
              if (isCompleted == 0) SizedBox(width: 8.0),
              if (isCompleted == 0)
                ElevatedButton(onPressed: onSkipPressed, child: Text('Skip')),
              if (isCompleted == 2) Text('Completed'),
              if (isCompleted == -1) SizedBox(width: 8.0),
              if (isCompleted == -1) Text('Skipped'),
            ],
          ),
        ),
      );
}
