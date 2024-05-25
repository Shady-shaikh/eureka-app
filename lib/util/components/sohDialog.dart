import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:eureka/util/constants.dart' as constants;
import 'package:http/http.dart' as http;
import 'package:eureka/global_helper.dart';

class SohDialog extends StatefulWidget {
  final int outletID;

  const SohDialog({super.key, required this.outletID});
  @override
  _SohDialogState createState() => _SohDialogState();
}

class _SohDialogState extends State<SohDialog> {
  final globalHelper = GlobalHelper();
  List<Map<String, dynamic>> prevSohs = [];
  bool isDataLoaded = false;
  final TextEditingController itemDescriptionController =
      TextEditingController();
  final TextEditingController skuController = TextEditingController();

  final TextEditingController qtyController = TextEditingController();

  Future<void> _updateSoh() async {
    final url =
        '${constants.apiBaseURL}/save_soh'; // Replace with your PHP API endpoint

    // Create a multipart request
    var request = http.MultipartRequest('POST', Uri.parse(url));

    // Add other form data
    request.fields['outlet_id'] = widget.outletID.toString();
    request.fields['quantity'] = qtyController.text;
    request.fields['sku'] = skuController.text;
    request.fields['item_desc'] = itemDescriptionController.text;

    // Send the request
    try {
      request.fields['posted_data'] = jsonEncode({
        'outlet_id': widget.outletID,
        'quantity': qtyController.text,
        'sku': skuController.text,
        'item_desc': itemDescriptionController.text,
      });
      var response = await request.send();

      // Check the response
      if (response.statusCode == 200) {
        // Successful upload
        print('success');
      } else {
        // Handle errors
        print('Failed to upload image. Status code: ${response.statusCode}');
        // print(await response.stream.bytesToString());
      }
    } catch (e) {
      print('Exception during image upload: $e');
    }
  }

  void _showSuggestions(
      Map<String, dynamic> response, Function updateControllers) {
    List<Map<String, dynamic>> itemList =
        List<Map<String, dynamic>>.from(response['item']);
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Item Suggestions'),
          content: Container(
            height: 250.0,
            child: SingleChildScrollView(
              child: Column(
                children: itemList.map((item) {
                  return Column(
                    children: [
                      ListTile(
                        title: Text(item['name'],style: TextStyle(fontSize: 13),),
                        onTap: () {
                          updateControllers(item);
                          Navigator.pop(context);
                        },
                      ),
                      Divider(), // Divider after each ListTile
                    ],
                  );
                }).toList(),
              ),
            ),
          ),
        );
      },
    );
  }

  void _onDescriptionChanged(String value) async {
    if (value.isNotEmpty && value.length >= 3) {
      if (value == itemDescriptionController.text) {
        final response =
            await globalHelper.get_item_auto(value, widget.outletID);
        _showSuggestions(response, (item) {
          itemDescriptionController.text = item['name'];
          skuController.text = item['sku'];
        });
      }
      ;
    }
  }

  @override
  void initState() {
    super.initState();
    initializeData();
  }

  Future<void> initializeData() async {
    try {
      final response = await globalHelper.get_previous_soh(widget.outletID);
      if (mounted) {
        setState(() {
          prevSohs = List<Map<String, dynamic>>.from(response['previous_soh']);
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
        title: Text('SOH'),
        content: SingleChildScrollView(
            child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
              TextFormField(
                controller: itemDescriptionController,
                onFieldSubmitted: _onDescriptionChanged,
                decoration: InputDecoration(
                  labelText: 'Item Name',
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter Item Name';
                  }
                  return null;
                },
              ),
              TextFormField(
                controller: qtyController,
                keyboardType: TextInputType.number,
                decoration: InputDecoration(
                  labelText: 'Quantity',
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter quantity';
                  }
                  return null;
                },
              ),
              SizedBox(height: 16.0),
              // Save Button
              Center(
                child: ElevatedButton(
                  onPressed: () async {
                    _updateSoh();
                    constants.Notification('SOH Updated');
                    Navigator.pop(context);
                  },
                  child: Text('Save'),
                ),
              ),
              SizedBox(height: 14.0),
              // List of cards showing previous comments

              if (!isDataLoaded)
                Center(child: CircularProgressIndicator())
              else if (prevSohs.isNotEmpty)
                Container(
                  height: 200,
                  child: SingleChildScrollView(
                    child: Column(
                      children: [
                        Text('Previous SOH:'),
                        SizedBox(height: 8.0),
                        for (var i = 0; i < prevSohs.length; i++)
                          Card(
                            elevation: 3, // Add elevation for a shadow effect
                            margin: EdgeInsets.symmetric(
                                horizontal: 16, vertical: 8),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: ListTile(
                              title: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    prevSohs[i]['item_desc'],
                                    style: TextStyle(
                                      fontWeight: FontWeight.bold,
                                      fontSize: 12,
                                    ),
                                  ),
                                  SizedBox(height: 4),
                                  Text(
                                    'SKU: ${prevSohs[i]['sku']}',
                                    style: TextStyle(
                                      color: Colors.grey,
                                      fontSize: 10,
                                    ),
                                  ),
                                  SizedBox(height: 4),
                                  Text(
                                    'Date: ${constants.formatDate(prevSohs[i]['date'])}',
                                    style: TextStyle(
                                      color: Colors.grey,
                                      fontSize: 10,
                                    ),
                                  ),
                                ],
                              ),
                              trailing: Container(
                                padding: EdgeInsets.all(8),
                                decoration: BoxDecoration(
                                  shape: BoxShape.circle,
                                  color:
                                      Colors.blue, // Change the color as needed
                                ),
                                child: Text(
                                  prevSohs[i]['quantity'],
                                  style: TextStyle(
                                    fontSize: 15,
                                    color: Colors
                                        .white, // Change the text color as needed
                                  ),
                                ),
                              ),
                            ),
                          ),
                      ],
                    ),
                  ),
                ),
            ])));
  }
}
