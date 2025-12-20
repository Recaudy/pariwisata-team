import 'package:flutter/material.dart';
import '../services/wisata_services.dart';
import '../models/wisata_model.dart';
import 'wisata_form_page.dart';



const Color primaryColor = Color(0xFF21899C);

class AdminDashboardPage extends StatelessWidget {
  AdminDashboardPage({super.key});

  final WisataService _service = WisataService();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Admin Dashboard")),
      drawer: Drawer(
        child: ListView(
          children: [
            const DrawerHeader(
              decoration: BoxDecoration(color: primaryColor),
              child: Text(
                "Admin Panel",
                style: TextStyle(color: Colors.white, fontSize: 20),
              ),
            ),
            const ListTile(
              leading: Icon(Icons.place),
              title: Text("Kelola Wisata"),
            ),
            ListTile(
              leading: const Icon(Icons.logout),
              title: const Text("Logout"),
              onTap: () {
                Navigator.pushNamedAndRemoveUntil(
                  context,
                  '/',
                  (route) => false,
                );
              },
            ),
          ],
        ),
      ),

      // ================= BODY =================
      body: StreamBuilder<List<WisataModel>>(
        stream: _service.getWisata(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          final wisataList = snapshot.data ?? [];

          if (wisataList.isEmpty) {
            return const Center(child: Text("Belum ada data wisata"));
          }

          return ListView(
            padding: const EdgeInsets.all(16),
            children: [
              ElevatedButton.icon(
                style: ElevatedButton.styleFrom(
                  backgroundColor: primaryColor,
                ),
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => const WisataFormPage(),
                    ),
                  );
                },
                icon: const Icon(Icons.add),
                label: const Text("Tambah Wisata"),
              ),
              const SizedBox(height: 10),

              // ===== LIST DATA WISATA =====
              ...wisataList.map(
                (w) => Card(
                  child: ListTile(
                    title: Text(w.nama),
                    subtitle: Text(w.lokasi),
                    trailing: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        IconButton(
                          icon:
                              const Icon(Icons.edit, color: Colors.blue),
                          onPressed: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (_) =>
                                    WisataFormPage(wisata: w),
                              ),
                            );
                          },
                        ),
                        IconButton(
  icon: const Icon(Icons.delete, color: Colors.red),
  onPressed: () async {
    await _service.deleteWisata(w.id);
  },
),

                      ],
                    ),
                  ),
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}
