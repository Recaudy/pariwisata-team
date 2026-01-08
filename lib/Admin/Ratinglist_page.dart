import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/wisata_model.dart';

class AppColors {
  static const Color primary = Color(0xFF21899C);
  static const Color secondary = Color(0xFF4DA1B0);
  static const Color accent = Color(0xFFF56B3F);
  static const Color highlight = Color(0xFFF9CA58);
}

class RatingListPage extends StatelessWidget {
  final List<WisataModel> wisataList;
  final Map<String, List<int>>? ratingPerWisata;

  const RatingListPage({
    super.key,
    required this.wisataList,
    this.ratingPerWisata,
  });

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 3,
      child: Scaffold(
        backgroundColor: const Color(0xFFF2F5F7),
        appBar: AppBar(
          elevation: 0,
          centerTitle: true,
          backgroundColor: AppColors.primary,
          title: Text(
            "RATING WISATA",
            style: GoogleFonts.poppins(
              fontWeight: FontWeight.bold,
              fontSize: 18,
            ),
          ),
          bottom: TabBar(
            indicatorColor: AppColors.highlight,
            indicatorWeight: 4,
            labelStyle: GoogleFonts.inter(
              fontWeight: FontWeight.bold,
              fontSize: 14,
            ),
            unselectedLabelStyle: GoogleFonts.inter(
              fontWeight: FontWeight.w500,
            ),
            tabs: const [
              Tab(text: "BAGUS"),
              Tab(text: "CUKUP"),
              Tab(text: "BURUK"),
            ],
          ),
        ),

        body: StreamBuilder<QuerySnapshot>(
          stream: FirebaseFirestore.instance.collection('ratings').snapshots(),
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Center(
                child: CircularProgressIndicator(
                  color: AppColors.primary,
                ),
              );
            }

            if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
              return Center(
                child: Text(
                  "Belum ada data rating",
                  style: GoogleFonts.inter(),
                ),
              );
            }
            Map<String, List<int>> ratingMap = {};
            for (var doc in snapshot.data!.docs) {
              final data = doc.data() as Map<String, dynamic>;
              final wisataId = data['wisataId'] ?? '';
              final rating = data['rating'] ?? 0;

              if (wisataId.isNotEmpty) {
                ratingMap.putIfAbsent(wisataId, () => []);
                ratingMap[wisataId]!.add(rating);
              }
            }

            List<Widget> bagus = [];
            List<Widget> cukup = [];
            List<Widget> buruk = [];

            ratingMap.forEach((wisataId, ratings) {
              final wisata = wisataList.firstWhere(
                (w) => w.id == wisataId,
                orElse: () => WisataModel(
                  id: '',
                  nama: 'Wisata tidak ditemukan',
                  lokasi: '',
                  deskripsi: '',
                  desc: '',
                  gambar: '',
                  image: '',
                  kategori: '',
                  subJudul: '',
                  sejarah: '',
                ),
              );

              final average =
                  ratings.reduce((a, b) => a + b) / ratings.length;
              final Widget card = Container(
                margin:
                    const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
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
                child: ListTile(
                  contentPadding: const EdgeInsets.symmetric(
                    horizontal: 20,
                    vertical: 10,
                  ),
                  leading: CircleAvatar(
                    backgroundColor:
                        AppColors.secondary.withOpacity(0.15),
                  ),
                  title: Text(
                    wisata.nama,
                    style: GoogleFonts.poppins(
                      fontWeight: FontWeight.bold,
                      fontSize: 15,
                      color: AppColors.primary,
                    ),
                  ),
                  subtitle: Row(
                    children: [
                      const Icon(
                        Icons.star_rounded,
                        color: AppColors.highlight,
                        size: 20,
                      ),
                      const SizedBox(width: 4),
                      Text(
                        "Rata-rata: ${average.toStringAsFixed(1)}",
                        style: GoogleFonts.inter(
                          fontWeight: FontWeight.w600,
                          color: Colors.black87,
                        ),
                      ),
                    ],
                  ),
                ),
              );

              if (average >= 4) {
                bagus.add(card);
              } else if (average >= 3) {
                cukup.add(card);
              } else {
                buruk.add(card);
              }
            });

            return TabBarView(
              children: [
                bagus.isEmpty
                    ? Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(
                              Icons.star_border_rounded,
                              size: 80,
                              color: Colors.grey[300],
                            ),
                            const SizedBox(height: 10),
                            Text(
                              "Tidak ada rating Bagus",
                              style: GoogleFonts.inter(
                                color: Colors.grey,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ],
                        ),
                      )
                    : ListView(
                        padding:
                            const EdgeInsets.symmetric(vertical: 12),
                        physics: const BouncingScrollPhysics(),
                        children: bagus,
                      ),
                cukup.isEmpty
                    ? Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(
                              Icons.star_border_rounded,
                              size: 80,
                              color: Colors.grey[300],
                            ),
                            const SizedBox(height: 10),
                            Text(
                              "Tidak ada rating Cukup",
                              style: GoogleFonts.inter(
                                color: Colors.grey,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ],
                        ),
                      )
                    : ListView(
                        padding:
                            const EdgeInsets.symmetric(vertical: 12),
                        physics: const BouncingScrollPhysics(),
                        children: cukup,
                      ),
                buruk.isEmpty
                    ? Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(
                              Icons.star_border_rounded,
                              size: 80,
                              color: Colors.grey[300],
                            ),
                            const SizedBox(height: 10),
                            Text(
                              "Tidak ada rating Buruk",
                              style: GoogleFonts.inter(
                                color: Colors.grey,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ],
                        ),
                      )
                    : ListView(
                        padding:
                            const EdgeInsets.symmetric(vertical: 12),
                        physics: const BouncingScrollPhysics(),
                        children: buruk,
                 ),
              ],
            );
          },
        ),
      ),
    );
  }
}
