import 'package:flutter/material.dart';
import 'package:attendance_app/ui/absent/absent_screen.dart';
import 'package:attendance_app/ui/attend/attend_screen.dart';
import 'package:attendance_app/ui/attendance_history/attendance_history.dart';
import 'package:google_fonts/google_fonts.dart';

// Hapus StatefulWidget, ganti jadi StatelessWidget lagi
class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  // Widget Kustom untuk Border Rame (INI TETAP SAMA)
  Widget _buildMenuSection({
    required String title,
    required String imagePath,
    required Color borderColor,
    required VoidCallback onTap,
  }) {
    return Expanded(
      child: Container(
        margin: const EdgeInsets.all(10),
        decoration: BoxDecoration(
          border: Border.all(color: borderColor, width: 5),
          borderRadius: BorderRadius.circular(15),
          color: const Color(0xFFFFFF00).withOpacity(0.8), // Latar Kuning Transparan
        ),
        child: InkWell(
          onTap: onTap,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Image(
                image: AssetImage(imagePath),
                height: 100,
                width: 100,
              ),
              const SizedBox(height: 10),
              Container(
                padding: const EdgeInsets.all(5),
                color: const Color(0xFFFF00FF), // Background Teks Pink
                child: Text(
                  title,
                  textAlign: TextAlign.center,
                  style: GoogleFonts.comicNeue(
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                    color: const Color(0xFFFFFF00), // Teks Kuning
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("!! ATTENDANCE APP !!"),
      ),
      // HAPUS Container dengan decoration image dari sini
      body: Column(
        children: [
          // GANTI AnimatedBuilder menjadi Container biasa
          Container(
            width: double.infinity,
            color: Colors.black,
            padding: const EdgeInsets.all(10),
            child: Text(
              "PILIH MENU DI BAWAH INI!!!",
              textAlign: TextAlign.center,
              style: GoogleFonts.comicNeue(
                fontSize: 26,
                fontWeight: FontWeight.w900,
                color: const Color(0xFFFF0000), // Ganti ke warna statis (Merah)
              ),
            ),
          ),

          // Menu (Isi tetap sama)
          Expanded(
            child: Column(
              children: [
                _buildMenuSection(
                  title: "Attendance Record",
                  imagePath: 'assets/images/ic_absen.png',
                  borderColor: const Color(0xFFFF0000), // Border Merah
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
                  title: "Permission",
                  imagePath: 'assets/images/ic_leave.png',
                  borderColor: const Color(0xFF0000FF), // Border Biru
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
                  title: "Attendance History",
                  imagePath: 'assets/images/ic_history.png',
                  borderColor: const Color(0xFF000000), // Border Hitam
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

          // Footer (Tetap sama)
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(10),
            color: const Color(0xFFFF00FF), // Pink
            child: Text(
              "IDN Boarding School Solo",
              textAlign: TextAlign.center,
              style: GoogleFonts.comicNeue(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: const Color(0xFFFFFF00), // Kuning
              ),
            ),
          ),
        ],
      ),
    );
  }
}