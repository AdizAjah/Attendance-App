import 'dart:io';
import 'package:camera/camera.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:geocoding/geocoding.dart';
import 'package:geolocator/geolocator.dart';
import 'package:intl/intl.dart';
import 'package:attendance_app/ui/attend/camera_screen.dart';
import 'package:attendance_app/ui/home_screen.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:attendance_app/main.dart';

class AttendScreen extends StatefulWidget {
  final XFile? image;
  const AttendScreen({super.key, this.image});

  @override
  State<AttendScreen> createState() => _AttendScreenState();
}

class _AttendScreenState extends State<AttendScreen> {
  XFile? image;
  String strAlamat = "", strDateTime = "", strStatus = "Attend";
  bool isLoading = false;
  double dLat = 0.0, dLong = 0.0;
  final controllerName = TextEditingController();
  final CollectionReference dataCollection = FirebaseFirestore.instance
      .collection('attendance');

  @override
  void initState() {
    super.initState();
    image = widget.image;
    handleLocationPermission();
    setDateTime();
    setStatusAbsen();
    if (image != null) {
      isLoading = true;
      getGeoLocationPosition();
    }
  }

  // ... (Kode Logika Lokasi tetap sama, hanya UI yang berubah)
  // START LOGIC AREA
  Future<void> getGeoLocationPosition() async {
    try {
      Position position = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.low,
      );
      if (mounted) {
        setState(() {
          isLoading = false;
          getAddressFromLongLat(position);
        });
      }
    } catch (e) {
      if (mounted) setState(() => isLoading = false);
    }
  }

  Future<void> getAddressFromLongLat(Position position) async {
    try {
      List<Placemark> placemarks = await placemarkFromCoordinates(
        position.latitude,
        position.longitude,
      );
      Placemark place = placemarks[0];
      if (mounted) {
        setState(() {
          dLat = position.latitude;
          dLong = position.longitude;
          strAlamat =
              "${place.street}, ${place.subLocality}, ${place.locality}, ${place.postalCode}, ${place.country}";
        });
      }
    } catch (e) {
      // handle error
    }
  }

  Future<bool> handleLocationPermission() async {
    bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      // Show snackbar
      return false;
    }
    LocationPermission permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) return false;
    }
    if (permission == LocationPermission.deniedForever) return false;
    return true;
  }

  void setDateTime() async {
    var dateNow = DateTime.now();
    var dateFormat = DateFormat('dd MMMM yyyy');
    var dateTime = DateFormat('HH:mm:ss');
    if (mounted) {
      setState(() {
        strDateTime =
            "${dateFormat.format(dateNow)} | ${dateTime.format(dateNow)}";
      });
    }
  }

  void setStatusAbsen() {
    var dateNow = DateTime.now();
    var hour = int.parse(DateFormat('HH').format(dateNow));
    var minute = int.parse(DateFormat('mm').format(dateNow));
    if (hour < 8 || (hour == 8 && minute <= 30)) {
      strStatus = "Attend";
    } else if ((hour > 8 && hour < 18) || (hour == 8 && minute >= 31)) {
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
            const SnackBar(
              content: Text("Absensi Berhasil!"),
              backgroundColor: successColor,
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
            const SnackBar(
              content: Text("Gagal Absen"),
              backgroundColor: accentColor,
            ),
          );
        });
  }

  showLoaderDialog(BuildContext context) {
    AlertDialog alert = AlertDialog(
      content: Row(
        children: [
          const CircularProgressIndicator(
            valueColor: AlwaysStoppedAnimation<Color>(primaryColor),
          ),
          Container(
            margin: const EdgeInsets.only(left: 20),
            child: const Text("Loading..."),
          ),
        ],
      ),
    );
    showDialog(
      barrierDismissible: false,
      context: context,
      builder: (BuildContext context) => alert,
    );
  }
  // END LOGIC AREA

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: backgroundColor,
      appBar: AppBar(
        title: const Text("Absensi"),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new_rounded),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Section Foto
            Center(
              child: GestureDetector(
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => const CameraScreen(),
                    ),
                  );
                },
                child: Container(
                  width: 150,
                  height: 150,
                  decoration: BoxDecoration(
                    color: Colors.white,
                    shape: BoxShape.circle,
                    border: Border.all(
                      color: primaryColor.withOpacity(0.2),
                      width: 4,
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: primaryColor.withOpacity(0.1),
                        blurRadius: 20,
                        spreadRadius: 5,
                      ),
                    ],
                    image: image != null
                        ? DecorationImage(
                            image: FileImage(File(image!.path)),
                            fit: BoxFit.cover,
                          )
                        : null,
                  ),
                  child: image == null
                      ? const Center(
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(
                                Icons.camera_alt_rounded,
                                color: primaryColor,
                                size: 40,
                              ),
                              SizedBox(height: 5),
                              Text(
                                "Tap Foto",
                                style: TextStyle(
                                  color: primaryColor,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ],
                          ),
                        )
                      : null,
                ),
              ),
            ),
            const SizedBox(height: 30),

            // Form Section
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(20),
                boxShadow: [
                  BoxShadow(
                    color: Colors.grey.shade100,
                    blurRadius: 15,
                    offset: const Offset(0, 5),
                  ),
                ],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    "Data Diri",
                    style: GoogleFonts.poppins(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: secondaryColor,
                    ),
                  ),
                  const SizedBox(height: 15),
                  TextField(
                    controller: controllerName,
                    decoration: kModernInputDecoration(
                      "Nama Lengkap",
                      icon: Icons.person_outline_rounded,
                    ),
                  ),
                  const SizedBox(height: 20),

                  Text(
                    "Lokasi Saat Ini",
                    style: GoogleFonts.poppins(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: secondaryColor,
                    ),
                  ),
                  const SizedBox(height: 10),
                  Container(
                    padding: const EdgeInsets.all(15),
                    decoration: BoxDecoration(
                      color: backgroundColor,
                      borderRadius: BorderRadius.circular(15),
                      border: Border.all(color: Colors.grey.shade200),
                    ),
                    child: Row(
                      children: [
                        const Icon(
                          Icons.location_on_rounded,
                          color: accentColor,
                        ),
                        const SizedBox(width: 10),
                        Expanded(
                          child: isLoading
                              ? const LinearProgressIndicator(
                                  color: primaryColor,
                                )
                              : Text(
                                  strAlamat.isEmpty
                                      ? "Lokasi belum ditemukan"
                                      : strAlamat,
                                  style: GoogleFonts.poppins(
                                    fontSize: 13,
                                    color: textColor,
                                  ),
                                ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 30),

            ModernButton(
              text: "Check In Sekarang",
              icon: Icons.fingerprint_rounded,
              onPressed: () {
                if (image == null || controllerName.text.isEmpty) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text("Lengkapi foto dan nama!"),
                      backgroundColor: accentColor,
                    ),
                  );
                } else {
                  submitAbsen(strAlamat, controllerName.text, strStatus);
                }
              },
            ),
          ],
        ),
      ),
    );
  }
}
