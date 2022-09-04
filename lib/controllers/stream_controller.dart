// Location services
import 'package:geolocator/geolocator.dart';
// Firebase Firestore
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:geoflutterfire/geoflutterfire.dart';

class StreamController {
  late final Position initialPosition;

  StreamController({required this.initialPosition});

  Stream<List<DocumentSnapshot>> getStream() {
    // Initialize Firestore
    FirebaseFirestore firestore = FirebaseFirestore.instance;
    CollectionReference defibrillators = firestore.collection('defibrillators');
    // Initialize GeoFlutterFire
    Geoflutterfire geoflutterfire = Geoflutterfire();
    GeoFirePoint center = geoflutterfire.point(
      latitude: initialPosition.latitude,
      longitude: initialPosition.longitude,
    );
    // Return stream
    return geoflutterfire.collection(collectionRef: defibrillators).within(
          field: 'position',
          center: center,
          radius: 20,
        );
  }

  List<DocumentSnapshot> getList(List<DocumentSnapshot> documents) {
    // Truncate number of documents
    int length = documents.length;
    if (length > 20) documents.removeRange(20, length);
    // Sort documents by distance
    documents.sort((a, b) {
      GeoFirePoint center = GeoFirePoint(
        initialPosition.latitude,
        initialPosition.longitude,
      );
      // Read positions
      GeoPoint geoPointA = a.get('position')['geopoint'];
      GeoPoint geoPointB = b.get('position')['geopoint'];
      // Compare distances
      return center
          .distance(
            lat: geoPointA.latitude,
            lng: geoPointB.longitude,
          )
          .compareTo(
            center.distance(
              lat: geoPointB.latitude,
              lng: geoPointB.longitude,
            ),
          );
    });
    return documents;
  }
}
