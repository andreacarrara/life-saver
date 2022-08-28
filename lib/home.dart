// User interface
import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/scheduler.dart';
import 'package:modal_bottom_sheet/modal_bottom_sheet.dart';
// Location services
import 'package:geolocator/geolocator.dart';
// Map
import 'map.dart';
import 'dart:async';
import 'package:flutter/services.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
// Firebase Firestore
import 'package:cloud_firestore/cloud_firestore.dart';
// Buttons
import 'buttons/control_button.dart';
import 'buttons/closest_button.dart';
// Sheets
import 'sheets/add_sheet.dart';
import 'sheets/info_sheet.dart';
import 'sheets/marker_sheet.dart';
// Utilities
import 'utilities/logo.dart';
import 'utilities/permission.dart';

class Home extends StatefulWidget {
  const Home({Key? key}) : super(key: key);

  @override
  State<Home> createState() => _HomeState();
}

class _HomeState extends State<Home> with TickerProviderStateMixin {
  bool? _locationPermission; // To be set later
  Position? _initialPosition; // To be set later
  DocumentSnapshot<Object?>? _closestMarker; // To be set later
  Completer<GoogleMapController> _mapController = Completer();

  @override
  void initState() {
    super.initState();
    _setInitState();
  }

  Future<void> _setInitState() async {
    await _setLocationPermission();
    await _setInitialPosition();
  }

  Future<void> _setLocationPermission() async {
    // Request location permission
    LocationPermission locationPermission =
        await Geolocator.requestPermission();
    // Set location permission
    setState(() {
      locationPermission == LocationPermission.deniedForever
          ? _locationPermission = false
          : _locationPermission = true;
    });
  }

  Future<void> _setInitialPosition() async {
    // If location permission has been granted
    if (_locationPermission!) {
      // Get current position
      Position initialPosition = await _getCurrentPosition();
      // Set current position
      setState(() {
        _initialPosition = initialPosition;
        _locationPermission = true;
      });
    }
  }

  Future<Position> _getCurrentPosition() async {
    return await Geolocator.getCurrentPosition();
  }

  void _setClosestMarker(DocumentSnapshot<Object?> closestMarker) {
    // Wait for build to finish
    SchedulerBinding.instance.addPostFrameCallback((duration) {
      setState(() {
        _closestMarker = closestMarker;
      });
    });
  }

  Future<void> _animateToLatLng(LatLng latLng) async {
    // Get map center
    LatLng mapCenter = await _getMapCenter();
    // Get map zoom
    double mapZoom = await _getMapZoom();
    // Initiliaze tweens
    Tween<double> latTween = Tween<double>(
      begin: mapCenter.latitude,
      end: latLng.latitude,
    );
    Tween<double> lngTween = Tween<double>(
      begin: mapCenter.longitude,
      end: latLng.longitude,
    );
    Tween<double> zoomTween = Tween<double>(
      begin: mapZoom,
      end: 16,
    );
    // Initiliaze animation controller
    AnimationController animationController = AnimationController(
      duration: Duration(seconds: 1),
      vsync: this,
    );
    // Initiliaze animation
    Animation<double> animation = CurvedAnimation(
      parent: animationController,
      curve: Curves.fastOutSlowIn,
    );
    // Add listener to animation controller
    animationController.addListener(() {
      _moveToLatLngZoom(
        LatLng(
          latTween.evaluate(animation),
          lngTween.evaluate(animation),
        ),
        zoomTween.evaluate(animation),
      );
    });
    // Add status listener to animation
    animation.addStatusListener((AnimationStatus status) {
      if (status == AnimationStatus.completed) {
        animationController.dispose();
      } else if (status == AnimationStatus.dismissed) {
        animationController.dispose();
      }
    });
    // Run animation
    animationController.forward();
  }

