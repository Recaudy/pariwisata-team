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
          return Center(child: Text('Terjadi kesalahan'));
        }

        if (snapshot.connectionState == ConnectionState.waiting) {
          return Center(child: CircularProgressIndicator());
        }

        final docs = snapshot.data!.docs;

        if (docs.isEmpty) {
          return Center(child: Text('Belum ada data'));
        }

        return ListView.builder(
          padding: EdgeInsets.all(12),
          itemCount: docs.length,
          itemBuilder: (context, index) {
            final doc = docs[index];
            final raw = doc.data();
            if (raw is! Map<String, dynamic>) {
              return SizedBox.shrink();
            }
            final data = raw;

            final nama = (data['nama'] ?? 'Tanpa nama').toString();
            final subJudul = (data['sub_judul'] ?? '').toString();
            final image = (data['image'] ?? '').toString();

            return Card(
              elevation: 3,
              margin: EdgeInsets.only(bottom: 14),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(14),
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
                child: Container(
                  height: 180,
                  child: Stack(
                    children: [
                      ClipRRect(
                        borderRadius: BorderRadius.circular(14),
                        child: image.isEmpty
                            ? Container(
                              color: 
                            Colors.grey.shade300)
                            : (image.startsWith('http')
                                  ? Image.network(
                                      image,
                                      width: double.infinity,
                                      height: double.infinity,
                                      fit: BoxFit.cover,
                                      errorBuilder: (c, e, s) {
                                        return Container(
                                          color: Colors.grey.shade300,
                                        );
                                      },
                                    )
                                  : Image.asset(
                                      image,
                                      width: double.infinity,
                                      height: double.infinity,
                                      fit: BoxFit.cover,
                                      errorBuilder: (c, e, s) {
                                        return Container(
                                          color: Colors.grey.shade300,
                                        );
                                      },
                                    )),
                      ),
                      Container(
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(14),
                        ),
                      ),
                      Padding(
                        padding: EdgeInsets.all(16),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              nama,
                              style: TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                                color: Colors.white,
                                shadows: [
                                  Shadow(
                                    color: Colors.black,
                                    blurRadius: 10,
                                    offset: Offset(2, 2),
                                  ),
                                ],
                              ),
                            ),
                            SizedBox(height: 6),
                            Text(
                              subJudul,
                              style: TextStyle(
                                fontSize: 14,
                                color: Colors.white,
                                fontWeight: FontWeight.w500,
                                shadows: [
                                  Shadow(
                                    color: Colors.black,
                                    blurRadius: 8,
                                    offset: Offset(1, 1),
                                  ),
                                ],
                              ),
                            ),
                            SizedBox(height: 10),
                            Expanded(
                              child: Align(
                                alignment: Alignment.bottomLeft,
                                child: Text(
                                  (data['desc'] ?? '').toString(),
                                  maxLines: 3,
                                  overflow: TextOverflow.ellipsis,
                                  style: TextStyle(
                                    fontSize: 12,
                                    color: Colors.white,
                                    fontWeight: FontWeight.bold,
                                    shadows: [
                                      Shadow(
                                        color: Colors.black,
                                        blurRadius: 8,
                                        offset: Offset(1, 1),
                                      ),
                                    ],
                                  ),
                                ),
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
