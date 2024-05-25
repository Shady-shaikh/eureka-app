import 'dart:convert';
import 'dart:async';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:eureka/global_helper.dart';
import 'package:eureka/util/constants.dart' as constants;

class CommentsDialog extends StatefulWidget {
  final int outletID;

  const CommentsDialog({super.key, required this.outletID});
  @override
  _CommentsDialogState createState() => _CommentsDialogState();
}

class _CommentsDialogState extends State<CommentsDialog> {
  bool isDataLoaded = false;
  TextEditingController commentController = TextEditingController();
  final globalHelper = GlobalHelper();
  List<Map<String, dynamic>> prevComments = [];

  Future<void> _saveComments() async {
    final url =
        '${constants.apiBaseURL}/save_comments'; // Replace with your PHP API endpoint
    var request = http.MultipartRequest('POST', Uri.parse(url));

    // Add other form data
    request.fields['outlet_id'] = widget.outletID.toString();
    request.fields['comments'] = commentController.text;
    // Send the request
    try {
      request.fields['posted_data'] = jsonEncode({
        'outlet_id': widget.outletID,
        'comments': commentController.text,
      });
      var response = await request.send();

      // Check the response
      if (response.statusCode == 200) {
        // Successful upload
      } else {
        // Handle errors
        print('Failed to upload image. Status code: ${response.statusCode}');
        // print(await response.stream.bytesToString());
      }
    } catch (e) {
      print('Exception during image upload: $e');
    }
  }

  @override
  void initState() {
    super.initState();
    initializeData();
  }

  Future<void> initializeData() async {
    try {
      final response =
          await globalHelper.get_previous_comments(widget.outletID);
      if (mounted) {
        setState(() {
          prevComments =
              List<Map<String, dynamic>>.from(response['previous_comments']);
        });
        isDataLoaded = true;
      }
    } catch (e) {
      print('Error initializing data: $e');
    } finally {
      await Future.delayed(Duration(seconds: constants.delayedTime));
    }
  }

  @override
  void dispose() {
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text('Comments'),
      content: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Input field for entering comments
            TextField(
              controller: commentController,
              decoration: InputDecoration(
                border: OutlineInputBorder(),
                labelText: 'Enter Comments',
              ),
            ),
            SizedBox(height: 16.0),
            ElevatedButton(
              onPressed: () async {
                await _saveComments();
                constants.Notification('Commented Successfully');
                Navigator.pop(context);
              },
              child: Text('Submit'),
            ),
            SizedBox(height: 14.0),
            // List of cards showing previous comments

            if (!isDataLoaded)
              Center(child: CircularProgressIndicator())
            else if (prevComments.isNotEmpty)
              Container(
                height: 200,
                child: SingleChildScrollView(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('Previous Comments:'),
                      SizedBox(height: 8.0),
                      for (var i = 0; i < prevComments.length; i++)
                        Card(
                          child: ListTile(
                            title: Text(prevComments[i]['comments']),
                            subtitle: Text(
                              '${constants.formatDateTime(prevComments[i]['date'])}',
                              style: TextStyle(color: Colors.grey),
                            ),
                          ),
                        ),
                    ],
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}
