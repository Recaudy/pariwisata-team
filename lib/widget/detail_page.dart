import 'package:flutter/material.dart';
import 'aksi_icon.dart';

class DetailPage extends StatelessWidget {
  final Map<String, dynamic> wisataData;
  const DetailPage({super.key, required this.wisataData});

  @override
  Widget build(BuildContext context) {
    final nama = (wisataData['nama'] ?? 'Tanpa nama').toString();
    final subJudul = (wisataData['sub_judul'] ?? '').toString();
    final image = (wisataData['image'] ?? '').toString();
    final desc = (wisataData['desc'] ?? '').toString();
    final sejarah = (wisataData['sejarah'] ?? '').toString();
    final wisataId = wisataData['id']; // ✅ AMBIL ID DI SINI

    final screenHeight = MediaQuery.of(context).size.height;

    Widget headerImage;

    if (image.isEmpty) {
      headerImage = Container(
        width: double.infinity,
        height: screenHeight * 0.6,
        color: Colors.grey.shade200,
        alignment: Alignment.center,
        child: const Icon(Icons.image_not_supported, size: 48),
      );
    } else if (image.startsWith('http')) {
      headerImage = Image.network(
        image,
        width: double.infinity,
        height: screenHeight * 0.6,
        fit: BoxFit.cover,
      );
    } else {
      headerImage = Image.asset(
        image,
        width: double.infinity,
        height: screenHeight * 0.6,
        fit: BoxFit.cover,
      );
    }

    return Scaffold(
      body: Stack(
        children: [
          Positioned(top: 0, left: 0, right: 0, child: headerImage),

          Positioned(
            top: 50,
            left: 20,
            child: CircleAvatar(
              backgroundColor: Colors.black45,
              child: IconButton(
                icon: const Icon(Icons.arrow_back, color: Colors.white),
                onPressed: () => Navigator.pop(context),
              ),
            ),
          ),

          Positioned(
            top: screenHeight * 0.26,
            left: 24,
            right: 24,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  nama,
                  style: const TextStyle(
                    fontSize: 28,
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 6),
                Text(subJudul, style: const TextStyle(color: Colors.white)),
                const SizedBox(height: 10),

                /// 🔥 AKSI ICON
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(12),
                      child: LikeButton(),
                    ),
                    const SizedBox(width: 5),

                    GestureDetector(
                      onTap: () {
                        openKomentarSheet(context, wisataId); // ✅ FIX
                      },
                      child: const Padding(
                        padding: EdgeInsets.all(12),
                        child: Icon(Icons.mode_comment, color: Colors.white),
                      ),
                    ),

                    const SizedBox(width: 5),

                    GestureDetector(
                      onTap: () {
                        showDialog(
                          context: context,
                          builder: (_) => RatingPopup(),
                        );
                      },
                      child: const Padding(
                        padding: EdgeInsets.all(12),
                        child: Icon(Icons.star, color: Colors.white),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),

          Positioned(
            top: screenHeight * 0.43,
            bottom: 0,
            left: 0,
            right: 0,
            child: Container(
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  stops: const [0.0, 0.10, 1.0],
                  colors: [
                    Colors.transparent,
                    Color(0xFF21899C),
                    Color(0xFFE6F4F6),
                  ],
                ),
              ),

              child: SingleChildScrollView(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Deskripsi',
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 10),
                    Text(desc.isNotEmpty ? desc : 'Tidak ada deskripsi.'),

                    const SizedBox(height: 30),

                    const Text(
                      'Sejarah dan Fakta Menarik',
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 10),
                    Text(sejarah.isNotEmpty ? sejarah : 'Belum ada sejarah.'),
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
