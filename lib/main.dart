// User interface
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:modal_bottom_sheet/modal_bottom_sheet.dart';
// Home
import 'home.dart';

void main() {
  runApp(LifeSaver());
}

class LifeSaver extends StatelessWidget {
  const LifeSaver({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Life Saver',
      theme: ThemeData(
        textTheme: GoogleFonts.interTextTheme(),
      ),
      onGenerateRoute: (RouteSettings settings) => MaterialWithModalsPageRoute(
        builder: (BuildContext context) => Home(),
      ),
      debugShowCheckedModeBanner: false,
    );
  }
}
