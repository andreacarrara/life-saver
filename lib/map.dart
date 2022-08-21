// User interface
import 'package:flutter/material.dart';
import 'package:modal_bottom_sheet/modal_bottom_sheet.dart';
// Location services
import 'package:geolocator/geolocator.dart';
// Map
import 'package:google_maps_flutter/google_maps_flutter.dart';
// Firebase Firestore
import 'firebase_options.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
// Geoqueries
import 'package:geoflutterfire/geoflutterfire.dart';
// Sheets
import 'sheets/marker_sheet.dart';

class Map extends StatefulWidget {
  final Position initialPosition;
  final Function(GoogleMapController) onMapCreated;
  final Function(LatLng) onMarkerTapped;

  const Map({
    Key? key,
    required this.initialPosition,
    required this.onMapCreated,
    required this.onMarkerTapped,
  }) : super(key: key);

  @override
  State<Map> createState() => _MapState();
}

class _MapState extends State<Map> {
  Stream<List<DocumentSnapshot>>? _markersStream; // To be set later
  int _maxMarkers = 10; // Maximum number of markers to display
  double _radius = 5; // Radius of geoquery in kilometers

  @override
  void initState() {
    super.initState();
    _setMarkersStream();
  }

  Future<void> _setMarkersStream() async {
    // Initialize Firebase
    await Firebase.initializeApp(
        options: DefaultFirebaseOptions.currentPlatform);
    // Initialize Firestore
    FirebaseFirestore firestore = FirebaseFirestore.instance;
    CollectionReference defibrillators = firestore.collection('defibrillators');
    // Initialize GeoFlutterFire
    Geoflutterfire geoflutterfire = Geoflutterfire();
    // Initialize markers stream
    GeoFirePoint center = geoflutterfire.point(
      latitude: widget.initialPosition.latitude,
      longitude: widget.initialPosition.longitude,
    );
    Stream<List<DocumentSnapshot<Object?>>> markersStream =
        geoflutterfire.collection(collectionRef: defibrillators).within(
              center: center,
              radius: _radius,
              field: 'position',
            );
    // Set markers stream
    setState(() {
      _markersStream = markersStream;
    });
  }

  List<DocumentSnapshot> _getDocuments(List<DocumentSnapshot> documents) {
    // Sort documents by distance
    documents.sort((a, b) {
      GeoFirePoint center = GeoFirePoint(
        widget.initialPosition.latitude,
        widget.initialPosition.longitude,
      );
      // Read locations
      GeoPoint geoPointA = a.get('position')['geopoint'];
      GeoPoint geoPointB = b.get('position')['geopoint'];
      // Compare distances
      return center
          .distance(
            lat: geoPointA.latitude,
            lng: geoPointA.longitude,
          )
          .compareTo(
            center.distance(
              lat: geoPointB.latitude,
              lng: geoPointB.longitude,
            ),
          );
    });
    // Truncate number of documents
    int numDocuments = documents.length;
    if (numDocuments > _maxMarkers)
      documents.removeRange(_maxMarkers, numDocuments);
    // Return list of documents
    return documents;
  }

  void _onMarkerTapped(BuildContext context, DocumentSnapshot document) {
    // Read marker location
    GeoPoint geoPoint = document.get('position')['geopoint'];
    // Animate to marker location
    widget.onMarkerTapped(
      LatLng(
        geoPoint.latitude,
        geoPoint.longitude,
      ),
    );
    // Open marker sheet
    showCupertinoModalBottomSheet(
      context: context,
      topRadius: Radius.circular(10),
      builder: (BuildContext context) => MarkerSheet(
        document: document,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return StreamBuilder(
      stream: _markersStream,
      builder: (
        BuildContext context,
        AsyncSnapshot<List<DocumentSnapshot>> snapshot,
      ) {
        // Initialize empty set of markers
        Set<Marker> markers = {};
        // If snapshot has data
        if (snapshot.hasData) {
          // Get list of documents
          List<DocumentSnapshot> documents = _getDocuments(snapshot.data!);
          // Read list of documents
          for (DocumentSnapshot document in documents) {
            // Read marker location
            GeoPoint geoPoint = document.get('position')['geopoint'];
            // Add marker to set
            markers.add(
              Marker(
                markerId: MarkerId(document.id),
                position: LatLng(
                  geoPoint.latitude,
                  geoPoint.longitude,
                ),
                onTap: () => _onMarkerTapped(context, document),
                // Disable default animation
                consumeTapEvents: true,
              ),
            );
          }
        }

        return GoogleMap(
          onMapCreated: widget.onMapCreated,
          initialCameraPosition: CameraPosition(
            target: LatLng(
              widget.initialPosition.latitude,
              widget.initialPosition.longitude,
            ),
            zoom: 16,
          ),
          markers: markers,
          myLocationEnabled: true,
          minMaxZoomPreference: MinMaxZoomPreference(10, null),
          myLocationButtonEnabled: false,
          zoomControlsEnabled: false,
          mapToolbarEnabled: false,
          compassEnabled: false,
        );
      },
    );
  }
}
