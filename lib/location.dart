import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';

class LocationService {
  static Future<void> checkLocationPermission(BuildContext context) async {
    bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
    while (!serviceEnabled) {
      await showDialog(
        context: context,
        barrierDismissible: false,
        builder: (BuildContext context) {
          return AlertDialog(
            title: Text("Location Service Required"),
            content: Text("Please enable location service to use this application."),
            actions: [
              TextButton(
                onPressed: () async {
                  Navigator.pop(context);
                  await Geolocator.openLocationSettings();
                  // Check again if location services are enabled after returning from settings
                  serviceEnabled = await Geolocator.isLocationServiceEnabled();
                  if (serviceEnabled) {
                    Navigator.pop(context); // Close the AlertDialog if location services are enabled
                  }
                },
                child: Text("Enable Location"),
              ),
            ],
          );
        },
      );

      // Check again if location services are enabled after returning from settings
      serviceEnabled = await Geolocator.isLocationServiceEnabled();
    }

    LocationPermission permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) {
        showDialog(
          context: context,
          barrierDismissible: false,
          builder: (BuildContext context) {
            return AlertDialog(
              title: Text("Location Permission Required"),
              content: Text("Please enable location access to use this application."),
              actions: [
                TextButton(
                  onPressed: () {
                    Navigator.pop(context);
                  },
                  child: Text("Close"),
                ),
              ],
            );
          },
        );
      }
    }
  }
}