import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:attendance_app/ui/home_screen.dart';
import 'package:google_fonts/google_fonts.dart'; // Import google_fonts

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  try {
    await Firebase.initializeApp(
      options: const FirebaseOptions(
        // Konfigurasi Firebase Anda
        apiKey: 'AIzaSyAuOwv_6wAcl-MFERFYnvmFxsRnOdfcVRs', // api_key
        appId:
            '1:224064991079:android:c3a6385b0130c18ecf49c2', // mobilesdk_app_id
        messagingSenderId: '224064991079', // project_number
        projectId: 'attendance-app-44df3', // project_id
      ),
    );
    print("Firebase Terhubung!");
  } catch (e) {
    print("Firebase gagal terhubung: $e");
  }
  runApp(const SakitMataApp()); // Ganti nama App
}

class SakitMataApp extends StatelessWidget {
  const SakitMataApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Attendance App (Sakit Mata Edition)',
      theme: ThemeData(
        // WARNA UTAMA: LIME GREEN & HOT PINK
        primaryColor: const Color(0xFFFF00FF), // Hot Pink
        scaffoldBackgroundColor: const Color(0xFF00FF00), // Lime Green
        
        // FONT UTAMA: COMIC SANS
        textTheme: GoogleFonts.comicNeueTextTheme(
          Theme.of(context).textTheme,
        ).apply(
          bodyColor: const Color(0xFFFF0000), // Teks Merah
          displayColor: const Color(0xFFFF0000), // Teks Merah
        ),

        // APP BAR THEME
        appBarTheme: AppBarTheme(
          backgroundColor: const Color(0xFFFF00FF), // Hot Pink
          elevation: 15,
          centerTitle: true,
          titleTextStyle: GoogleFonts.comicNeue(
            color: const Color(0xFFFFFF00), // Teks Kuning
            fontSize: 24,
            fontWeight: FontWeight.w900,
            shadows: [
              const Shadow(color: Colors.black, blurRadius: 2, offset: Offset(2, 2))
            ]
          ),
          iconTheme: const IconThemeData(color: Color(0xFFFFFF00), size: 30), // Ikon Kuning
        ),

        // Floating Action Button
        floatingActionButtonTheme: const FloatingActionButtonThemeData(
          backgroundColor: Color(0xFFFFFF00), // Kuning
          foregroundColor: Color(0xFFFF0000), // Ikon Merah
        )
      ),
      home: const HomeScreen(), 
    );
  }
}