// User interface
import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:google_fonts/google_fonts.dart';
// Location services
import 'package:geolocator/geolocator.dart';
// Google Maps
import '/controllers/marker_controller.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
// Buttons
import '/buttons/action_button.dart';

class AddSheet extends StatelessWidget {
  final Position currentPosition;

  AddSheet({
    Key? key,
    required this.currentPosition,
  }) : super(key: key);

  final MarkerController markerController = MarkerController();

  void addPressed(BuildContext context) {
    // Close sheet
    Navigator.of(context).pop();
    // Add marker
    markerController.addMarker(
      LatLng(
        currentPosition.latitude,
        currentPosition.longitude,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    double bottomPadding = MediaQuery.of(context).viewPadding.bottom / 1.5;

    return Padding(
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
            height: 16,
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
            child: FutureBuilder<String>(
              future: markerController.getAddress(
                LatLng(
                  currentPosition.latitude,
                  currentPosition.longitude,
                ),
              ),
              initialData: 'Loading...',
              builder: (context, snapshot) {
                return Text(
                  snapshot.data!,
                  overflow: TextOverflow.ellipsis,
                  style: GoogleFonts.inter(
                    fontSize: 18,
                    color: Colors.black87,
                  ),
                );
              },
            ),
          ),
          SizedBox(
            height: 38,
          ),
          // Buttons
          Row(
            children: [
              // Cancel
              Expanded(
                child: ActionButton(
                  onPressed: Navigator.of(context).pop,
                  text: 'Cancel',
                  textColor: Colors.black87,
                  backgroundColor: Colors.grey[200]!,
                ),
              ),
              SizedBox(
                width: 24,
              ),
              // Add
              Expanded(
                child: ActionButton(
                  onPressed: () => addPressed(context),
                  text: 'Add',
                  textColor: Colors.white,
                  backgroundColor: Colors.black87,
                ),
              )
            ],
          ),
          SizedBox(
            height: bottomPadding + 46,
          ),
        ],
      ),
    );
  }
}
