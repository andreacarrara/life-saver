// User interface
import 'package:flutter/material.dart';
// Buttons
import '/buttons/action_button.dart';

class Error extends StatelessWidget {
  final String message;
  final Function() onPressed;

  const Error({
    Key? key,
    required this.message,
    required this.onPressed,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Padding(
        padding: EdgeInsets.symmetric(
          horizontal: 22,
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Text(
              message,
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 18,
              ),
            ),
            SizedBox(
              height: 24,
            ),
            ActionButton(
              onPressed: onPressed,
              text: 'Open Settings',
              textColor: Colors.black,
              backgroundColor: Colors.grey[200]!,
            ),
          ],
        ),
      ),
    );
  }
}
