import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';

import '../models/user_model.dart';
import '../services/auth_service.dart';

const Color primaryColor = Color(0xFF21899C);

class InformasiProfilAdmin extends StatefulWidget {
  const InformasiProfilAdmin({super.key});

  @override
  State<InformasiProfilAdmin> createState() => _InformasiProfilAdminState();
}

class _InformasiProfilAdminState extends State<InformasiProfilAdmin> {
  final AuthService _authService = AuthService();

  UserModel? admin;
  bool isLoading = true;

  File? _newProfileImageFile;

  @override
  void initState() {
    super.initState();
    _loadAdmin();
  }

  Future<void> _loadAdmin() async {
    final user = await _authService.getCurrentUserData();

    setState(() {
      admin = user;
      isLoading = false;
    });
  }

  Future<void> _pickImage() async {
    final picker = ImagePicker();
    final picked = await picker.pickImage(source: ImageSource.gallery);

    if (picked != null) {
      setState(() {
        _newProfileImageFile = File(picked.path);
      });

      await _authService.uploadProfilePicture(picked.path);
      await _loadAdmin(); // refresh data
    }
  }

  @override
  Widget build(BuildContext context) {
    if (isLoading) {
      return const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    }

    if (admin == null) {
      return const Scaffold(
        body: Center(child: Text("Admin tidak ditemukan")),
      );
    }

    ImageProvider profileImage;
    if (_newProfileImageFile != null) {
      profileImage = FileImage(_newProfileImageFile!);
    } else if (admin!.photoUrl != null && admin!.photoUrl!.isNotEmpty) {
      profileImage = NetworkImage(admin!.photoUrl!);
    } else {
      profileImage = const AssetImage("assets/images/profil.jpg");
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text("Profil Admin"),
        centerTitle: true,
        backgroundColor: primaryColor,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            GestureDetector(
              onTap: _pickImage,
              child: CircleAvatar(
                radius: 60,
                backgroundImage: profileImage,
              ),
            ),
            const SizedBox(height: 16),

            Text(
              admin!.name,
              style: const TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 6),

            Text(
              admin!.email,
              style: const TextStyle(color: Colors.grey),
            ),

            const SizedBox(height: 30),

            _buildInfoTile(Icons.person, "Nama", admin!.name),
            const SizedBox(height: 16),
            _buildInfoTile(Icons.email, "Email", admin!.email),
            const SizedBox(height: 16),
            _buildInfoTile(Icons.security, "Role", admin!.role),
          ],
        ),
      ),
    );
  }

  Widget _buildInfoTile(IconData icon, String label, String value) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 18),
      decoration: BoxDecoration(
        color: Colors.grey[100],
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: Colors.grey.shade300),
      ),
      child: Row(
        children: [
          Icon(icon, color: primaryColor),
          const SizedBox(width: 12),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(label, style: const TextStyle(color: Colors.grey)),
              const SizedBox(height: 4),
              Text(value, style: const TextStyle(fontSize: 16)),
            ],
          ),
        ],
      ),
    );
  }
}
