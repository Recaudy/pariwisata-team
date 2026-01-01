import 'package:flutter/material.dart';
import '../models/wisata_model.dart';
import '../services/wisata_services.dart';
import 'wisata_form_page.dart';

const Color primaryColor = Color(0xFF21899C);

class WisataListPage extends StatefulWidget {
  final String kategori;
  final String kategoriName;

  const WisataListPage({
    super.key,
    required this.kategori,
    required this.kategoriName,
  });

  @override
  State<WisataListPage> createState() => _WisataListPageState();
}

class _WisataListPageState extends State<WisataListPage> {
  final WisataService _service = WisataService();

  /// kategori aktif
  late String selectedKategori;

  /// map kategori
  final Map<String, String> kategoriMap = {
    'all': 'Semua Wisata',
    'pantai': 'Pantai',
    'bukit': 'Bukit',
    'religi': 'Wisata Religi',
  };

  /// limit item (untuk dashboard)
  final int maxItems = 5;

  @override
  void initState() {
    super.initState();
    selectedKategori = widget.kategori;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(kategoriMap[selectedKategori] ?? "Wisata"),
        backgroundColor: primaryColor,
      ),
      body: StreamBuilder<List<WisataModel>>(
        stream: _service.getWisata(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          final wisataList = snapshot.data ?? [];

          /// filter kategori
          final filteredWisata = selectedKategori == 'all'
              ? wisataList
              : wisataList
                  .where((w) => w.kategori == selectedKategori)
                  .toList();

          /// batasi tampilan
          final displayWisata = filteredWisata.length > maxItems
              ? filteredWisata.sublist(0, maxItems)
              : filteredWisata;

          return Column(
            children: [
              /// ================= DROPDOWN =================
              Padding(
                padding: const EdgeInsets.all(12),
                child: DropdownButtonFormField<String>(
                  value: selectedKategori,
                  decoration: const InputDecoration(
                    labelText: "Pilih Kategori",
                    border: OutlineInputBorder(),
                  ),
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
              ),

              /// ================= LIST =================
              Expanded(
                child: displayWisata.isEmpty
                    ? const Center(child: Text("Belum ada wisata"))
                    : ListView.builder(
                        itemCount: displayWisata.length,
                        itemBuilder: (context, index) {
                          final w = displayWisata[index];
                          return Card(
                            margin: const EdgeInsets.symmetric(
                                horizontal: 12, vertical: 6),
                            child: ListTile(
                              title: Text(
                                w.nama,
                                style: const TextStyle(
                                    fontWeight: FontWeight.bold),
                              ),
                              subtitle: Text(w.lokasi),
                              trailing: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  /// EDIT
                                  IconButton(
                                    icon: const Icon(Icons.edit,
                                        color: Colors.blue),
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

                                  /// DELETE
                                  IconButton(
                                    icon: const Icon(Icons.delete,
                                        color: Colors.red),
                                    onPressed: () async {
                                      await _service.deleteWisata(w.id);
                                    },
                                  ),
                                ],
                              ),
                            ),
                          );
                        },
                      ),
              ),

              /// ================= LIHAT SELENGKAPNYA =================
              if (filteredWisata.length > maxItems)
                Padding(
                  padding: const EdgeInsets.only(bottom: 12),
                  child: TextButton(
                    child: const Text("Lihat Selengkapnya"),
                    onPressed: () {
                      Navigator.pushReplacement(
                        context,
                        MaterialPageRoute(
                          builder: (_) => WisataListPage(
                            kategori: selectedKategori,
                            kategoriName:
                                kategoriMap[selectedKategori] ?? "Wisata",
                          ),
                        ),
                      );
                    },
                  ),
                ),
            ],
          );
        },
      ),
    );
  }
}
