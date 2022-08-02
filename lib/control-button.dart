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
      onPressed: onPressed,
      foregroundColor: Colors.black,
      backgroundColor: Colors.white,
      splashColor: Colors.transparent,
      mini: true,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.all(
          Radius.circular(10),
        ),
      ),
      child: Icon(
        icon,
      ),
    );
  }
}
