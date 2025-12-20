import 'package:flutter/material.dart';
import 'package:lottie/lottie.dart';
import 'wisata_list_page.dart';

class WisataTabViewPage extends StatelessWidget {
  final int initialIndex; // Tambahkan parameter untuk index awal

  const WisataTabViewPage({super.key, this.initialIndex = 0});

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 3,
      initialIndex: initialIndex, // Set index sesuai kategori yang dipilih
      child: Scaffold(
        appBar: AppBar(
          backgroundColor: const Color(0xFF21899C),
          leading: IconButton(
            icon: const Icon(Icons.arrow_back, color: Colors.white),
            onPressed: () => Navigator.pop(context),
          ),
          title: const Text(
            'Destinasi Wisata',
            style: TextStyle(color: Colors.white),
          ),
          centerTitle: true,
        ),
        body: Container(
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: [Color(0xFF21899C), Color(0xFFE6F4F6)],
            ),
          ),
          child: Column(
            children: [
              const SizedBox(height: 16),
              Lottie.asset('assets/images/Map.json', height: 80),
              const SizedBox(height: 5),
              const Padding(
                padding: EdgeInsets.symmetric(horizontal: 16),
                child: Text(
                  'Kunjungi berbagai tempat wisata favorit Anda',
                  style: TextStyle(
                    fontSize: 13,
                    color: Colors.white,
                    shadows: [
                      Shadow(
                        color: Colors.black,
                        blurRadius: 8,
                        offset: Offset(1, 1),
                      ),
                    ],
                  ),
                  textAlign: TextAlign.center,
                ),
              ),
              const SizedBox(height: 12),
              Container(
                color: const Color(0xFF21899C),
                child: const TabBar(
                  indicatorColor:
                      Colors.white, // Diubah agar terlihat tab yang aktif
                  indicatorWeight: 3,
                  labelColor: Colors.white,
                  unselectedLabelColor: Colors.black54,
                  tabs: [
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
      ),
    );
  }
}
