// User interface
import 'package:flutter/material.dart';
// Map
import 'package:google_maps_flutter/google_maps_flutter.dart';

class Map extends StatelessWidget {
  final Function(GoogleMapController) onMapCreated;
  final CameraPosition initialCameraPosition;

  const Map({
    Key? key,
    required this.onMapCreated,
    required this.initialCameraPosition,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return GoogleMap(
      onMapCreated: onMapCreated,
      initialCameraPosition: initialCameraPosition,
      minMaxZoomPreference: MinMaxZoomPreference(12, null),
      myLocationButtonEnabled: false,
      zoomControlsEnabled: false,
      mapToolbarEnabled: false,
      myLocationEnabled: true,
      compassEnabled: false,
    );
  }
}
