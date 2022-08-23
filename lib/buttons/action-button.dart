// User interface
import 'package:flutter/cupertino.dart';
import 'package:google_fonts/google_fonts.dart';

class ActionButton extends StatelessWidget {
  final String text;
  final Function() onPressed;
  final Color backgroundColor;
  final Color textColor;

  const ActionButton({
    Key? key,
    required this.text,
    required this.onPressed,
    required this.backgroundColor,
    required this.textColor,
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
          textStyle: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.w800,
            color: textColor,
          ),
        ),
      ),
    );
  }
}
