// User interface
import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:modal_bottom_sheet/modal_bottom_sheet.dart';
// Location services
import 'package:geolocator/geolocator.dart';
// Geocoding
import 'package:geocoding/geocoding.dart';
// Sheets
import '../sheets/add-sheet.dart';

class AddButton extends StatelessWidget {
  final Function() onPressed;

  const AddButton({
    Key? key,
    required this.onPressed,
  }) : super(key: key);

  Future<String> getCurrentAddress(Position currentPosition) async {
    // Get current placemark
    List<Placemark> currentPlacemarks = await placemarkFromCoordinates(
      currentPosition.latitude,
      currentPosition.longitude,
    );
    Placemark currentPlacemark = currentPlacemarks[0];
    // Return current address
    if (currentPlacemark.street!.isEmpty) return 'Middle of nowhere';
    String currentAddress = currentPlacemark.street!;
    if (currentPlacemark.locality!.isEmpty) return currentAddress;
    currentAddress += ', ' + currentPlacemark.locality!;
    if (currentPlacemark.postalCode!.isEmpty) return currentAddress;
    currentAddress += ' ' + currentPlacemark.postalCode!;
    return currentAddress;
  }

  Future<void> addPressed(BuildContext context) async {
    // Go to current position
    onPressed();
    // Get current position
    Position currentPosition = await Geolocator.getCurrentPosition();
    // Get current address
    String currentAddress = await getCurrentAddress(currentPosition);
    // Show add sheet
    showCupertinoModalBottomSheet(
      context: context,
      topRadius: Radius.circular(10),
      builder: (BuildContext context) => AddSheet(
        currentPosition: currentPosition,
        currentAddress: currentAddress,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return FloatingActionButton.extended(
      heroTag: UniqueKey(),
      onPressed: () => addPressed(context),
      backgroundColor: Colors.white,
      foregroundColor: Colors.black87,
      splashColor: Colors.transparent,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.all(
          Radius.circular(10),
        ),
      ),
      label: Text(
        'Add here',
        style: TextStyle(
          fontSize: 16,
          letterSpacing: 0,
        ),
      ),
      icon: Icon(
        CupertinoIcons.add_circled_solid,
      ),
    );
  }
}
