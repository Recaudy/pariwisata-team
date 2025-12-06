import 'package:flutter/material.dart';
import 'package:lottie/lottie.dart';
import 'wisata_list_page.dart';

class WisataTabViewPage extends StatelessWidget {
  const WisataTabViewPage({super.key});

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 3,
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Destinasi Wisata'),
          centerTitle: true,
        ),
        backgroundColor: Colors.grey[100],
        body: Column(
          children: [
            const SizedBox(height: 16),
            Lottie.asset('assets/images/Map.json', height: 80),
            const SizedBox(height: 5),
            const Padding(
              padding: EdgeInsets.symmetric(horizontal: 16),
              child: Text(
                'Kunjungi berbagai tempat wisata favorit Anda',
                style: TextStyle(fontSize: 13, color: Colors.black54),
                textAlign: TextAlign.center,
              ),
            ),
            const SizedBox(height: 12),
            Container(
              color: Colors.white,
              child: const TabBar(
                labelColor: Colors.blue,
                unselectedLabelColor: Colors.black54,
                tabs: [
                  Tab(text: "Pantai"),
                  Tab(text: "Bukit"),
                  Tab(text: "Religi"),
                ],
              ),
            ),
            Expanded(
              child: TabBarView(
                children: const [
                  WisataListPage(kategori: 'pantai'),
                  WisataListPage(kategori: 'bukit'),
                  WisataListPage(kategori: 'religi'),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
