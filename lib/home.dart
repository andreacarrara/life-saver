// Splash screen
import 'package:flutter_native_splash/flutter_native_splash.dart';
// User interface
import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/scheduler.dart';
import 'package:flutter/services.dart';
import 'package:modal_bottom_sheet/modal_bottom_sheet.dart';
// Connection checker
import 'package:internet_connection_checker/internet_connection_checker.dart';
// Settings launcher
import 'package:app_settings/app_settings.dart';
// Location services
import 'package:geolocator/geolocator.dart';
// Google Maps
import 'map.dart';
import 'controllers/map_controller.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
// Firebase Firestore
import 'package:cloud_firestore/cloud_firestore.dart';
// Utilities
import 'utilities/error.dart';
// Buttons
import 'buttons/control_button.dart';
import 'buttons/closest_button.dart';
// Sheets
import 'sheets/add_sheet.dart';
import 'sheets/alert_sheet.dart';
import 'sheets/marker_sheet.dart';

class Home extends StatelessWidget {
  Home({Key? key}) : super(key: key);

  final String internetMessage = 'You are offline. ' +
      'Life Saver will not work if not connected to the internet.';
  final String locationMessage =
      'Your precise location is used to load nearby defibrillators. ' +
          'Life Saver will not work if not granted the permission.';

  @override
  Widget build(BuildContext context) {
    return StreamBuilder(
      // Get updates on internet status
      stream: InternetConnectionChecker().onStatusChange.asBroadcastStream(),
      builder: (context, snapshot) {
        // If internet status is loading
        if (!snapshot.hasData) return Text('Loading');
        // If internet status is disconnected
        if (snapshot.data == InternetConnectionStatus.disconnected) {
          // Remove splash screen
          FlutterNativeSplash.remove();
          return Error(
            message: internetMessage,
            onPressed: AppSettings.openWirelessSettings,
          );
        }
        // Else, get location permission
        return FutureBuilder(
          future: Geolocator.requestPermission(),
          builder: (context, snapshot) {
            // If location permission is loading
            if (!snapshot.hasData) return Text('Loading..');
            // If location permission is denied
            if (snapshot.data == LocationPermission.deniedForever) {
              // Remove splash screen
              FlutterNativeSplash.remove();
              return Error(
                message: locationMessage,
                onPressed: AppSettings.openLocationSettings,
              );
            }
            // Else, get current position
            return FutureBuilder<Position>(
              future: Geolocator.getCurrentPosition(),
              builder: (context, snapshot) {
                // If location permission is loading
                if (!snapshot.hasData) return Text('Loading...');
                // Remove splash screen
                FlutterNativeSplash.remove();
                // Else, show map
                return HomeScreen(
                  initialPosition: snapshot.data!,
                );
              },
            );
          },
        );
      },
    );
  }
}

class HomeScreen extends StatefulWidget {
  final Position initialPosition;

  const HomeScreen({
    Key? key,
    required this.initialPosition,
  }) : super(key: key);

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

// State is required for map animations as they need a ticker provider
class _HomeScreenState extends State<HomeScreen> with TickerProviderStateMixin {
  late final MapController _mapController;
  DocumentSnapshot? _closestMarker;

  void _onMapCreated(GoogleMapController controller) {
    // Initialize map controller
    _mapController = MapController(
      controller: controller,
      tickerProvider: this,
    );
  }

  void _setClosestMarker(DocumentSnapshot document) {
    // Wait for build to finish
    SchedulerBinding.instance.addPostFrameCallback((timeStamp) {
      _closestMarker = document;
    });
  }

  void _onMarkerTapped(LatLng latLng) {
    // Animate to marker position
    _mapController.animateToLatLng(latLng);
  }

  Future<void> _onMyLocationPressed() async {
    // Get current position
    Position currentPosition = await Geolocator.getCurrentPosition();
    // Animate to current position
    _mapController.animateToLatLng(
      LatLng(
        currentPosition.latitude,
        currentPosition.longitude,
      ),
    );
  }

  Future<void> _onAddPressed() async {
    // Get current position
    Position currentPosition = await Geolocator.getCurrentPosition();
    // Animate to current position
    _mapController.animateToLatLng(
      LatLng(
        currentPosition.latitude,
        currentPosition.longitude,
      ),
    );
    // Show add sheet
    showCupertinoModalBottomSheet(
      context: context,
      builder: (context) => AddSheet(
        currentPosition: currentPosition,
      ),
    );
  }

  void _onClosestPressed() {
    // If no closest marker
    if (_closestMarker == null) {
      // Show alert sheet
      showCupertinoModalBottomSheet(
        context: context,
        topRadius: Radius.circular(10),
        builder: (context) => AlertSheet(),
      );
    } else {
      // Read marker position
      GeoPoint geoPoint = _closestMarker!.get('position')['geopoint'];
      // Animate to marker position
      _mapController.animateToLatLng(
        LatLng(
          geoPoint.latitude,
          geoPoint.longitude,
        ),
      );
      // Show marker sheet
      showCupertinoModalBottomSheet(
        context: context,
        topRadius: Radius.circular(10),
        builder: (context) => MarkerSheet(
          document: _closestMarker!,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    // Compute padding
    double topPadding = MediaQuery.of(context).viewPadding.top / 2;
    double bottomPadding = MediaQuery.of(context).viewPadding.bottom / 2;

    return Scaffold(
      // Set status bar theme
      body: AnnotatedRegion<SystemUiOverlayStyle>(
        value: SystemUiOverlayStyle.dark,
        child: Stack(
          children: [
            // Map
            Map(
              initialPosition: widget.initialPosition,
              onMapCreated: _onMapCreated,
              setClosestMarker: _setClosestMarker,
              onMarkerTapped: _onMarkerTapped,
            ),
            // My location button
            Positioned(
              right: 15,
              top: topPadding + 30,
              child: ControlButton(
                onPressed: _onMyLocationPressed,
                icon: CupertinoIcons.location_circle_fill,
              ),
            ),
            // Add button
            Positioned(
              right: 15,
              top: topPadding + 80,
              child: ControlButton(
                onPressed: _onAddPressed,
                icon: CupertinoIcons.add_circled_solid,
              ),
            ),
            // Closest button
            Positioned(
              right: 20,
              bottom: bottomPadding + 20,
              child: ClosestButton(
                onPressed: _onClosestPressed,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
