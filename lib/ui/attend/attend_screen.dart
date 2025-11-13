import 'dart:io'; 
import 'package:camera/camera.dart'; 
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:dotted_border/dotted_border.dart'; 
import 'package:flutter/material.dart';
import 'package:geocoding/geocoding.dart'; 
import 'package:geolocator/geolocator.dart'; 
import 'package:intl/intl.dart'; 
import 'package:attendance_app/ui/attend/camera_screen.dart';
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


class AttendScreen extends StatefulWidget {
  final XFile? image;
  const AttendScreen({super.key, this.image});
  @override
  State<AttendScreen> createState() => _AttendScreenState(image);
}

class _AttendScreenState extends State<AttendScreen> {
  _AttendScreenState(this.image);
  XFile? image;
  String strAlamat = "",
      strDate = "",
      strTime = "",
      strDateTime = "",
      strStatus = "Attend";
  bool isLoading = false;
  double dLat = 0.0, dLong = 0.0;
  int dateHours = 0, dateMinutes = 0;
  final controllerName = TextEditingController();
  final CollectionReference dataCollection = FirebaseFirestore.instance
      .collection('attendance');

  @override
  void initState() {
    handleLocationPermission();
    setDateTime();
    setStatusAbsen();
    if (image != null) {
      isLoading = true;
      getGeoLocationPosition();
    }
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("ATTENDANCE MENU"),
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
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(20),
          child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  "FOTO SELFIE ANDA!",
                  style: GoogleFonts.comicNeue(
                    fontSize: 18,
                    fontWeight: FontWeight.w900,
                    color: const Color(0xFFFF0000), // Merah
                  ),
                ),
                const SizedBox(height: 10),
                GestureDetector(
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => const CameraScreen(),
                      ),
                    );
                  },
                  child: DottedBorder(
                    radius: const Radius.circular(0),
                    borderType: BorderType.RRect,
                    color: const Color(0xFFFF0000), // Border Merah
                    strokeWidth: 4,
                    dashPattern: const [3, 3],
                    child: Container(
                      width: double.infinity,
                      height: 200,
                      decoration: BoxDecoration(
                        color: const Color(0xFFFFFF00).withOpacity(0.7), // Kuning transparan
                        borderRadius: BorderRadius.circular(0)
                      ),
                      child: image != null
                          ? ClipRRect(
                            borderRadius: BorderRadius.circular(0),
                            child: Image.file(
                                File(image!.path),
                                fit: BoxFit.cover,
                              ),
                          )
                          : Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              const Icon(
                                Icons.camera_enhance_outlined,
                                color: Color(0xFFFF0000),
                                size: 50,
                              ),
                              const SizedBox(height: 10),
                              Text(
                                "KLIK DI SINI!!",
                                style: GoogleFonts.comicNeue(
                                  color: const Color(0xFFFF0000),
                                  fontWeight: FontWeight.bold
                                ),
                              )
                            ],
                          ),
                    ),
                  ),
                ),
                const SizedBox(height: 20),
                TextField(
                  textInputAction: TextInputAction.done,
                  keyboardType: TextInputType.text,
                  controller: controllerName,
                  decoration: kSakitMataInputDecoration("NAMA LENGKAP"),
                ),
                const SizedBox(height: 20),
                Text(
                  "LOKASI ANDA SEKARANG:",
                  style: GoogleFonts.comicNeue(
                    fontSize: 18,
                    fontWeight: FontWeight.w900,
                    color: const Color(0xFFFF0000),
                  ),
                ),
                const SizedBox(height: 10),
                isLoading
                    ? const Center(
                      child: CircularProgressIndicator(color: Color(0xFFFF0000)),
                    )
                    : TextField(
                          enabled: false,
                          maxLines: 3,
                          decoration: kSakitMataInputDecoration("").copyWith(
                            hintText: strAlamat.isEmpty ? "Mencari lokasi..." : strAlamat,
                            hintStyle: GoogleFonts.comicNeue(color: const Color(0xFF0000FF)), // Biru
                          ),
                        ),
                const SizedBox(height: 30),
                SakitMataButton(
                  text: "LAPOR SEKARANG!",
                  onPressed: () {
                    if (image == null || controllerName.text.isEmpty) {
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
                        strAlamat,
                        controllerName.text.toString(),
                        strStatus,
                      );
                    }
                  },
                )
              ],
            ),
        ),
      ),
    );
  }

  // --- SEMUA FUNGSI DI BAWAH INI TETAP SAMA ---
  // (Hanya mengubah warna SnackBar dan Dialog)

  Future<void> getGeoLocationPosition() async {
    Position position = await Geolocator.getCurrentPosition(
      desiredAccuracy: LocationAccuracy.low,
    );
    setState(() {
      isLoading = false;
      getAddressFromLongLat(position);
    });
  }

  Future<void> getAddressFromLongLat(Position position) async {
    List<Placemark> placemarks = await placemarkFromCoordinates(
      position.latitude,
      position.longitude,
    );
    Placemark place = placemarks[0];
    setState(() {
      dLat = double.parse('${position.latitude}');
      dLat = double.parse('${position.longitude}');
      strAlamat =
          "${place.street}, ${place.subLocality}, ${place.locality}, ${place.postalCode}, ${place.country}";
    });
  }

  Future<bool> handleLocationPermission() async {
    bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            "Nyalakan GPS dulu!",
            style: GoogleFonts.comicNeue(color: Colors.white, fontWeight: FontWeight.bold),
          ),
          backgroundColor: Colors.redAccent,
          behavior: SnackBarBehavior.floating,
        ),
      );
      return false;
    }

    LocationPermission permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              "Izin lokasi ditolak.",
              style: GoogleFonts.comicNeue(color: Colors.white, fontWeight: FontWeight.bold),
            ),
            backgroundColor: Colors.redAccent,
            behavior: SnackBarBehavior.floating,
          ),
        );
        return false;
      }
    }

    if (permission == LocationPermission.deniedForever) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            "Izin lokasi ditolak selamanya.",
            style: GoogleFonts.comicNeue(color: Colors.white, fontWeight: FontWeight.bold),
          ),
          backgroundColor: Colors.redAccent,
          behavior: SnackBarBehavior.floating,
        ),
      );
      return false;
    }
    return true;
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

  void setDateTime() async {
    var dateNow = DateTime.now();
    var dateFormat = DateFormat('dd MMMM yyyy');
    var dateTime = DateFormat('HH:mm:ss');
    var dateHour = DateFormat('HH');
    var dateMinute = DateFormat('mm');

    setState(() {
      strDate = dateFormat.format(dateNow);
      strTime = dateTime.format(dateNow);
      strDateTime = "$strDate | $strTime";

      dateHours = int.parse(dateHour.format(dateNow));
      dateMinutes = int.parse(dateMinute.format(dateNow));
    });
  }

  void setStatusAbsen() {
    if (dateHours < 8 || (dateHours == 8 && dateMinutes <= 30)) {
      strStatus = "Attend";
    } else if ((dateHours > 8 && dateHours < 18) ||
        (dateHours == 8 && dateMinutes >= 31)) {
      strStatus = "Late";
    } else {
      strStatus = "Leave";
    }
  }

  Future<void> submitAbsen(String alamat, String nama, String status) async {
    showLoaderDialog(context);
    dataCollection
        .add({
          'address': alamat,
          'name': nama,
          'description': status,
          'datetime': strDateTime,
        })
        .then((result) {
          setState(() {
            Navigator.of(context).pop();
            try {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Row(
                    children: [
                      const Icon(Icons.check_circle_outline, color: Colors.white),
                      const SizedBox(width: 10),
                      Text(
                        "BERHASIL!",
                        style: GoogleFonts.comicNeue(color: Colors.white, fontWeight: FontWeight.bold),
                      ),
                    ],
                  ),
                  backgroundColor: Colors.green, // Tetap hijau untuk sukses
                  behavior: SnackBarBehavior.floating,
                ),
              );
              Navigator.pushReplacement(
                context,
                MaterialPageRoute(builder: (context) => const HomeScreen()),
              );
            } catch (e) {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Row(
                    children: [
                      const Icon(Icons.info_outline, color: Colors.white),
                      const SizedBox(width: 10),
                      Expanded(
                        child: Text(
                          "Ups, $e",
                          style: GoogleFonts.comicNeue(color: Colors.white, fontWeight: FontWeight.bold),
                        ),
                      ),
                    ],
                  ),
                  backgroundColor: Colors.redAccent,
                  behavior: SnackBarBehavior.floating,
                ),
              );
            }
          });
        })
        .catchError((error) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Row(
                children: [
                  const Icon(Icons.error_outline, color: Colors.white),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Text(
                      "Ups, $error",
                      style: GoogleFonts.comicNeue(color: Colors.white, fontWeight: FontWeight.bold),
                    ),
                  ),
                ],
              ),
              backgroundColor: Colors.redAccent,
              behavior: SnackBarBehavior.floating,
            ),
          );
          Navigator.of(context).pop();
        });
  }
}