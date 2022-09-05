// User interface
import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:google_fonts/google_fonts.dart';
// Buttons
import '/buttons/action_button.dart';

class AlertSheet extends StatelessWidget {
  const AlertSheet({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    double bottomPadding = MediaQuery.of(context).viewPadding.bottom / 2;

    return Material(
      child: Padding(
        padding: EdgeInsets.symmetric(
          horizontal: 24,
          vertical: 14,
        ),
        child: Wrap(
          children: [
            // Knob
            Center(
              child: Container(
                width: 28,
                height: 6,
                decoration: BoxDecoration(
                  color: Colors.grey[300],
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
            ),
            SizedBox(
              height: 20,
            ),
            // Alert
            Row(
              children: [
                Icon(
                  CupertinoIcons.exclamationmark_circle_fill,
                  color: Colors.grey[400],
                ),
                SizedBox(
                  width: 6,
                ),
                Text(
                  'Alert',
                  overflow: TextOverflow.ellipsis,
                  style: GoogleFonts.inter(
                    fontSize: 16,
                    color: Colors.grey[400],
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
            SizedBox(
              height: 30,
            ),
            // Message
            Padding(
              padding: EdgeInsets.only(
                left: 6,
              ),
              child: Text(
                'No nearby defibrillators were found',
                overflow: TextOverflow.clip,
                style: GoogleFonts.inter(
                  fontSize: 18,
                  color: Colors.black87,
                ),
              ),
            ),
            SizedBox(
              height: 42,
            ),
            // Close button
            Row(
              children: [
                Expanded(
                  child: ActionButton(
                    onPressed: Navigator.of(context).pop,
                    text: 'Close',
                    textColor: Colors.black87,
                    backgroundColor: Colors.grey[200]!,
                  ),
                ),
              ],
            ),
            SizedBox(
              height: bottomPadding + 46,
            ),
          ],
        ),
      ),
    );
  }
}
