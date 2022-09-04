// Location services
import 'package:geocoding/geocoding.dart';
// Google Maps
import 'package:google_maps_flutter/google_maps_flutter.dart';
// Firebase Firestore
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:geoflutterfire/geoflutterfire.dart';
// Local storage
import 'package:shared_preferences/shared_preferences.dart';

class MarkerController {
  Future<String> getAddress(LatLng latLng) async {
    // Get nearest placemark
    List<Placemark> placemarks = await placemarkFromCoordinates(
      latLng.latitude,
      latLng.longitude,
    );
    // Get nearest placemark
    Placemark placemark = placemarks[0];
    // Compute address
    String address = placemark.street!;
    if (address.isNotEmpty) address += ', ';
    address += placemark.locality!;
    if (address.isNotEmpty) address += ' ';
    address += placemark.postalCode!;
    if (address.isNotEmpty) return address;
    return 'Middle of Nowhere';
  }

  void addMarker(LatLng latLng) {
    // Initialize Firestore
    FirebaseFirestore firestore = FirebaseFirestore.instance;
    // Initialize GeoFlutterFire
    Geoflutterfire geoflutterfire = Geoflutterfire();
    // Add marker
    GeoFirePoint marker = geoflutterfire.point(
      latitude: latLng.latitude,
      longitude: latLng.longitude,
    );
    firestore.collection('defibrillators').add({
      'position': marker.data,
      'reviews': 0,
    });
  }

  Future<bool> getReviewed(String id) async {
    // Initiliaze local storage
    SharedPreferences localStorage = await SharedPreferences.getInstance();
    return localStorage.getBool(id) != null;
  }

  Future<void> updateMarker(String id, int reviews) async {
    // Initialize local storage
    SharedPreferences localStorage = await SharedPreferences.getInstance();
    // Write to local storage
    localStorage.setBool(id, true);
    // Initialize Firestore
    FirebaseFirestore firestore = FirebaseFirestore.instance;
    // If reviewed negatively
    if (reviews.isNegative) {
      // Delete marker
      firestore.collection('defibrillators').doc(id).delete();
    } else {
      // Else, update marker
      firestore.collection('defibrillators').doc(id).update({
        'reviews': reviews,
      });
    }
  }
}
