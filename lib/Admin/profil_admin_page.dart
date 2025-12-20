// screens/admin_profil_page.dart

import 'package:flutter/material.dart';

// WARNA UTAMA
const Color primaryColor = Color(0xFF21899C);

// Dummy AdminModel untuk contoh UI
class AdminModel {
  final String name;
  final String email;
  final String? photoUrl;

  AdminModel({required this.name, required this.email, this.photoUrl});
}

class AdminProfilPage extends StatelessWidget {
  final AdminModel admin;

  const AdminProfilPage({super.key, required this.admin});

  @override
  Widget build(BuildContext context) {
    ImageProvider profileImage;
    if (admin.photoUrl != null && admin.photoUrl!.isNotEmpty) {
      profileImage = NetworkImage(admin.photoUrl!);
    } else {
      profileImage = const AssetImage("assets/images/profil.jpg");
    }

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: const Text(
          "Profil Admin",
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        centerTitle: true,
        backgroundColor: primaryColor,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 30),
        child: Column(
          children: [
            // FOTO PROFIL
            Hero(
              tag: 'foto-profil-admin',
              child: CircleAvatar(
                radius: 60,
                backgroundImage: profileImage,
              ),
            ),
            const SizedBox(height: 16),

            // NAMA ADMIN
            Text(
              admin.name,
              style: const TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.bold
              ),
            ),
            const SizedBox(height: 8),
            Text(
              "Admin",
              style: TextStyle(
                fontSize: 16,
                color: Colors.grey[600],
              ),
            ),
            const SizedBox(height: 30),

            // FIELD NAMA
            _buildStaticField(icon: Icons.person, label: "Nama", value: admin.name),
            const SizedBox(height: 20),

            // FIELD EMAIL
            _buildStaticField(icon: Icons.email, label: "Email", value: admin.email),
          ],
        ),
      ),
    );
  }

  // Widget statis untuk field
  Widget _buildStaticField({required IconData icon, required String label, required String value}) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 18),
      decoration: BoxDecoration(
        color: Colors.grey[100],
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: Colors.grey.shade300),
      ),
      child: Row(
        children: [
          Icon(icon, color: Colors.grey, size: 22),
          const SizedBox(width: 12),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: const TextStyle(fontSize: 14, color: Colors.grey),
              ),
              const SizedBox(height: 4),
              Text(
                value,
                style: const TextStyle(fontSize: 16, color: Colors.black87),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
