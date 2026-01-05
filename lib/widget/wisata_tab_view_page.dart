import 'package:flutter/material.dart';
import 'package:lottie/lottie.dart';
import 'package:google_fonts/google_fonts.dart';
import 'wisata_list_page.dart';

// 4 WARNA UTAMA APLIKASI
class AppColors {
  static const Color primary = Color(0xFF21899C); // Teal Tua
  static const Color secondary = Color(0xFF4DA1B0); // Teal Muda
  static const Color accent = Color(0xFFF56B3F); // Oranye
  static const Color highlight = Color(0xFFF9CA58); // Kuning Cerah
}

class WisataTabViewPage extends StatelessWidget {
  final int initialIndex;

  const WisataTabViewPage({super.key, this.initialIndex = 0});

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 3,
      initialIndex: initialIndex,
      child: Scaffold(
        backgroundColor: const Color(0xFFF2F5F7),
        body: Column(
          children: [
            // 1. HEADER MELENGKUNG MANUAL (Warna Teal Tua)
            Stack(
              children: [
                Container(
                  height: 180,
                  width: double.infinity,
                  decoration: const BoxDecoration(
                    color: AppColors.primary,
                    borderRadius: BorderRadius.only(
                      bottomLeft: Radius.circular(40),
                      bottomRight: Radius.circular(40),
                    ),
                  ),
                ),
                SafeArea(
                  child: Column(
                    children: [
                      // Bar Atas: Tombol Back & Judul
                      Padding(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 10,
                          vertical: 5,
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            IconButton(
                              icon: const Icon(
                                Icons.arrow_back_ios_new,
                                color: Colors.white,
                                size: 20,
                              ),
                              onPressed: () => Navigator.pop(context),
                            ),
                            Text(
                              "DESTINASI WISATA",
                              style: GoogleFonts.poppins(
                                color: Colors.white,
                                fontWeight: FontWeight.bold,
                                fontSize: 16,
                                letterSpacing: 1.1,
                              ),
                            ),
                            const SizedBox(width: 48), // Penyeimbang
                          ],
                        ),
                      ),
                      // Animasi Lottie & Subtitle
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Lottie.asset(
                            'assets/images/Map.json',
                            height: 70,
                            repeat: true,
                          ),
                          const SizedBox(width: 10),
                          Flexible(
                            child: Text(
                              "Temukan tempat favoritmu\ndi Bangka Belitung",
                              style: GoogleFonts.inter(
                                color: Colors.white.withOpacity(0.9),
                                fontSize: 13,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ],
            ),

            // 2. TAB BAR (PENGATURAN WARNA KONSISTEN)
            Container(
              margin: const EdgeInsets.symmetric(horizontal: 20, vertical: 15),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(15),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.05),
                    blurRadius: 10,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: TabBar(
                indicatorColor:
                    AppColors.accent, // Aksen Oranye untuk indikator
                indicatorWeight: 4,
                indicatorSize: TabBarIndicatorSize.label,
                labelColor: AppColors.primary,
                unselectedLabelColor: Colors.grey,
                labelStyle: GoogleFonts.poppins(
                  fontWeight: FontWeight.bold,
                  fontSize: 14,
                ),
                unselectedLabelStyle: GoogleFonts.poppins(
                  fontWeight: FontWeight.w500,
                  fontSize: 14,
                ),
                tabs: const [
                  Tab(text: "Pantai"),
                  Tab(text: "Bukit"),
                  Tab(text: "Religi"),
                ],
              ),
            ),

            // 3. TAB VIEW CONTENT
            const Expanded(
              child: TabBarView(
                children: [
                  WisataListPage(kategori: 'pantai'),
                  WisataListPage(kategori: 'bukit'),
                  WisataListPage(kategori: 'religi'),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
