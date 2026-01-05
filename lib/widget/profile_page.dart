import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:google_fonts/google_fonts.dart';
import '../models/user_model.dart';
import '../services/auth_service.dart';

class InformasiProfil extends StatefulWidget {
  final UserModel user;

  const InformasiProfil({super.key, required this.user});

  @override
  State<InformasiProfil> createState() => _InformasiProfilState();
}

class _InformasiProfilState extends State<InformasiProfil> {
  final AuthService _authService = AuthService();
  final _formKey = GlobalKey<FormState>();

  late TextEditingController _nameController;
  final TextEditingController _passwordController = TextEditingController();

  bool _isLoading = false;
  bool _showPassword = false;
  File? _newProfileImageFile;

  // Warna Utama Konsisten
  final Color primaryColor = const Color(0xFF21899C);
   final Color accent = const Color(0xFFF56B3F); 

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController(text: widget.user.name);
  }

  @override
  void dispose() {
    _nameController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  // --- LOGIKA FUNGSI ---
  Future<void> _pickImage() async {
    final picker = ImagePicker();
    final pickedFile = await picker.pickImage(source: ImageSource.gallery);

    if (pickedFile != null) {
      setState(() {
        _newProfileImageFile = File(pickedFile.path);
      });
      await _updateProfilePicture();
    }
  }

  Future<void> _updateProfilePicture() async {
    if (_newProfileImageFile == null) return;
    setState(() => _isLoading = true);
    final res = await _authService.uploadProfilePicture(_newProfileImageFile!.path);

    if (mounted) {
      if (res != null && !res.startsWith("Firebase")) {
        setState(() {
          widget.user.photoUrl = res;
          _newProfileImageFile = null;
        });
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Foto profil diperbarui!')),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Gagal mengunggah foto: $res')),
        );
      }
      setState(() => _isLoading = false);
    }
  }

  Future<void> _updateProfileData() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() => _isLoading = true);

    try {
      if (_nameController.text != widget.user.name) {
        await _authService.updateUserName(_nameController.text);
        widget.user.name = _nameController.text;
      }
      if (_passwordController.text.isNotEmpty) {
        await _authService.updatePassword(_passwordController.text);
      }

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Profil berhasil diperbarui!')),
        );
        _passwordController.clear();
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error: $e')),
        );
      }
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    // Logika Gambar Profil
    ImageProvider profileImg;
    if (_newProfileImageFile != null) {
      profileImg = FileImage(_newProfileImageFile!);
    } else if (widget.user.photoUrl != null && widget.user.photoUrl!.isNotEmpty) {
      profileImg = NetworkImage(widget.user.photoUrl!);
    } else {
      profileImg = const AssetImage("assets/images/profil.jpg");
    }

    return Scaffold(
      backgroundColor: const Color(0xFFF2F5F7),
      body: SingleChildScrollView(
        child: Column(
          children: [
            // --- HEADER MELENGKUNG (SAMA DENGAN DASHBOARD) ---
            Stack(
              children: [
                Container(
                  height: 220,
                  width: double.infinity,
                  decoration: BoxDecoration(
                    color: primaryColor,
                    borderRadius: const BorderRadius.only(
                      bottomLeft: Radius.circular(50),
                      bottomRight: Radius.circular(50),
                    ),
                  ),
                ),
                SafeArea(
                  child: Column(
                    children: [
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 10),
                        child: Row(
                          children: [
                            const Spacer(),
                            Text(
                              "Edit Profil",
                              style: GoogleFonts.poppins(
                                color: Colors.white,
                                fontWeight: FontWeight.bold,
                                fontSize: 18,
                              ),
                            ),
                            const Spacer(),
                            const SizedBox(width: 48), // Penyeimbang Leading
                          ],
                        ),
                      ),
                      const SizedBox(height: 20),
                      // FOTO PROFIL MANUAL
                      Center(
                        child: Stack(
                          children: [
                            Container(
                              padding: const EdgeInsets.all(4),
                              decoration: const BoxDecoration(
                                color: Colors.white,
                                shape: BoxShape.circle,
                              ),
                              child: CircleAvatar(
                                radius: 60,
                                backgroundColor: Colors.grey[200],
                                backgroundImage: profileImg,
                              ),
                            ),
                            Positioned(
                              bottom: 0,
                              right: 0,
                              child: GestureDetector(
                                onTap: _isLoading ? null : _pickImage,
                                child: Container(
                                  padding: const EdgeInsets.all(8),
                                  decoration: BoxDecoration(
                                    color: const Color(0xFFF9CA58), // Warna Highlight Kuning
                                    shape: BoxShape.circle,
                                    border: Border.all(color: Colors.white, width: 2),
                                  ),
                                  child: const Icon(Icons.camera_alt, size: 20, color: Colors.white),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),

            // --- FORM INPUT MANUAL ---
            Padding(
              padding: const EdgeInsets.all(25),
              child: Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // INPUT NAMA
                    Text("Nama Lengkap", style: GoogleFonts.poppins(fontWeight: FontWeight.w600, color: primaryColor)),
                    const SizedBox(height: 8),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 15),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(15),
                        boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 10)],
                      ),
                      child: TextFormField(
                        controller: _nameController,
                        decoration: const InputDecoration(
                          border: InputBorder.none,
                          icon: Icon(Icons.person_outline, color: Color(0xFF4DA1B0)),
                        ),
                      ),
                    ),

                    const SizedBox(height: 20),

                    // INPUT EMAIL (READ ONLY)
                    Text("Email", style: GoogleFonts.poppins(fontWeight: FontWeight.w600, color: primaryColor)),
                    const SizedBox(height: 8),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 15),
                      decoration: BoxDecoration(
                        color: Colors.grey[200],
                        borderRadius: BorderRadius.circular(15),
                      ),
                      child: TextFormField(
                        initialValue: widget.user.email,
                        readOnly: true,
                        decoration: const InputDecoration(
                          border: InputBorder.none,
                          icon: Icon(Icons.email_outlined, color: Colors.grey),
                        ),
                      ),
                    ),

                    const SizedBox(height: 20),

                    // INPUT PASSWORD
                    Text("Password Baru", style: GoogleFonts.poppins(fontWeight: FontWeight.w600, color: primaryColor)),
                    const SizedBox(height: 8),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 15),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(15),
                        boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 10)],
                      ),
                      child: TextFormField(
                        controller: _passwordController,
                        obscureText: !_showPassword,
                        decoration: InputDecoration(
                          border: InputBorder.none,
                          icon: const Icon(Icons.lock_outline, color: Color(0xFF4DA1B0)),
                          suffixIcon: IconButton(
                            icon: Icon(_showPassword ? Icons.visibility : Icons.visibility_off, size: 20),
                            onPressed: () => setState(() => _showPassword = !_showPassword),
                          ),
                        ),
                      ),
                    ),

                    const SizedBox(height: 40),

                    // TOMBOL UPDATE MANUAL
                    GestureDetector(
                      onTap: _isLoading ? null : _updateProfileData,
                      child: Container(
                        width: double.infinity,
                        height: 55,
                        decoration: BoxDecoration(
                          color: accent,
                          borderRadius: BorderRadius.circular(15),
                          boxShadow: [
                            BoxShadow(
                              color: primaryColor.withOpacity(0.3),
                              blurRadius: 10,
                              offset: const Offset(0, 5),
                            ),
                          ],
                        ),
                        child: Center(
                          child: _isLoading
                              ? const CircularProgressIndicator(color: Colors.white)
                              : Text(
                                  "UPDATE PROFIL",
                                  style: GoogleFonts.poppins(
                                    color: Colors.white,
                                    fontWeight: FontWeight.bold,
                                    fontSize: 16,
                                  ),
                                ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 20),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}