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
      backgroundColor: Colors.white,
      foregroundColor: Colors.black87,
      splashColor: Colors.transparent,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.all(
          Radius.circular(10),
        ),
      ),
      label: Text(
        'Closest',
        style: TextStyle(
          fontSize: 16,
          letterSpacing: 0,
        ),
      ),
      icon: Icon(
        CupertinoIcons.bolt_circle_fill,
      ),
    );
  }
}
