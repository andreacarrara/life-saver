// User interface
import 'package:flutter/material.dart';
// Widgets
import 'home.dart';

void main() {
  runApp(const LifeSaver());
}

class LifeSaver extends StatelessWidget {
  const LifeSaver({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return const MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Life Saver',
      home: Home(),
    );
  }
}
