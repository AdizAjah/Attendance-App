import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:attendance_app/ui/home_screen.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/date_symbol_data_local.dart'; // Tambahkan import ini

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  // Tambahkan baris ini untuk menginisialisasi format tanggal Indonesia
  await initializeDateFormatting('id_ID', null);

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

// Palet Warna Modern
const Color primaryColor = Color(0xFF567DF4); // Royal Blue yang cerah
const Color secondaryColor = Color(0xFF22215B); // Dark Navy untuk teks heading
const Color accentColor = Color(0xFFFF6B6B); // Coral Red untuk aksen/warning
const Color successColor = Color(0xFF4CAF50); // Green untuk sukses
const Color backgroundColor = Color(0xFFF5F7FA); // Light Grey untuk background
const Color textColor = Color(0xFF333333); // Dark Grey untuk teks body
const Color cardColor = Colors.white;

class AppPresensi extends StatelessWidget {
  const AppPresensi({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Attendance App',
      theme: ThemeData(
        primaryColor: primaryColor,
        scaffoldBackgroundColor: backgroundColor,
        
        textTheme: GoogleFonts.poppinsTextTheme(
          Theme.of(context).textTheme,
        ).apply(
          bodyColor: textColor,
          displayColor: secondaryColor,
        ),

        appBarTheme: AppBarTheme(
          backgroundColor: Colors.transparent,
          elevation: 0,
          centerTitle: true,
          titleTextStyle: GoogleFonts.poppins(
            color: secondaryColor,
            fontSize: 18,
            fontWeight: FontWeight.w700,
          ),
          iconTheme: const IconThemeData(color: secondaryColor),
        ),

        cardTheme: CardThemeData(
          elevation: 2,
          shadowColor: Colors.black.withOpacity(0.1),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20.0),
          ),
          color: cardColor,
        ),

        colorScheme: ColorScheme.fromSwatch().copyWith(
          primary: primaryColor,
          secondary: accentColor,
          surface: cardColor,
        ),
        useMaterial3: true,
      ),
      home: const HomeScreen(),
    );
  }
}

// Style Input Modern
InputDecoration kModernInputDecoration(String label, {IconData? icon}) {
  return InputDecoration(
    labelText: label,
    prefixIcon: icon != null ? Icon(icon, color: primaryColor.withOpacity(0.7)) : null,
    labelStyle: GoogleFonts.poppins(
      color: Colors.grey.shade600,
      fontWeight: FontWeight.w500,
      fontSize: 14,
    ),
    filled: true,
    fillColor: Colors.white,
    contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 18),
    border: OutlineInputBorder(
      borderRadius: BorderRadius.circular(15),
      borderSide: BorderSide.none, // Borderless look
    ),
    enabledBorder: OutlineInputBorder(
      borderRadius: BorderRadius.circular(15),
      borderSide: BorderSide(color: Colors.grey.shade200, width: 1),
    ),
    focusedBorder: OutlineInputBorder(
      borderRadius: BorderRadius.circular(15),
      borderSide: const BorderSide(color: primaryColor, width: 1.5),
    ),
    errorBorder: OutlineInputBorder(
      borderRadius: BorderRadius.circular(15),
      borderSide: const BorderSide(color: accentColor, width: 1),
    ),
  );
}

// Tombol Modern
class ModernButton extends StatelessWidget {
  final VoidCallback onPressed;
  final String text;
  final Color color;
  final Color textColor;
  final bool isOutline;
  final IconData? icon;

  const ModernButton({
    Key? key,
    required this.onPressed,
    required this.text,
    this.color = primaryColor,
    this.textColor = Colors.white,
    this.isOutline = false,
    this.icon,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      height: 55,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(15),
        boxShadow: isOutline ? [] : [
          BoxShadow(
            color: color.withOpacity(0.3),
            blurRadius: 10,
            offset: const Offset(0, 5),
          )
        ],
      ),
      child: ElevatedButton(
        onPressed: onPressed,
        style: ElevatedButton.styleFrom(
          backgroundColor: isOutline ? Colors.transparent : color,
          foregroundColor: isOutline ? color : textColor,
          shadowColor: Colors.transparent, // Disable default shadow
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(15),
            side: isOutline ? BorderSide(color: color, width: 2) : BorderSide.none,
          ),
          elevation: 0,
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            if (icon != null) ...[
              Icon(icon, size: 20),
              const SizedBox(width: 8),
            ],
            Text(
              text,
              style: GoogleFonts.poppins(
                fontWeight: FontWeight.w600,
                fontSize: 16,
              ),
            ),
          ],
        ),
      ),
    );
  }
}