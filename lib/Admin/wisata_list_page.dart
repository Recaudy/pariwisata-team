import 'package:flutter/material.dart';
import '../models/wisata_model.dart';
import '../services/wisata_services.dart';
import 'wisata_form_page.dart';

const Color primaryColor = Color(0xFF21899C);

class WisataListPage extends StatelessWidget {
  final String kategori;
  final String kategoriName;

  const WisataListPage({
    super.key,
    required this.kategori,
    required this.kategoriName,
  });

  @override
  Widget build(BuildContext context) {
    final WisataService _service = WisataService();

    return Scaffold(
      appBar: AppBar(
        title: Text(kategoriName),
        backgroundColor: primaryColor,
      ),
      body: StreamBuilder<List<WisataModel>>(
        stream: _service.getWisata(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          final wisataList = snapshot.data ?? [];
          final filteredWisata = kategori == 'all'
              ? wisataList
              : wisataList.where((w) => w.kategori == kategori).toList();

          if (filteredWisata.isEmpty) {
            return const Center(child: Text("Belum ada wisata"));
          }

          return ListView.builder(
            itemCount: filteredWisata.length,
            itemBuilder: (context, index) {
              final w = filteredWisata[index];
              return Card(
                margin: const EdgeInsets.all(8),
                child: ListTile(
                  title: Text(w.nama, style: const TextStyle(fontWeight: FontWeight.bold)),
                  subtitle: Text(w.lokasi),
                  trailing: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      IconButton(
                        icon: const Icon(Icons.edit, color: Colors.blue),
                        onPressed: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(builder: (_) => WisataFormPage(wisata: w)),
                          );
                        },
                      ),
                      IconButton(
                        icon: const Icon(Icons.delete, color: Colors.red),
                        onPressed: () async {
                          await _service.deleteWisata(w.id);
                        },
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
