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

// Import tema dan widget baru dari main.dart
import 'package:attendance_app/main.dart'; // Import primaryColor, accentColor, textColor, kModernInputDecoration, ModernButton

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
    // Panggil permission check lebih awal, tapi proses lokasi hanya jika ada gambar
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
  void dispose() {
    controllerName.dispose();
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
              "Memuat lokasi...",
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

  // --- SEMUA FUNGSI LOKASI & WAKTU (Fungsionalitas Asli) ---

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
      dLat = position.latitude;
      dLong = position.longitude;
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
            style: GoogleFonts.poppins(color: Colors.white, fontWeight: FontWeight.w600),
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
              style: GoogleFonts.poppins(color: Colors.white, fontWeight: FontWeight.w600),
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
            style: GoogleFonts.poppins(color: Colors.white, fontWeight: FontWeight.w600),
          ),
          backgroundColor: Colors.redAccent,
          behavior: SnackBarBehavior.floating,
        ),
      );
      return false;
    }
    return true;
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
          'created_at': FieldValue.serverTimestamp(),
        })
        .then((result) {
          Navigator.of(context).pop();
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Row(
                children: [
                  const Icon(Icons.check_circle_outline, color: Colors.white),
                  const SizedBox(width: 10),
                  Text(
                    "Absensi BERHASIL dengan status: $status!",
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
        })
        .catchError((error) {
          Navigator.of(context).pop();
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Row(
                children: [
                  const Icon(Icons.error_outline, color: Colors.white),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Text(
                      "ERROR: Gagal menyimpan data.",
                      style: GoogleFonts.poppins(color: Colors.white, fontWeight: FontWeight.w600),
                    ),
                  ),
                ],
              ),
              backgroundColor: Colors.redAccent,
              behavior: SnackBarBehavior.floating,
            ),
          );
        });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("ABSENSI HARI INI"),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                "Ambil Foto Selfie Anda",
                style: GoogleFonts.poppins(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  color: textColor, 
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
                  radius: const Radius.circular(15), 
                  borderType: BorderType.RRect,
                  color: primaryColor, 
                  strokeWidth: 2,
                  dashPattern: const [6, 4], 
                  child: Container(
                    width: double.infinity,
                    height: 200,
                    decoration: BoxDecoration(
                      color: Colors.white, 
                      borderRadius: BorderRadius.circular(15)
                    ),
                    child: image != null
                        ? ClipRRect(
                          borderRadius: BorderRadius.circular(15),
                          child: Image.file(
                              File(image!.path),
                              fit: BoxFit.cover,
                            ),
                        )
                        : Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            const Icon(
                              Icons.camera_alt_outlined,
                              color: primaryColor,
                              size: 50,
                            ),
                            const SizedBox(height: 10),
                            Text(
                              "KETUK UNTUK FOTO",
                              style: GoogleFonts.poppins(
                                color: primaryColor,
                                fontWeight: FontWeight.w600
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
                decoration: kModernInputDecoration("Nama Lengkap"),
              ),
              const SizedBox(height: 20),
              Text(
                "Lokasi Anda Saat Ini:",
                style: GoogleFonts.poppins(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  color: textColor,
                ),
              ),
              const SizedBox(height: 10),
              isLoading
                  ? const Center(
                    child: LinearProgressIndicator(color: primaryColor), 
                  )
                  : TextField(
                        enabled: false,
                        maxLines: 3,
                        decoration: kModernInputDecoration("").copyWith(
                          hintText: strAlamat.isEmpty ? "Mencari lokasi, tunggu sebentar..." : strAlamat,
                          hintStyle: GoogleFonts.poppins(
                            color: textColor.withOpacity(0.6), 
                            fontSize: 14,
                          ), 
                          filled: true,
                          fillColor: lightAccent.withOpacity(0.5), 
                        ),
                      ),
              const SizedBox(height: 30),
              ModernButton(
                text: "KIRIM ABSENSI",
                color: accentColor,
                onPressed: () {
                  if (image == null || controllerName.text.isEmpty) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text(
                          "Mohon lengkapi semua data (Foto dan Nama)!",
                          style: GoogleFonts.poppins(color: Colors.white, fontWeight: FontWeight.w600),
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
    );
  }
}