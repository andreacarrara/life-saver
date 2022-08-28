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
import '/buttons/thumb_button.dart';
import '/buttons/action_button.dart';

class MarkerSheet extends StatefulWidget {
  final DocumentSnapshot document;

  const MarkerSheet({
    Key? key,
    required this.document,
  }) : super(key: key);

  @override
  State<MarkerSheet> createState() => _MarkerSheetState();
}

class _MarkerSheetState extends State<MarkerSheet> {
  String _address = 'Loading...'; // To be set later
  bool _isReviewed = true; // To be set later
  int _confirmations = -1; // To be set later
  int _reports = -1; // To be set later

  @override
  void initState() {
    super.initState();
    _setAddress();
    _setIsReviewed();
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
    String address = placemark.street!;
    if (address.isNotEmpty) address += ', ';
    address += placemark.locality!;
    if (address.isNotEmpty) address += ' ';
    address += placemark.postalCode!;
    if (address.isEmpty) address = 'Middle of nowhere';
    // Set address
    setState(() {
      _address = address;
    });
  }

  Future<void> _setIsReviewed() async {
    // Initialize local storage
    SharedPreferences localStorage = await SharedPreferences.getInstance();
    // Read from local storage
    bool? isReviewed = localStorage.getBool(widget.document.id);
    // Set is reviewed
    setState(() {
      _isReviewed = isReviewed != null;
    });
  }

  void _setReviews() {
    setState(() {
      _confirmations = widget.document.get('confirmations');
      _reports = widget.document.get('reports');
    });
  }

  String _getReviews() {
    // If reviews are still loading
    if (_confirmations == -1 || _reports == -1) return 'Loading...';
    // Compute reviews
    String reviews = '$_confirmations';
    reviews += _confirmations == 1 ? ' Confirmation' : ' Confirmations';
    reviews += ', $_reports';
    reviews += _reports == 1 ? ' Report' : ' Reports';
    // Return reviews
    return reviews;
  }

  Future<void> _onThumbPressed(bool isUp) async {
    setState(() {
      // Set is reviewed
      _isReviewed = true;
      // Set reviews
      isUp ? _confirmations += 1 : _reports += 1;
    });
    // Initialize local storage
    SharedPreferences localStorage = await SharedPreferences.getInstance();
    // Write to local storage
    await localStorage.setBool(widget.document.id, true);
    // Initialize Firestore
    final firestore = FirebaseFirestore.instance;
    // Update reviews
    if (isUp) {
      // Update confirmations
      firestore
          .collection('defibrillators')
          .doc(widget.document.id)
          .update({'confirmations': _confirmations});
    } else {
      // Update reports
      firestore
          .collection('defibrillators')
          .doc(widget.document.id)
          .update({'reports': _reports});
    }
  }

  Future<void> _showDirections() async {
    // Read location
    GeoPoint geoPoint = widget.document.get('position')['geopoint'];
    // Get list of available maps
    List<AvailableMap> availableMaps = await MapLauncher.installedMaps;
    // Show directions on default map
    await availableMaps.first.showMarker(
      title: 'Defibrillator',
      coords: Coords(
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
              height: 20,
            ),
            // Location
            Row(
              children: [
                Icon(
                  CupertinoIcons.arrow_up_right_circle_fill,
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
              height: 36,
            ),
            // Reviews
            Row(
              children: [
                Icon(
                  CupertinoIcons.checkmark_circle_fill,
                  color: Colors.grey.shade400,
                ),
                SizedBox(
                  width: 6,
                ),
                Text(
                  'Reviews',
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
            // Confirmations and Reports
            Padding(
              padding: EdgeInsets.only(left: 6),
              child: Text(
                _getReviews(),
                overflow: TextOverflow.clip,
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
                // Thumbs
                Expanded(
                  child: _isReviewed
                      ? ActionButton(
                          text: 'Reviewed',
                          onPressed: () {},
                          backgroundColor: Colors.grey.shade200,
                          textColor: Colors.black,
                        )
                      : Row(
                          children: <Widget>[
                            Expanded(
                              child: ThumbButton(
                                isUp: true,
                                onPressed: _onThumbPressed,
                              ),
                            ),
                            SizedBox(
                              width: 12,
                            ),
                            Expanded(
                              child: ThumbButton(
                                isUp: false,
                                onPressed: _onThumbPressed,
                              ),
                            ),
                          ],
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
              height: 46 + bottomPadding,
            ),
          ],
        ),
      ),
    );
  }
}
