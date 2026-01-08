import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:google_fonts/google_fonts.dart';
import 'aksi_icon.dart';

class AppColors {
  static const Color primary = Color(0xFF21899C);
  static const Color secondary = Color(0xFF4DA1B0);
  static const Color accent = Color(0xFFF56B3F);
  static const Color highlight = Color(0xFFF9CA58);
}

class DetailPage extends StatelessWidget {
  final Map<String, dynamic> wisataData;
  const DetailPage({super.key, required this.wisataData});

  @override
  Widget build(BuildContext context) {
    final nama = (wisataData['nama'] ?? 'Tanpa nama').toString();
    final subJudul = (wisataData['sub_judul'] ?? '').toString();
    final image = (wisataData['image'] ?? wisataData['gambar'] ?? '')
        .toString();
    final desc = (wisataData['desc'] ?? '').toString();
    final sejarah = (wisataData['sejarah'] ?? '').toString();
    final wisataId = (wisataData['id'] ?? wisataData['wisataId'] ?? '')
        .toString();

    final screenHeight = MediaQuery.of(context).size.height;

    return Scaffold(
      backgroundColor: Colors.white,
      body: Stack(
        children: [
          Positioned(
            top: 0,
            left: 0,
            right: 0,
            child: SizedBox(
              height: screenHeight * 0.5,
              width: double.infinity,
              child: image.isEmpty
                  ? Container(
                      color: Colors.grey[300],
                      child: const Icon(Icons.image_not_supported, size: 50),
                    )
                  : image.startsWith('http')
                  ? Image.network(image, fit: BoxFit.cover)
                  : Image.asset(image, fit: BoxFit.cover),
            ),
          ),

          Positioned(
            top: 50,
            left: 20,
            child: GestureDetector(
              onTap: () => Navigator.pop(context),
              child: Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: Colors.black.withOpacity(0.4),
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  Icons.arrow_back_ios_new,
                  color: Colors.white,
                  size: 20,
                ),
              ),
            ),
          ),

          Positioned(
            top: screenHeight * 0.25,
            left: 24,
            right: 24,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  nama,
                  style: GoogleFonts.poppins(
                    fontSize: 28,
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                    shadows: [
                      Shadow(
                        color: Colors.black.withOpacity(0.6),
                        blurRadius: 12,
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 4),
                Row(
                  children: [
                    const Icon(
                      Icons.location_on,
                      color: AppColors.highlight,
                      size: 18,
                    ),
                    const SizedBox(width: 6),
                    Expanded(
                      child: Text(
                        subJudul,
                        style: GoogleFonts.inter(
                          color: Colors.white,
                          fontWeight: FontWeight.w500,
                          fontSize: 14,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 20),
                Row(
                  children: [
                    Container(
                      margin: const EdgeInsets.only(right: 15),
                      child: LikeButton(),
                    ),

                    GestureDetector(
                      onTap: () => openKomentarSheet(context, wisataId),
                      child: Container(
                        padding: const EdgeInsets.all(12),
                        margin: const EdgeInsets.only(right: 15),
                        decoration: BoxDecoration(
                          color: Colors.black.withOpacity(0.5),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: const Icon(
                          Icons.chat_bubble_outline,
                          color: Colors.white,
                          size: 22,
                        ),
                      ),
                    ),

                    GestureDetector(
                      onTap: () => showDialog(
                        context: context,
                        builder: (_) => RatingPopup(wisataId: wisataId),
                      ),
                      child: Container(
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: Colors.black.withOpacity(0.5),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: const Icon(
                          Icons.star_border_rounded,
                          color: Colors.white,
                          size: 24,
                        ),
                      ),
                    ),

                    const Spacer(),

                    StreamBuilder<QuerySnapshot>(
                      stream: FirebaseFirestore.instance
                          .collection('ratings')
                          .where('wisataId', isEqualTo: wisataId)
                          .snapshots(),
                      builder: (context, snapshot) {
                        double avg = 0.0;
                        if (snapshot.hasData &&
                            snapshot.data!.docs.isNotEmpty) {
                          double total = 0;
                          for (var doc in snapshot.data!.docs) {
                            total += (doc['rating'] ?? 0).toDouble();
                          }
                          avg = total / snapshot.data!.docs.length;
                        }
                        return Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 14,
                            vertical: 8,
                          ),
                          decoration: BoxDecoration(
                            color: AppColors.highlight,
                            borderRadius: BorderRadius.circular(25),
                            boxShadow: [
                              BoxShadow(color: Colors.black, blurRadius: 4),
                            ],
                          ),
                          child: Row(
                            children: [
                              const Icon(
                                Icons.star,
                                color: AppColors.primary,
                                size: 18,
                              ),
                              const SizedBox(width: 4),
                              Text(
                                avg.toStringAsFixed(1),
                                style: const TextStyle(
                                  fontWeight: FontWeight.bold,
                                  color: AppColors.primary,
                                  fontSize: 16,
                                ),
                              ),
                            ],
                          ),
                        );
                      },
                    ),
                  ],
                ),
              ],
            ),
          ),

          Positioned(
            top: screenHeight * 0.45,
            bottom: 0,
            left: 0,
            right: 0,
            child: Container(
              decoration: const BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.only(
                  topLeft: Radius.circular(40),
                  topRight: Radius.circular(40),
                ),
              ),
              child: SingleChildScrollView(
                padding: const EdgeInsets.fromLTRB(25, 35, 25, 30),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Container(
                          width: 5,
                          height: 22,
                          color: AppColors.accent,
                        ),
                        const SizedBox(width: 12),
                        Text(
                          'Deskripsi Wisata',
                          style: GoogleFonts.poppins(
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                            color: AppColors.primary,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 15),
                    Text(
                      desc.isNotEmpty
                          ? desc
                          : 'Deskripsi belum tersedia untuk tempat ini.',
                      style: GoogleFonts.inter(
                        fontSize: 15,
                        color: Colors.black87,
                        height: 1.7,
                      ),
                      textAlign: TextAlign.justify,
                    ),

                    const SizedBox(height: 35),

                    Row(
                      children: [
                        Container(
                          width: 5,
                          height: 22,
                          color: AppColors.accent,
                        ),
                        const SizedBox(width: 12),
                        Text(
                          'Sejarah & Fakta',
                          style: GoogleFonts.poppins(
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                            color: AppColors.primary,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 15),
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(18),
                      decoration: BoxDecoration(
                        color: AppColors.secondary.withOpacity(0.08),
                        borderRadius: BorderRadius.circular(18),
                        border: Border.all(
                          color: AppColors.secondary.withOpacity(0.15),
                        ),
                      ),
                      child: Text(
                        sejarah.isNotEmpty
                            ? sejarah
                            : 'Informasi sejarah belum tersedia.',
                        style: GoogleFonts.inter(
                          fontSize: 14,
                          color: Colors.black87,
                          fontStyle: FontStyle.italic,
                          height: 1.6,
                        ),
                        textAlign: TextAlign.justify,
                      ),
                    ),
                    const SizedBox(height: 40),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
