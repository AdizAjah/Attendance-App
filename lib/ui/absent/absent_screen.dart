import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:attendance_app/ui/home_screen.dart';
import 'package:google_fonts/google_fonts.dart';

// Import tema dan widget baru
import 'package:attendance_app/main.dart'; // Import primaryColor, accentColor, kModernInputDecoration, ModernButton

// Hapus definisi kSakitMataInputDecoration dan SakitMataButton karena sudah diimpor dari main.dart

class AbsentScreen extends StatefulWidget {
  const AbsentScreen({super.key});

  @override
  State<AbsentScreen> createState() => _AbsentScreenState();
}

class _AbsentScreenState extends State<AbsentScreen> {
  var categoriesList = <String>[
    "Pilih Keterangan:",
    "Lainnya",
    "Izin",
    "Sakit",
  ];

  final controllerName = TextEditingController();
  final CollectionReference dataCollection = FirebaseFirestore.instance
      .collection('attendance');

  String dropValueCategories = "Pilih Keterangan:";
  final fromController = TextEditingController();
  final toController = TextEditingController();

  @override
  void dispose() {
    controllerName.dispose();
    fromController.dispose();
    toController.dispose();
    super.dispose();
  }

  // Dialog Loading dengan UI yang lebih bersih
  showLoaderDialog(BuildContext context) {
    AlertDialog alert = AlertDialog(
      backgroundColor: Colors.white, 
      contentPadding: const EdgeInsets.all(20),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
      content: Row(
        children: [
          const CircularProgressIndicator(
            valueColor: AlwaysStoppedAnimation<Color>(primaryColor),
          ),
          Container(
            margin: const EdgeInsets.only(left: 20),
            child: Text(
              "Mengajukan izin...",
              style: GoogleFonts.poppins(color: textColor, fontWeight: FontWeight.w500),
            ),
          ),
        ],
      ),
    );
    showDialog(
      barrierDismissible: false,
      context: context,
      builder: (BuildContext context) {
        return alert;
      },
    );
  }

  Future<void> submitAbsen(
    String nama,
    String keterangan,
    String from,
    String until,
  ) async {
    if (nama.isEmpty ||
        keterangan == "Pilih Keterangan:" ||
        from.isEmpty ||
        until.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            "Mohon lengkapi semua kolom!",
            style: GoogleFonts.poppins(color: Colors.white, fontWeight: FontWeight.w600),
          ),
          backgroundColor: Colors.redAccent,
          behavior: SnackBarBehavior.floating,
        ),
      );
      return;
    }

    showLoaderDialog(context);

    try {
      await dataCollection.add({
        'address': '-', // Tidak relevan untuk izin/cuti
        'name': nama,
        'description': keterangan,
        'datetime': '$from - $until',
        'created_at': FieldValue.serverTimestamp(),
      });

      Navigator.of(context).pop();

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Row(
            children: [
              const Icon(Icons.check_circle_outline, color: Colors.white),
              const SizedBox(width: 10),
              Text(
                "Pengajuan Izin BERHASIL!",
                style: GoogleFonts.poppins(color: Colors.white, fontWeight: FontWeight.w600),
              ),
            ],
          ),
          backgroundColor: accentColor, 
          behavior: SnackBarBehavior.floating,
        ),
      );

      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => const HomeScreen()),
      );
    } catch (e) {
      Navigator.of(context).pop();
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            "ERROR: Gagal menyimpan data.",
            style: GoogleFonts.poppins(color: Colors.white, fontWeight: FontWeight.w600),
          ),
          backgroundColor: Colors.redAccent,
          behavior: SnackBarBehavior.floating,
        ),
      );
    }
  }

  Future<void> _selectDate(
      BuildContext context, TextEditingController controller) async {
    DateTime? pickedDate = await showDatePicker(
      builder: (BuildContext context, Widget? child) {
        return Theme(
          // Tema Date Picker yang Fresh
          data: Theme.of(context).copyWith(
            colorScheme: ColorScheme.light(
              onPrimary: Colors.white, 
              onSurface: primaryColor, 
              primary: primaryColor, 
              surface: Colors.white
            ),
            dialogBackgroundColor: Colors.white,
            datePickerTheme: const DatePickerThemeData(
              headerBackgroundColor: primaryColor, 
              backgroundColor: Colors.white, 
              headerForegroundColor: Colors.white, 
            ),
          ),
          child: child!,
        );
      },
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime(2023), // Batas lebih realistis
      lastDate: DateTime(2030), // Batas lebih realistis
    );
    if (pickedDate != null) {
      controller.text = DateFormat('dd/M/yyyy').format(pickedDate);
    }
  }


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("PENGAJUAN IZIN"),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              "Formulir Pengajuan Izin/Cuti",
              style: GoogleFonts.poppins(
                fontSize: 20,
                fontWeight: FontWeight.w700,
                color: textColor,
              ),
            ),
            const SizedBox(height: 5),
            Text(
              "Mohon isi data dengan lengkap dan benar.",
              style: GoogleFonts.poppins(
                fontSize: 14,
                fontWeight: FontWeight.w400,
                color: textColor.withOpacity(0.7),
              ),
            ),
            const SizedBox(height: 20),
            
            TextField(
              textInputAction: TextInputAction.next,
              keyboardType: TextInputType.text,
              controller: controllerName,
              decoration: kModernInputDecoration("Nama Lengkap"),
            ),
            const SizedBox(height: 20),
            
            DropdownButtonFormField<String>(
              decoration: kModernInputDecoration("Keterangan Izin/Cuti").copyWith(
                contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 0),
              ),
              value: dropValueCategories,
              dropdownColor: Colors.white, 
              style: GoogleFonts.poppins(color: textColor, fontWeight: FontWeight.w500, fontSize: 14),
              onChanged: (value) {
                setState(() {
                  dropValueCategories = value.toString();
                });
              },
              items:
                  categoriesList.map((String value) {
                    return DropdownMenuItem<String>(
                      value: value,
                      child: Text(
                        value,
                        style: GoogleFonts.poppins(fontSize: 14, color: textColor),
                      ),
                    );
                  }).toList(),
              icon: const Icon(Icons.keyboard_arrow_down_rounded, color: primaryColor, size: 24),
            ),
            const SizedBox(height: 20),

            Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: fromController,
                    readOnly: true,
                    decoration: kModernInputDecoration("Dari Tanggal").copyWith(
                      suffixIcon: const Icon(Icons.calendar_today, color: primaryColor, size: 20),
                    ),
                    onTap: () => _selectDate(context, fromController),
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: TextField(
                    controller: toController,
                    readOnly: true,
                    decoration: kModernInputDecoration("Sampai Tanggal").copyWith(
                      suffixIcon: const Icon(Icons.calendar_today, color: primaryColor, size: 20),
                    ),
                    onTap: () => _selectDate(context, toController),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 30),

            ModernButton(
              text: "AJUKAN IZIN",
              color: primaryColor,
              onPressed: () {
                if (controllerName.text.isEmpty ||
                    dropValueCategories == "Pilih Keterangan:" ||
                    fromController.text.isEmpty ||
                    toController.text.isEmpty) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text(
                        "Mohon lengkapi semua kolom!",
                        style: GoogleFonts.poppins(color: Colors.white, fontWeight: FontWeight.w600),
                      ),
                      backgroundColor: Colors.redAccent,
                      behavior: SnackBarBehavior.floating,
                    ),
                  );
                } else {
                  submitAbsen(
                    controllerName.text.toString(),
                    dropValueCategories.toString(),
                    fromController.text,
                    toController.text,
                  );
                }
              },
            ),
          ],
        ),
      ),
    );
  }
}