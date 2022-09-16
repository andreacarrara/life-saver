// User interface
import 'package:flutter/material.dart';
import 'package:modal_bottom_sheet/modal_bottom_sheet.dart';
// Location services
import 'package:geolocator/geolocator.dart';
// Google Maps
import 'package:google_maps_flutter/google_maps_flutter.dart';
// Firebase Firestore
import 'controllers/stream_controller.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
// Sheets
import 'sheets/marker_sheet.dart';

class Map extends StatelessWidget {
  final Position initialPosition;
  final Function(GoogleMapController) onMapCreated;
  final Function(DocumentSnapshot?) setClosestMarker;
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
    GeoPoint geoPoint = document.get('position')['geopoint'];
    // Animate to marker position
    onMarkerTapped(
      LatLng(
        geoPoint.latitude,
        geoPoint.longitude,
      ),
    );
    // Open marker sheet
    showMaterialModalBottomSheet(
      context: context,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(10),
          topRight: Radius.circular(10),
        ),
      ),
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
        List<DocumentSnapshot> documents = [];
        if (snapshot.hasData)
          // Sort and truncate documents
          documents = streamController.getDocuments(snapshot.data!);
        // Set closest marker
        setClosestMarker(documents.length > 0 ? documents[0] : null);

        Set<Marker> markers = {};
        for (DocumentSnapshot document in documents) {
          GeoPoint geoPoint = document.get('position')['geopoint'];
          // Add marker
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
          minMaxZoomPreference: MinMaxZoomPreference(10, null),
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
