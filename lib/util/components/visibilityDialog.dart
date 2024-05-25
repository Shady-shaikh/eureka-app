import 'dart:io';
import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:eureka/util/constants.dart' as constants;
import 'package:image_picker/image_picker.dart';
import 'package:http/http.dart' as http;

class VisibilityDialog extends StatefulWidget {
  final int outletID;

  const VisibilityDialog({super.key, required this.outletID});
  @override
  _VisibilityDialogState createState() => _VisibilityDialogState();
}

class _VisibilityDialogState extends State<VisibilityDialog> {
  bool isDocumentProper = false;
  String rentalType = 'start';

  File? _chequeImage;
  List<File> _chequeImages = [];

  Future<void> _uploadImage() async {
    final url =
        '${constants.apiBaseURL}/update_visibility'; // Replace with your PHP API endpoint

    // Create a multipart request
    var request = http.MultipartRequest('POST', Uri.parse(url));

    // Add other form data
    request.fields['outlet_id'] = widget.outletID.toString();
    request.fields['rental_type'] = rentalType;

    if (_chequeImage != null) {
      // Add the image file to the request
      request.files.add(await http.MultipartFile.fromPath(
          'visibility_image', _chequeImage!.path));
    }

    if (_chequeImages.isNotEmpty) {
      for (var i = 0; i < _chequeImages.length; i++) {
        request.files.add(await http.MultipartFile.fromPath(
            'visibility_images[]', _chequeImages[i].path));
      }
    }

    // Send the request
    try {
      request.fields['posted_data'] = jsonEncode({
        'outlet_id': widget.outletID,
        'rental_type': rentalType,
      });
      var response = await request.send();

      // Check the response
      if (response.statusCode == 200) {
        // Successful upload
        print('uploaded');
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
      title: Text('Visibility'),
      content: SingleChildScrollView(
        child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Styled image upload button
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
                    child: Text('Upload/Capture Images'),
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

              Row(
                children: [
                  Text(
                    'Rental: ',
                    style: TextStyle(fontSize: 20),
                  ),
                  SizedBox(width: 16),
                  DropdownButton<String>(
                    value: rentalType,
                    onChanged: (String? newValue) {
                      setState(() {
                        rentalType = newValue!;
                      });
                    },
                    items: <String>['start', 'stop', 'continue']
                        .map<DropdownMenuItem<String>>((String value) {
                      return DropdownMenuItem<String>(
                        value: value,
                        child: Text(value),
                      );
                    }).toList(),
                  ),
                ],
              ),
            ]),
      ),
      actions: [
        ElevatedButton(
          onPressed: () async {
            await _uploadImage();
            constants.Notification('Visibility Updated');
            Navigator.pop(context);
          },
          child: Text('Submit'),
        ),
      ],
    );
  }
}
