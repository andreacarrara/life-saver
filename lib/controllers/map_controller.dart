// User interface
import 'package:flutter/material.dart';
// Google Maps
import 'package:flutter/services.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

class MapController {
  late final GoogleMapController mapController;
  late final dynamic tickerProvider;

  MapController({required this.mapController, required this.tickerProvider}) {
    // Style map
    rootBundle.loadString('assets/mapStyle.json').then((mapStyle) {
      mapController.setMapStyle(mapStyle);
    });
  }

  Future<void> animateToLatLng(LatLng latLng) async {
    LatLng center = await _getCenter();
    double zoom = await mapController.getZoomLevel();
    // Initialize tweens
    Tween<double> latTween = Tween(
      begin: center.latitude,
      end: latLng.latitude,
    );
    Tween<double> lngTween = Tween(
      begin: center.longitude,
      end: latLng.longitude,
    );
    Tween<double> zoomTween = Tween(
      begin: zoom,
      end: 16,
    );
    // Initialize animation
    AnimationController animationController = AnimationController(
      duration: Duration(seconds: 1),
      vsync: tickerProvider,
    );
    Animation<double> animation = CurvedAnimation(
      parent: animationController,
      curve: Curves.fastOutSlowIn,
    );
    animationController.addListener(() {
      _moveToLatLngZoom(
        LatLng(
          latTween.evaluate(animation),
          lngTween.evaluate(animation),
        ),
        zoomTween.evaluate(animation),
      );
    });
    animation.addStatusListener((status) {
      if (status == AnimationStatus.completed) animationController.dispose();
    });
    // Run animation
    animationController.forward();
  }

  Future<LatLng> _getCenter() async {
    LatLngBounds region = await mapController.getVisibleRegion();
    return LatLng(
      (region.northeast.latitude + region.southwest.latitude) / 2,
      (region.northeast.longitude + region.southwest.longitude) / 2,
    );
  }

  void _moveToLatLngZoom(LatLng latLng, double zoom) {
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
}
