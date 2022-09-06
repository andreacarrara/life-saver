// User interface
import 'package:flutter/material.dart';

class ControlButton extends StatelessWidget {
  final Function() onPressed;
  final IconData icon;

  const ControlButton({
    Key? key,
    required this.onPressed,
    required this.icon,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return FloatingActionButton(
      heroTag: UniqueKey(),
      onPressed: onPressed,
      foregroundColor: Colors.black87,
      splashColor: Colors.transparent,
      backgroundColor: Colors.white,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.all(
          Radius.circular(10),
        ),
      ),
      mini: true,
      child: Icon(
        icon,
      ),
    );
  }
}
