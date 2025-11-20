import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
// Import tema dan widget baru
import 'package:attendance_app/main.dart'; // Import primaryColor, accentColor, kModernInputDecoration, ModernButton

// Hapus definisi kSakitMataInputDecoration karena sudah diimpor dari main.dart

class AttendanceHistoryScreen extends StatefulWidget {
  const AttendanceHistoryScreen({super.key});

  @override
  State<AttendanceHistoryScreen> createState() =>
      _AttendanceHistoryScreenState();
}

class _AttendanceHistoryScreenState extends State<AttendanceHistoryScreen> {
  final CollectionReference dataCollection = FirebaseFirestore.instance
      .collection('attendance');

  // Skema warna baru untuk status
  Color _getColorForDescription(String description) {
    if (description.toLowerCase() == 'attend') {
      return accentColor; // Hijau Mint untuk Hadir
    } else if (description.toLowerCase() == 'late') {
      return Colors.orange.shade700; // Orange yang lebih kalem untuk Terlambat
    } else if (description == 'Permission' || description == 'Izin' || description == 'Sick' || description == 'Sakit' || description == 'Others' || description == 'Lainnya') {
      return primaryColor; // Biru Laut untuk Izin/Sakit
    }
    return textColor;
  }

  IconData _getIconForDescription(String description) {
     if (description.toLowerCase() == 'attend') {
      return Icons.check_circle_outline;
    } else if (description.toLowerCase() == 'late') {
      return Icons.access_time_filled_rounded;
    } else if (description == 'Permission' || description == 'Izin' || description == 'Sick' || description == 'Sakit' || description == 'Others' || description == 'Lainnya') {
      return Icons.event_note_outlined;
    }
    return Icons.person_outline;
  }

