// User interface
import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:google_fonts/google_fonts.dart';
// Geocoding
import 'package:geocoding/geocoding.dart';
// Firebase Firestore
import 'package:cloud_firestore/cloud_firestore.dart';
// Map launcher
import 'package:map_launcher/map_launcher.dart';
// Local storage
import 'package:shared_preferences/shared_preferences.dart';
// Buttons
import '/buttons/action-button.dart';

class MarkerSheet extends StatefulWidget {
  final DocumentSnapshot document;

  MarkerSheet({
    Key? key,
    required this.document,
  }) : super(key: key);

  @override
  State<MarkerSheet> createState() => _MarkerSheetState();
}

class _MarkerSheetState extends State<MarkerSheet> {
  String _address = 'Loading...'; // To be set later
  bool _reviewed = true; // To be set later
  int _reviews = -1; // To be set later

  @override
  void initState() {
    super.initState();
    _setAddress();
    _setReviewed();
    _setReviews();
  }

  Future<void> _setAddress() async {
    // Read location
    GeoPoint geoPoint = widget.document.get('position')['geopoint'];
    // Get list of placemarks
    List<Placemark> placemarks = await placemarkFromCoordinates(
      geoPoint.latitude,
      geoPoint.longitude,
    );
    // Get nearest placemark
    Placemark placemark = placemarks[0];
    // Compute address
    String address = 'Middle of nowhere';
    if (placemark.street!.isNotEmpty) address = placemark.street!;
    if (placemark.locality!.isNotEmpty) address += ', ' + placemark.locality!;
    if (placemark.postalCode!.isNotEmpty)
      address += ' ' + placemark.postalCode!;
    // Set  address
    setState(() {
      _address = address;
    });
  }

  Future<void> _setReviewed() async {
    // Initialize local storage
    SharedPreferences localStorage = await SharedPreferences.getInstance();
    // Read local storage
    bool? reviewed = localStorage.getBool(widget.document.id);
    // Set reviewed
    setState(() {
      _reviewed = reviewed != null;
    });
  }

  void _setReviews() {
    setState(() {
      _reviews = widget.document.get('reviews');
    });
  }

  String _getReviews() {
    if (_reviews == -1) return 'Loading...';
    if (_reviews == 1) return '1 Review';
    return '$_reviews Reviews';
  }

  Future<void> _review() async {
    // Set reviewed
    setState(() {
      _reviewed = true;
    });
    // Set reviews
    setState(() {
      _reviews = _reviews + 1;
    });
    // Initialize local storage
    SharedPreferences localStorage = await SharedPreferences.getInstance();
    // Write local storage
    await localStorage.setBool(widget.document.id, true);
    // Initialize Firestore
    final firestore = FirebaseFirestore.instance;
    // Update reviews
    firestore
        .collection('defibrillators')
        .doc(widget.document.id)
        .update({'reviews': _reviews});
  }

  Future<void> _showDirections() async {
    // Read location
    GeoPoint geoPoint = widget.document.get('position')['geopoint'];
    // Get list of available maps
    List<AvailableMap> availableMaps = await MapLauncher.installedMaps;
    // Show directions on default map
    await availableMaps.first.showDirections(
      destinationTitle: 'Defibrillator',
      destination: Coords(
        geoPoint.latitude,
        geoPoint.longitude,
      ),
    );
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
              height: 30,
            ),
            // Address
            Padding(
              padding: EdgeInsets.only(left: 6),
              child: Text(
                _address,
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
              height: 34,
            ),
            // Reviews
            Row(
              children: [
                Icon(
                  CupertinoIcons.checkmark_shield_fill,
                  color: Colors.grey.shade400,
                ),
                SizedBox(
                  width: 6,
                ),
                Text(
                  _getReviews(),
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
              height: 42,
            ),
            // Buttons
            Row(
              children: <Widget>[
                // Review
                Expanded(
                  child: ActionButton(
                    text: _reviewed ? 'Reviewed' : 'Review',
                    onPressed: _reviewed ? () {} : _review,
                    backgroundColor: Colors.grey.shade200,
                    textColor: Colors.black87,
                  ),
                ),
                SizedBox(
                  width: 24,
                ),
                // Directions
                Expanded(
                  child: ActionButton(
                    text: 'Directions',
                    onPressed: _showDirections,
                    backgroundColor: Colors.black87,
                    textColor: Colors.white,
                  ),
                ),
              ],
            ),
            SizedBox(
              height: 44 + bottomPadding,
            ),
          ],
        ),
      ),
    );
  }
}
