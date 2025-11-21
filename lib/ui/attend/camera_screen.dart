import 'dart:io';
import 'package:camera/camera.dart';
import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:google_mlkit_face_detection/google_mlkit_face_detection.dart';
import 'package:lottie/lottie.dart'; 
import 'package:attendance_app/ui/attend/attend_screen.dart';
import 'package:attendance_app/utils/face_detection/google_ml_kit.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:attendance_app/main.dart';

class CameraScreen extends StatefulWidget {
  const CameraScreen({super.key});
  @override
  State<CameraScreen> createState() => _State();
}

class _State extends State<CameraScreen> with TickerProviderStateMixin {
  FaceDetector faceDetector = GoogleMlKit.vision.faceDetector(
    FaceDetectorOptions(enableContours: true, enableClassification: true, enableTracking: true, enableLandmarks: true),
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
      final frontCamera = cameras!.firstWhere((c) => c.lensDirection == CameraLensDirection.front, orElse: () => cameras!.first);
      controller = CameraController(frontCamera, ResolutionPreset.medium);
      await controller!.initialize();
      if (mounted) setState(() {});
    }
  }

  // ... (Logika proses image tetap sama)
  Future<void> processImage(InputImage inputImage) async {
    if (isBusy) return;
    isBusy = true;
    final faces = await faceDetector.processImage(inputImage);
    isBusy = false;
    if (mounted) {
      Navigator.of(context).pop();
      if (faces.isNotEmpty) {
        Navigator.pushReplacement(context, MaterialPageRoute(builder: (context) => AttendScreen(image: image)));
      } else {
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Wajah tidak terdeteksi!"), backgroundColor: accentColor));
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    Size size = MediaQuery.of(context).size;
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(icon: const Icon(Icons.arrow_back_ios_new, color: Colors.white), onPressed: () => Navigator.pop(context)),
        title: const Text("Face ID", style: TextStyle(color: Colors.white)),
      ),
      body: Stack(
        children: [
          if (controller != null && controller!.value.isInitialized)
            SizedBox(width: size.width, height: size.height, child: CameraPreview(controller!))
          else 
            const Center(child: CircularProgressIndicator(color: Colors.white)),
          
          Center(
            child: Lottie.asset("assets/raw/face_id_ring.json", width: size.width * 0.8),
          ),

          Align(
            alignment: Alignment.bottomCenter,
            child: Container(
              margin: const EdgeInsets.only(bottom: 50),
              child: IconButton(
                onPressed: () async {
                  if (controller != null && controller!.value.isInitialized) {
                    try {
                      image = await controller!.takePicture();
                      showDialog(context: context, barrierDismissible: false, builder: (c) => const Center(child: CircularProgressIndicator(color: primaryColor)));
                      final inputImage = InputImage.fromFilePath(image!.path);
                      if (Platform.isAndroid) {
                        await processImage(inputImage);
                      } else {
                        Navigator.pop(context);
                        Navigator.pushReplacement(context, MaterialPageRoute(builder: (context) => AttendScreen(image: image)));
                      }
                    } catch (e) {
                      // error handling
                    }
                  }
                },
                icon: const Icon(Icons.camera, color: Colors.white, size: 50),
                style: IconButton.styleFrom(backgroundColor: primaryColor, padding: const EdgeInsets.all(15)),
              ),
            ),
          )
        ],
      ),
    );
  }
}