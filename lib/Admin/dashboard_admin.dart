import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:project_uts_pariwisata/Admin/profil_admin_page.dart';
import '../services/wisata_services.dart';
import '../models/wisata_model.dart';
import '../services/komentar_service.dart';
import 'wisata_form_page.dart';
import 'Komentar_page.dart';
import 'wisata_list_page.dart';
import 'ratinglist_page.dart';

class AppColors {
  static const Color primary = Color(0xFF21899C);
  static const Color secondary = Color(0xFF4DA1B0);
  static const Color accent = Color(0xFFF56B3F);
  static const Color highlight = Color(0xFFF9CA58);
}

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
              style: TextStyle(color: Color(0xFF21899C)),
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF2F5F7),
      appBar: AppBar(
        title: Text('Selamat Datang di Dashboard Admin',
        style: GoogleFonts.poppins(
          fontWeight: FontWeight.bold,
          fontSize: 14,
          color: Colors.white,
        ),
        ),
        elevation: 0, backgroundColor: AppColors.primary
        ),
      drawer: Drawer(
        child: Container(
          color: Colors.white,
          child: Column(
            children: [
              Container(
                width: double.infinity,
                padding: const EdgeInsets.only(
                  top: 60,
                  bottom: 30,
                  left: 20,
                  right: 20,
                ),
                decoration: const BoxDecoration(
                  color: AppColors.primary,
                  borderRadius: BorderRadius.only(
                    bottomLeft: Radius.circular(30),
                  ),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Center(
                      child: Container(
                        padding: const EdgeInsets.all(3),
                        decoration: const BoxDecoration(
                          color: AppColors.highlight,
                          shape: BoxShape.circle,
                        ),
                        child: const CircleAvatar(
                          radius: 40,
                          backgroundImage: AssetImage(
                            "assets/images/profil.jpg",
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 15),
                    Center(
                      child: Text(
                        "Admin",
                        style: GoogleFonts.poppins(
                          color: Colors.white,
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 10),

              ListTile(
                leading: const Icon(
                  Icons.dashboard_rounded,
                  color: AppColors.primary,
                ),
                title: Text(
                  "Kelola Wisata",
                  style: GoogleFonts.inter(fontWeight: FontWeight.w600),
                ),
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
              ListTile(
                leading: const Icon(
                  Icons.map_rounded,
                  color: AppColors.primary,
                ),
                title: Text(
                  "Profil",
                  style: GoogleFonts.inter(fontWeight: FontWeight.w600),
                ),
                onTap: () {
                  Navigator.pop(context);
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => const InformasiProfilAdmin(),
                    ),
                  );
                },
              ),
              const Divider(indent: 20, endIndent: 20),

              const Spacer(),
              Padding(
                padding: const EdgeInsets.all(20.0),
                child: Container(
                  decoration: BoxDecoration(
                    color: Colors.red.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: ListTile(
                    leading: const Icon(
                      Icons.logout_rounded,
                      color: Color(0xFF21899C),
                    ),
                    title: Text(
                      "Logout",
                      style: GoogleFonts.inter(
                        color: Color(0xFF21899C),
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    onTap: _showLogoutDialog,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),

      floatingActionButton: FloatingActionButton(
        backgroundColor: AppColors.accent,
        child: const Icon(Icons.add, color: Colors.white),
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

          return SingleChildScrollView(
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  "Statistik Hari Ini",
                  style: GoogleFonts.poppins(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: AppColors.primary,
                  ),
                ),
                const SizedBox(height: 15),

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

                        return Container(
                          padding: const EdgeInsets.symmetric(vertical: 25),
                          decoration: BoxDecoration(
                            gradient: const LinearGradient(
                              colors: [AppColors.primary, AppColors.secondary],
                              begin: Alignment.topLeft,
                              end: Alignment.bottomRight,
                            ),
                            borderRadius: BorderRadius.circular(20),
                            boxShadow: [
                              BoxShadow(
                                color: AppColors.primary.withOpacity(0.3),
                                blurRadius: 10,
                                offset: const Offset(0, 5),
                              ),
                            ],
                          ),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceAround,
                            children: [
                              Expanded(
                                child: GestureDetector(
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
                                  child: Column(
                                    children: [
                                      const Icon(
                                        Icons.landscape_rounded,
                                        color: AppColors.highlight,
                                        size: 30,
                                      ),
                                      const SizedBox(height: 5),
                                      Text(
                                        wisataList.length.toString(),
                                        style: const TextStyle(
                                          color: Colors.white,
                                          fontSize: 18,
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                      const Text(
                                        "Wisata",
                                        style: TextStyle(
                                          color: Colors.white70,
                                          fontSize: 12,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                              Expanded(
                                child: GestureDetector(
                                  onTap: () {
                                    Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                        builder: (_) => KomentarPage(
                                          wisataList: wisataList,
                                        ),
                                      ),
                                    );
                                  },
                                  child: Column(
                                    children: [
                                      const Icon(
                                        Icons.rate_review_rounded,
                                        color: AppColors.highlight,
                                        size: 30,
                                      ),
                                      const SizedBox(height: 5),
                                      Text(
                                        totalUlasan.toString(),
                                        style: const TextStyle(
                                          color: Colors.white,
                                          fontSize: 18,
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                      const Text(
                                        "Ulasan",
                                        style: TextStyle(
                                          color: Colors.white70,
                                          fontSize: 12,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                              Expanded(
                                child: GestureDetector(
                                  onTap: () {
                                    Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                        builder: (_) => RatingListPage(
                                          wisataList: wisataList,
                                          ratingPerWisata:
                                              const <String, List<int>>{},
                                        ),
                                      ),
                                    );
                                  },
                                  child: Column(
                                    children: [
                                      const Icon(
                                        Icons.star_rounded,
                                        color: AppColors.highlight,
                                        size: 30,
                                      ),
                                      const SizedBox(height: 5),
                                      Text(
                                        avgRating.toStringAsFixed(1),
                                        style: const TextStyle(
                                          color: Colors.white,
                                          fontSize: 18,
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                      const Text(
                                        "Rating",
                                        style: TextStyle(
                                          color: Colors.white70,
                                          fontSize: 12,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            ],
                          ),
                        );
                      },
                    );
                  },
                ),

                const SizedBox(height: 30),
                Text(
                  "Menu Utama",
                  style: GoogleFonts.poppins(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: AppColors.primary,
                  ),
                ),
                const SizedBox(height: 15),

                Row(
                  children: [
                    Expanded(
                      child: GestureDetector(
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
                        child: Container(
                          padding: const EdgeInsets.symmetric(vertical: 25),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(15),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black12,
                                blurRadius: 10,
                                offset: const Offset(0, 4),
                              ),
                            ],
                          ),
                          child: Column(
                            children: [
                              const Icon(
                                Icons.edit_location_alt_rounded,
                                color: AppColors.primary,
                                size: 35,
                              ),
                              const SizedBox(height: 10),
                              Text(
                                "Kelola Wisata",
                                style: GoogleFonts.inter(
                                  fontWeight: FontWeight.bold,
                                  fontSize: 14,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 15),
                    Expanded(
                      child: GestureDetector(
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (_) =>
                                  KomentarPage(wisataList: wisataList),
                            ),
                          );
                        },
                        child: Container(
                          padding: const EdgeInsets.symmetric(vertical: 25),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(15),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black12,
                                blurRadius: 10,
                                offset: const Offset(0, 4),
                              ),
                            ],
                          ),
                          child: Column(
                            children: [
                              const Icon(
                                Icons.chat_bubble_rounded,
                                color: AppColors.accent,
                                size: 35,
                              ),
                              const SizedBox(height: 10),
                              Text(
                                "Ulasan User",
                                style: GoogleFonts.inter(
                                  fontWeight: FontWeight.bold,
                                  fontSize: 14,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          );
        },
      ),

      bottomNavigationBar: BottomNavigationBar(
        selectedItemColor: AppColors.primary,
        unselectedItemColor: Colors.grey,
        currentIndex: 0,
        backgroundColor: Colors.white,
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.grid_view_rounded),
            label: "Dashboard",
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.map_rounded),
            label: "Wisata",
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.person_pin_rounded),
            label: "Profil",
          ),
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
              MaterialPageRoute(builder: (_) => const InformasiProfilAdmin()),
            );
          }
        },
      ),
    );
  }
}
