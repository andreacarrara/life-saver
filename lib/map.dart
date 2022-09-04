// User interface
import 'package:flutter/material.dart';
import 'package:modal_bottom_sheet/modal_bottom_sheet.dart';
// Location services
import 'package:geolocator/geolocator.dart';
// Google Maps
import 'controllers/stream_controller.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
// Firebase Firestore
import 'package:cloud_firestore/cloud_firestore.dart';
// Sheets
import 'sheets/marker_sheet.dart';

class Map extends StatelessWidget {
  final Position initialPosition;
  final Function(GoogleMapController) onMapCreated;
  final Function(DocumentSnapshot) setClosestMarker;
  final Function(LatLng) onMarkerTapped;

  Map({
    Key? key,
    required this.initialPosition,
    required this.onMapCreated,
    required this.setClosestMarker,
    required this.onMarkerTapped,
  }) : super(key: key);

  // Late keyword is required to access initialPosition
  late final StreamController streamController =
      StreamController(initialPosition: initialPosition);

  void onTapped(BuildContext context, DocumentSnapshot document) {
    // Read marker position
    GeoPoint geoPoint = document.get('position')['geopoint'];
    // Animate to marker position
    onMarkerTapped(
      LatLng(
        geoPoint.latitude,
        geoPoint.longitude,
      ),
    );
    // Open marker sheet
    showCupertinoModalBottomSheet(
      context: context,
      topRadius: Radius.circular(10),
      builder: (context) => MarkerSheet(
        document: document,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    // Get updates on markers
    return StreamBuilder<List<DocumentSnapshot>>(
      stream: streamController.getStream(),
      builder: (context, snapshot) {
        List<DocumentSnapshot> list = [];
        if (snapshot.hasData) {
          // Sort and truncate documents
          list = streamController.getList(snapshot.data!);
          // Set closest marker
          if (list.isNotEmpty) setClosestMarker(list[0]);
        }
        // Initiliaze set of markers
        Set<Marker> markers = {};
        for (DocumentSnapshot document in list) {
          // Read marker position
          GeoPoint geoPoint = document.get('position')['geopoint'];
          // Add marker to set
          markers.add(
            Marker(
              markerId: MarkerId(document.id),
              position: LatLng(
                geoPoint.latitude,
                geoPoint.longitude,
              ),
              onTap: () => onTapped(
                context,
                document,
              ),
              // Disable default animation
              consumeTapEvents: true,
            ),
          );
        }

        return GoogleMap(
          onMapCreated: onMapCreated,
          initialCameraPosition: CameraPosition(
            target: LatLng(
              initialPosition.latitude,
              initialPosition.longitude,
            ),
            zoom: 16,
          ),
          markers: markers,
          myLocationEnabled: true,
          minMaxZoomPreference: MinMaxZoomPreference(8, null),
          myLocationButtonEnabled: false,
          rotateGesturesEnabled: false,
          zoomControlsEnabled: false,
          mapToolbarEnabled: false,
          compassEnabled: false,
        );
      },
    );
  }
}
