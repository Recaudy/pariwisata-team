import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../services/komentar_service.dart';
import '../models/wisata_model.dart';
import 'package:intl/intl.dart';

class KomentarPage extends StatelessWidget {
  final List<WisataModel> wisataList;

  const KomentarPage({super.key, required this.wisataList});

  @override
  Widget build(BuildContext context) {
    final KomentarService service = KomentarService();

    return Scaffold(
      appBar: AppBar(
        title: const Text('Ulasan Pengguna'),
        backgroundColor: const Color(0xFF21899C),
      ),
      body: StreamBuilder<QuerySnapshot>(
        stream: service.getKomentar(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          final komentarList = snapshot.data?.docs ?? [];

          if (komentarList.isEmpty) {
            return const Center(
              child: Text('Belum ada ulasan',
                  style: TextStyle(fontSize: 16, color: Colors.grey)),
            );
          }

          return ListView.builder(
            padding: const EdgeInsets.all(12),
            itemCount: komentarList.length,
            itemBuilder: (context, index) {
              final doc = komentarList[index];
              final data = doc.data() as Map<String, dynamic>;
              final user = data['user'] ?? 'Anonim';
              final komentar = data['komentar'] ?? '';
              final wisataId = data['wisataId'] ?? '';
              final Timestamp? createdAtTimestamp = data['createdAt'];
              final createdAt = createdAtTimestamp != null
                  ? DateFormat('dd MMM yyyy, HH:mm')
                      .format(createdAtTimestamp.toDate())
                  : '';

              // Cari data wisata sesuai wisataId
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

              return Card(
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12)),
                elevation: 2,
                margin: const EdgeInsets.symmetric(vertical: 6),
                child: Padding(
                  padding: const EdgeInsets.all(12),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // FOTO WISATA
                      if (wisata.gambar.isNotEmpty)
                        ClipRRect(
                          borderRadius: BorderRadius.circular(10),
                          child: Image.network(
                            wisata.gambar,
                            height: 150,
                            width: double.infinity,
                            fit: BoxFit.cover,
                          ),
                        ),
                      const SizedBox(height: 8),
                      // Nama & deskripsi wisata
                      Text(
                        wisata.nama,
                        style: const TextStyle(
                            fontWeight: FontWeight.bold, fontSize: 16),
                      ),
                      Text(
                        wisata.deskripsi,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        style:
                            const TextStyle(fontSize: 14, color: Colors.grey),
                      ),
                      const Divider(height: 16),
                      // Nama user & komentar
                      Row(
                        children: [
                          const Icon(Icons.person, color: Colors.blue),
                          const SizedBox(width: 8),
                          Text(user,
                              style:
                                  const TextStyle(fontWeight: FontWeight.bold)),
                          const Spacer(),
                          if (createdAt.isNotEmpty)
                            Text(
                              createdAt,
                              style: const TextStyle(
                                  fontSize: 12, color: Colors.grey),
                            ),
                        ],
                      ),
                      const SizedBox(height: 8),
                      Text(komentar, style: const TextStyle(fontSize: 14)),
                      const SizedBox(height: 8),
                      // Tombol hapus admin
                      Row(
                        mainAxisAlignment: MainAxisAlignment.end,
                        children: [
                          IconButton(
                            icon: const Icon(Icons.delete, color: Colors.red),
                            onPressed: () async {
                              try {
                                // Ambil id dokumen langsung
                                final docId = doc.id;
                                await service.deleteKomentar(docId);

                                ScaffoldMessenger.of(context).showSnackBar(
                                  const SnackBar(
                                      content: Text("Komentar berhasil dihapus")),
                                );
                              } catch (e) {
                                ScaffoldMessenger.of(context).showSnackBar(
                                  SnackBar(
                                      content: Text(
                                          "Gagal menghapus komentar: $e")),
                                );
                              }
                            },
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              );
            },
          );
        },
      ),
    );
  }
}
