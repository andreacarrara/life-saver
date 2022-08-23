// User interface
import 'package:flutter/material.dart';
// App settings
import 'package:app_settings/app_settings.dart';
// Buttons
import '/buttons/action-button.dart';

class Permission extends StatelessWidget {
  const Permission({Key? key}) : super(key: key);

  final String text =
      'Your precise location is used to load nearby defibrillators. ' +
          'Life Saver will not work if not granted the permission.';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Padding(
        padding: EdgeInsets.all(22),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Text(
              text,
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 18,
              ),
            ),
            SizedBox(
              height: 24,
            ),
            ActionButton(
              text: 'Open Settings',
              onPressed: AppSettings.openLocationSettings,
              backgroundColor: Colors.grey.shade200,
              textColor: Colors.black,
            ),
          ],
        ),
      ),
    );
  }
}
