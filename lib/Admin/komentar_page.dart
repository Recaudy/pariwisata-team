import 'package:flutter/material.dart';
import '../services/komentar_service.dart';

class KomentarPage extends StatelessWidget {
  const KomentarPage({super.key});

  @override
  Widget build(BuildContext context) {
    final KomentarService service = KomentarService();

    return Scaffold(
      appBar: AppBar(
        title: const Text('Ulasan Pengguna'),
        backgroundColor: const Color(0xFF21899C),
      ),
      body: StreamBuilder(
        stream: service.getKomentar(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          final komentarList = snapshot.data?.docs ?? [];

          if (komentarList.isEmpty) {
            return const Center(child: Text('Belum ada ulasan'));
          }

          return ListView.builder(
            itemCount: komentarList.length,
            itemBuilder: (context, index) {
              final data =
                  komentarList[index].data() as Map<String, dynamic>;

              return Card(
                margin: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 6,
                ),
                child: ListTile(
                  leading: const Icon(Icons.comment),
                  title: Text(
                    data['user'] ?? 'Anonim', // 🔥 sesuai Firebase
                    style: const TextStyle(fontWeight: FontWeight.bold),
                  ),
                  subtitle: Text(
                    data['komentar'] ?? '', 
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
