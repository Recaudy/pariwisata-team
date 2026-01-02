import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:project_uts_pariwisata/Admin/profil_admin_page.dart';
import '../services/wisata_services.dart';
import '../models/wisata_model.dart';
import '../services/komentar_service.dart';
import 'wisata_form_page.dart';
import 'Komentar_page.dart';
import 'wisata_list_page.dart';

/* ===== WARNA TEMA (4 WARNA SAJA) ===== */
const Color primaryColor = Color(0xFF21899C);
const Color secondaryColor = Color(0xFF176B78);
const Color accentColor = Color(0xFFFFC107);
const Color backgroundColor = Color(0xFFF2F5F7);

class AdminDashboardPage extends StatefulWidget {
  const AdminDashboardPage({super.key});

  @override
  State<AdminDashboardPage> createState() => _AdminDashboardPageState();
}

class _AdminDashboardPageState extends State<AdminDashboardPage> {
  final WisataService _wisataService = WisataService();
  final KomentarService _komentarService = KomentarService();

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
            child: const Text(
              "Logout",
              style: TextStyle(color: Colors.red),
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: backgroundColor,
      appBar: AppBar(
        elevation: 0,
        backgroundColor: secondaryColor,
        title: const Text(
          "Dashboard Admin",
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
      ),

      /* ===== DRAWER ===== */
      drawer: Drawer(
        child: Column(
          children: [
            Container(
              height: 200,
              width: double.infinity,
              padding: const EdgeInsets.all(16),
              decoration: const BoxDecoration(
                color: secondaryColor,
              ),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.end,
                children: const [
                  CircleAvatar(
                    radius: 36,
                    backgroundImage: AssetImage("assets/images/profil.jpg"),
                  ),
                  SizedBox(height: 12),
                  Text(
                    "Admin",
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
            ),

            ListTile(
              leading: Icon(Icons.dashboard, color: primaryColor),
              title: const Text("Dashboard"),
              onTap: () => Navigator.pop(context),
            ),
            ListTile(
              leading: Icon(Icons.place, color: primaryColor),
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

      /* ===== FAB ===== */
      floatingActionButton: FloatingActionButton(
        backgroundColor: accentColor,
        child: const Icon(Icons.add, color: Colors.black),
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (_) => const WisataFormPage()),
          );
        },
      ),

      /* ===== BODY ===== */
      body: StreamBuilder<List<WisataModel>>(
        stream: _wisataService.getWisata(),
        builder: (context, snapshot) {
          final wisataList = snapshot.data ?? [];

          return SingleChildScrollView(
            padding: const EdgeInsets.all(16),
            child: Column(
              children: [
                StreamBuilder<QuerySnapshot>(
                  stream: _komentarService.getKomentar(),
                  builder: (context, komentarSnap) {
                    int totalUlasan =
                        komentarSnap.hasData ? komentarSnap.data!.docs.length : 0;

                    return StreamBuilder<QuerySnapshot>(
                      stream: FirebaseFirestore.instance
                          .collection('ratings')
                          .snapshots(),
                      builder: (context, ratingSnap) {
                        double avgRating = 0;
                        if (ratingSnap.hasData &&
                            ratingSnap.data!.docs.isNotEmpty) {
                          final ratings = ratingSnap.data!.docs
                              .map((e) =>
                                  (e.data() as Map<String, dynamic>)['rating'] as int)
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

      /* ===== BOTTOM NAV ===== */
      bottomNavigationBar: BottomNavigationBar(
        selectedItemColor: primaryColor,
        unselectedItemColor: Colors.grey,
        backgroundColor: Colors.white,
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.dashboard), label: "Dashboard"),
          BottomNavigationBarItem(icon: Icon(Icons.place), label: "Wisata"),
          BottomNavigationBarItem(icon: Icon(Icons.person), label: "Profil"),
        ],
        onTap: (index) {
          if (index == 1) {
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
                builder: (_) => const InformasiProfilAdmin(),
              ),
            );
          }
        },
      ),
    );
  }
}

/* ===== WIDGET BAWAH ===== */

Widget dashboardHeader({
  required int totalWisata,
  required int totalUlasan,
  required double rating,
}) {
  return Container(
    padding: const EdgeInsets.all(20),
    decoration: BoxDecoration(
      color: secondaryColor,
      borderRadius: BorderRadius.circular(24),
    ),
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          "Statistik",
          style: TextStyle(
            color: Colors.white,
            fontSize: 18,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 20),
        Row(
          children: [
            headerStat(Icons.place, "Wisata", totalWisata.toString()),
            headerStat(Icons.comment, "Ulasan", totalUlasan.toString()),
            headerStat(Icons.star, "Rating", rating.toStringAsFixed(1)),
          ],
        ),
      ],
    ),
  );
}

Widget headerStat(IconData icon, String label, String value) {
  return Expanded(
    child: Column(
      children: [
        Icon(icon, color: accentColor, size: 28),
        const SizedBox(height: 4),
        Text(
          value,
          style: const TextStyle(
            color: Colors.white,
            fontSize: 16,
            fontWeight: FontWeight.bold,
          ),
        ),
        Text(label, style: const TextStyle(color: Colors.white70)),
      ],
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
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(18),
          boxShadow: const [
            BoxShadow(
              color: Colors.black12,
              blurRadius: 6,
              offset: Offset(0, 3),
            ),
          ],
        ),
        child: Column(
          children: [
            Icon(icon, color: primaryColor, size: 28),
            const SizedBox(height: 8),
            Text(
              label,
              style: const TextStyle(fontWeight: FontWeight.w600),
            ),
          ],
        ),
      ),
    ),
  );
}
