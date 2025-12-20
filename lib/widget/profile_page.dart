// screens/informasi_profil.dart

import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
// Sesuaikan path import
import '../models/user_model.dart';
import '../services/auth_service.dart';
import '../login/login_screen.dart';

// WARNA UTAMA
const Color primaryColor = Color(0xFF21899C);

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

  @override
  void initState() {
    super.initState();
    // Inisialisasi controller hanya untuk Nama
    _nameController = TextEditingController(text: widget.user.name);
  }

  @override
  void dispose() {
    _nameController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

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

    setState(() {
      _isLoading = true;
    });

    final newPhotoUrlOrError = await _authService.uploadProfilePicture(
      _newProfileImageFile!.path,
    );

    if (mounted) {
      if (newPhotoUrlOrError != null &&
          !newPhotoUrlOrError.startsWith("Firebase")) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Foto profil berhasil diperbarui!')),
        );
        setState(() {
          widget.user.photoUrl = newPhotoUrlOrError;
          _newProfileImageFile = null;
        });
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Gagal mengunggah foto: $newPhotoUrlOrError')),
        );
      }
      setState(() {
        _isLoading = false;
      });
    }
  }


  Future<void> _updateProfileData() async {
    if (!_formKey.currentState!.validate()) return;

    final bool nameChanged = _nameController.text != widget.user.name;
    final bool passwordChanged = _passwordController.text.isNotEmpty;

    if (!nameChanged && !passwordChanged) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Tidak ada perubahan untuk disimpan.')),
      );
      return;
    }

    setState(() {
      _isLoading = true;
    });

    String? errorMessage;
    String? nameUpdateError;
    String? passwordUpdateError;

    try {
      // 1. Perbarui Nama
      if (nameChanged) {
        nameUpdateError = await _authService.updateUserName(
          _nameController.text,
        );
        if (nameUpdateError != null)
          errorMessage =
              (errorMessage ?? '') + 'Nama gagal: $nameUpdateError. ';
      }

      // 2. Perbarui Password
      if (passwordChanged) {
        passwordUpdateError = await _authService.updatePassword(
          _passwordController.text,
        );
        if (passwordUpdateError != null)
          errorMessage =
              (errorMessage ?? '') + 'Password gagal: $passwordUpdateError. ';
      }

      if (mounted) {
        if (errorMessage == null) {
          // Update data lokal
          setState(() {
            widget.user.name = _nameController.text;
            _passwordController.clear();
          });

          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Profil berhasil diperbarui!')),
          );
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Gagal memperbarui: $errorMessage')),
          );
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Terjadi kesalahan umum: $e')));
      }
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    ImageProvider profileImage;
    if (_newProfileImageFile != null) {
      profileImage = FileImage(_newProfileImageFile!);
    } else if (widget.user.photoUrl != null &&
        widget.user.photoUrl!.isNotEmpty) {
      profileImage = NetworkImage(widget.user.photoUrl!);
    } else {
      profileImage = const AssetImage("assets/images/profil.jpg");
    }

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: const Text(
          "Edit Profile",
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        centerTitle: true,
        elevation: 0,
        backgroundColor: primaryColor,
        foregroundColor: Colors.white,
        leading: IconButton(
          icon: const Icon(Icons.keyboard_arrow_left, color: Colors.white),
          onPressed: () => Navigator.pop(context),
        ),
        actions: [
          IconButton(
            onPressed: _isLoading ? null : _updateProfileData,
            icon: _isLoading
                ? const SizedBox(
                    width: 20,
                    height: 20,
                    child: CircularProgressIndicator(
                      color: Colors.white,
                      strokeWidth: 2,
                    ),
                  )
                : const Icon(Icons.save, color: Colors.white),
            tooltip: 'Simpan Perubahan',
          ),
        ],
      ),
      body: Form(
        key: _formKey,
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: Column(
            children: [
              const SizedBox(height: 40),

              // FOTO PROFIL & Tombol Ganti Foto
              GestureDetector(
                onTap: _pickImage,
                child: Stack(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(4),
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: Colors.white,
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.15),
                            blurRadius: 12,
                            offset: const Offset(0, 6),
                          ),
                        ],
                      ),
                      child: Hero(
                        tag: 'foto-profil',
                        child: CircleAvatar(
                          radius: 55,
                          backgroundImage: profileImage,
                        ),
                      ),
                    ),
                    // Tombol overlay untuk ganti foto
                    Positioned(
                      bottom: 0,
                      right: 0,
                      child: Container(
                        padding: const EdgeInsets.all(4),
                        decoration: BoxDecoration(
                          color: primaryColor,
                          shape: BoxShape.circle,
                          border: Border.all(color: Colors.white, width: 2),
                        ),
                        child: const Icon(
                          Icons.camera_alt,
                          color: Colors.white,
                          size: 20,
                        ),
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 12),
              Text(
                widget.user.name,
                style: const TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 35),

              // FIELD NAMA
              _buildTextFormField(
                controller: _nameController,
                icon: Icons.person,
                label: "Nama",
                validator: (val) =>
                    val!.isEmpty ? 'Nama tidak boleh kosong' : null,
              ),
              const SizedBox(height: 20),

              // FIELD EMAIL (Ditampilkan, tetapi tidak dapat diedit)
              _buildStaticField(
                icon: Icons.email,
                label: "Email",
                value: widget.user.email,
              ),

              const SizedBox(height: 20),

              // FIELD PASSWORD
              _buildPasswordFormField(),

              const SizedBox(height: 50),
            ],
          ),
        ),
      ),
    );
  }

  // Widget kustom untuk field yang TIDAK DAPAT diedit (Email)
  Widget _buildStaticField({
    required IconData icon,
    required String label,
    required String value,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 18),
      decoration: BoxDecoration(
        color: Colors
            .grey[100], // Warna abu-abu untuk menunjukkan tidak bisa diedit
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: Colors.grey.shade300),
      ),
      child: Row(
        children: [
          Icon(icon, color: Colors.grey, size: 22),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              value,
              style: const TextStyle(fontSize: 16, color: Colors.black54),
            ),
          ),
        ],
      ),
    );
  }

  // Widget kustom TextFormField
  Widget _buildTextFormField({
    required TextEditingController controller,
    required IconData icon,
    required String label,
    String? Function(String?)? validator,
    bool isEmail = false,
  }) {
    return TextFormField(
      controller: controller,
      keyboardType: isEmail ? TextInputType.emailAddress : TextInputType.text,
      validator: validator,
      style: const TextStyle(fontSize: 16),
      decoration: InputDecoration(
        labelText: label,
        labelStyle: const TextStyle(color: primaryColor),
        prefixIcon: Icon(icon, color: primaryColor),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: BorderSide(color: Colors.grey.shade300),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: BorderSide(color: Colors.grey.shade300),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: const BorderSide(color: primaryColor, width: 2),
        ),
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 16,
          vertical: 14,
        ),
        filled: true,
        fillColor: Colors.grey[50],
      ),
    );
  }

  // Widget kustom PasswordField
  Widget _buildPasswordFormField() {
    return TextFormField(
      controller: _passwordController,
      obscureText: !_showPassword,
      style: const TextStyle(fontSize: 16),
      decoration: InputDecoration(
        labelText: "Password Baru (Kosongkan jika tidak ingin ganti)",
        labelStyle: const TextStyle(color: primaryColor),
        prefixIcon: Icon(Icons.lock, color: primaryColor),
        suffixIcon: IconButton(
          icon: Icon(
            _showPassword ? Icons.visibility : Icons.visibility_off,
            color: primaryColor,
          ),
          onPressed: () => setState(() => _showPassword = !_showPassword),
        ),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: BorderSide(color: Colors.grey.shade300),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: BorderSide(color: Colors.grey.shade300),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: const BorderSide(color: primaryColor, width: 2),
        ),
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 16,
          vertical: 14,
        ),
        filled: true,
        fillColor: Colors.grey[50],
      ),
      validator: (val) {
        if (val!.isNotEmpty && val.length < 6) {
          return 'Password minimal 6 karakter';
        }
        return null;
      },
    );
  }
}


class _ZoomFotoProfil extends StatelessWidget {
  const _ZoomFotoProfil();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        backgroundColor: Colors.black,
        iconTheme: const IconThemeData(color: Colors.white),
        elevation: 0,
      ),
      body: Center(
        child: Hero(
          tag: 'foto-profil',
          child: InteractiveViewer(
            minScale: 1,
            maxScale: 4,
            child: Image.asset("assets/images/profil.jpg"),
          ),
        ),
      ),
    );
  }
}

// ------------------------------------------------------------------
// DUMMY CLASS LoginScreen
// ------------------------------------------------------------------

