// User interface
import 'package:flutter/material.dart';
// App settings
import 'package:app_settings/app_settings.dart';
// Buttons
import '/buttons/action_button.dart';

class Permission extends StatelessWidget {
  const Permission({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Padding(
        padding: EdgeInsets.symmetric(horizontal: 22),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Text(
              'Your precise location is used to load nearby defibrillators. ' +
                  'Life Saver will not work if not granted the permission.',
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
