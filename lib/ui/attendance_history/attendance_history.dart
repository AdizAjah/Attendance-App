import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:attendance_app/main.dart';
import 'package:attendance_app/utils/export_helper.dart';

class AttendanceHistoryScreen extends StatefulWidget {
  const AttendanceHistoryScreen({super.key});

  @override
  State<AttendanceHistoryScreen> createState() =>
      _AttendanceHistoryScreenState();
}

class _AttendanceHistoryScreenState extends State<AttendanceHistoryScreen> {
  final CollectionReference dataCollection = FirebaseFirestore.instance
      .collection('attendance');
  String searchQuery = "";
  String filterStatus = "Semua";

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: backgroundColor,
      appBar: AppBar(
        title: const Text("Riwayat Presensi"),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new_rounded),
          onPressed: () => Navigator.pop(context),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.download_rounded),
            onPressed: () async {
              String report = await ExportHelper.generateReport();
              if (context.mounted) {
                ExportHelper.showReportDialog(context, report);
              }
            },
          ),
          PopupMenuButton<String>(
            icon: const Icon(Icons.filter_list_rounded),
            onSelected: (value) {
              setState(() => filterStatus = value);
            },
            itemBuilder: (context) => [
              const PopupMenuItem(value: "Semua", child: Text("Semua")),
              const PopupMenuItem(value: "Attend", child: Text("Hadir")),
              const PopupMenuItem(value: "Late", child: Text("Terlambat")),
              const PopupMenuItem(value: "Izin", child: Text("Izin/Sakit")),
            ],
          ),
        ],
      ),
      body: Column(
        children: [
          // Search Bar
          Padding(
            padding: const EdgeInsets.all(16),
            child: TextField(
              onChanged: (value) =>
                  setState(() => searchQuery = value.toLowerCase()),
              decoration: InputDecoration(
                hintText: "Cari nama atau tanggal...",
                prefixIcon: const Icon(Icons.search, color: primaryColor),
                filled: true,
                fillColor: Colors.white,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide.none,
                ),
                contentPadding: const EdgeInsets.symmetric(vertical: 0),
              ),
            ),
          ),
          Expanded(
            child: StreamBuilder<QuerySnapshot>(
              stream: dataCollection
                  .orderBy('created_at', descending: true)
                  .snapshots(),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(
                    child: CircularProgressIndicator(color: primaryColor),
                  );
                }
                if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
                  return Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.history_toggle_off_rounded,
                          size: 80,
                          color: Colors.grey.shade300,
                        ),
                        const SizedBox(height: 10),
                        Text(
                          "Belum ada riwayat",
                          style: GoogleFonts.poppins(color: Colors.grey),
                        ),
                      ],
                    ),
                  );
                }

                var data = snapshot.data!.docs;

                // Filter data
                var filteredData = data.where((doc) {
                  Map<String, dynamic> d = doc.data() as Map<String, dynamic>;
                  String name = (d['name'] ?? '').toString().toLowerCase();
                  String datetime = (d['datetime'] ?? '')
                      .toString()
                      .toLowerCase();
                  String status = (d['description'] ?? '')
                      .toString()
                      .toLowerCase();

                  bool matchSearch =
                      searchQuery.isEmpty ||
                      name.contains(searchQuery) ||
                      datetime.contains(searchQuery);

                  bool matchFilter =
                      filterStatus == "Semua" ||
                      status.contains(filterStatus.toLowerCase());

                  return matchSearch && matchFilter;
                }).toList();

                if (filteredData.isEmpty) {
                  return Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.search_off_rounded,
                          size: 80,
                          color: Colors.grey.shade300,
                        ),
                        const SizedBox(height: 10),
                        Text(
                          "Tidak ada data ditemukan",
                          style: GoogleFonts.poppins(color: Colors.grey),
                        ),
                      ],
                    ),
                  );
                }

                return ListView.builder(
                  padding: const EdgeInsets.all(20),
                  itemCount: filteredData.length,
                  itemBuilder: (context, index) {
                    var doc = filteredData[index];
                    Map<String, dynamic> d = doc.data() as Map<String, dynamic>;

                    // Styling Logic
                    String status = d['description'] ?? '';
                    Color statusColor = primaryColor;
                    if (status.toLowerCase().contains('late'))
                      statusColor = Colors.orange;
                    if (status.toLowerCase().contains('izin') ||
                        status.toLowerCase().contains('sakit'))
                      statusColor = accentColor;
                    if (status.toLowerCase().contains('attend'))
                      statusColor = successColor;

                    return Container(
                      margin: const EdgeInsets.only(bottom: 15),
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
                            width: 6,
                            height: 90, // Tinggi menyesuaikan konten
                            decoration: BoxDecoration(
                              color: statusColor,
                              borderRadius: const BorderRadius.only(
                                topLeft: Radius.circular(15),
                                bottomLeft: Radius.circular(15),
                              ),
                            ),
                          ),
                          Expanded(
                            child: Padding(
                              padding: const EdgeInsets.all(16),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Row(
                                    mainAxisAlignment:
                                        MainAxisAlignment.spaceBetween,
                                    children: [
                                      Text(
                                        d['name'] ?? 'Tanpa Nama',
                                        style: GoogleFonts.poppins(
                                          fontWeight: FontWeight.bold,
                                          fontSize: 16,
                                          color: secondaryColor,
                                        ),
                                      ),
                                      Container(
                                        padding: const EdgeInsets.symmetric(
                                          horizontal: 8,
                                          vertical: 4,
                                        ),
                                        decoration: BoxDecoration(
                                          color: statusColor.withOpacity(0.1),
                                          borderRadius: BorderRadius.circular(
                                            8,
                                          ),
                                        ),
                                        child: Text(
                                          status.toUpperCase(),
                                          style: GoogleFonts.poppins(
                                            fontSize: 10,
                                            fontWeight: FontWeight.bold,
                                            color: statusColor,
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                  const SizedBox(height: 8),
                                  Row(
                                    children: [
                                      Icon(
                                        Icons.calendar_today_rounded,
                                        size: 14,
                                        color: Colors.grey.shade500,
                                      ),
                                      const SizedBox(width: 5),
                                      Text(
                                        d['datetime'] ?? '-',
                                        style: GoogleFonts.poppins(
                                          fontSize: 12,
                                          color: Colors.grey.shade600,
                                        ),
                                      ),
                                    ],
                                  ),
                                  if (d['address'] != null &&
                                      d['address'] != '-') ...[
                                    const SizedBox(height: 4),
                                    Row(
                                      children: [
                                        Icon(
                                          Icons.location_on_outlined,
                                          size: 14,
                                          color: Colors.grey.shade500,
                                        ),
                                        const SizedBox(width: 5),
                                        Expanded(
                                          child: Text(
                                            d['address'],
                                            maxLines: 1,
                                            overflow: TextOverflow.ellipsis,
                                            style: GoogleFonts.poppins(
                                              fontSize: 12,
                                              color: Colors.grey.shade600,
                                            ),
                                          ),
                                        ),
                                      ],
                                    ),
                                  ],
                                ],
                              ),
                            ),
                          ),
                          IconButton(
                            icon: const Icon(
                              Icons.delete_outline_rounded,
                              color: Colors.redAccent,
                            ),
                            onPressed: () => _deleteData(doc.id, context),
                          ),
                        ],
                      ),
                    );
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  void _deleteData(String docId, BuildContext context) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: const Text("Hapus Data"),
        content: const Text("Yakin ingin menghapus riwayat ini?"),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text("Batal", style: TextStyle(color: Colors.grey)),
          ),
          TextButton(
            onPressed: () {
              dataCollection.doc(docId).delete();
              Navigator.pop(ctx);
            },
            child: const Text("Hapus", style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
  }
}
