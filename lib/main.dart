import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:attendance_app/ui/home_screen.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  try {
    await Firebase.initializeApp(
      options: const FirebaseOptions(
        // Add your own Firebase project configuration from google-services.json
        apiKey: 'AIzaSyAuOwv_6wAcl-MFERFYnvmFxsRnOdfcVRs', // api_key
        appId:
            '1:224064991079:android:c3a6385b0130c18ecf49c2', // mobilesdk_app_id
        messagingSenderId: '224064991079', // project_number
        projectId: 'attendance-app-44df3', // project_id
      ),
    );
    // Firebase connection success
    print("Firebase Terhubung ke:");
    print("API Key: ${Firebase.app().options.apiKey}");
    print("Project ID: ${Firebase.app().options.projectId}");
  } catch (e) {
    // Firebase connection failed
    print("Firebase gagal terhubung: $e");
  }
  // runApp(const HomeScreen());
  runApp(const TestApp());
}

class TestApp extends StatelessWidget {
  // Main App
  const TestApp({super.key}); // Constructor of TestApp clas

  @override // can give information about about your missing override code
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false, // remove debug banner
      home: const HomeScreen(), // HomeScreen class
    );
  }
}