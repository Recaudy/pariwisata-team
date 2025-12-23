import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../services/wisata_services.dart';
import '../models/wisata_model.dart';
import '../services/komentar_service.dart';
import 'wisata_form_page.dart';
import 'Ratinglist_page.dart';
import 'Komentar_page.dart';
import 'wisata_list_page.dart';

const Color primaryColor = Color(0xFF21899C);

class AdminDashboardPage extends StatefulWidget {
  const AdminDashboardPage({super.key});

  @override
  State<AdminDashboardPage> createState() => _AdminDashboardPageState();
}

class _AdminDashboardPageState extends State<AdminDashboardPage> {
  final WisataService _service = WisataService();
  final KomentarService _komentarService = KomentarService();
  String selectedKategori = 'all';
  int _selectedIndex = 0;
  final int maxItems = 2;

  final Map<String, String> kategoriMap = {
    'all': 'Semua Wisata',
    'pantai': 'Pantai',
    'bukit': 'Bukit',
    'religi': 'Wisata Religi',
  };

  void _showLogoutDialog() {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('Konfirmasi Logout'),
        content: const Text('Apakah anda yakin ingin logout?'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text('Batal')),
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              Navigator.pushNamedAndRemoveUntil(context, '/', (route) => false);
            },
            child: const Text('Logout', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    double screenWidth = MediaQuery.of(context).size.width;

    return Scaffold(
      appBar: AppBar(
        title: const Text("Dashboard Admin"),
        backgroundColor: primaryColor,
        actions: [
          IconButton(
            icon: const Icon(Icons.notifications),
            onPressed: () {},
          ),
        ],
      ),
      drawer: Drawer(
        child: Column(
          children: [
            const DrawerHeader(
              decoration: BoxDecoration(color: primaryColor),
              child: Align(
                alignment: Alignment.bottomLeft,
                child: Text(
                  'Admin',
                  style: TextStyle(color: Colors.white, fontSize: 22, fontWeight: FontWeight.bold),
                ),
              ),
            ),
            ListTile(
              leading: const Icon(Icons.dashboard),
              title: const Text('Dashboard'),
              onTap: () => Navigator.pop(context),
            ),
            ListTile(
              leading: const Icon(Icons.place),
              title: const Text('Kelola Wisata'),
              onTap: () {
                Navigator.pop(context);
                Navigator.push(context, MaterialPageRoute(builder: (_) => const WisataFormPage()));
              },
            ),
            const Spacer(),
            ListTile(
              leading: const Icon(Icons.logout, color: Colors.red),
              title: const Text('Logout'),
              onTap: _showLogoutDialog,
            ),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        backgroundColor: primaryColor,
        child: const Icon(Icons.add),
        onPressed: () => Navigator.push(
          context,
          MaterialPageRoute(builder: (_) => const WisataFormPage()),
        ),
      ),
      body: StreamBuilder<List<WisataModel>>(
        stream: _service.getWisata(),
        builder: (context, snapshotWisata) {
          final wisataList = snapshotWisata.data ?? [];
          final filteredWisata = selectedKategori == 'all'
              ? wisataList
              : wisataList.where((w) => w.kategori == selectedKategori).toList();
          final displayWisata = filteredWisata.length > maxItems
              ? filteredWisata.sublist(0, maxItems)
              : filteredWisata;

          return SingleChildScrollView(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  "Selamat datang, Admin!",
                  style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 16),

                // ===== Statistik Grid =====
                LayoutBuilder(builder: (context, constraints) {
                  int gridCount = screenWidth > 600 ? 3 : 1;
                  return GridView(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                        crossAxisCount: gridCount, mainAxisSpacing: 16, crossAxisSpacing: 16, childAspectRatio: 3),
                    children: [
                      _statCard("Total Wisata", wisataList.length.toString(), Icons.place),
                      StreamBuilder<QuerySnapshot>(
                        stream: _komentarService.getKomentar(),
                        builder: (context, snapshotKomentar) {
                          final totalKomentar =
                              snapshotKomentar.hasData ? snapshotKomentar.data!.docs.length : 0;
                          return _statCard("Total Ulasan", totalKomentar.toString(), Icons.comment);
                        },
                      ),
                      StreamBuilder<QuerySnapshot>(
                        stream: FirebaseFirestore.instance.collection('ratings').snapshots(),
                        builder: (context, snapshotRating) {
                          if (!snapshotRating.hasData) return _statCard("Rating", "0", Icons.star);
                          final ratingDocs = snapshotRating.data!.docs;
                          double avgRating = 0;
                          if (ratingDocs.isNotEmpty) {
                            final ratings = ratingDocs
                                .map((doc) => (doc.data() as Map<String, dynamic>)['rating'] as int)
                                .toList();
                            avgRating = ratings.reduce((a, b) => a + b) / ratings.length;
                          }
                          return _statCard("Rata-rata Rating", avgRating.toStringAsFixed(1), Icons.star);
                        },
                      ),
                    ],
                  );
                }),

                const SizedBox(height: 32),

                // ===== Horizontal List Pantai =====
                const Text(
                  "Pantai dengan Ulasan & Rating",
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 12),
                SizedBox(
                  height: 250,
                  child: ListView.builder(
                    scrollDirection: Axis.horizontal,
                    itemCount: wisataList.length,
                    itemBuilder: (context, index) {
                      final wisata = wisataList[index];
                      if (wisata.kategori != 'pantai') return const SizedBox();
                      return Container(
                        width: 180,
                        margin: const EdgeInsets.only(right: 12),
                        child: Card(
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                          elevation: 3,
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              if (wisata.gambar.isNotEmpty)
                                ClipRRect(
                                  borderRadius: const BorderRadius.only(
                                      topLeft: Radius.circular(12), topRight: Radius.circular(12)),
                                  child: Image.asset(
                                    'assets/images/${wisata.gambar}',
                                    height: 120,
                                    width: double.infinity,
                                    fit: BoxFit.cover,
                                  ),
                                ),
                              Padding(
                                padding: const EdgeInsets.all(8),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(wisata.nama,
                                        style: const TextStyle(
                                            fontWeight: FontWeight.bold, fontSize: 16),
                                        maxLines: 1,
                                        overflow: TextOverflow.ellipsis),
                                    const SizedBox(height: 4),
                                    Text(wisata.deskripsi,
                                        style:
                                            const TextStyle(fontSize: 12, color: Colors.grey),
                                        maxLines: 2,
                                        overflow: TextOverflow.ellipsis),
                                    const SizedBox(height: 8),
                                    StreamBuilder<QuerySnapshot>(
                                      stream: FirebaseFirestore.instance
                                          .collection('ratings')
                                          .where('wisataId', isEqualTo: wisata.id)
                                          .snapshots(),
                                      builder: (context, snapshotRating) {
                                        if (!snapshotRating.hasData ||
                                            snapshotRating.data!.docs.isEmpty) {
                                          return const Text("Belum ada rating",
                                              style: TextStyle(fontSize: 12));
                                        }
                                        final ratings = snapshotRating.data!.docs
                                            .map((doc) =>
                                                (doc.data() as Map<String, dynamic>)['rating']
                                                    as int)
                                            .toList();
                                        double avg = ratings.isNotEmpty
                                            ? ratings.reduce((a, b) => a + b) / ratings.length
                                            : 0;
                                        return Row(
                                          children: [
                                            const Icon(Icons.star,
                                                color: Colors.orange, size: 16),
                                            const SizedBox(width: 4),
                                            Text(avg.toStringAsFixed(1),
                                                style: const TextStyle(fontSize: 12)),
                                          ],
                                        );
                                      },
                                    ),
                                  ],
                                ),
                              )
                            ],
                          ),
                        ),
                      );
                    },
                  ),
                ),

                const SizedBox(height: 32),

                // ===== Ulasan Terbaru =====
                const Text("Ulasan Terbaru",
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                const SizedBox(height: 8),
                StreamBuilder<QuerySnapshot>(
                  stream: _komentarService.getKomentar(),
                  builder: (context, snapshotKomentar) {
                    if (!snapshotKomentar.hasData) return const SizedBox();
                    final now = DateTime.now().toUtc();
                    final recent = snapshotKomentar.data!.docs.where((doc) {
                      final data = doc.data() as Map<String, dynamic>;
                      final createdAt = data['createdAt'] as Timestamp?;
                      if (createdAt == null) return false;
                      return now.difference(createdAt.toDate().toUtc()).inHours <= 24;
                    }).toList();
                    final displayRecent =
                        recent.length > maxItems ? recent.sublist(0, maxItems) : recent;
                    return Column(
                      children: [
                        for (var doc in displayRecent)
                          Card(
                            margin: const EdgeInsets.only(bottom: 8),
                            child: ListTile(
                              leading: const Icon(Icons.person),
                              title: Text(
                                  (doc.data() as Map<String, dynamic>)['user'] ?? 'Anonim'),
                              subtitle: Text(
                                  (doc.data() as Map<String, dynamic>)['komentar'] ?? ''),
                              trailing: const Icon(Icons.notifications_active,
                                  color: Colors.orange),
                            ),
                          ),
                        if (recent.length > maxItems)
                          TextButton(
                              onPressed: () => Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                      builder: (_) => KomentarPage(
                                          wisataList: wisataList))),
                              child: const Text("Lihat Selengkapnya")),
                      ],
                    );
                  },
                ),

