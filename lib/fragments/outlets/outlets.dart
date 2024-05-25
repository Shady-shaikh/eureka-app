// ignore_for_file: prefer_const_constructors, non_constant_identifier_names, use_build_context_synchronously, avoid_print

import 'package:eureka/fragments/outlets/outletForm.dart';
import 'package:flutter/material.dart';
import 'package:eureka/global_helper.dart';
import 'package:eureka/timer.dart';
import 'package:eureka/util/constants.dart' as constants;

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Outlets(),
    );
  }
}

class Outlets extends StatefulWidget {
  @override
  State<Outlets> createState() => _OutletsState();
}

class _OutletsState extends State<Outlets> {
  bool isDataLoaded = false;
  final globalHelper = GlobalHelper();
  List<Map<String, dynamic>> outlets = [];

  @override
  void initState() {
    super.initState();
    timerController = TimerController(
      duration: Duration(seconds: constants.refTime),
      callback: initializeData,
    )..startPeriodic();
    initializeData();
  }

  void initializeData() async {
    try {
      final response = await globalHelper.outlets();
      if (mounted) {
        setState(() {
          outlets = List<Map<String, dynamic>>.from(response['outlets']);
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
        title: const Text("Outlets"),
        centerTitle: true,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Padding(
          padding: EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              if (!isDataLoaded)
                Center(child: CircularProgressIndicator())
              else if (outlets.isEmpty)
                Center(
                  child: Text('No Outlets available.',
                      style: TextStyle(fontSize: 16.0)),
                )
              else
                Expanded(
                  child: ListView.builder(
                    itemCount: outlets.length,
                    itemBuilder: (context, index) {
                      var outlet = outlets[index];
                      return OutletCard(
                        name: outlet['bp_name'],
                        onEdit: () async {
                          final itemData = await globalHelper
                              .view_outlet(outlet['business_partner_id']);

                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => OutletForm(
                                isEditing: true,
                                itemData: itemData,
                              ),
                            ),
                          );
                        },
                        onDelete: () async {
                          // Handle delete action
                          // Handle delete action

                          // Show a confirmation dialog before proceeding with deletion
                          bool confirmDelete = await showDialog(
                            context: context,
                            builder: (BuildContext context) {
                              return AlertDialog(
                                title: Text('Confirm Delete'),
                                content: Text(
                                    'Are you sure you want to delete this Item?'),
                                actions: <Widget>[
                                  TextButton(
                                    onPressed: () {
                                      // User clicked "Cancel"
                                      Navigator.of(context).pop(false);
                                    },
                                    child: Text('Cancel'),
                                  ),
                                  TextButton(
                                    onPressed: () {
                                      // User clicked "Delete"
                                      Navigator.of(context).pop(true);
                                    },
                                    child: Text('Delete'),
                                  ),
                                ],
                              );
                            },
                          );

                          // Proceed with deletion only if the user confirmed
                          if (confirmDelete == true) {
                            var res = await globalHelper
                                .delete_outlet(outlet['business_partner_id']);

                            if (res['success'] != null) {
                              constants.Notification(res['success']);
                            }
                          }
                        },
                      );
                    },
                  ),
                ),
            ],
          ),
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () async {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => OutletForm(),
            ),
          );
        },
        child: Icon(Icons.add),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
    );
  }
}

class OutletCard extends StatelessWidget {
  final String name;
  final VoidCallback? onEdit;
  final VoidCallback? onDelete;

  OutletCard({
    required this.name,
    this.onEdit,
    this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: EdgeInsets.symmetric(vertical: 8.0),
      child: Column(
        children: [
          Container(
            decoration: BoxDecoration(
              color: Colors.grey[200],
              borderRadius: BorderRadius.all(Radius.circular(16.0)),
            ),
            padding: EdgeInsets.all(16.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  name,
                  style: TextStyle(
                    fontSize: 18.0,
                    fontWeight: FontWeight.w400,
                  ),
                ),
                Row(
                  children: [
                    IconButton(
                      icon: Icon(Icons.edit),
                      onPressed: onEdit,
                    ),
                    IconButton(
                      icon: Icon(Icons.delete),
                      onPressed: onDelete,
                    ),
                  ],
                ),
              ],
            ),
          ),
          // Add additional content for the card body if needed
        ],
      ),
    );
  }
}
