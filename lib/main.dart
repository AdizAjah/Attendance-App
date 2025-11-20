import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:attendance_app/ui/home_screen.dart';
import 'package:google_fonts/google_fonts.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  try {
    await Firebase.initializeApp(
      options: const FirebaseOptions(
        apiKey: 'AIzaSyAuOwv_6wAcl-MFERFYnvmFxsRnOdfcVRs', 
        appId: '1:224064991079:android:c3a6385b0130c18ecf49c2', 
        messagingSenderId: '224064991079', 
        projectId: 'attendance-app-44df3',
      ),
    );
    print("Firebase Terhubung!");
  } catch (e) {
    print("Firebase gagal terhubung: $e");
  }
  runApp(const AppPresensi()); 
}

const Color primaryColor = Color(0xFF007AFF); 
const Color accentColor = Color(0xFF34C759); 
const Color backgroundColor = Color(0xFFF0F3F7); 
const Color textColor = Color(0xFF1C1C1E); 
const Color lightAccent = Color(0xFFE5F5E7); 

class AppPresensi extends StatelessWidget {
  const AppPresensi({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Attendance App (Fresh UI)',
      theme: ThemeData(
        primaryColor: primaryColor,
        scaffoldBackgroundColor: backgroundColor,
        
        textTheme: GoogleFonts.poppinsTextTheme(
          Theme.of(context).textTheme,
        ).apply(
          bodyColor: textColor,
          displayColor: textColor,
        ),

        appBarTheme: AppBarTheme(
          backgroundColor: primaryColor, 
          elevation: 0, 
          centerTitle: true,
          titleTextStyle: GoogleFonts.poppins(
            color: Colors.white, 
            fontSize: 20,
            fontWeight: FontWeight.w600,
          ),
          iconTheme: const IconThemeData(color: Colors.white), 
        ),

        // PERBAIKAN: Menggunakan CardThemeData dan MENGHAPUS 'const'
        // karena BorderRadius.circular() tidak konstan.
        cardTheme: CardThemeData(
          elevation: 5,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(15.0),
          ),
          color: Colors.white, 
        ),

        floatingActionButtonTheme: const FloatingActionButtonThemeData(
          backgroundColor: accentColor, 
          foregroundColor: Colors.white, 
        ),

        colorScheme: ColorScheme.fromSwatch(
          primarySwatch: MaterialColor(primaryColor.value, <int, Color>{
            50: primaryColor.withOpacity(0.1),
            100: primaryColor.withOpacity(0.2),
            200: primaryColor.withOpacity(0.3),
            300: primaryColor.withOpacity(0.4),
            400: primaryColor.withOpacity(0.5),
            500: primaryColor.withOpacity(0.6),
            600: primaryColor.withOpacity(0.7),
            700: primaryColor.withOpacity(0.8),
            800: primaryColor.withOpacity(0.9),
            900: primaryColor.withOpacity(1.0),
          }),
        ).copyWith(
          secondary: accentColor,
          background: backgroundColor,
        ),
        useMaterial3: true,
      ),
      home: const HomeScreen(), 
    );
  }
}

InputDecoration kModernInputDecoration(String label) {
  return InputDecoration(
    labelText: label,
    labelStyle: GoogleFonts.poppins(
      color: primaryColor,
      fontWeight: FontWeight.w500,
      fontSize: 14,
    ),
    filled: true,
    fillColor: Colors.white, 
    contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
    border: OutlineInputBorder(
      borderRadius: BorderRadius.circular(12),
      borderSide: const BorderSide(color: Color(0xFFE0E0E0), width: 1), 
    ),
    enabledBorder: OutlineInputBorder(
      borderRadius: BorderRadius.circular(12),
      borderSide: const BorderSide(color: Color(0xFFE0E0E0), width: 1),
    ),
    focusedBorder: OutlineInputBorder(
      borderRadius: BorderRadius.circular(12),
      borderSide: const BorderSide(color: primaryColor, width: 2), 
    ),
  );
}

class ModernButton extends StatelessWidget {
  final VoidCallback onPressed;
  final String text;
  final Color color;
  final Color textColor;
  final bool isOutline;

  const ModernButton({
    Key? key,
    required this.onPressed,
    required this.text,
    this.color = primaryColor,
    this.textColor = Colors.white,
    this.isOutline = false,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    if (isOutline) {
      return OutlinedButton(
        onPressed: onPressed,
        style: OutlinedButton.styleFrom(
          padding: const EdgeInsets.symmetric(vertical: 16),
          side: BorderSide(color: color, width: 2),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          foregroundColor: color,
        ),
        child: Text(
          text.toUpperCase(),
          style: GoogleFonts.poppins(
            fontWeight: FontWeight.w600,
            fontSize: 16,
          ),
        ),
      );
    }
    return ElevatedButton(
      onPressed: onPressed,
      style: ElevatedButton.styleFrom(
        backgroundColor: color,
        foregroundColor: textColor,
        padding: const EdgeInsets.symmetric(vertical: 16),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
        elevation: 5,
        shadowColor: color.withOpacity(0.5),
      ),
      child: Container(
        width: double.infinity,
        alignment: Alignment.center,
        child: Text(
          text.toUpperCase(),
          style: GoogleFonts.poppins(
            fontWeight: FontWeight.w600,
            fontSize: 16,
          ),
        ),
      ),
    );
  }
}