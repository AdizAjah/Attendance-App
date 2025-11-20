import 'dart:io';

import 'package:camera/camera.dart';
import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:google_mlkit_face_detection/google_mlkit_face_detection.dart';
import 'package:lottie/lottie.dart'; 
import 'package:attendance_app/ui/attend/attend_screen.dart';
import 'package:attendance_app/utils/face_detection/google_ml_kit.dart';
import 'package:google_fonts/google_fonts.dart';

// Import tema baru
import 'package:attendance_app/main.dart'; // Import primaryColor, accentColor, textColor

class CameraScreen extends StatefulWidget {
  const CameraScreen({super.key});

  @override
  State<CameraScreen> createState() => _State();
}

class _State extends State<CameraScreen> with TickerProviderStateMixin {
  FaceDetector faceDetector = GoogleMlKit.vision.faceDetector(
    FaceDetectorOptions(
      enableContours: true,
      enableClassification: true,
      enableTracking: true,
      enableLandmarks: true,
    ),
  );

  List<CameraDescription>? cameras;
  CameraController? controller;
  XFile? image;
  bool isBusy = false;

  @override
  void initState() {
    loadCamera();
    super.initState();
  }

  @override
  void dispose() {
    controller?.dispose();
    super.dispose();
  }

  Future<void> loadCamera() async {
    cameras = await availableCameras();
    if (cameras != null) {
      final frontCamera = cameras!.firstWhere(
        (camera) => camera.lensDirection == CameraLensDirection.front,
        orElse: () => cameras!.first,
      );
      controller = CameraController(frontCamera, ResolutionPreset.medium); // Resolusi diturunkan agar lebih stabil
      try {
        await controller!.initialize();
        if (mounted) {
          setState(() {});
        }
      } catch (e) {
        debugPrint('Error initializing camera: $e');
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(
                "Gagal menginisialisasi kamera: ${e.toString()}",
                style: GoogleFonts.poppins(color: Colors.white, fontWeight: FontWeight.w600),
              ),
              backgroundColor: Colors.redAccent,
              behavior: SnackBarBehavior.floating,
            ),
          );
        }
      }
    } else {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              "KAMERA TIDAK DITEMUKAN!",
              style: GoogleFonts.poppins(color: Colors.white, fontWeight: FontWeight.w600),
            ),
            backgroundColor: Colors.redAccent,
            behavior: SnackBarBehavior.floating,
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    Size size = MediaQuery.of(context).size;

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
                "Memproses Wajah...",
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

    return Scaffold(
      appBar: AppBar(
        title: const Text("Ambil Foto Selfie"),
      ),
      body: Stack(
        children: [
          // Camera Preview
          controller == null || !controller!.value.isInitialized
              ? Container(
                color: Colors.black,
                child: Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Icon(Icons.videocam_off, size: 80, color: Colors.redAccent),
                      const SizedBox(height: 10),
                      Text(
                        "Kamera tidak tersedia atau gagal dimuat.",
                        style: GoogleFonts.poppins(
                          color: Colors.white,
                          fontWeight: FontWeight.w500,
                          fontSize: 16
                        ),
                      ),
                    ],
                  ),
                ),
              )
              : SizedBox(
                  height: size.height,
                  width: size.width,
                  child: CameraPreview(controller!),
                ),
          
          // Lottie Animation (Ring)
          Center(
            child: Lottie.asset(
              "assets/raw/face_id_ring.json",
              fit: BoxFit.contain,
              width: size.width * 0.8,
              height: size.width * 0.8,
            ),
          ),
          
          // Bottom Control Panel
          Align(
            alignment: Alignment.bottomCenter,
            child: Container(
              width: size.width,
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.95), 
                borderRadius: const BorderRadius.only(
                  topLeft: Radius.circular(20),
                  topRight: Radius.circular(20),
                ),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.1),
                    blurRadius: 10,
                    offset: const Offset(0, -5),
                  )
                ]
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    "Pastikan wajah Anda berada di dalam lingkaran dan kondisi cahaya memadai.",
                    textAlign: TextAlign.center,
                    style: GoogleFonts.poppins(
                      fontSize: 14, 
                      color: textColor.withOpacity(0.8), 
                      fontWeight: FontWeight.w500
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.only(top: 30),
                    child: FloatingActionButton(
                      backgroundColor: primaryColor,
                      foregroundColor: Colors.white,
                      shape: const CircleBorder(),
                      onPressed: () async {
                        if (controller == null || !controller!.value.isInitialized) return;

                        final hasPermission = await handleLocationPermission();
                        
                        try {
                          if (hasPermission) {
                            controller!.setFlashMode(FlashMode.off);
                            image = await controller!.takePicture();
                            
                            // Tampilkan loading saat memproses
                            showLoaderDialog(context);

                            // Lanjutkan ke deteksi wajah
                            final inputImage = InputImage.fromFilePath(image!.path);
                            // Logika untuk Android (deteksi wajah)
                            if (Platform.isAndroid) {
                               await processImage(inputImage);
                            } else {
                               // Untuk platform lain, langsung ke AttendScreen tanpa deteksi ML Kit (jika ML Kit hanya diimplementasikan untuk Android)
                               if (mounted) {
                                  Navigator.of(context).pop(); // Tutup dialog loading
                                  Navigator.pushReplacement(
                                    context,
                                    MaterialPageRoute(
                                      builder:
                                          (context) => AttendScreen(
                                            image: image,
                                          ),
                                    ),
                                  );
                               }
                            }
                            
                          } else {
                            // Pesan ditangani di dalam handleLocationPermission
                          }
                        } catch (e) {
                          if (mounted) {
                            Navigator.of(context).pop(); // Tutup dialog loading jika ada error
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                content: Text(
                                  "Gagal mengambil foto: ${e.toString()}",
                                  style: GoogleFonts.poppins(
                                    color: Colors.white,
                                    fontWeight: FontWeight.w600
                                  ),
                                ),
                                backgroundColor: Colors.redAccent,
                                behavior: SnackBarBehavior.floating,
                              ),
                            );
                          }
                        }
                      },
                      child: const Icon(
                        Icons.camera,
                        size: 32,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  // --- FUNGSI BAWAAN (Hanya mengubah teks dan style SnackBar) ---

  Future<bool> handleLocationPermission() async {
    // ... (logic sama, hanya mengubah SnackBar)
    bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              "Nyalakan GPS Anda untuk melanjutkan!",
              style: GoogleFonts.poppins(color: Colors.white, fontWeight: FontWeight.w600),
            ),
            backgroundColor: Colors.redAccent,
            behavior: SnackBarBehavior.floating,
          ),
        );
      }
      return false;
    }

    LocationPermission permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(
                "Izin lokasi ditolak. Harap izinkan akses lokasi.",
                style: GoogleFonts.poppins(color: Colors.white, fontWeight: FontWeight.w600),
              ),
              backgroundColor: Colors.redAccent,
              behavior: SnackBarBehavior.floating,
            ),
          );
        }
        return false;
      }
    }

    if (permission == LocationPermission.deniedForever) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              "Izin lokasi ditolak selamanya. Mohon ubah di pengaturan aplikasi.",
              style: GoogleFonts.poppins(color: Colors.white, fontWeight: FontWeight.w600),
            ),
            backgroundColor: Colors.redAccent,
            behavior: SnackBarBehavior.floating,
          ),
        );
      }
      return false;
    }
    return true;
  }

  Future<void> processImage(InputImage inputImage) async {
    if (isBusy) return;
    isBusy = true;
    final faces = await faceDetector.processImage(inputImage);
    isBusy = false;

    if (mounted) {
      // Hapus dialog loading
      Navigator.of(context).pop(true);

      if (faces.isNotEmpty) {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => AttendScreen(image: image)),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              "Wajah tidak terdeteksi! Pastikan wajah Anda terlihat jelas.",
              style: GoogleFonts.poppins(color: Colors.white, fontWeight: FontWeight.w600),
            ),
            backgroundColor: Colors.redAccent,
            behavior: SnackBarBehavior.floating,
          ),
        );
      }
    }
  }
}