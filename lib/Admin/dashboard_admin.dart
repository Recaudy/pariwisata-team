import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:project_uts_pariwisata/Admin/profil_admin_page.dart';
import '../services/wisata_services.dart';
import '../models/wisata_model.dart';
import '../services/komentar_service.dart';
import 'wisata_form_page.dart';
import 'Komentar_page.dart';
import 'wisata_list_page.dart';

const Color primaryColor = Color(0xFF21899C);

class AdminDashboardPage extends StatefulWidget {
  const AdminDashboardPage({super.key});

  @override
  State<AdminDashboardPage> createState() => _AdminDashboardPageState();
}

class _AdminDashboardPageState extends State<AdminDashboardPage> {
  final WisataService _wisataService = WisataService();
  final KomentarService _komentarService = KomentarService();

  String selectedKategori = 'all';
  int maxItems = 2;
  int _selectedIndex = 0;


  void _showLogoutDialog() {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text("Konfirmasi Logout"),
        content: const Text("Apakah Anda yakin ingin logout?"),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text("Batal"),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              Navigator.pushNamedAndRemoveUntil(context, '/', (route) => false);
            },
            child: const Text("Logout", style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF4F6FA),

      appBar: AppBar(
        elevation: 0,
        backgroundColor: primaryColor,
        title: const Text("Dashboard Admin"),
      ),

      drawer: Drawer(
        child: Column(
          children: [
            const DrawerHeader(
              decoration: BoxDecoration(color: primaryColor),
              child: Align(
                alignment: Alignment.bottomLeft,
                child: Text(
                  "Admin",
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),
            ListTile(
              leading: const Icon(Icons.dashboard),
              title: const Text("Dashboard"),
              onTap: () => Navigator.pop(context),
            ),
            ListTile(
              leading: const Icon(Icons.place),
              title: const Text("Kelola Wisata"),
              onTap: () {
                Navigator.pop(context);
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => const WisataListPage(
                      kategori: 'all',
                      kategoriName: 'Semua Wisata',
                    ),
                  ),
                );
              },
            ),
            const Spacer(),
            ListTile(
              leading: const Icon(Icons.logout, color: Colors.red),
              title: const Text("Logout"),
              onTap: _showLogoutDialog,
            ),
          ],
        ),
      ),

      floatingActionButton: FloatingActionButton(
        backgroundColor: primaryColor,
        child: const Icon(Icons.add),
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (_) => const WisataFormPage()),
          );
        },
      ),

      body: StreamBuilder<List<WisataModel>>(
        stream: _wisataService.getWisata(),
        builder: (context, snapshot) {
          final wisataList = snapshot.data ?? [];

          final filteredWisata = selectedKategori == 'all'
              ? wisataList
              : wisataList
                    .where((w) => w.kategori == selectedKategori)
                    .toList();

          final displayWisata = filteredWisata.length > maxItems
              ? filteredWisata.sublist(0, maxItems)
              : filteredWisata;

          return SingleChildScrollView(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // ================= HEADER DASHBOARD =================
                StreamBuilder<QuerySnapshot>(
                  stream: _komentarService.getKomentar(),
                  builder: (context, komentarSnap) {
                    int totalUlasan = komentarSnap.hasData
                        ? komentarSnap.data!.docs.length
                        : 0;

                    return StreamBuilder<QuerySnapshot>(
                      stream: FirebaseFirestore.instance
                          .collection('ratings')
                          .snapshots(),
                      builder: (context, ratingSnap) {
                        double avgRating = 0;
                        if (ratingSnap.hasData &&
                            ratingSnap.data!.docs.isNotEmpty) {
                          final ratings = ratingSnap.data!.docs
                              .map(
                                (e) =>
                                    (e.data() as Map<String, dynamic>)['rating']
                                        as int,
                              )
                              .toList();
                          avgRating =
                              ratings.reduce((a, b) => a + b) / ratings.length;
                        }

                        return dashboardHeader(
                          totalWisata: wisataList.length,
                          totalUlasan: totalUlasan,
                          rating: avgRating,
                        );
                      },
                    );
                  },
                ),

                const SizedBox(height: 24),
                quickMenu(context),

                
              ],
            ),
          );
        },
      ),

      bottomNavigationBar: BottomNavigationBar(
        selectedItemColor: primaryColor,
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.dashboard),
            label: "Dashboard",
          ),
          BottomNavigationBarItem(icon: Icon(Icons.place), label: "Wisata"),
          BottomNavigationBarItem(icon: Icon(Icons.person), label: "Profil"),
        ],
        onTap: (index) {
          if (index == 0) {
            Navigator.push(
              context,
              MaterialPageRoute(builder: (_) => const AdminDashboardPage()),
            );
          } else if (index == 1) {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (_) => const WisataListPage(
                  kategori: 'all',
                  kategoriName: 'Semua Wisata',
                ),
              ),
            );
          } else if (index == 2) {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (_) =>
                    const InformasiProfilAdmin(), // ganti sesuai punyamu
              ),
            );
          }
        },
      ),
    );
  }
}

