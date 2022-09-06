// User interface
import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';

class ThumbButton extends StatelessWidget {
  final Function(bool) onPressed;
  final bool isUp;

  const ThumbButton({
    Key? key,
    required this.onPressed,
    required this.isUp,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return TextButton(
      onPressed: () => onPressed(isUp),
      style: ButtonStyle(
        foregroundColor: MaterialStateProperty.all(Colors.black87),
        overlayColor: MaterialStateProperty.all(Colors.transparent),
        backgroundColor: MaterialStateProperty.all(Colors.grey[200]),
        shape: MaterialStateProperty.all(RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(10),
        )),
        padding: MaterialStateProperty.all(
          EdgeInsets.symmetric(
            vertical: 10,
            horizontal: 24,
          ),
        ),
      ),
      child: Icon(
        isUp
            ? CupertinoIcons.hand_thumbsup_fill
            : CupertinoIcons.hand_thumbsdown_fill,
      ),
    );
  }
}
