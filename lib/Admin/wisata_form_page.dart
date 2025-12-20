import 'package:flutter/material.dart';
import '../services/wisata_services.dart';
import '../models/wisata_model.dart';

class WisataFormPage extends StatefulWidget {
  final WisataModel? wisata;

  const WisataFormPage({super.key, this.wisata});

  @override
  State<WisataFormPage> createState() => _WisataFormPageState();
}

class _WisataFormPageState extends State<WisataFormPage> {
  final WisataService _service = WisataService();

  // ================= CONTROLLERS =================
  final TextEditingController namaController = TextEditingController();
  final TextEditingController lokasiController = TextEditingController();
  final TextEditingController deskripsiController = TextEditingController();
  final TextEditingController descController = TextEditingController();
  final TextEditingController gambarController = TextEditingController();
  final TextEditingController imageController = TextEditingController();
  final TextEditingController kategoriController = TextEditingController();
  final TextEditingController subJudulController = TextEditingController();
  final TextEditingController sejarahController = TextEditingController();

  @override
  void initState() {
    super.initState();

    // JIKA EDIT DATA
    if (widget.wisata != null) {
      namaController.text = widget.wisata!.nama;
      lokasiController.text = widget.wisata!.lokasi;
      deskripsiController.text = widget.wisata!.deskripsi;
      descController.text = widget.wisata!.desc;
      gambarController.text = widget.wisata!.gambar;
      imageController.text = widget.wisata!.image;
      kategoriController.text = widget.wisata!.kategori;
      subJudulController.text = widget.wisata!.subJudul;
      sejarahController.text = widget.wisata!.sejarah;
    }
  }

  @override
  void dispose() {
    namaController.dispose();
    lokasiController.dispose();
    deskripsiController.dispose();
    descController.dispose();
    gambarController.dispose();
    imageController.dispose();
    kategoriController.dispose();
    subJudulController.dispose();
    sejarahController.dispose();
    super.dispose();
  }

  // ================= SIMPAN DATA =================
  void _simpan() async {
    final wisata = WisataModel(
      id: widget.wisata?.id ?? '',
      nama: namaController.text.trim(),
      lokasi: lokasiController.text.trim(),
      deskripsi: deskripsiController.text.trim(),
      desc: descController.text.trim(),
      gambar: gambarController.text.trim(),
      image: imageController.text.trim(),
      kategori: kategoriController.text.trim(),
      subJudul: subJudulController.text.trim(),
      sejarah: sejarahController.text.trim(),
    );

    try {
      if (widget.wisata == null) {
        // CREATE
        await _service.tambahWisata(wisata);
      } else {
        // UPDATE
        await _service.updateWisata(wisata);
      }

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Data wisata berhasil disimpan')),
        );
        Navigator.pop(context);
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Gagal menyimpan data: $e')),
      );
    }
  }

  // ================= UI =================
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.wisata == null ? 'Tambah Wisata' : 'Edit Wisata'),
        backgroundColor: const Color(0xFF21899C),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            _field(namaController, 'Nama Wisata'),
            _field(subJudulController, 'Sub Judul'),
            _field(lokasiController, 'Lokasi'),
            _field(kategoriController, 'Kategori'),
            _field(deskripsiController, 'Deskripsi', maxLines: 3),
            _field(descController, 'Desc (Ringkas)', maxLines: 2),
            _field(sejarahController, 'Sejarah', maxLines: 4),
            _field(gambarController, 'Gambar (URL)'),
            _field(imageController, 'Image (Asset / URL)'),
            const SizedBox(height: 24),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: _simpan,
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF21899C),
                  padding: const EdgeInsets.symmetric(vertical: 14),
                ),
                child: const Text(
                  'Simpan',
                  style: TextStyle(fontSize: 16),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ================= WIDGET FIELD =================
  Widget _field(
    TextEditingController controller,
    String label, {
    int maxLines = 1,
  }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: TextField(
        controller: controller,
        maxLines: maxLines,
        decoration: InputDecoration(
          labelText: label,
          border: const OutlineInputBorder(),
        ),
      ),
    );
  }
}
