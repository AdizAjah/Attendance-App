import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class ExportHelper {
  static Future<String> generateReport() async {
    try {
      final snapshot = await FirebaseFirestore.instance
          .collection('attendance')
          .orderBy('created_at', descending: true)
          .get();

      if (snapshot.docs.isEmpty) {
        return "Tidak ada data untuk diekspor.";
      }

      StringBuffer report = StringBuffer();
      report.writeln("=" * 50);
      report.writeln("LAPORAN KEHADIRAN");
      report.writeln(
        "Tanggal Export: ${DateFormat('dd MMMM yyyy HH:mm').format(DateTime.now())}",
      );
      report.writeln("=" * 50);
      report.writeln();

      int attend = 0, late = 0, absent = 0;

      for (var doc in snapshot.docs) {
        Map<String, dynamic> data = doc.data();
        String name = data['name'] ?? '-';
        String datetime = data['datetime'] ?? '-';
        String status = data['description'] ?? '-';
        String address = data['address'] ?? '-';

        report.writeln("Nama      : $name");
        report.writeln("Waktu     : $datetime");
        report.writeln("Status    : $status");
        report.writeln("Lokasi    : $address");
        report.writeln("-" * 50);

        // Count statistics
        String statusLower = status.toLowerCase();
        if (statusLower.contains('attend')) {
          attend++;
        } else if (statusLower.contains('late')) {
          late++;
        } else {
          absent++;
        }
      }

      report.writeln();
      report.writeln("=" * 50);
      report.writeln("RINGKASAN");
      report.writeln("=" * 50);
      report.writeln("Total Hadir       : $attend");
      report.writeln("Total Terlambat   : $late");
      report.writeln("Total Izin/Sakit  : $absent");
      report.writeln("Total Keseluruhan : ${attend + late + absent}");
      report.writeln("=" * 50);

      return report.toString();
    } catch (e) {
      return "Error saat membuat laporan: $e";
    }
  }

  static void showReportDialog(BuildContext context, String report) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text("Laporan Kehadiran"),
        content: SingleChildScrollView(
          child: SelectableText(
            report,
            style: const TextStyle(fontFamily: 'monospace', fontSize: 12),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text("Tutup"),
          ),
        ],
      ),
    );
  }
}