  Future<LatLng> _getMapCenter() async {
    GoogleMapController mapController = await _mapController.future;
    // Get map region
    LatLngBounds mapRegion = await mapController.getVisibleRegion();
    // Compute map center
    LatLng mapCenter = LatLng(
      (mapRegion.northeast.latitude + mapRegion.southwest.latitude) / 2,
      (mapRegion.northeast.longitude + mapRegion.southwest.longitude) / 2,
    );
    // Return map center
    return mapCenter;
  }

  Future<double> _getMapZoom() async {
    GoogleMapController mapController = await _mapController.future;
    // Return map zoom
    return mapController.getZoomLevel();
  }

  Future<void> _moveToLatLngZoom(LatLng latLng, double zoom) async {
    GoogleMapController mapController = await _mapController.future;
    // Move camera
    mapController.moveCamera(
      CameraUpdate.newLatLngZoom(
        LatLng(
          latLng.latitude,
          latLng.longitude,
        ),
        zoom,
      ),
    );
  }

  void _onMapCreated(GoogleMapController controller) {
    _mapController.complete(controller);
    // Style map
    rootBundle.loadString('assets/mapStyle.json').then((String mapStyle) {
      controller.setMapStyle(mapStyle);
    });
  }

  Future<void> _onMyLocationPressed() async {
    // Get current position
    Position currentPosition = await _getCurrentPosition();
    // Animate to current position
    _animateToLatLng(
      LatLng(
        currentPosition.latitude,
        currentPosition.longitude,
      ),
    );
  }

  Future<void> _onAddPressed(BuildContext context) async {
    // Get current position
    Position currentPosition = await _getCurrentPosition();
    // Animate to current position
    _animateToLatLng(
      LatLng(
        currentPosition.latitude,
        currentPosition.longitude,
      ),
    );
    // Show add sheet
    showCupertinoModalBottomSheet(
      context: context,
      topRadius: Radius.circular(10),
      builder: (BuildContext context) => AddSheet(
        currentPosition: currentPosition,
      ),
    );
  }

  void _onClosestPressed() {
    // If no closest marker
    if (_closestMarker == null) {
      // Show info sheet
      showCupertinoModalBottomSheet(
        context: context,
        topRadius: Radius.circular(10),
        builder: (BuildContext context) => InfoSheet(),
      );
    } else {
      // Read marker location
      GeoPoint geoPoint = _closestMarker!.get('position')['geopoint'];
      // Animate to marker location
      _animateToLatLng(
        LatLng(
          geoPoint.latitude,
          geoPoint.longitude,
        ),
      );
      // Show marker sheet
      showCupertinoModalBottomSheet(
        context: context,
        topRadius: Radius.circular(10),
        builder: (BuildContext context) => MarkerSheet(
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

    // If location permission is still loading
    if (_locationPermission == null) return Logo();

    // If location permission has been denied
    if (_locationPermission == false) return Permission();

    // If initial position is still loading
    if (_initialPosition == null) return Logo();

    // If initial position has been loaded
    return Scaffold(
      body: AnnotatedRegion<SystemUiOverlayStyle>(
        value: SystemUiOverlayStyle.dark,
        child: Stack(
          children: <Widget>[
            // Map
            Map(
              initialPosition: _initialPosition!,
              setClosestMarker: _setClosestMarker,
              onMarkerTapped: _animateToLatLng,
              onMapCreated: _onMapCreated,
            ),
            // My location button
            Positioned(
              top: 30 + topPadding,
              right: 15,
              child: ControlButton(
                onPressed: _onMyLocationPressed,
                icon: CupertinoIcons.location_circle_fill,
              ),
            ),
            // Add button
            Positioned(
              top: 80 + topPadding,
              right: 15,
              child: ControlButton(
                onPressed: () => _onAddPressed(context),
                icon: CupertinoIcons.add_circled_solid,
              ),
            ),
            // Closest button
            Positioned(
              bottom: 20 + bottomPadding,
              right: 20,
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
