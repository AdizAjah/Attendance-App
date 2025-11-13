import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:attendance_app/ui/home_screen.dart';
import 'package:google_fonts/google_fonts.dart';

// --- COPY PASTE kSakitMataInputDecoration & SakitMataButton DARI ATAS KE SINI ---

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

// Tombol Gradien yang Menyebalkan
class SakitMataButton extends StatelessWidget {
  final VoidCallback onPressed;
  final String text;

  const SakitMataButton({
    Key? key,
    required this.onPressed,
    required this.text,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return ElevatedButton(
      onPressed: onPressed,
      style: ElevatedButton.styleFrom(
        padding: const EdgeInsets.all(0),
        shape: BeveledRectangleBorder( // Bentuk aneh
          borderRadius: BorderRadius.circular(12),
          side: const BorderSide(color: Colors.black, width: 3)
        ),
        elevation: 10,
        shadowColor: Colors.black,
      ),
      child: Ink(
        decoration: BoxDecoration(
          // Gradien Pink ke Kuning
          gradient: const LinearGradient(
            colors: [Color(0xFFFF00FF), Color(0xFFFFFF00)],
            begin: Alignment.centerLeft,
            end: Alignment.centerRight,
          ),
          borderRadius: BorderRadius.circular(10),
        ),
        child: Container(
          width: double.infinity,
          height: 60,
          alignment: Alignment.center,
          child: Text(
            text.toUpperCase(),
            style: GoogleFonts.comicNeue(
              color: const Color(0xFF0000FF), // Teks Biru
              fontWeight: FontWeight.w900,
              fontSize: 20,
            ),
          ),
        ),
      ),
    );
  }
}
// -------------------------------------------------------------------------

class AbsentScreen extends StatefulWidget {
  const AbsentScreen({super.key});

  @override
  State<AbsentScreen> createState() => _AbsentScreenState();
}

class _AbsentScreenState extends State<AbsentScreen> {
  var categoriesList = <String>[
    "Please Choose:",
    "Others",
    "Permission",
    "Sick",
  ];

  final controllerName = TextEditingController();
  final CollectionReference dataCollection = FirebaseFirestore.instance
      .collection('attendance');

  String dropValueCategories = "Please Choose:";
  final fromController = TextEditingController();
  final toController = TextEditingController();

  @override
  void initState() {
    super.initState();
  }

  showLoaderDialog(BuildContext context) {
    AlertDialog alert = AlertDialog(
      backgroundColor: const Color(0xFFFFFF00), // Kuning
      content: Row(
        children: [
          const CircularProgressIndicator(
            valueColor: AlwaysStoppedAnimation<Color>(Colors.red),
          ),
          Container(
            margin: const EdgeInsets.only(left: 20),
            child: Text(
              "LOADING...",
              style: GoogleFonts.comicNeue(color: Colors.red, fontWeight: FontWeight.bold),
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
        keterangan == "Please Choose:" ||
        from.isEmpty ||
        until.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            "ISI SEMUA WOI!",
            style: GoogleFonts.comicNeue(color: Colors.white, fontWeight: FontWeight.bold),
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
        'address': '-',
        'name': nama,
        'description': keterangan,
        'datetime': '$from - $until',
        'created_at': FieldValue.serverTimestamp(),
      });

      Navigator.of(context).pop();

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            "BERHASIL!",
            style: GoogleFonts.comicNeue(color: Colors.white, fontWeight: FontWeight.bold),
          ),
          backgroundColor: Colors.green,
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
            "ERROR: $e",
            style: GoogleFonts.comicNeue(color: Colors.white, fontWeight: FontWeight.bold),
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
          // Tema Date Picker yang Sakit Mata
          data: Theme.of(context).copyWith(
            colorScheme: const ColorScheme.light(
              onPrimary: Color(0xFFFFFF00), // Teks Header Kuning
              onSurface: Color(0xFFFF0000), // Teks Tanggal Merah
              primary: Color(0xFFFF00FF), // Pink
            ),
            datePickerTheme: const DatePickerThemeData(
              headerBackgroundColor: Color(0xFFFF00FF), // Header Pink
              backgroundColor: Color(0xFF00FF00), // Latar Lime
              headerForegroundColor: Color(0xFFFFFF00), // Teks Header Kuning
            ),
          ),
          child: child!,
        );
      },
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime(1900),
      lastDate: DateTime(9999),
    );
    if (pickedDate != null) {
      controller.text = DateFormat('dd/M/yyyy').format(pickedDate);
    }
  }


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("PERMISSION REQUEST"),
      ),
      body: Container(
        // Latar belakang tiling
        decoration: const BoxDecoration(
          image: DecorationImage(
            image: AssetImage('assets/images/ic_history.png'), // Ganti gambar tiling
            repeat: ImageRepeat.repeat,
            opacity: 0.2,
          ),
        ),
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                "FORMULIR IZIN!",
                style: GoogleFonts.comicNeue(
                  fontSize: 22,
                  fontWeight: FontWeight.w900,
                  color: const Color(0xFFFF0000), // Merah
                ),
              ),
              const SizedBox(height: 20),
              TextField(
                textInputAction: TextInputAction.next,
                keyboardType: TextInputType.text,
                controller: controllerName,
                decoration: kSakitMataInputDecoration("NAMA LENGKAP"),
              ),
              const SizedBox(height: 20),
              
              DropdownButtonFormField<String>(
                decoration: kSakitMataInputDecoration("KETERANGAN"),
                value: dropValueCategories,
                dropdownColor: const Color(0xFFFFFF00), // Dropdown Kuning
                style: GoogleFonts.comicNeue(color: const Color(0xFFFF0000), fontWeight: FontWeight.bold),
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
                          value.toUpperCase(),
                          style: GoogleFonts.comicNeue(fontSize: 14, color: const Color(0xFFFF0000), fontWeight: FontWeight.bold),
                        ),
                      );
                    }).toList(),
                icon: const Icon(Icons.arrow_downward_rounded, color: Color(0xFF0000FF), size: 30),
              ),
              const SizedBox(height: 20),

              Row(
                children: [
                  Expanded(
                    child: TextField(
                      controller: fromController,
                      readOnly: true,
                      decoration: kSakitMataInputDecoration("DARI TANGGAL").copyWith(
                        suffixIcon: const Icon(Icons.calendar_today, color: Color(0xFF0000FF)),
                      ),
                      onTap: () => _selectDate(context, fromController),
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: TextField(
                      controller: toController,
                      readOnly: true,
                      decoration: kSakitMataInputDecoration("SAMPAI TANGGAL").copyWith(
                        suffixIcon: const Icon(Icons.calendar_today, color: Color(0xFF0000FF)),
                      ),
                      onTap: () => _selectDate(context, toController),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 30),

              SakitMataButton(
                text: "AJUKAN REQUEST!",
                onPressed: () {
                  if (controllerName.text.isEmpty ||
                      dropValueCategories == "Please Choose:" ||
                      fromController.text.isEmpty ||
                      toController.text.isEmpty) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text(
                          "ISI SEMUA WOI!",
                          style: GoogleFonts.comicNeue(color: Colors.white, fontWeight: FontWeight.bold),
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
      ),
    );
  }
}