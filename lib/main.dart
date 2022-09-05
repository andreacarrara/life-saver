// Splash screen
import 'package:flutter_native_splash/flutter_native_splash.dart';
// User interface
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:modal_bottom_sheet/modal_bottom_sheet.dart';
// Firebase Firestore
import 'firebase_options.dart';
import 'package:firebase_core/firebase_core.dart';
// Home
import 'home.dart';

void main() async {
  WidgetsBinding widgetsBinding = WidgetsFlutterBinding.ensureInitialized();
  // Preserve splash screen
  FlutterNativeSplash.preserve(widgetsBinding: widgetsBinding);
  // Initialize Firebase
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
  runApp(LifeSaver());
}

class LifeSaver extends StatelessWidget {
  const LifeSaver({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Life Saver',
      // Set app font
      theme: ThemeData(
        textTheme: GoogleFonts.interTextTheme(),
      ),
      // Enable sheet animation
      onGenerateRoute: (settings) => MaterialWithModalsPageRoute(
        builder: (context) => Home(),
      ),
      debugShowCheckedModeBanner: false,
    );
  }
}
