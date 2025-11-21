import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:attendance_app/ui/home_screen.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:attendance_app/main.dart';

class AbsentScreen extends StatefulWidget {
  const AbsentScreen({super.key});

  @override
  State<AbsentScreen> createState() => _AbsentScreenState();
}

class _AbsentScreenState extends State<AbsentScreen> {
  String dropValueCategories = "Pilih Keterangan";
  var categoriesList = ["Pilih Keterangan", "Sakit", "Izin", "Lainnya"];
  final controllerName = TextEditingController();
  final fromController = TextEditingController();
  final toController = TextEditingController();
  final CollectionReference dataCollection = FirebaseFirestore.instance.collection('attendance');

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: backgroundColor,
      appBar: AppBar(
        title: const Text("Formulir Izin"),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new_rounded),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(
          children: [
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(20),
                boxShadow: [
                  BoxShadow(
                    color: Colors.grey.shade100,
                    blurRadius: 10,
                    offset: const Offset(0, 5),
                  )
                ]
              ),
              child: Column(
                children: [
                  TextField(
                    controller: controllerName,
                    decoration: kModernInputDecoration("Nama Lengkap", icon: Icons.person),
                  ),
                  const SizedBox(height: 20),
                  DropdownButtonFormField<String>(
                    value: dropValueCategories,
                    decoration: kModernInputDecoration("Keterangan", icon: Icons.assignment_outlined),
                    dropdownColor: Colors.white,
                    borderRadius: BorderRadius.circular(15),
                    items: categoriesList.map((e) => DropdownMenuItem(value: e, child: Text(e))).toList(),
                    onChanged: (v) => setState(() => dropValueCategories = v!),
                  ),
                  const SizedBox(height: 20),
                  Row(
                    children: [
                      Expanded(
                        child: TextField(
                          controller: fromController,
                          readOnly: true,
                          onTap: () => _selectDate(context, fromController),
                          decoration: kModernInputDecoration("Dari", icon: Icons.date_range),
                        ),
                      ),
                      const SizedBox(width: 15),
                      Expanded(
                        child: TextField(
                          controller: toController,
                          readOnly: true,
                          onTap: () => _selectDate(context, toController),
                          decoration: kModernInputDecoration("Sampai", icon: Icons.date_range),
                        ),
                      ),
                    ],
                  )
                ],
              ),
            ),
            const SizedBox(height: 40),
            ModernButton(
              text: "Ajukan Permohonan",
              color: const Color(0xFFFF9800), // Orange Theme for Permission
              icon: Icons.send_rounded,
              onPressed: () => submitAbsen(),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _selectDate(BuildContext context, TextEditingController controller) async {
    DateTime? picked = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime(2024),
      lastDate: DateTime(2030),
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: const ColorScheme.light(primary: primaryColor),
            dialogBackgroundColor: Colors.white,
          ),
          child: child!,
        );
      }
    );
    if (picked != null) controller.text = DateFormat('dd/MM/yyyy').format(picked);
  }

  Future<void> submitAbsen() async {
    if (controllerName.text.isEmpty || dropValueCategories == "Pilih Keterangan" || fromController.text.isEmpty || toController.text.isEmpty) {
       ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Isi semua data!"), backgroundColor: accentColor));
       return;
    }
    
    showDialog(context: context, barrierDismissible: false, builder: (c) => const Center(child: CircularProgressIndicator(color: primaryColor)));

    await dataCollection.add({
      'address': '-',
      'name': controllerName.text,
      'description': dropValueCategories,
      'datetime': "${fromController.text} - ${toController.text}",
      'created_at': FieldValue.serverTimestamp(),
    });

    if(mounted) {
      Navigator.pop(context);
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Berhasil diajukan"), backgroundColor: successColor));
      Navigator.pushReplacement(context, MaterialPageRoute(builder: (context) => const HomeScreen()));
    }
  }
}