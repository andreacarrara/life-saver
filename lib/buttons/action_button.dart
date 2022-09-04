// User interface
import 'package:flutter/cupertino.dart';
import 'package:google_fonts/google_fonts.dart';

class ActionButton extends StatelessWidget {
  final Function() onPressed;
  final String text;
  final Color textColor;
  final Color backgroundColor;

  const ActionButton({
    Key? key,
    required this.onPressed,
    required this.text,
    required this.textColor,
    required this.backgroundColor,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return CupertinoButton(
      onPressed: onPressed,
      color: backgroundColor,
      borderRadius: BorderRadius.circular(10),
      padding: EdgeInsets.symmetric(
        vertical: 0,
        horizontal: 24,
      ),
      child: Text(
        text,
        overflow: TextOverflow.ellipsis,
        style: GoogleFonts.inter(
          fontSize: 18,
          color: textColor,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }
}
