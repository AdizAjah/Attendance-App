import 'dart:math';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

// --- COPY PASTE kSakitMataInputDecoration DARI ATAS KE SINI ---
// Helper untuk Input Style
InputDecoration kSakitMataInputDecoration(String label) {
  return InputDecoration(
    labelText: "--> $label <--",
    labelStyle: GoogleFonts.comicNeue(
      color: const Color(0xFFFF0000), // Merah
      fontWeight: FontWeight.w900,
      fontSize: 16,
    ),
    filled: true,
    fillColor: const Color(0xFFFFFF00), // Latar Kuning
    contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
    border: OutlineInputBorder(
      borderRadius: BorderRadius.circular(0), // Kotak
      borderSide: const BorderSide(color: Color(0xFF0000FF), width: 4), // Border Biru Tebal
    ),
    enabledBorder: OutlineInputBorder(
      borderRadius: BorderRadius.circular(0),
      borderSide: const BorderSide(color: Color(0xFF0000FF), width: 4),
    ),
    focusedBorder: OutlineInputBorder(
      borderRadius: BorderRadius.circular(0),
      borderSide: const BorderSide(color: Color(0xFFFF0000), width: 6), // Border Merah Tebal saat Fokus
    ),
  );
}
// -----------------------------------------------------------------

class AttendanceHistoryScreen extends StatefulWidget {
  const AttendanceHistoryScreen({super.key});

  @override
  State<AttendanceHistoryScreen> createState() =>
      _AttendanceHistoryScreenState();
}

class _AttendanceHistoryScreenState extends State<AttendanceHistoryScreen> {
  final CollectionReference dataCollection = FirebaseFirestore.instance
      .collection('attendance');

  Color _getColorForDescription(String description) {
    if (description.toLowerCase() == 'attend') {
      return Colors.green;
    } else if (description.toLowerCase() == 'late') {
      return Colors.orange;
    } else if (description == 'Permission' || description == 'Sick' || description == 'Others') {
      return Colors.blue;
    }
    return Colors.black;
  }

