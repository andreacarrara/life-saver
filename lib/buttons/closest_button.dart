// User interface
import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';

class ClosestButton extends StatelessWidget {
  final Function() onPressed;

  const ClosestButton({
    Key? key,
    required this.onPressed,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return FloatingActionButton.extended(
      onPressed: onPressed,
      foregroundColor: Colors.black87,
      splashColor: Colors.transparent,
      backgroundColor: Colors.white,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.all(
          Radius.circular(10),
        ),
      ),
      icon: Icon(
        CupertinoIcons.bolt_circle_fill,
      ),
      label: Text(
        'Closest',
        style: TextStyle(
          fontSize: 16,
          letterSpacing: 0,
        ),
      ),
    );
  }
}
