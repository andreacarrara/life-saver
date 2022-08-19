// User interface
import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:modal_bottom_sheet/modal_bottom_sheet.dart';
// Location services
import 'package:geolocator/geolocator.dart';
// Sheets
import '../sheets/add-sheet.dart';

class AddButton extends StatelessWidget {
  final Function(Position) onPressed;

  const AddButton({
    Key? key,
    required this.onPressed,
  }) : super(key: key);

  Future<void> addPressed(BuildContext context) async {
    // Get current position
    Position currentPosition = await Geolocator.getCurrentPosition();
    // Animate to current position
    onPressed(currentPosition);
    // Show add sheet
    showCupertinoModalBottomSheet(
      context: context,
      topRadius: Radius.circular(10),
      builder: (BuildContext context) => AddSheet(
        currentPosition: currentPosition,
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