  IconData _getIconForDescription(String description) {
     if (description.toLowerCase() == 'attend') {
      return Icons.check_circle_outline;
    } else if (description.toLowerCase() == 'late') {
      return Icons.hourglass_bottom_rounded;
    } else if (description == 'Permission' || description == 'Sick' || description == 'Others') {
      return Icons.event_note_outlined;
    }
    return Icons.person_outline;
  }

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
            backgroundColor: const Color(0xFF00FF00), // Latar Lime
            shape: BeveledRectangleBorder(
              side: const BorderSide(color: Color(0xFFFF0000), width: 5), // Border Merah
            ),
            title: Text("EDIT DATA", style: GoogleFonts.comicNeue(fontWeight: FontWeight.w900, color: const Color(0xFFFFFF00), backgroundColor: const Color(0xFFFF00FF))),
            content: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  TextField(
                    controller: nameController,
                    decoration: kSakitMataInputDecoration("Name"),
                  ),
                  const SizedBox(height: 10),
                  TextField(
                    controller: addressController,
                    decoration: kSakitMataInputDecoration("Address"),
                  ),
                  const SizedBox(height: 10),
                  TextField(
                    controller: descriptionController,
                    decoration: kSakitMataInputDecoration("Description"),
                  ),
                  const SizedBox(height: 10),
                  TextField(
                    controller: datetimeController,
                    decoration: kSakitMataInputDecoration("Datetime"),
                  ),
                ],
              ),
            ),
            actions: [
              TextButton(
                style: TextButton.styleFrom(backgroundColor: const Color(0xFFFFFF00)),
                onPressed: () => Navigator.pop(context),
                child: Text(
                  "BATAL",
                  style: GoogleFonts.comicNeue(color: Colors.red, fontWeight: FontWeight.bold),
                ),
              ),
              TextButton(
                style: TextButton.styleFrom(backgroundColor: const Color(0xFFFFFF00)),
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
                child: Text(
                  "SIMPAN",
                  style: GoogleFonts.comicNeue(color: const Color(0xFF0000FF), fontWeight: FontWeight.bold),
                ),
              ),
            ],
          ),
    );
  }

  void _deleteData(String docId) {
    showDialog(
      context: context,
      builder:
          (context) => AlertDialog(
            backgroundColor: const Color(0xFF00FF00), // Latar Lime
            shape: BeveledRectangleBorder(
              side: const BorderSide(color: Color(0xFFFF0000), width: 5), // Border Merah
            ),
            title: Text("HAPUS DATA??", style: GoogleFonts.comicNeue(fontWeight: FontWeight.w900, color: const Color(0xFFFFFF00), backgroundColor: const Color(0xFFFF00FF))),
            content: Text("YAKIN MAU DIHAPUS?!", style: GoogleFonts.comicNeue(color: Colors.red, fontWeight: FontWeight.bold)),
            actions: [
              TextButton(
                style: TextButton.styleFrom(backgroundColor: const Color(0xFFFFFF00)),
                onPressed: () => Navigator.pop(context),
                child: Text("GAK JADI", style: GoogleFonts.comicNeue(color: Colors.blue, fontWeight: FontWeight.bold)),
              ),
              TextButton(
                 style: TextButton.styleFrom(backgroundColor: const Color(0xFFFFFF00)),
                onPressed: () async {
                  await dataCollection.doc(docId).delete();
                  Navigator.pop(context);
                  setState(() {}); 
                },
                child: Text("HAPUS!", style: GoogleFonts.comicNeue(color: Colors.red, fontWeight: FontWeight.bold)),
              ),
            ],
          ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("ATTENDANCE HISTORY"),
      ),
      body: Container(
        // Latar belakang tiling
        decoration: const BoxDecoration(
          image: DecorationImage(
            image: AssetImage('assets/images/ic_leave.png'), // Ganti gambar tiling
            repeat: ImageRepeat.repeat,
            opacity: 0.2,
          ),
        ),
        child: StreamBuilder<QuerySnapshot>(
          stream: dataCollection.orderBy('created_at', descending: true).snapshots(),
          builder: (context, snapshot) {
            if (snapshot.hasData) {
              var data = snapshot.data!.docs;
              return data.isNotEmpty
                  ? ListView.builder(
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
                        elevation: 10,
                        shadowColor: const Color(0xFF0000FF), // Shadow Biru
                        color: const Color(0xFFFFFF00), // Latar Kuning
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(0), // Kotak
                          side: BorderSide(color: itemColor, width: 4), // Border sesuai status
                        ),
                        child: ListTile(
                          contentPadding: const EdgeInsets.symmetric(vertical: 10, horizontal: 15),
                          leading: CircleAvatar(
                            backgroundColor: itemColor,
                            radius: 30,
                            child: Icon(
                              itemIcon,
                              color: Colors.white,
                              size: 30,
                            ),
                          ),
                          title: Text(
                            name.toUpperCase(),
                            style: GoogleFonts.comicNeue(
                              fontWeight: FontWeight.w900,
                              fontSize: 18,
                              color: const Color(0xFF0000FF), // Biru
                            ),
                          ),
                          subtitle: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                description,
                                style: GoogleFonts.comicNeue(
                                  fontWeight: FontWeight.w900,
                                  fontSize: 16,
                                  color: itemColor,
                                ),
                              ),
                              const SizedBox(height: 2),
                              Text(
                                datetime,
                                style: GoogleFonts.comicNeue(fontSize: 14, color: Colors.black, fontWeight: FontWeight.bold),
                              ),
                              if(address != '-')
                                Text(
                                  address,
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                  style: GoogleFonts.comicNeue(fontSize: 12, color: Colors.black54),
                                ),
                            ],
                          ),
                          trailing: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              IconButton(
                                icon: const Icon(
                                  Icons.edit_outlined,
                                  color: Color(0xFF0000FF), // Biru
                                  size: 30,
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
                                  Icons.delete_forever_rounded,
                                  color: Colors.redAccent,
                                  size: 30,
                                ),
                                onPressed: () => _deleteData(docId),
                              ),
                            ],
                          ),
                        ),
                      );
                    },
                  )
                  : Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Icon(Icons.cloud_off_rounded, size: 100, color: Colors.red),
                        const SizedBox(height: 10),
                        Text(
                          "DATA KOSONG!!",
                          style: GoogleFonts.comicNeue(fontSize: 30, color: Colors.red, fontWeight: FontWeight.bold),
                        ),
                      ],
                    ),
                  );
            } else {
              return const Center(child: CircularProgressIndicator(color: Colors.red));
            }
          },
        ),
      ),
    );
  }
}