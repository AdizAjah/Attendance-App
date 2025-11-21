import 'package:flutter/material.dart';
import 'package:attendance_app/ui/absent/absent_screen.dart';
import 'package:attendance_app/ui/attend/attend_screen.dart';
import 'package:attendance_app/ui/attendance_history/attendance_history.dart';
import 'package:attendance_app/ui/profile/profile_screen.dart';
import 'package:attendance_app/ui/statistics/statistics_screen.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import 'package:attendance_app/main.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  @override
  Widget build(BuildContext context) {
    var now = DateTime.now();
    String dateDisplay = DateFormat('EEEE, d MMMM yyyy', 'id_ID').format(now);
    String timeDisplay = DateFormat('HH:mm').format(now);

    return Scaffold(
      backgroundColor: backgroundColor,
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header Section dengan Gradient
            Container(
              width: double.infinity,
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [primaryColor, primaryColor.withValues(alpha: 0.8)],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: const BorderRadius.only(
                  bottomLeft: Radius.circular(30),
                  bottomRight: Radius.circular(30),
                ),
              ),
              child: Padding(
                padding: const EdgeInsets.fromLTRB(24, 20, 24, 30),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              "Selamat Datang 👋",
                              style: GoogleFonts.poppins(
                                fontSize: 14,
                                color: Colors.white.withValues(alpha: 0.9),
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              "User Presensi",
                              style: GoogleFonts.poppins(
                                fontSize: 22,
                                fontWeight: FontWeight.bold,
                                color: Colors.white,
                              ),
                            ),
                          ],
                        ),
                        Container(
                          padding: const EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            color: Colors.white.withValues(alpha: 0.2),
                            borderRadius: BorderRadius.circular(15),
                          ),
                          child: const Icon(
                            Icons.notifications_none_rounded,
                            color: Colors.white,
                            size: 26,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 20),
                    // Card Tanggal & Waktu
                    Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: Colors.white.withValues(alpha: 0.15),
                        borderRadius: BorderRadius.circular(15),
                        border: Border.all(
                          color: Colors.white.withValues(alpha: 0.3),
                          width: 1,
                        ),
                      ),
                      child: Row(
                        children: [
                          Container(
                            padding: const EdgeInsets.all(10),
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: const Icon(
                              Icons.calendar_today_rounded,
                              color: primaryColor,
                              size: 24,
                            ),
                          ),
                          const SizedBox(width: 15),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  dateDisplay,
                                  style: GoogleFonts.poppins(
                                    color: Colors.white,
                                    fontSize: 14,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                                const SizedBox(height: 2),
                                Text(
                                  "Pukul $timeDisplay WIB",
                                  style: GoogleFonts.poppins(
                                    color: Colors.white.withValues(alpha: 0.8),
                                    fontSize: 12,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),

            const SizedBox(height: 30),

            // Menu Section
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24),
              child: Text(
                "Menu Utama",
                style: GoogleFonts.poppins(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: secondaryColor,
                ),
              ),
            ),

            const SizedBox(height: 16),

            // Quick Stats
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24),
              child: Row(
                children: [
                  Expanded(
                    child: _buildQuickStat(
                      "Hadir Bulan Ini",
                      "12 Hari",
                      Icons.check_circle_outline,
                      successColor,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: _buildQuickStat(
                      "Terlambat",
                      "2 Hari",
                      Icons.access_time,
                      Colors.orange,
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 20),

            Expanded(
              child: GridView.count(
                padding: const EdgeInsets.symmetric(horizontal: 24),
                crossAxisCount: 2,
                childAspectRatio: 1.0,
                mainAxisSpacing: 16,
                crossAxisSpacing: 16,
                children: [
                  _buildMenuCard(
                    context,
                    title: "Absen\nMasuk",
                    icon: Icons.fingerprint_rounded,
                    gradient: const LinearGradient(
                      colors: [Color(0xFF4CAF50), Color(0xFF66BB6A)],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                    onTap: () => Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => const AttendScreen(),
                      ),
                    ),
                  ),
                  _buildMenuCard(
                    context,
                    title: "Izin /\nCuti",
                    icon: Icons.event_note_rounded,
                    gradient: const LinearGradient(
                      colors: [Color(0xFFFF9800), Color(0xFFFFB74D)],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                    onTap: () => Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => const AbsentScreen(),
                      ),
                    ),
                  ),
                  _buildMenuCard(
                    context,
                    title: "Riwayat\nAbsensi",
                    icon: Icons.history_rounded,
                    gradient: const LinearGradient(
                      colors: [Color(0xFF2196F3), Color(0xFF42A5F5)],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                    onTap: () => Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => const AttendanceHistoryScreen(),
                      ),
                    ),
                  ),
                  _buildMenuCard(
                    context,
                    title: "Statistik",
                    icon: Icons.bar_chart_rounded,
                    gradient: const LinearGradient(
                      colors: [Color(0xFFE91E63), Color(0xFFF48FB1)],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                    onTap: () => Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => const StatisticsScreen(),
                      ),
                    ),
                  ),
                  _buildMenuCard(
                    context,
                    title: "Profil\nSaya",
                    icon: Icons.person_rounded,
                    gradient: const LinearGradient(
                      colors: [Color(0xFF9C27B0), Color(0xFFBA68C8)],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                    onTap: () => Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => const ProfileScreen(),
                      ),
                    ),
                  ),
                  _buildMenuCard(
                    context,
                    title: "Pengaturan",
                    icon: Icons.settings_rounded,
                    gradient: const LinearGradient(
                      colors: [Color(0xFF607D8B), Color(0xFF90A4AE)],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                    onTap: () {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text("Fitur Pengaturan segera hadir!"),
                        ),
                      );
                    },
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildMenuCard(
    BuildContext context, {
    required String title,
    required IconData icon,
    required Gradient gradient,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        decoration: BoxDecoration(
          gradient: gradient,
          borderRadius: BorderRadius.circular(20),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.1),
              blurRadius: 10,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.3),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(icon, color: Colors.white, size: 32),
              ),
              const Spacer(),
              Text(
                title,
                style: GoogleFonts.poppins(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                  height: 1.2,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildQuickStat(
    String label,
    String value,
    IconData icon,
    Color color,
  ) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(15),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.shade100,
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: color.withOpacity(0.1),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(icon, color: color, size: 24),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  value,
                  style: GoogleFonts.poppins(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: secondaryColor,
                  ),
                ),
                Text(
                  label,
                  style: GoogleFonts.poppins(
                    fontSize: 11,
                    color: Colors.grey.shade600,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
