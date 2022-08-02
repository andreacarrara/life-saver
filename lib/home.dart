// User interface
import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
// Location services
import 'package:geolocator/geolocator.dart';
// Map
import 'dart:async';
import 'package:flutter/services.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
// Widgets
import 'map.dart';
import 'control-button.dart';

class Home extends StatefulWidget {
  const Home({Key? key}) : super(key: key);

  @override
  State<Home> createState() => _HomeState();
}

class _HomeState extends State<Home> {
  Completer<GoogleMapController> _mapController = Completer();
  CameraPosition? _initialCameraPosition; // To be set later

  @override
  void initState() {
    super.initState();
    _setInitiaPosition();
  }

  Future<void> _setInitiaPosition() async {
    // Request location permission
    LocationPermission permission = await Geolocator.requestPermission();
    // If location permission has been granted
    if (permission == LocationPermission.whileInUse) {
      // Get initial position
      Position initialPosition = await Geolocator.getCurrentPosition();
      // Set initial position
      setState(() {
        _initialCameraPosition = CameraPosition(
          target: LatLng(
            initialPosition.latitude,
            initialPosition.longitude,
          ),
          zoom: 16,
        );
      });
    }
  }

  void _onMapCreated(GoogleMapController controller) {
    _mapController.complete(controller);
    // Style map
    rootBundle.loadString('assets/mapStyle.json').then((String mapStyle) {
      controller.setMapStyle(mapStyle);
    });
  }

  Future<void> _goToCurrentPosition() async {
    // Get current position
    Position currentPosition = await Geolocator.getCurrentPosition();
    // Animate map to current position
    GoogleMapController mapController = await _mapController.future;
    mapController.animateCamera(
      CameraUpdate.newCameraPosition(
        CameraPosition(
          target: LatLng(
            currentPosition.latitude,
            currentPosition.longitude,
          ),
          zoom: 16,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    // If location permission has not been granted
    if (_initialCameraPosition == null) {
      return Scaffold(
        body: Center(
          child: Text(
            'Grant location permission',
          ),
        ),
      );
    }
    // If location permission has been granted
    return Scaffold(
      body: Stack(
        children: <Widget>[
          // Map
          Map(
            onMapCreated: _onMapCreated,
            initialCameraPosition: _initialCameraPosition!,
          ),
          // Info button
          Positioned(
            top: 35,
            right: 15,
            child: ControlButton(
              onPressed: () {},
              icon: CupertinoIcons.info_circle_fill,
            ),
          ),
          // My location button
          Positioned(
            top: 85,
            right: 15,
            child: ControlButton(
              onPressed: _goToCurrentPosition,
              icon: CupertinoIcons.location_circle_fill,
            ),
          ),
        ],
      ),
    );
  }
}
