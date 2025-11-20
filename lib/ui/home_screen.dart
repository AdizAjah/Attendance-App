import 'package:flutter/material.dart';
import 'package:attendance_app/ui/absent/absent_screen.dart';
import 'package:attendance_app/ui/attend/attend_screen.dart';
import 'package:attendance_app/ui/attendance_history/attendance_history.dart';
import 'package:google_fonts/google_fonts.dart';
// Import tema baru
import 'package:attendance_app/main.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  // Ubah animasi menjadi warna aksen yang lebih lembut
  late Animation<Color?> _colorAnimation; 

  @override
  void initState() {
    super.initState();
    // Animasi berkedip (opsional) tetap dipertahankan
    _controller = AnimationController(
      duration: const Duration(milliseconds: 1000),
      vsync: this,
    )..repeat(reverse: true);

    _colorAnimation = ColorTween(
      begin: primaryColor.withOpacity(0.8), // Biru agak pudar
      end: accentColor.withOpacity(0.8),   // Hijau agak pudar
    ).animate(_controller);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  // Widget Kustom untuk Menu Card yang Fresh
  Widget _buildMenuSection({
    required String title,
    required String imagePath,
    required Color cardColor,
    required Color iconColor,
    required VoidCallback onTap,
  }) {
    return Expanded(
      child: Card(
        margin: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
        color: Colors.white,
        elevation: 8,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(15),
          side: BorderSide(color: cardColor, width: 3),
        ),
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(15),
          child: Container(
            padding: const EdgeInsets.all(20),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                // Menggunakan CircleAvatar untuk highlight icon
                CircleAvatar(
                  radius: 40,
                  backgroundColor: cardColor.withOpacity(0.1),
                  child: Image.asset(
                    imagePath,
                    height: 60,
                    width: 60,
                    color: iconColor, // Beri warna pada icon agar seragam
                    errorBuilder: (context, error, stackTrace) => Icon(
                      Icons.folder_open,
                      color: iconColor,
                      size: 40,
                    ),
                  ),
                ),
                const SizedBox(height: 15),
                Text(
                  title,
                  textAlign: TextAlign.center,
                  style: GoogleFonts.poppins(
                    fontSize: 18,
                    fontWeight: FontWeight.w700,
                    color: textColor,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("APP PRESENSI"),
      ),
      body: Column(
        children: [
          // Header Informasi
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(15),
            decoration: BoxDecoration(
              color: primaryColor,
              borderRadius: const BorderRadius.only(
                bottomLeft: Radius.circular(20),
                bottomRight: Radius.circular(20),
              ),
              boxShadow: [
                BoxShadow(
                  color: primaryColor.withOpacity(0.3),
                  blurRadius: 10,
                  offset: const Offset(0, 5),
                ),
              ],
            ),
            child: AnimatedBuilder(
              animation: _colorAnimation,
              builder: (context, child) {
                return Text(
                  "PILIH MENU UTAMA",
                  textAlign: TextAlign.center,
                  style: GoogleFonts.poppins(
                    fontSize: 22,
                    fontWeight: FontWeight.w800,
                    color: Colors.white.withOpacity(0.9), // Teks putih berkedip lembut
                  ),
                );
              },
            ),
          ),

          // Menu Pilihan
          Expanded(
            child: Column(
              children: [
                _buildMenuSection(
                  title: "ABSENSI HARI INI",
                  imagePath: 'assets/images/ic_absen.png',
                  cardColor: accentColor,
                  iconColor: accentColor,
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => const AttendScreen(),
                      ),
                    );
                  },
                ),
                _buildMenuSection(
                  title: "PENGAJUAN IZIN",
                  imagePath: 'assets/images/ic_leave.png',
                  cardColor: primaryColor,
                  iconColor: primaryColor,
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => const AbsentScreen(),
                      ),
                    );
                  },
                ),
                _buildMenuSection(
                  title: "RIWAYAT ABSENSI",
                  imagePath: 'assets/images/ic_history.png',
                  cardColor: Colors.orange,
                  iconColor: Colors.orange,
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => const AttendanceHistoryScreen(),
                      ),
                    );
                  },
                ),
              ],
            ),
          ),

          // Footer
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(12),
            color: primaryColor.withOpacity(0.1), 
            child: Text(
              "IDN Boarding School Solo © 2025",
              textAlign: TextAlign.center,
              style: GoogleFonts.poppins(
                fontSize: 14,
                fontWeight: FontWeight.w500,
                color: textColor.withOpacity(0.7), 
              ),
            ),
          ),
        ],
      ),
    );
  }
}