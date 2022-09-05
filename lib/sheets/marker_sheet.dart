// User interface
import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:google_fonts/google_fonts.dart';
// Google Maps
import '/controllers/marker_controller.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
// Firebase Firestore
import 'package:cloud_firestore/cloud_firestore.dart';
// Map launcher
import 'package:map_launcher/map_launcher.dart';
// Buttons
import '/buttons/thumb_button.dart';
import '/buttons/action_button.dart';

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
  final MarkerController _markerController = MarkerController();
  String _address = 'Loading...';
  // Late keywork is required to access widget.document
  late int _reviews = widget.document.get('reviews');
  bool _reviewed = true;

  @override
  initState() {
    super.initState();
    _setAddress();
    _setReviewed();
  }

  Future<void> _setAddress() async {
    GeoPoint geoPoint = widget.document.get('position')['geopoint'];
    _address = await _markerController.getAddress(
      LatLng(
        geoPoint.latitude,
        geoPoint.longitude,
      ),
    );
    setState(() {});
  }

  Future<void> _setReviewed() async {
    _reviewed = await _markerController.getReviewed(widget.document.id);
    setState(() {});
  }

  void _onThumbPressed(bool isUp) {
    _reviewed = true;
    _reviews += isUp ? 1 : -1;
    // If reviewed negatively
    if (_reviews.isNegative) {
      // Close sheet
      Navigator.of(context).pop();
    } else {
      // Set reviews
      setState(() {});
    }
    // Update marker
    _markerController.updateMarker(
      widget.document.id,
      _reviews,
    );
  }

  Future<void> _showDirections() async {
    GeoPoint geoPoint = widget.document.get('position')['geopoint'];
    List<AvailableMap> availableMaps = await MapLauncher.installedMaps;
    availableMaps.first.showMarker(
      title: 'Defibrillator',
      coords: Coords(
        geoPoint.latitude,
        geoPoint.longitude,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    double bottomPadding = MediaQuery.of(context).viewPadding.bottom / 2;

    return Material(
      child: Padding(
        padding: EdgeInsets.symmetric(
          horizontal: 24,
          vertical: 14,
        ),
        child: Wrap(
          children: [
            // Knob
            Center(
              child: Container(
                width: 28,
                height: 6,
                decoration: BoxDecoration(
                  color: Colors.grey[300],
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
                  color: Colors.grey[400],
                ),
                SizedBox(
                  width: 6,
                ),
                Text(
                  'Location',
                  overflow: TextOverflow.ellipsis,
                  style: GoogleFonts.inter(
                    fontSize: 16,
                    color: Colors.grey[400],
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
            SizedBox(
              height: 30,
            ),
            // Address
            Padding(
              padding: EdgeInsets.only(
                left: 6,
              ),
              child: Text(
                _address,
                overflow: TextOverflow.ellipsis,
                style: GoogleFonts.inter(
                  fontSize: 18,
                  color: Colors.black87,
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
                  color: Colors.grey[400],
                ),
                SizedBox(
                  width: 6,
                ),
                Text(
                  '$_reviews Review' + (_reviews == 1 ? '' : 's'),
                  overflow: TextOverflow.ellipsis,
                  style: GoogleFonts.inter(
                    fontSize: 16,
                    color: Colors.grey[400],
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
            SizedBox(
              height: 44,
            ),
            // Buttons
            Row(
              children: [
                Expanded(
                  child: Builder(
                    builder: (context) {
                      // If already reviewed
                      if (_reviewed)
                        // Reviewed
                        return ActionButton(
                          onPressed: () {},
                          text: 'Reviewed',
                          textColor: Colors.black87,
                          backgroundColor: Colors.grey[200]!,
                        );
                      // Else, thumbs
                      return Row(
                        children: [
                          Expanded(
                            child: ThumbButton(
                              onPressed: _onThumbPressed,
                              isUp: true,
                            ),
                          ),
                          SizedBox(
                            width: 12,
                          ),
                          Expanded(
                            child: ThumbButton(
                              onPressed: _onThumbPressed,
                              isUp: false,
                            ),
                          ),
                        ],
                      );
                    },
                  ),
                ),
                SizedBox(
                  width: 24,
                ),
                // Directions
                Expanded(
                  child: ActionButton(
                    onPressed: _showDirections,
                    text: 'Directions',
                    textColor: Colors.white,
                    backgroundColor: Colors.black87,
                  ),
                ),
              ],
            ),
            SizedBox(
              height: bottomPadding + 46,
            ),
          ],
        ),
      ),
    );
  }
}
