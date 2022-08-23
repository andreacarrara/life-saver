// User interface
import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
// Location services
import 'package:geolocator/geolocator.dart';
// Map
import 'map.dart';
import 'dart:async';
import 'package:flutter/services.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
// Buttons
import 'buttons/control-button.dart';
import 'buttons/add-button.dart';
// Utilities
import 'utilities/logo.dart';
import 'utilities/permission.dart';

class Home extends StatefulWidget {
  const Home({Key? key}) : super(key: key);

  @override
  State<Home> createState() => _HomeState();
}

class _HomeState extends State<Home> with TickerProviderStateMixin {
  Completer<GoogleMapController> _mapController = Completer();
  LocationPermission? _locationPermission; // To be set later

  @override
  void initState() {
    super.initState();
    _setLocationPermission();
  }

  Future<void> _setLocationPermission() async {
    // Request location permission
    LocationPermission locationPermission =
        await Geolocator.requestPermission();
    // Set location permission
    setState(() {
      _locationPermission = locationPermission;
    });
  }

  Future<Position> _getCurrentPosition() async {
    return await Geolocator.getCurrentPosition();
  }

  void _onMapCreated(GoogleMapController controller) {
    _mapController.complete(controller);
    // Style map
    rootBundle.loadString('assets/mapStyle.json').then((String mapStyle) {
      controller.setMapStyle(mapStyle);
    });
  }

  Future<void> _myLocationPressed() async {
    // Get current position
    Position currentPosition = await Geolocator.getCurrentPosition();
    // Animate to current position
    _animateToLatLng(
      LatLng(
        currentPosition.latitude,
        currentPosition.longitude,
      ),
    );
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

  @override
  Widget build(BuildContext context) {
    // If location permission is still loading
    if (_locationPermission == null) return Logo();

    // If location permission has been denied
    if (_locationPermission == LocationPermission.deniedForever)
      return Permission();

    // If location permission has been granted
    return FutureBuilder(
      future: _getCurrentPosition(),
      builder: (BuildContext context, AsyncSnapshot<Position> snapshot) {
        // Compute padding
        double topPadding = MediaQuery.of(context).viewPadding.top / 2;
        double bottomPadding = MediaQuery.of(context).viewPadding.bottom / 2;

        // If initial position is still loading
        if (!snapshot.hasData) return Logo();

        // If initial position has been loaded
        return Scaffold(
          body: AnnotatedRegion<SystemUiOverlayStyle>(
            value: SystemUiOverlayStyle.dark,
            child: Stack(
              children: <Widget>[
                // Map
                Map(
                  initialPosition: snapshot.data!,
                  onMapCreated: _onMapCreated,
                  onMarkerTapped: _animateToLatLng,
                ),
                // Info button
                Positioned(
                  top: 30 + topPadding,
                  right: 15,
                  child: ControlButton(
                    onPressed: () {},
                    icon: CupertinoIcons.info_circle_fill,
                  ),
                ),
                // My location button
                Positioned(
                  top: 80 + topPadding,
                  right: 15,
                  child: ControlButton(
                    onPressed: _myLocationPressed,
                    icon: CupertinoIcons.location_circle_fill,
                  ),
                ),
                // Add button
                Positioned(
                  bottom: 20 + bottomPadding,
                  right: 20,
                  child: AddButton(
                    onPressed: _animateToLatLng,
                  ),
                )
              ],
            ),
          ),
        );
      },
    );
  }
}
