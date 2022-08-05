// User interface
import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:google_fonts/google_fonts.dart';
// Location services
import 'package:geolocator/geolocator.dart';
// Firebase Firestore
import 'package:cloud_firestore/cloud_firestore.dart';
// Geoqueries
import 'package:geoflutterfire/geoflutterfire.dart';
// Buttons
import '../buttons/action-button.dart';

class AddSheet extends StatelessWidget {
  final Position currentPosition;
  final String currentAddress;

  const AddSheet({
    Key? key,
    required this.currentPosition,
    required this.currentAddress,
  }) : super(key: key);

  void closeSheet(BuildContext context) {
    Navigator.of(context).pop();
  }

  void confirmPressed(BuildContext context) {
    closeSheet(context);
    addMarker();
  }

  Future<void> addMarker() async {
    // Initialize Firestore
    final firestore = FirebaseFirestore.instance;
    // Intiialiaze GeoFlutterFire
    final geoflutterfire = Geoflutterfire();
    // Add marker
    GeoFirePoint defibrillator = geoflutterfire.point(
      latitude: currentPosition.latitude,
      longitude: currentPosition.longitude,
    );
    firestore.collection('defibrillators').add({
      'position': defibrillator.data,
      'reviews': 0,
    });
  }

  @override
  Widget build(BuildContext context) {
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
                      color: Colors.grey.shade400,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                ),
              ],
            ),
            SizedBox(
              height: 30,
            ),
            // Address
            Padding(
              padding: EdgeInsets.only(left: 6),
              child: Text(
                currentAddress,
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
              height: 46,
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
              height: 42,
            ),
          ],
        ),
      ),
    );
  }
}
