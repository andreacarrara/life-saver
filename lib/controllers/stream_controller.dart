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
    return geoflutterfire.collection(collectionRef: defibrillators).within(
          field: 'position',
          center: center,
          radius: 10,
        );
  }

  List<DocumentSnapshot> getDocuments(List<DocumentSnapshot> documents) {
    // Sort documents by distance
    documents.sort((a, b) {
      GeoFirePoint center = GeoFirePoint(
        initialPosition.latitude,
        initialPosition.longitude,
      );
      GeoPoint geoPointA = a.get('position')['geopoint'];
      GeoPoint geoPointB = b.get('position')['geopoint'];
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
    int length = documents.length;
    if (length > 10) documents.removeRange(10, length);
    return documents;
  }
}
