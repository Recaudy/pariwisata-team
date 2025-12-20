import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:project_uts_pariwisata/Admin/komentar_page.dart';
import 'package:project_uts_pariwisata/Admin/wisata_list_page.dart';
import '../services/wisata_services.dart';
import '../models/wisata_model.dart';
import 'wisata_form_page.dart';
import '../services/komentar_service.dart';

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
  final int maxItems = 2; // batas tampilan di dashboard

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
    return Scaffold(
      appBar: AppBar(
        title: const Text(""),
        backgroundColor: Colors.white,
        actions: [
          IconButton(
            icon: const Icon(Icons.notifications),
            onPressed: () => Navigator.push(
              context,
              MaterialPageRoute(builder: (_) => const KomentarPage()),
            ),
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
                  style: TextStyle(color: Colors.white, fontSize: 20, fontWeight: FontWeight.bold),
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

          // filter wisata sesuai kategori
          final filteredWisata = selectedKategori == 'all'
              ? wisataList
              : wisataList.where((w) => w.kategori == selectedKategori).toList();

          // ambil maksimal 2 untuk dashboard
          final displayWisata =
              filteredWisata.length > maxItems ? filteredWisata.sublist(0, maxItems) : filteredWisata;

          return SingleChildScrollView(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  "Selamat datang, Admin!",
                  style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 16),

                // Statistik total wisata
                _statCard("Total Wisata", wisataList.length.toString(), Icons.place),
                const SizedBox(height: 16),

                // Statistik total ulasan
                StreamBuilder<QuerySnapshot>(
                  stream: _komentarService.getKomentar(),
                  builder: (context, snapshotKomentar) {
                    final totalKomentar =
                        snapshotKomentar.hasData ? snapshotKomentar.data!.docs.length : 0;
                    return _statCard("Total Ulasan", totalKomentar.toString(), Icons.comment);
                  },
                ),
                const SizedBox(height: 32),

                const Text("Ulasan Terbaru", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                const SizedBox(height: 8),

                // Ulasan terbaru manual
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

                    final displayRecent = recent.length > maxItems ? recent.sublist(0, maxItems) : recent;

                    return Column(
                      children: [
                        for (var doc in displayRecent)
                          Card(
                            margin: const EdgeInsets.only(bottom: 8),
                            child: ListTile(
                              leading: const Icon(Icons.person),
                              title: Text((doc.data() as Map<String, dynamic>)['user'] ?? 'Anonim'),
                              subtitle: Text((doc.data() as Map<String, dynamic>)['komentar'] ?? ''),
                              trailing:
                                  const Icon(Icons.notifications_active, color: Colors.orange),
                            ),
                          ),
                        if (recent.length > maxItems)
                          TextButton(
                            onPressed: () => Navigator.push(
                              context,
                              MaterialPageRoute(builder: (_) => const KomentarPage()),
                            ),
                            child: const Text("Lihat Selengkapnya"),
                          ),
                      ],
                    );
                  },
                ),

                const SizedBox(height: 32),
                const Text("Cari Kategori Wisata", style: TextStyle(fontWeight: FontWeight.bold)),
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

                // List wisata manual
                for (var w in displayWisata)
                  Card(
                    margin: const EdgeInsets.only(bottom: 10),
                    child: ListTile(
                      title: Text(w.nama, style: const TextStyle(fontWeight: FontWeight.bold)),
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
          } else if (index == 1) {
            Navigator.push(context, MaterialPageRoute(builder: (_) => const WisataFormPage()));
          } else if (index == 2) {
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
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(color: primaryColor, borderRadius: BorderRadius.circular(12)),
      child: Row(
        children: [
          Icon(icon, color: Colors.white),
          const SizedBox(width: 12),
          Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Text(value,
                style: const TextStyle(fontSize: 22, color: Colors.white, fontWeight: FontWeight.bold)),
            Text(title, style: const TextStyle(color: Colors.white70)),
          ]),
        ],
      ),
    );
  }
}
