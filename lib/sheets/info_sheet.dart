// User interface
import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:google_fonts/google_fonts.dart';
// Buttons
import '/buttons/action_button.dart';

class InfoSheet extends StatelessWidget {
  const InfoSheet({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    // Compute padding
    double bottomPadding = MediaQuery.of(context).viewPadding.bottom / 2;

    return Material(
      child: Padding(
        padding: EdgeInsets.symmetric(
          horizontal: 24,
          vertical: 14,
        ),
        child: Wrap(
          children: <Widget>[
            // Knob
            Center(
              child: Container(
                width: 28,
                height: 6,
                decoration: BoxDecoration(
                  color: Colors.grey.shade300,
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
            ),
            SizedBox(
              height: 20,
            ),
            // Header
            Row(
              children: [
                Icon(
                  CupertinoIcons.exclamationmark_circle_fill,
                  color: Colors.grey.shade400,
                ),
                SizedBox(
                  width: 6,
                ),
                Text(
                  'Message',
                  overflow: TextOverflow.ellipsis,
                  style: GoogleFonts.inter(
                    textStyle: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w800,
                      color: Colors.grey.shade400,
                    ),
                  ),
                ),
              ],
            ),
            SizedBox(
              height: 30,
            ),
            // Body
            Padding(
              padding: EdgeInsets.only(left: 6),
              child: Text(
                'No nearby defibrillators were found',
                overflow: TextOverflow.clip,
                style: GoogleFonts.inter(
                  textStyle: TextStyle(
                    fontSize: 18,
                    color: Colors.black87,
                  ),
                ),
              ),
            ),
            SizedBox(
              height: 44,
            ),
            // Close button
            Row(
              children: [
                Expanded(
                  child: ActionButton(
                    text: 'Close',
                    onPressed: () => Navigator.of(context).pop(),
                    backgroundColor: Colors.grey.shade200,
                    textColor: Colors.black87,
                  ),
                ),
              ],
            ),
            SizedBox(
              height: 46 + bottomPadding,
            ),
          ],
        ),
      ),
    );
  }
}
