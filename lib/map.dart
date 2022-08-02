// User interface
import 'package:flutter/material.dart';
// Location services
import 'package:geolocator/geolocator.dart';
// Map
import 'dart:async';
import 'package:flutter/services.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

class Map extends StatefulWidget {
  const Map({Key? key}) : super(key: key);

  @override
  State<Map> createState() => _MapState();
}

class _MapState extends State<Map> {
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
      body: GoogleMap(
        onMapCreated: _onMapCreated,
        initialCameraPosition: _initialCameraPosition!,
        minMaxZoomPreference: MinMaxZoomPreference(12, null),
        myLocationButtonEnabled: false,
        zoomControlsEnabled: false,
        mapToolbarEnabled: false,
        myLocationEnabled: true,
        compassEnabled: false,
      ),
    );
  }
}
