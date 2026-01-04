import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:google_fonts/google_fonts.dart';
import '../services/wisata_services.dart';
import '../models/wisata_model.dart';

// Tema Warna Konsisten
class AppColors {
  static const Color primary   = Color(0xFF21899C); // Teal Tua
  static const Color secondary = Color(0xFF4DA1B0); // Teal Muda
  static const Color accent    = Color(0xFFF56B3F); // Oranye
  static const Color highlight = Color(0xFFF9CA58); // Kuning
}

class WisataFormPage extends StatefulWidget {
  final WisataModel? wisata;

  const WisataFormPage({super.key, this.wisata});

  @override
  State<WisataFormPage> createState() => _WisataFormPageState();
}

class _WisataFormPageState extends State<WisataFormPage> {
  final WisataService _service = WisataService();
  final ImagePicker _picker = ImagePicker();

  final TextEditingController namaController = TextEditingController();
  final TextEditingController subJudulController = TextEditingController();
  final TextEditingController descController = TextEditingController();
  final TextEditingController sejarahController = TextEditingController();

  String selectedKategori = 'pantai';

  final Map<String, String> kategoriMap = {
    'pantai': 'Pantai',
    'bukit': 'Bukit',
    'religi': 'Wisata Religi',
  };

  File? selectedImage;

  @override
  void initState() {
    super.initState();
    if (widget.wisata != null) {
      namaController.text = widget.wisata!.nama;
      subJudulController.text = widget.wisata!.subJudul;
      descController.text = widget.wisata!.desc;
      sejarahController.text = widget.wisata!.sejarah;
      selectedKategori = widget.wisata!.kategori;
    }
  }

  @override
  void dispose() {
    namaController.dispose();
    subJudulController.dispose();
    descController.dispose();
    sejarahController.dispose();
    super.dispose();
  }

  Future<void> _pickImage() async {
    final XFile? image = await _picker.pickImage(
      source: ImageSource.gallery,
      imageQuality: 70,
    );
    if (image != null) {
      setState(() {
        selectedImage = File(image.path);
      });
    }
  }

  void _simpan() async {
    if (selectedImage == null && widget.wisata == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Silakan pilih gambar destinasi')),
      );
      return;
    }

    final wisata = WisataModel(
      id: widget.wisata?.id ?? '',
      nama: namaController.text.trim(),
      subJudul: subJudulController.text.trim(),
      kategori: selectedKategori,
      desc: descController.text.trim(),
      sejarah: sejarahController.text.trim(),
      image: selectedImage?.path ?? widget.wisata!.image,
      lokasi: '',
      deskripsi: '',
      gambar: '',
    );

    try {
      if (widget.wisata == null) {
        await _service.tambahWisata(wisata);
      } else {
        await _service.updateWisata(wisata);
      }

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Data wisata berhasil disimpan'),
            backgroundColor: AppColors.primary,
          ),
        );
        Navigator.pop(context);
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Gagal menyimpan data: $e'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF2F5F7),
      appBar: AppBar(
        title: Text(
          widget.wisata == null ? 'TAMBAH WISATA' : 'EDIT WISATA',
          style: GoogleFonts.poppins(fontWeight: FontWeight.bold, fontSize: 18),
        ),
        centerTitle: true,
        backgroundColor: AppColors.primary,
        elevation: 0,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header Info
            Text(
              "Detail Destinasi",
              style: GoogleFonts.poppins(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: AppColors.primary,
              ),
            ),
            const SizedBox(height: 5),
            const Text("Lengkapi formulir di bawah ini untuk mengelola data wisata", 
              style: TextStyle(color: Colors.grey, fontSize: 13)),
            const SizedBox(height: 25),

            // Form Input Area (WIDGET DASAR LINIER)
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(20),
                boxShadow: [
                  BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 15, offset: const Offset(0, 5)),
                ],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Nama Wisata
                  const Text("Nama Wisata", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
                  const SizedBox(height: 8),
                  TextField(
                    controller: namaController,
                    decoration: InputDecoration(
                      hintText: "Contoh: Pantai Tanjung Tinggi",
                      filled: true,
                      fillColor: Colors.grey[50],
                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none),
                    ),
                  ),
                  const SizedBox(height: 20),

                  // Lokasi
                  const Text("Lokasi", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
                  const SizedBox(height: 8),
                  TextField(
                    controller: subJudulController,
                    decoration: InputDecoration(
                      hintText: "Contoh: Belitung Sijuk",
                      filled: true,
                      fillColor: Colors.grey[50],
                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none),
                    ),
                  ),
                  const SizedBox(height: 20),

                  // Dropdown Kategori
                  const Text("Kategori", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
                  const SizedBox(height: 8),
                  DropdownButtonFormField<String>(
                    value: selectedKategori,
                    decoration: InputDecoration(
                      filled: true,
                      fillColor: Colors.grey[50],
                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none),
                    ),
                    items: kategoriMap.entries.map((e) {
                      return DropdownMenuItem(value: e.key, child: Text(e.value));
                    }).toList(),
                    onChanged: (value) => setState(() => selectedKategori = value!),
                  ),
                  const SizedBox(height: 20),

                  // Deskripsi
                  const Text("Deskripsi Singkat", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
                  const SizedBox(height: 8),
                  TextField(
                    controller: descController,
                    maxLines: 3,
                    decoration: InputDecoration(
                      hintText: "Ceritakan sedikit tentang keindahan tempat ini...",
                      filled: true,
                      fillColor: Colors.grey[50],
                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none),
                    ),
                  ),
                  const SizedBox(height: 20),

                  // Sejarah
                  const Text("Sejarah", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
                  const SizedBox(height: 8),
                  TextField(
                    controller: sejarahController,
                    maxLines: 4,
                    decoration: InputDecoration(
                      hintText: "Asal usul atau sejarah tempat ini...",
                      filled: true,
                      fillColor: Colors.grey[50],
                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none),
                    ),
                  ),
                  const SizedBox(height: 25),

                  // Image Picker Area
                  const Text("Foto Destinasi", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
                  const SizedBox(height: 10),
                  GestureDetector(
                    onTap: _pickImage,
                    child: Container(
                      height: 200,
                      width: double.infinity,
                      decoration: BoxDecoration(
                        color: Colors.grey[100],
                        borderRadius: BorderRadius.circular(15),
                        border: Border.all(color: Colors.grey.shade300, width: 2),
                      ),
                      child: selectedImage != null
                          ? ClipRRect(
                              borderRadius: BorderRadius.circular(13),
                              child: Image.file(selectedImage!, fit: BoxFit.cover),
                            )
                          : Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                const Icon(Icons.add_photo_alternate_rounded, size: 50, color: AppColors.secondary),
                                const SizedBox(height: 8),
                                Text("Klik untuk pilih foto", style: TextStyle(color: Colors.grey[600], fontSize: 13)),
                              ],
                            ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 35),

            // Tombol Simpan (WIDGET DASAR ELEVATEDBUTTON)
            SizedBox(
              width: double.infinity,
              height: 55,
              child: ElevatedButton(
                onPressed: _simpan,
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.accent,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
                  elevation: 5,
                ),
                child: Text(
                  widget.wisata == null ? 'KIRIM DATA' : 'SIMPAN PERUBAHAN',
                  style: GoogleFonts.inter(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.white, letterSpacing: 1),
                ),
              ),
            ),
            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }
}