  // Dialog Edit Data dengan UI yang bersih
  void _editData(
    String docId,
    String currentName,
    String currentAddress,
    String currentDescription,
    String currentDatetime,
  ) {
    TextEditingController nameController = TextEditingController(
      text: currentName,
    );
    TextEditingController addressController = TextEditingController(
      text: currentAddress,
    );
    TextEditingController descriptionController = TextEditingController(
      text: currentDescription,
    );
    TextEditingController datetimeController = TextEditingController(
      text: currentDatetime,
    );

    showDialog(
      context: context,
      builder:
          (context) => AlertDialog(
            backgroundColor: Colors.white, 
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(15),
            ),
            title: Text("Edit Data", style: GoogleFonts.poppins(fontWeight: FontWeight.w600, color: textColor)),
            content: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  TextField(
                    controller: nameController,
                    decoration: kModernInputDecoration("Nama"),
                  ),
                  const SizedBox(height: 10),
                  TextField(
                    controller: addressController,
                    decoration: kModernInputDecoration("Alamat"),
                  ),
                  const SizedBox(height: 10),
                  TextField(
                    controller: descriptionController,
                    decoration: kModernInputDecoration("Keterangan"),
                  ),
                  const SizedBox(height: 10),
                  TextField(
                    controller: datetimeController,
                    decoration: kModernInputDecoration("Waktu (Datetime)"),
                  ),
                ],
              ),
            ),
            actions: [
              ModernButton(
                text: "BATAL",
                color: Colors.grey.shade400,
                textColor: textColor,
                onPressed: () => Navigator.pop(context),
              ),
              ModernButton(
                text: "SIMPAN",
                color: primaryColor,
                onPressed: () async {
                  await dataCollection.doc(docId).update({
                    'name': nameController.text,
                    'address': addressController.text,
                    'description': descriptionController.text,
                    'datetime': datetimeController.text,
                  });
                  Navigator.pop(context);
                  setState(() {}); 
                },
              ),
            ],
          ),
    );
  }

  // Dialog Hapus Data dengan UI yang bersih
  void _deleteData(String docId) {
    showDialog(
      context: context,
      builder:
          (context) => AlertDialog(
            backgroundColor: Colors.white, 
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(15),
            ),
            title: Text("Konfirmasi Hapus", style: GoogleFonts.poppins(fontWeight: FontWeight.w600, color: textColor)),
            content: Text("Anda yakin ingin menghapus data ini?", style: GoogleFonts.poppins(color: textColor)),
            actions: [
              ModernButton(
                text: "TIDAK",
                color: Colors.grey.shade400,
                textColor: textColor,
                onPressed: () => Navigator.pop(context),
              ),
              ModernButton(
                text: "HAPUS",
                color: Colors.red,
                onPressed: () async {
                  await dataCollection.doc(docId).delete();
                  Navigator.pop(context);
                  setState(() {}); 
                },
              ),
            ],
          ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("RIWAYAT ABSENSI"),
      ),
      body: StreamBuilder<QuerySnapshot>(
        // Mengurutkan berdasarkan timestamp untuk konsistensi
        stream: dataCollection.orderBy('created_at', descending: true).snapshots(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator(color: primaryColor));
          }
          if (snapshot.hasError) {
            return Center(child: Text("Error: ${snapshot.error}", style: GoogleFonts.poppins(color: Colors.red)));
          }

          var data = snapshot.data!.docs;
          if (data.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.inbox_outlined, size: 80, color: textColor.withOpacity(0.4)),
                  const SizedBox(height: 10),
                  Text(
                    "Belum Ada Data Absensi.",
                    style: GoogleFonts.poppins(fontSize: 18, color: textColor.withOpacity(0.6), fontWeight: FontWeight.w500),
                  ),
                ],
              ),
            );
          }

          return ListView.builder(
            padding: const EdgeInsets.all(10),
            itemCount: data.length,
            itemBuilder: (context, index) {
              var docId = data[index].id;
              var docData = data[index].data() as Map<String, dynamic>;
              var name = docData.containsKey('name') ? docData['name'] : 'No Name';
              var address = docData.containsKey('address') ? docData['address'] : '-';
              var description = docData.containsKey('description') ? docData['description'] : 'N/A';
              var datetime = docData.containsKey('datetime') ? docData['datetime'] : 'N/A';

              Color itemColor = _getColorForDescription(description);
              IconData itemIcon = _getIconForDescription(description);

              return Card(
                margin: const EdgeInsets.symmetric(vertical: 8, horizontal: 5),
                elevation: 4,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(15), 
                  side: BorderSide(color: itemColor.withOpacity(0.5), width: 1), 
                ),
                child: ListTile(
                  contentPadding: const EdgeInsets.symmetric(vertical: 10, horizontal: 15),
                  leading: CircleAvatar(
                    backgroundColor: itemColor,
                    radius: 25,
                    child: Icon(
                      itemIcon,
                      color: Colors.white,
                      size: 24,
                    ),
                  ),
                  title: Text(
                    name,
                    style: GoogleFonts.poppins(
                      fontWeight: FontWeight.w700,
                      fontSize: 16,
                      color: textColor,
                    ),
                  ),
                  subtitle: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                        decoration: BoxDecoration(
                          color: itemColor.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(5),
                        ),
                        child: Text(
                          description.toUpperCase(),
                          style: GoogleFonts.poppins(
                            fontWeight: FontWeight.w600,
                            fontSize: 12,
                            color: itemColor,
                          ),
                        ),
                      ),
                      const SizedBox(height: 5),
                      Text(
                        datetime,
                        style: GoogleFonts.poppins(fontSize: 12, color: textColor.withOpacity(0.7)),
                      ),
                      if(address != '-')
                        Text(
                          address,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: GoogleFonts.poppins(fontSize: 12, color: textColor.withOpacity(0.5)),
                        ),
                    ],
                  ),
                  trailing: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      IconButton(
                        icon: const Icon(
                          Icons.edit_outlined,
                          color: primaryColor,
                          size: 22,
                        ),
                        onPressed:
                            () => _editData(
                              docId,
                              name,
                              address,
                              description,
                              datetime,
                            ),
                      ),
                      IconButton(
                        icon: const Icon(
                          Icons.delete_outline_rounded,
                          color: Colors.redAccent,
                          size: 22,
                        ),
                        onPressed: () => _deleteData(docId),
                      ),
                    ],
                  ),
                ),
              );
            },
          );
        },
      ),
    );
  }
}