import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'detail_page.dart';

class WisataListPage extends StatelessWidget {
  final String kategori;
  const WisataListPage({required this.kategori, super.key});

  @override
  Widget build(BuildContext context) {
    final ref = FirebaseFirestore.instance.collection('wisata');

    return StreamBuilder<QuerySnapshot>(
      stream: ref.where('kategori', isEqualTo: kategori).snapshots(),
      builder: (context, snapshot) {
        if (snapshot.hasError) {
          return const Center(child: Text('Terjadi kesalahan'));
        }

        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }

        final docs = snapshot.data!.docs;

        if (docs.isEmpty) {
          return const Center(child: Text('Belum ada data'));
        }

        return ListView.builder(
          padding: const EdgeInsets.all(12),
          itemCount: docs.length,
          itemBuilder: (context, index) {
            final doc = docs[index];
            final raw = doc.data();
            if (raw is! Map<String, dynamic>) {
              return const SizedBox.shrink();
            }
            final data = raw;
            final nama = (data['nama'] ?? 'Tanpa nama').toString();
            final subJudul = (data['sub_judul'] ?? '').toString();
            final image = (data['image'] ?? '').toString();

            Widget leadingImage;
            if (image.isEmpty) {
              leadingImage = Container(
                width: 90,
                height: 70,
                color: Colors.grey.shade200,
                child: const Icon(
                  Icons.image_not_supported,
                  color: Colors.grey,
                ),
              );
            } else if (image.startsWith('http')) {
              leadingImage = ClipRRect(
                borderRadius: BorderRadius.circular(6),
                child: Image.network(
                  image,
                  width: 90,
                  height: 70,
                  fit: BoxFit.cover,
                  errorBuilder: (c, e, s) => Container(
                    width: 90,
                    height: 70,
                    color: Colors.grey.shade200,
                    child: const Icon(Icons.broken_image, color: Colors.grey),
                  ),
                ),
              );
            } else {
              // treat as asset path
              leadingImage = ClipRRect(
                borderRadius: BorderRadius.circular(6),
                child: Image.asset(
                  image,
                  width: 90,
                  height: 70,
                  fit: BoxFit.cover,
                  errorBuilder: (c, e, s) => Container(
                    width: 90,
                    height: 70,
                    color: Colors.grey.shade200,
                    child: const Icon(Icons.broken_image, color: Colors.grey),
                  ),
                ),
              );
            }

            return Card(
              elevation: 2,
              margin: const EdgeInsets.only(bottom: 12),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10),
              ),
              child: InkWell(
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => DetailPage(
                        wisataData: {
                          'id': doc.id,
                          'nama': nama,
                          'sub_judul': subJudul,
                          'image': image,
                          'desc': data['desc'] ?? '',
                          'sejarah': data['sejarah'] ?? '',
                          'kategori': data['kategori'] ?? '',
                        },
                      ),
                    ),
                  );
                },
                child: Padding(
                  padding: const EdgeInsets.all(12),
                  child: Row(
                    children: [
                      leadingImage,
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              nama,
                              style: const TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 16,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              subJudul,
                              style: const TextStyle(
                                fontSize: 13,
                                color: Colors.grey,
                              ),
                            ),
                            const SizedBox(height: 8),
                            Text(
                              (data['desc'] ?? '').toString(),
                              maxLines: 2,
                              overflow: TextOverflow.ellipsis,
                              style: const TextStyle(
                                fontSize: 12,
                                color: Colors.black54,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            );
          },
        );
      },
    );
  }
}