                const SizedBox(height: 32),

                // ===== Dropdown Kategori & List Wisata =====
                const Text("Cari Kategori Wisata",
                    style: TextStyle(fontWeight: FontWeight.bold)),
                const SizedBox(height: 8),
                DropdownButton<String>(
                  value: selectedKategori,
                  items: kategoriMap.entries
                      .map((e) => DropdownMenuItem(value: e.key, child: Text(e.value)))
                      .toList(),
                  onChanged: (value) {
                    setState(() {
                      selectedKategori = value!;
                    });
                  },
                ),
                const SizedBox(height: 16),
                Text(
                  kategoriMap[selectedKategori]!,
                  style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 8),
                ListView.builder(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  itemCount: displayWisata.length,
                  itemBuilder: (context, index) {
                    final w = displayWisata[index];
                    return Card(
                      margin: const EdgeInsets.only(bottom: 10),
                      child: ListTile(
                        title: Text(w.nama,
                            style: const TextStyle(fontWeight: FontWeight.bold)),
                        subtitle: Text(w.lokasi),
                        trailing: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            IconButton(
                              icon: const Icon(Icons.edit, color: Colors.blue),
                              onPressed: () => Navigator.push(
                                context,
                                MaterialPageRoute(builder: (_) => WisataFormPage(wisata: w)),
                              ),
                            ),
                            IconButton(
                              icon: const Icon(Icons.delete, color: Colors.red),
                              onPressed: () async => await _service.deleteWisata(w.id),
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                ),
                if (filteredWisata.length > maxItems)
                  TextButton(
                    onPressed: () => Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => WisataListPage(
                          kategori: selectedKategori,
                          kategoriName: kategoriMap[selectedKategori]!,
                        ),
                      ),
                    ),
                    child: const Text("Lihat Selengkapnya"),
                  ),
              ],
            ),
          );
        },
      ),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _selectedIndex,
        selectedItemColor: primaryColor,
        onTap: (index) {
          setState(() => _selectedIndex = index);
          if (index == 0) {
            Navigator.pushReplacement(
                context, MaterialPageRoute(builder: (_) => const AdminDashboardPage()));
          } else if (index == 1 || index == 2) {
            Navigator.push(context, MaterialPageRoute(builder: (_) => const WisataFormPage()));
          }
        },
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.dashboard), label: 'Dashboard'),
          BottomNavigationBarItem(icon: Icon(Icons.place), label: 'Wisata'),
          BottomNavigationBarItem(icon: Icon(Icons.person), label: 'Profil'),
        ],
      ),
    );
  }

  Widget _statCard(String title, String value, IconData icon) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: primaryColor,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: [
          Icon(icon, color: Colors.white, size: 28),
          const SizedBox(width: 12),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(value,
                  style: const TextStyle(
                      fontSize: 20, color: Colors.white, fontWeight: FontWeight.bold)),
              Text(title, style: const TextStyle(color: Colors.white70)),
            ],
          ),
        ],
      ),
    );
  }
}
