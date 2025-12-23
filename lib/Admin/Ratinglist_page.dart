import 'package:flutter/material.dart';
import '../models/wisata_model.dart';

class RatingListPage extends StatelessWidget {
  final List<WisataModel> wisataList;
  final Map<String, List<int>> ratingPerWisata;

  const RatingListPage({
    super.key,
    required this.wisataList,
    required this.ratingPerWisata,
  });

  @override
  Widget build(BuildContext context) {
    // Pisahkan rating ke masing-masing kategori
    List<Widget> baguss = [];
    List<Widget> cukups = [];
    List<Widget> buruks = [];

    for (var entry in ratingPerWisata.entries) {
      final wisata = wisataList.firstWhere(
        (w) => w.id == entry.key,
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

      double average = 0;
      if (entry.value.isNotEmpty) {
        int sum = 0;
        for (var r in entry.value) sum += r;
        average = sum / entry.value.length;
      }

      Widget card = Card(
        margin: const EdgeInsets.symmetric(vertical: 6, horizontal: 8),
        child: ListTile(
          title: Text(wisata.nama),
          subtitle: Text("Rata-rata: ${average.toStringAsFixed(1)} ⭐"),
        ),
      );

      if (average >= 4) {
        baguss.add(card);
      } else if (average >= 3) {
        cukups.add(card);
      } else {
        buruks.add(card);
      }
    }

    return DefaultTabController(
      length: 3, // 3 kategori
      child: Scaffold(
        appBar: AppBar(
          title: const Text("Daftar Rating Wisata"),
          backgroundColor: const Color(0xFF21899C),
          bottom: const TabBar(
            tabs: [
              Tab(text: "Bagus"),
              Tab(text: "Cukup"),
              Tab(text: "Buruk"),
            ],
          ),
        ),
        body: TabBarView(
          children: [
            // Tab Bagus
            ListView(
              padding: const EdgeInsets.all(8),
              children: baguss.isNotEmpty
                  ? baguss
                  : [const Center(child: Text("Tidak ada wisata dengan rating Bagus"))],
            ),
            // Tab Cukup
            ListView(
              padding: const EdgeInsets.all(8),
              children: cukups.isNotEmpty
                  ? cukups
                  : [const Center(child: Text("Tidak ada wisata dengan rating Cukup"))],
            ),
            // Tab Buruk
            ListView(
              padding: const EdgeInsets.all(8),
              children: buruks.isNotEmpty
                  ? buruks
                  : [const Center(child: Text("Tidak ada wisata dengan rating Buruk"))],
            ),
          ],
        ),
      ),
    );
  }
}