Widget dashboardHeader({
  required int totalWisata,
  required int totalUlasan,
  required double rating,
}) {
  return Container(
    padding: const EdgeInsets.all(20),
    decoration: BoxDecoration(
      gradient: const LinearGradient(
        colors: [Color(0xFF4B6CB7), Color(0xFF182848)],
      ),
      borderRadius: BorderRadius.circular(24),
      boxShadow: [
        BoxShadow(
          color: Colors.black.withOpacity(0.15),
          blurRadius: 12,
          offset: const Offset(0, 6),
        ),
      ],
    ),
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          "Dashboard Admin",
          style: TextStyle(
            color: Colors.white,
            fontSize: 20,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 20),
        Row(
          children: [
            headerStat(Icons.place, "Wisata", totalWisata.toString()),
            const SizedBox(width: 12),
            headerStat(Icons.comment, "Ulasan", totalUlasan.toString()),
            const SizedBox(width: 12),
            headerStat(Icons.star, "Rating", rating.toStringAsFixed(1)),
          ],
        ),
      ],
    ),
  );
}

Widget headerStat(IconData icon, String label, String value) {
  return Expanded(
    child: Container(
      padding: const EdgeInsets.symmetric(vertical: 16),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.15),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        children: [
          Icon(icon, color: Colors.white),
          const SizedBox(height: 8),
          Text(
            value,
            style: const TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.bold,
              fontSize: 18,
            ),
          ),
          Text(
            label,
            style: const TextStyle(color: Colors.white70, fontSize: 12),
          ),
        ],
      ),
    ),
  );
}

Widget quickMenu(BuildContext context) {
  return Row(
    children: [
      quickMenuItem(
        icon: Icons.place,
        label: "Kelola Wisata",
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (_) => const WisataListPage(
                kategori: 'all',
                kategoriName: 'Semua Wisata',
              ),
            ),
          );
        },
      ),
      const SizedBox(width: 12),
      quickMenuItem(
        icon: Icons.comment,
        label: "Ulasan",
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (_) => KomentarPage(wisataList: const []),
            ),
          );
        },
      ),
    ],
  );
}

Widget quickMenuItem({
  required IconData icon,
  required String label,
  required VoidCallback onTap,
}) {
  return Expanded(
    child: InkWell(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: cardDecoration(),
        child: Column(
          children: [
            Icon(icon, color: primaryColor, size: 28),
            const SizedBox(height: 8),
            Text(label, style: const TextStyle(fontWeight: FontWeight.w600)),
          ],
        ),
      ),
    ),
  );
}

BoxDecoration cardDecoration() {
  return BoxDecoration(
    color: Colors.white,
    borderRadius: BorderRadius.circular(18),
    boxShadow: [
      BoxShadow(color: Colors.black.withOpacity(0.08), blurRadius: 10),
    ],
  );
}
