import 'dart:io';
import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:eureka/util/constants.dart' as constants;
import 'package:image_picker/image_picker.dart';
import 'package:http/http.dart' as http;

class OutstandingDialog extends StatefulWidget {
  final int outletID;

  const OutstandingDialog({super.key, required this.outletID});
  @override
  _OutstandingDialogState createState() => _OutstandingDialogState();
}

class _OutstandingDialogState extends State<OutstandingDialog> {

  String paymentType = 'cash';
  bool showChequeOptions = false;
  TextEditingController amountController = TextEditingController();
  File? _chequeImage;
  List<File> _chequeImages = [];

  Future<void> _uploadImage() async {
    final url =
        '${constants.apiBaseURL}/update_outstanding'; // Replace with your PHP API endpoint

    // Create a multipart request
    var request = http.MultipartRequest('POST', Uri.parse(url));

    // Add other form data
    request.fields['outlet_id'] = widget.outletID.toString();
    request.fields['amount'] = amountController.text;
    request.fields['payment_option'] = paymentType;

    if (_chequeImage != null) {
      // Add the image file to the request
      request.files.add(await http.MultipartFile.fromPath(
          'cheque_image', _chequeImage!.path));
    }

    if (_chequeImages.isNotEmpty) {
      for (var i = 0; i < _chequeImages.length; i++) {
        request.files.add(await http.MultipartFile.fromPath(
            'cheque_images[]', _chequeImages[i].path));
      }
    }

    // Send the request
    try {
      request.fields['posted_data'] = jsonEncode({
        'outlet_id': widget.outletID,
        'amount': amountController.text,
        'payment_option': paymentType,
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

  Future<void> _getImageFromGallery() async {
    List<XFile> pickedFiles = await ImagePicker().pickMultiImage();

    if (pickedFiles.isNotEmpty) {
      List<File> imageFiles =
          pickedFiles.map((pickedFile) => File(pickedFile.path)).toList();

      setState(() {
        _chequeImages = imageFiles;
      });
    }
  }

  Future<void> _captureImage() async {
    final pickedFile =
        await ImagePicker().pickImage(source: ImageSource.camera);

    if (pickedFile != null) {
      setState(() {
        _chequeImage = File(pickedFile.path);
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text('Outstanding'),
      content: SingleChildScrollView(
        child: Column(mainAxisSize: MainAxisSize.min, children: [
          // Input field for entering amount

          TextField(
            controller: amountController,
            keyboardType: TextInputType.number,
            decoration: InputDecoration(
              border: OutlineInputBorder(),
              labelText: 'Enter Amount',
            ),
          ),
          SizedBox(height: 16.0),
          // Dropdown for selecting payment type
          DropdownButton<String>(
            value: paymentType,
            onChanged: (String? newValue) {
              setState(() {
                paymentType = newValue!;
                showChequeOptions = paymentType == 'cheque';
              });
            },
            items: <String>['cash', 'cheque', 'upi']
                .map<DropdownMenuItem<String>>((String value) {
              return DropdownMenuItem<String>(
                value: value,
                child: Text(value),
              );
            }).toList(),
          ),

          // Cheque options (upload/capture)
          if (showChequeOptions)
            Column(
              children: [
                SizedBox(height: 8.0),
                ElevatedButton(
                  onPressed: () async {
                    await showDialog(
                      context: context,
                      builder: (BuildContext context) {
                        return AlertDialog(
                          title: Text('Choose option'),
                          content: Column(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              ElevatedButton(
                                onPressed: () {
                                  Navigator.pop(context); // Close the dialog
                                  _getImageFromGallery(); // Open gallery
                                },
                                child: Text('Pick from gallery'),
                              ),
                              SizedBox(height: 8),
                              ElevatedButton(
                                onPressed: () {
                                  Navigator.pop(context); // Close the dialog
                                  _captureImage(); // Open camera
                                },
                                child: Text('Capture from camera'),
                              ),
                            ],
                          ),
                        );
                      },
                    );
                  },
                  child: Text('Upload/Capture Cheque Image'),
                ),
                if (_chequeImage != null) Image.file(_chequeImage!),
                if (_chequeImages.isNotEmpty)
                  Column(
                    children: _chequeImages
                        .map((image) => Padding(
                          padding: const EdgeInsets.all(8.0),
                          child: Image.memory(image.readAsBytesSync()),
                        ))
                        .toList(),
                  ),
              ],
            ),

          SizedBox(height: 16.0),

          // Submit button
          ElevatedButton(
            onPressed: () async {
              if (amountController.text != '') {
                // Handle submit action
                await _uploadImage();
                constants.Notification('Payment Updated');
                Navigator.pop(context);
              }
            },
            child: Text('Receive'),
          ),

          // List of cards showing previous comments
        ]),
      ),
    );
  }
}
