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
    return CupertinoButton(
      onPressed: () => onPressed(isUp),
      color: Colors.grey.shade200,
      padding: EdgeInsets.zero,
      child: Icon(
        isUp
            ? CupertinoIcons.hand_thumbsup_fill
            : CupertinoIcons.hand_thumbsdown_fill,
        color: Colors.black87,
      ),
    );
  }
}
