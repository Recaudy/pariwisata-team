import 'package:flutter/material.dart';
import 'package:lottie/lottie.dart';
import 'package:google_fonts/google_fonts.dart';
import 'wisata_list_page.dart';

class AppColors {
  static const Color primary = Color(0xFF21899C);
  static const Color secondary = Color(0xFF4DA1B0);
  static const Color accent = Color(0xFFF56B3F);
  static const Color highlight = Color(0xFFF9CA58);
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
                      Padding(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 10,
                          vertical: 5,
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            SizedBox(height: 15),
                            Center(
                              child: Text(
                                "DESTINASI WISATA",
                                style: GoogleFonts.poppins(
                                  color: Colors.white,
                                  fontWeight: FontWeight.bold,
                                  fontSize: 16,
                                  letterSpacing: 1.1,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                      SizedBox(height: 15),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Lottie.asset(
                            'assets/images/Map.json',
                            height: 70,
                            repeat: true,
                          ),
                          const SizedBox(width: 30),
                          SizedBox(height: 40),
                          Flexible(
                            child: Text(
                              "Temukan tempat favoritmu\ndi Bangka Belitung",
                              textAlign: TextAlign.justify,
                              style: GoogleFonts.poppins(
                                color: Colors.white.withOpacity(0.9),
                                fontSize: 15,
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
                indicatorColor: AppColors.accent,
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
