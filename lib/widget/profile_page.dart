import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
// Sesuaikan path import sesuai struktur folder Anda
import '../models/user_model.dart';
import '../services/auth_service.dart';

// SKEMA WARNA BARU
const Color mainColor = Color(0xFF21899C); // Tosca
const Color subColor = Color(0xFFE6F4F6); // Biru Muda (Background)
const Color fieldFillColor = Color(
  0xFFF0F9FA,
); // Warna isi input yang lebih lembut

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
    final res = await _authService.uploadProfilePicture(
      _newProfileImageFile!.path,
    );

    if (mounted) {
      if (res != null && !res.startsWith("Firebase")) {
        setState(() {
          widget.user.photoUrl = res;
          _newProfileImageFile = null;
        });
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Foto profil berhasil diperbarui!')),
        );
      } else {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Gagal mengunggah foto: $res')));
      }
      setState(() => _isLoading = false);
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

    setState(() => _isLoading = true);

    try {
      String? errorMessage;
      if (nameChanged) {
        final err = await _authService.updateUserName(_nameController.text);
        if (err != null)
          errorMessage = (errorMessage ?? '') + 'Nama gagal: $err. ';
      }
      if (passwordChanged) {
        final err = await _authService.updatePassword(_passwordController.text);
        if (err != null)
          errorMessage = (errorMessage ?? '') + 'Password gagal: $err. ';
      }

      if (mounted) {
        if (errorMessage == null) {
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
        ).showSnackBar(SnackBar(content: Text('Terjadi kesalahan: $e')));
      }
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  // --- UI / TAMPILAN ---

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
      backgroundColor: subColor, // Latar belakang Biru Muda
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(
            Icons.keyboard_arrow_left,
            color: mainColor,
            size: 30,
          ),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text(
          "Edit Profile",
          style: TextStyle(color: mainColor, fontWeight: FontWeight.bold),
        ),
        centerTitle: true,
      ),
      body: Form(
        key: _formKey,
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 25),
          child: Column(
            children: [
              const SizedBox(height: 20),

              // FOTO PROFIL
              Center(
                child: Stack(
                  children: [
                    Container(
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        border: Border.all(color: Colors.white, width: 4),
                        boxShadow: [
                          BoxShadow(
                            color: mainColor.withOpacity(0.2),
                            blurRadius: 10,
                            spreadRadius: 2,
                          ),
                        ],
                      ),
                      child: CircleAvatar(
                        radius: 70,
                        backgroundColor: Colors.white,
                        backgroundImage: profileImage,
                      ),
                    ),
                    Positioned(
                      bottom: 5,
                      right: 5,
                      child: GestureDetector(
                        onTap: _pickImage,
                        child: Container(
                          padding: const EdgeInsets.all(8),
                          decoration: const BoxDecoration(
                            color: mainColor,
                            shape: BoxShape.circle,
                          ),
                          child: const Icon(
                            Icons.camera_alt_outlined,
                            color: Colors.white,
                            size: 20,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 40),

              // FIELD NAMA
              _buildCustomField(
                controller: _nameController,
                label: "Full Name",
                icon: Icons.person_outline,
              ),
              const SizedBox(height: 20),

              // FIELD EMAIL (Read Only)
              _buildCustomField(
                initialValue: widget.user.email,
                label: "E-Mail",
                icon: Icons.email_outlined,
                readOnly: true,
              ),
              const SizedBox(height: 20),

              // FIELD PASSWORD
              _buildCustomField(
                controller: _passwordController,
                label: "Password Baru",
                icon: Icons.lock_outline,
                isPassword: true,
              ),

              const SizedBox(height: 50),

              // TOMBOL EDIT PROFILE
              SizedBox(
                width: double.infinity,
                height: 55,
                child: ElevatedButton(
                  onPressed: _isLoading ? null : _updateProfileData,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: mainColor,
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(
                        15,
                      ), // Lebih kotak tapi tetap melengkung
                    ),
                    elevation: 4,
                    shadowColor: mainColor.withOpacity(0.4),
                  ),
                  child: _isLoading
                      ? const CircularProgressIndicator(color: Colors.white)
                      : const Text(
                          "Update Profil",
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                ),
              ),
              const SizedBox(height: 30),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildCustomField({
    TextEditingController? controller,
    String? initialValue,
    required String label,
    required IconData icon,
    bool isPassword = false,
    bool readOnly = false,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.only(left: 10, bottom: 8),
          child: Text(
            label,
            style: const TextStyle(
              color: mainColor,
              fontSize: 14,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
        TextFormField(
          controller: controller,
          initialValue: initialValue,
          readOnly: readOnly,
          obscureText: isPassword && !_showPassword,
          style: TextStyle(
            color: readOnly ? Colors.grey[600] : Colors.black87,
            fontSize: 16,
          ),
          decoration: InputDecoration(
            prefixIcon: Icon(icon, color: mainColor),
            suffixIcon: isPassword
                ? IconButton(
                    icon: Icon(
                      _showPassword ? Icons.visibility : Icons.visibility_off,
                      color: mainColor.withOpacity(0.6),
                    ),
                    onPressed: () =>
                        setState(() => _showPassword = !_showPassword),
                  )
                : null,
            contentPadding: const EdgeInsets.symmetric(
              horizontal: 20,
              vertical: 18,
            ),
            // Border normal
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(15),
              borderSide: BorderSide(color: mainColor.withOpacity(0.1)),
            ),
            // Border saat diklik
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(15),
              borderSide: const BorderSide(color: mainColor, width: 1.5),
            ),
            filled: true,
            fillColor: readOnly ? Colors.grey[200] : Colors.white,
          ),
        ),
      ],
    );
  }
}
