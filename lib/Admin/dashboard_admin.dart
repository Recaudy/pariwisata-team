import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

import '../services/wisata_services.dart';
import '../models/wisata_model.dart';
import '../services/komentar_service.dart';

import 'wisata_form_page.dart';
import 'Komentar_page.dart';
import 'wisata_list_page.dart';

const Color primaryColor = Color(0xFF21899C);

class AdminDashboardPage extends StatefulWidget {
  const AdminDashboardPage({super.key});

  @override
  State<AdminDashboardPage> createState() => _AdminDashboardPageState();
}

class _AdminDashboardPageState extends State<AdminDashboardPage> {
  final WisataService _wisataService = WisataService();
  final KomentarService _komentarService = KomentarService();

  String selectedKategori = 'all';
  int maxItems = 2;
  int _selectedIndex = 0;

  final Map<String, String> kategoriMap = {
    'all': 'Semua Wisata',
    'pantai': 'Pantai',
    'bukit': 'Bukit',
    'religi': 'Wisata Religi',
  };

  // ================= LOGOUT =================
  void _showLogoutDialog() {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text("Konfirmasi Logout"),
          content: const Text("Yakin ingin logout?"),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text("Batal"),
            ),
            TextButton(
              onPressed: () {
                Navigator.pop(context);
                Navigator.pushNamedAndRemoveUntil(
                    context, '/', (route) => false);
              },
              child: const Text(
                "Logout",
                style: TextStyle(color: Colors.red),
              ),
            ),
          ],
        );
      },
    );
  }

  // ================= UI =================
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Dashboard Admin"),
        backgroundColor: primaryColor,
      ),

      drawer: Drawer(
        child: Column(
          children: [
            const DrawerHeader(
              decoration: BoxDecoration(color: primaryColor),
              child: Align(
                alignment: Alignment.bottomLeft,
                child: Text(
                  "Admin",
                  style: TextStyle(
                    fontSize: 22,
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),
            ListTile(
              leading: const Icon(Icons.dashboard),
              title: const Text("Dashboard"),
              onTap: () => Navigator.pop(context),
            ),
            ListTile(
              leading: const Icon(Icons.place),
              title: const Text("Kelola Wisata"),
              onTap: () {
                Navigator.pop(context);
                Navigator.push(
                  context,
                  MaterialPageRoute(
                      builder: (_) => const WisataFormPage()),
                );
              },
            ),
            const Spacer(),
            ListTile(
              leading: const Icon(Icons.logout, color: Colors.red),
              title: const Text("Logout"),
              onTap: _showLogoutDialog,
            ),
          ],
        ),
      ),

      floatingActionButton: FloatingActionButton(
        backgroundColor: primaryColor,
        child: const Icon(Icons.add),
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (_) => const WisataFormPage()),
          );
        },
      ),

      // ================= BODY =================
      body: StreamBuilder<List<WisataModel>>(
        stream: _wisataService.getWisata(),
        builder: (context, snapshot) {
          final wisataList = snapshot.data ?? [];

          final filteredWisata = selectedKategori == 'all'
              ? wisataList
              : wisataList
                  .where((w) => w.kategori == selectedKategori)
                  .toList();

          final displayWisata = filteredWisata.length > maxItems
              ? filteredWisata.sublist(0, maxItems)
              : filteredWisata;

          return SingleChildScrollView(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [

                // ================= WELCOME =================
                const Text(
                  "Selamat Datang, Admin 👋",
                  style: TextStyle(
                      fontSize: 22, fontWeight: FontWeight.bold),
                ),

                const SizedBox(height: 16),

                // ================= STATISTIK =================
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: primaryColor.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        "Statistik Aplikasi",
                        style: TextStyle(
                            fontSize: 18, fontWeight: FontWeight.bold),
                      ),
                      const SizedBox(height: 16),

                      Row(
                        children: [
                          simpleStatItem(
                            icon: Icons.place,
                            title: "Total Wisata",
                            value: wisataList.length.toString(),
                          ),
                          const SizedBox(width: 8),

                          StreamBuilder<QuerySnapshot>(
                            stream: _komentarService.getKomentar(),
                            builder: (context, snap) {
                              int total = snap.hasData
                                  ? snap.data!.docs.length
                                  : 0;
                              return simpleStatItem(
                                icon: Icons.comment,
                                title: "Total Ulasan",
                                value: total.toString(),
                              );
                            },
                          ),
                          const SizedBox(width: 8),

                          StreamBuilder<QuerySnapshot>(
                            stream: FirebaseFirestore.instance
                                .collection('ratings')
                                .snapshots(),
                            builder: (context, snap) {
                              double avg = 0;
                              if (snap.hasData &&
                                  snap.data!.docs.isNotEmpty) {
                                final ratings = snap.data!.docs
                                    .map((doc) =>
                                        (doc.data() as Map<String, dynamic>)['rating']
                                            as int)
                                    .toList();
                                avg = ratings.reduce((a, b) => a + b) /
                                    ratings.length;
                              }
                              return simpleStatItem(
                                icon: Icons.star,
                                title: "Rating",
                                value: avg.toStringAsFixed(1),
                              );
                            },
                          ),
                        ],
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 32),

                // ================= ULASAN TERBARU =================
                const Text(
                  "Ulasan Terbaru",
                  style:
                      TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 8),

                StreamBuilder<QuerySnapshot>(
                  stream: _komentarService.getKomentar(),
                  builder: (context, snapshot) {
                    if (!snapshot.hasData) return const SizedBox();

                    final now = DateTime.now();
                    final recent = snapshot.data!.docs.where((doc) {
                      final data = doc.data() as Map<String, dynamic>;
                      final time = data['createdAt'] as Timestamp?;
                      if (time == null) return false;
                      return now.difference(time.toDate()).inHours <= 24;
                    }).toList();

                    final display = recent.length > maxItems
                        ? recent.sublist(0, maxItems)
                        : recent;

                    return Column(
                      children: [
                        for (var doc in display)
                          Card(
                            child: ListTile(
                              leading: const Icon(Icons.person),
                              title: Text(doc['user'] ?? 'Anonim'),
                              subtitle: Text(doc['komentar'] ?? ''),
                            ),
                          ),
                        if (recent.length > maxItems)
                          TextButton(
                            onPressed: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (_) =>
                                      KomentarPage(wisataList: wisataList),
                                ),
                              );
                            },
                            child: const Text("Lihat Selengkapnya"),
                          ),
                      ],
                    );
                  },
                ),

                const SizedBox(height: 32),

                // ================= FILTER =================
                const Text(
                  "Filter Wisata",
                  style:
                      TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),

                DropdownButton<String>(
                  value: selectedKategori,
                  items: kategoriMap.entries
                      .map(
                        (e) => DropdownMenuItem(
                          value: e.key,
                          child: Text(e.value),
                        ),
                      )
                      .toList(),
                  onChanged: (value) {
                    setState(() {
                      selectedKategori = value!;
                    });
                  },
                ),

                const SizedBox(height: 16),

                // ================= LIST WISATA =================
                for (var w in displayWisata)
                  Card(
                    child: ListTile(
                      title: Text(w.nama,
                          style: const TextStyle(
                              fontWeight: FontWeight.bold)),
                      subtitle: Text(w.lokasi),
                      trailing: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          IconButton(
                            icon: const Icon(Icons.edit, color: Colors.blue),
                            onPressed: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (_) =>
                                      WisataFormPage(wisata: w),
                                ),
                              );
                            },
                          ),
                          IconButton(
                            icon:
                                const Icon(Icons.delete, color: Colors.red),
                            onPressed: () async {
                              await _wisataService.deleteWisata(w.id);
                            },
                          ),
                        ],
                      ),
                    ),
                  ),

                if (filteredWisata.length > maxItems)
                  TextButton(
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => WisataListPage(
                            kategori: selectedKategori,
                            kategoriName:
                                kategoriMap[selectedKategori]!,
                          ),
                        ),
                      );
                    },
                    child: const Text("Lihat Selengkapnya"),
                  ),
              ],
            ),
          );
        },
      ),

      // ================= BOTTOM NAV =================
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _selectedIndex,
        selectedItemColor: primaryColor,
        onTap: (index) {
          setState(() => _selectedIndex = index);
        },
        items: const [
          BottomNavigationBarItem(
              icon: Icon(Icons.dashboard), label: "Dashboard"),
          BottomNavigationBarItem(
              icon: Icon(Icons.place), label: "Wisata"),
          BottomNavigationBarItem(
              icon: Icon(Icons.person), label: "Profil"),
        ],
      ),
    );
  }
}

// ================= STAT ITEM =================
Widget simpleStatItem({
  required IconData icon,
  required String title,
  required String value,
}) {
  return Expanded(
    child: Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(10),
      ),
      child: Column(
        children: [
          Icon(icon, color: primaryColor),
          const SizedBox(height: 6),
          Text(
            value,
            style:
                const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
          Text(
            title,
            style: const TextStyle(fontSize: 12, color: Colors.grey),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    ),
  );
}
