import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:attendance_app/main.dart';
import 'package:shared_preferences/shared_preferences.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  final TextEditingController nameController = TextEditingController();
  final TextEditingController emailController = TextEditingController();
  final TextEditingController phoneController = TextEditingController();
  final TextEditingController positionController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _loadProfile();
  }

  Future<void> _loadProfile() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      nameController.text = prefs.getString('name') ?? '';
      emailController.text = prefs.getString('email') ?? '';
      phoneController.text = prefs.getString('phone') ?? '';
      positionController.text = prefs.getString('position') ?? '';
    });
  }

  Future<void> _saveProfile() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('name', nameController.text);
    await prefs.setString('email', emailController.text);
    await prefs.setString('phone', phoneController.text);
    await prefs.setString('position', positionController.text);

    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("Profil berhasil disimpan!"),
          backgroundColor: successColor,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: backgroundColor,
      appBar: AppBar(
        title: const Text("Profil Saya"),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new_rounded),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(
          children: [
            // Avatar Section
            Center(
              child: Stack(
                children: [
                  Container(
                    width: 120,
                    height: 120,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      gradient: const LinearGradient(
                        colors: [primaryColor, Color(0xFF42A5F5)],
                      ),
                      boxShadow: [
                        BoxShadow(
                          color: primaryColor.withOpacity(0.3),
                          blurRadius: 20,
                          offset: const Offset(0, 10),
                        ),
                      ],
                    ),
                    child: const Icon(
                      Icons.person,
                      size: 60,
                      color: Colors.white,
                    ),
                  ),
                  Positioned(
                    bottom: 0,
                    right: 0,
                    child: Container(
                      padding: const EdgeInsets.all(8),
                      decoration: const BoxDecoration(
                        color: successColor,
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(
                        Icons.camera_alt,
                        size: 20,
                        color: Colors.white,
                      ),
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 40),

            // Form Section
            _buildTextField(
              "Nama Lengkap",
              nameController,
              Icons.person_outline,
            ),
            const SizedBox(height: 16),
            _buildTextField("Email", emailController, Icons.email_outlined),
            const SizedBox(height: 16),
            _buildTextField(
              "No. Telepon",
              phoneController,
              Icons.phone_outlined,
            ),
            const SizedBox(height: 16),
            _buildTextField("Jabatan", positionController, Icons.work_outline),

            const SizedBox(height: 30),

            // Save Button
            ModernButton(
              text: "Simpan Profil",
              icon: Icons.save_rounded,
              onPressed: _saveProfile,
            ),

            const SizedBox(height: 20),

            // Settings Options
            _buildSettingTile(
              icon: Icons.notifications_outlined,
              title: "Notifikasi",
              subtitle: "Atur pengingat absensi",
              onTap: () {},
            ),
            _buildSettingTile(
              icon: Icons.lock_outline,
              title: "Keamanan",
              subtitle: "Ubah password & PIN",
              onTap: () {},
            ),
            _buildSettingTile(
              icon: Icons.help_outline,
              title: "Bantuan",
              subtitle: "FAQ & Dukungan",
              onTap: () {},
            ),
            _buildSettingTile(
              icon: Icons.logout_rounded,
              title: "Keluar",
              subtitle: "Logout dari aplikasi",
              onTap: () {},
              isDestructive: true,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTextField(
    String label,
    TextEditingController controller,
    IconData icon,
  ) {
    return TextField(
      controller: controller,
      decoration: InputDecoration(
        labelText: label,
        prefixIcon: Icon(icon, color: primaryColor),
        filled: true,
        fillColor: Colors.white,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: Colors.grey.shade300),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: Colors.grey.shade300),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: primaryColor, width: 2),
        ),
      ),
    );
  }

  Widget _buildSettingTile({
    required IconData icon,
    required String title,
    required String subtitle,
    required VoidCallback onTap,
    bool isDestructive = false,
  }) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
      ),
      child: ListTile(
        leading: Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: isDestructive
                ? accentColor.withOpacity(0.1)
                : primaryColor.withOpacity(0.1),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Icon(icon, color: isDestructive ? accentColor : primaryColor),
        ),
        title: Text(
          title,
          style: GoogleFonts.poppins(
            fontWeight: FontWeight.w600,
            color: isDestructive ? accentColor : secondaryColor,
          ),
        ),
        subtitle: Text(subtitle, style: GoogleFonts.poppins(fontSize: 12)),
        trailing: const Icon(Icons.chevron_right_rounded),
        onTap: onTap,
      ),
    );
  }
}
