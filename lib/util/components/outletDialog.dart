import 'dart:io';
import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:eureka/util/constants.dart' as constants;
import 'package:image_picker/image_picker.dart';
import 'package:http/http.dart' as http;
import 'package:geolocator/geolocator.dart';

class OutletDialog extends StatefulWidget {
  final int outletID;
  final int beatId;
  final double latitude;
  final double longitude;

  const OutletDialog(
      {super.key,
      required this.outletID,
      required this.beatId,
      required this.latitude,
      required this.longitude});
  @override
  _OutletDialogState createState() => _OutletDialogState();
}

class _OutletDialogState extends State<OutletDialog> {
  bool isDocumentProper = false;

  File? _chequeImage;
  List<File> _chequeImages = [];

  Future<Map<String, double>> _getUserLocation() async {
    try {
      var status = await Geolocator.checkPermission();
      if (status == LocationPermission.denied) {
        status = await Geolocator.requestPermission();
        if (status != LocationPermission.whileInUse &&
            status != LocationPermission.always) {
          // Handle denied or restricted permission
          print(
              "User denied or restricted permissions to access the device's location.");
          return {
            "latitude": 0.0,
            "longitude": 0.0,
          };
        }
      }

      final position = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.best,
        forceAndroidLocationManager: true,
      );

      print(position);

      return {
        "latitude": position.latitude,
        "longitude": position.longitude,
      };
    } catch (e) {
      print("Error getting user location: $e");
      return {
        "latitude": 0.0,
        "longitude": 0.0,
      };
    }
  }

  Future<void> _uploadImage() async {
    final userLocation = await _getUserLocation();
    // validate range
    // Calculate the distance between the user's location and the fixed location
    final distance = Geolocator.distanceBetween(
      userLocation["latitude"]!,
      userLocation["longitude"]!,
      widget.latitude,
      widget.longitude,
    );

    // if (distance <= 100) {
    final url =
        '${constants.apiBaseURL}/update_outlet_image'; // Replace with your PHP API endpoint

    // Create a multipart request
    var request = http.MultipartRequest('POST', Uri.parse(url));

    // Add other form data
    request.fields['outlet_id'] = widget.outletID.toString();
    request.fields['beat_id'] = widget.beatId.toString();
    request.fields['latitude'] = userLocation['latitude'].toString();
    request.fields['longitude'] = userLocation['longitude'].toString();

    if (_chequeImage != null) {
      // Add the image file to the request
      request.files.add(await http.MultipartFile.fromPath(
          'outlet_image', _chequeImage!.path));
    }

    if (_chequeImages.isNotEmpty) {
      for (var i = 0; i < _chequeImages.length; i++) {
        request.files.add(await http.MultipartFile.fromPath(
            'outlet_images[]', _chequeImages[i].path));
      }
    }

    // print(_chequeImages);


    try {
      request.fields['posted_data'] = jsonEncode({
        'outlet_id': widget.outletID,
        'beat_id': widget.beatId,
        'latitude': userLocation['latitude'].toString(),
        'longitude': userLocation['longitude'].toString(),
      });
      var response = await request.send();
      
      // var responseData = await response.stream.bytesToString();
      // print(responseData);

      // Check the response
      if (response.statusCode == 200) {
        // Successful upload
        // print('uploaded');
        constants.Notification("Location Updated");
      } else {
        // Handle errors
        print('Failed to upload image. Status code: ${response.statusCode}');
      }
    } catch (e) {
      print('Exception during image upload: $e');
    }
    // } else {
    // User is not within 100 meters of the fixed location
    // }
  }

  void _showDistanceOutOfRangeDialog() {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          content: Text("You are not within 100 meters of outlet"),
        );
      },
    );
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
      title: Text('Outlet Image'),
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
            ]),
      ),
      actions: [
        ElevatedButton(
          onPressed: () async {
            await _uploadImage();
            Navigator.pop(context);
          },
          child: Text('Submit'),
        ),
      ],
    );
  }
}
