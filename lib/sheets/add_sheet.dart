// User interface
import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:google_fonts/google_fonts.dart';
// Location services
import 'package:geolocator/geolocator.dart';
// Geocoding
import 'package:geocoding/geocoding.dart';
// Firebase Firestore
import 'package:cloud_firestore/cloud_firestore.dart';
// Geoqueries
import 'package:geoflutterfire/geoflutterfire.dart';
// Buttons
import '/buttons/action-button.dart';

class AddSheet extends StatefulWidget {
  final Position currentPosition;

  AddSheet({
    Key? key,
    required this.currentPosition,
  }) : super(key: key);

  @override
  State<AddSheet> createState() => _AddSheetState();
}

class _AddSheetState extends State<AddSheet> {
  String _currentAddress = 'Loading...'; // To be set later

  @override
  void initState() {
    super.initState();
    _setCurrentAddress();
  }

  Future<void> _setCurrentAddress() async {
    // Get list of current placemarks
    List<Placemark> currentPlacemarks = await placemarkFromCoordinates(
      widget.currentPosition.latitude,
      widget.currentPosition.longitude,
    );
    // Get nearest current placemark
    Placemark currentPlacemark = currentPlacemarks[0];
    // Compute current address
    String currentAddress = 'Middle of nowhere';
    if (currentPlacemark.street!.isNotEmpty)
      currentAddress = currentPlacemark.street!;
    if (currentPlacemark.locality!.isNotEmpty)
      currentAddress += ', ' + currentPlacemark.locality!;
    if (currentPlacemark.postalCode!.isNotEmpty)
      currentAddress += ' ' + currentPlacemark.postalCode!;
    // Set current address
    setState(() {
      _currentAddress = currentAddress;
    });
  }

  void closeSheet(BuildContext context) {
    Navigator.of(context).pop();
  }

  void confirmPressed(BuildContext context) {
    closeSheet(context);
    addMarker();
  }

  Future<void> addMarker() async {
    // If it is still loading, return
    if (_currentAddress == 'Loading...') return;
    // Initialize Firestore
    final firestore = FirebaseFirestore.instance;
    // Intiialiaze GeoFlutterFire
    final geoflutterfire = Geoflutterfire();
    // Add marker
    GeoFirePoint defibrillator = geoflutterfire.point(
      latitude: widget.currentPosition.latitude,
      longitude: widget.currentPosition.longitude,
    );
    firestore.collection('defibrillators').add({
      'position': defibrillator.data,
      'reviews': 0,
    });
  }

  @override
  Widget build(BuildContext context) {
    // Compute padding
    double bottomPadding = MediaQuery.of(context).viewPadding.bottom / 2;

    return Material(
      child: Padding(
        padding: EdgeInsets.symmetric(
          horizontal: 24,
          vertical: 14,
        ),
        child: Wrap(
          children: <Widget>[
            // Knob
            Center(
              child: Container(
                width: 28,
                height: 6,
                decoration: BoxDecoration(
                  color: Colors.grey.shade300,
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
            ),
            SizedBox(
              height: 18,
            ),
            // Location
            Row(
              children: [
                Icon(
                  CupertinoIcons.location_solid,
                  color: Colors.grey.shade400,
                ),
                SizedBox(
                  width: 6,
                ),
                Text(
                  'Location',
                  overflow: TextOverflow.ellipsis,
                  style: GoogleFonts.inter(
                    textStyle: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w800,
                      color: Colors.grey.shade400,
                    ),
                  ),
                ),
              ],
            ),
            SizedBox(
              height: 32,
            ),
            // Address
            Padding(
              padding: EdgeInsets.only(left: 6),
              child: Text(
                _currentAddress,
                overflow: TextOverflow.ellipsis,
                style: GoogleFonts.inter(
                  textStyle: TextStyle(
                    fontSize: 18,
                    color: Colors.black87,
                  ),
                ),
              ),
            ),
            SizedBox(
              height: 44,
            ),
            // Buttons
            Row(
              children: <Widget>[
                // Cancel
                Expanded(
                  child: ActionButton(
                    text: 'Cancel',
                    onPressed: () => closeSheet(context),
                    backgroundColor: Colors.grey.shade200,
                    textColor: Colors.black87,
                  ),
                ),
                SizedBox(
                  width: 24,
                ),
                // Confirm
                Expanded(
                  child: ActionButton(
                    text: 'Confirm',
                    onPressed: () => confirmPressed(context),
                    backgroundColor: Colors.black87,
                    textColor: Colors.white,
                  ),
                ),
              ],
            ),
            SizedBox(
              height: 46 + bottomPadding,
            ),
          ],
        ),
      ),
    );
  }
}
