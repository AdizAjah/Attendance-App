import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:attendance_app/main.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class StatisticsScreen extends StatefulWidget {
  const StatisticsScreen({super.key});

  @override
  State<StatisticsScreen> createState() => _StatisticsScreenState();
}

class _StatisticsScreenState extends State<StatisticsScreen> {
  final CollectionReference dataCollection = FirebaseFirestore.instance
      .collection('attendance');

  int totalAttend = 0;
  int totalLate = 0;
  int totalAbsent = 0;
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadStatistics();
  }

  Future<void> _loadStatistics() async {
    try {
      final snapshot = await dataCollection.get();
      int attend = 0, late = 0, absent = 0;

      for (var doc in snapshot.docs) {
        Map<String, dynamic> data = doc.data() as Map<String, dynamic>;
        String status = (data['description'] ?? '').toString().toLowerCase();

        if (status.contains('attend')) {
          attend++;
        } else if (status.contains('late')) {
          late++;
        } else {
          absent++;
        }
      }

      setState(() {
        totalAttend = attend;
        totalLate = late;
        totalAbsent = absent;
        isLoading = false;
      });
    } catch (e) {
      setState(() => isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    int total = totalAttend + totalLate + totalAbsent;
    double attendPercentage = total > 0 ? (totalAttend / total) * 100 : 0;

    return Scaffold(
      backgroundColor: backgroundColor,
      appBar: AppBar(
        title: const Text("Statistik Kehadiran"),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new_rounded),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: isLoading
          ? const Center(child: CircularProgressIndicator(color: primaryColor))
          : SingleChildScrollView(
              padding: const EdgeInsets.all(24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Overall Stats Card
                  Container(
                    padding: const EdgeInsets.all(24),
                    decoration: BoxDecoration(
                      gradient: const LinearGradient(
                        colors: [primaryColor, Color(0xFF42A5F5)],
                      ),
                      borderRadius: BorderRadius.circular(20),
                      boxShadow: [
                        BoxShadow(
                          color: primaryColor.withOpacity(0.3),
                          blurRadius: 15,
                          offset: const Offset(0, 8),
                        ),
                      ],
                    ),
                    child: Column(
                      children: [
                        Text(
                          "Tingkat Kehadiran",
                          style: GoogleFonts.poppins(
                            color: Colors.white.withOpacity(0.9),
                            fontSize: 14,
                          ),
                        ),
                        const SizedBox(height: 10),
                        Text(
                          "${attendPercentage.toStringAsFixed(1)}%",
                          style: GoogleFonts.poppins(
                            color: Colors.white,
                            fontSize: 48,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 5),
                        Text(
                          "$totalAttend dari $total hari hadir",
                          style: GoogleFonts.poppins(
                            color: Colors.white.withOpacity(0.8),
                            fontSize: 13,
                          ),
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 30),

                  Text(
                    "Detail Statistik",
                    style: GoogleFonts.poppins(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: secondaryColor,
                    ),
                  ),

                  const SizedBox(height: 16),

                  // Stats Grid
                  Row(
                    children: [
                      Expanded(
                        child: _buildStatCard(
                          "Hadir",
                          totalAttend.toString(),
                          Icons.check_circle_rounded,
                          successColor,
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: _buildStatCard(
                          "Terlambat",
                          totalLate.toString(),
                          Icons.access_time_rounded,
                          Colors.orange,
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(height: 12),

                  Row(
                    children: [
                      Expanded(
                        child: _buildStatCard(
                          "Izin/Sakit",
                          totalAbsent.toString(),
                          Icons.event_busy_rounded,
                          accentColor,
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: _buildStatCard(
                          "Total",
                          total.toString(),
                          Icons.calendar_month_rounded,
                          primaryColor,
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(height: 30),

                  // Progress Bars
                  _buildProgressBar("Hadir", totalAttend, total, successColor),
                  const SizedBox(height: 12),
                  _buildProgressBar(
                    "Terlambat",
                    totalLate,
                    total,
                    Colors.orange,
                  ),
                  const SizedBox(height: 12),
                  _buildProgressBar(
                    "Izin/Sakit",
                    totalAbsent,
                    total,
                    accentColor,
                  ),
                ],
              ),
            ),
    );
  }

  Widget _buildStatCard(
    String label,
    String value,
    IconData icon,
    Color color,
  ) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(15),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.shade100,
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: color.withOpacity(0.1),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(icon, color: color, size: 28),
          ),
          const SizedBox(height: 12),
          Text(
            value,
            style: GoogleFonts.poppins(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: secondaryColor,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            label,
            style: GoogleFonts.poppins(
              fontSize: 12,
              color: Colors.grey.shade600,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildProgressBar(String label, int value, int total, Color color) {
    double percentage = total > 0 ? (value / total) : 0;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              label,
              style: GoogleFonts.poppins(
                fontSize: 14,
                fontWeight: FontWeight.w600,
                color: secondaryColor,
              ),
            ),
            Text(
              "$value hari",
              style: GoogleFonts.poppins(
                fontSize: 12,
                color: Colors.grey.shade600,
              ),
            ),
          ],
        ),
        const SizedBox(height: 8),
        ClipRRect(
          borderRadius: BorderRadius.circular(10),
          child: LinearProgressIndicator(
            value: percentage,
            minHeight: 8,
            backgroundColor: Colors.grey.shade200,
            valueColor: AlwaysStoppedAnimation<Color>(color),
          ),
        ),
      ],
    );
  }
}
