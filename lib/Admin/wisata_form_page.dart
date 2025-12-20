import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import '../services/wisata_services.dart';
import '../models/wisata_model.dart';

const Color primaryColor = Color(0xFF21899C);

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
        const SnackBar(content: Text('Silakan pilih gambar')),
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.wisata == null ? 'Tambah Wisata' : 'Edit Wisata'),
        backgroundColor: primaryColor,
        elevation: 2,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 20),
        child: Column(
          children: [
            // Card untuk form fields
            Card(
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              elevation: 3,
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  children: [
                    _field(namaController, 'Nama Wisata'),
                    _field(subJudulController, 'Lokasi'),
                    const SizedBox(height: 12),
                    DropdownButtonFormField<String>(
                      value: selectedKategori,
                      decoration: InputDecoration(
                        labelText: 'Kategori',
                        border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
                        filled: true,
                        fillColor: Colors.grey[100],
                      ),
                      items: kategoriMap.entries.map((e) {
                        return DropdownMenuItem(
                          value: e.key,
                          child: Text(e.value),
                        );
                      }).toList(),
                      onChanged: (value) {
                        setState(() {
                          selectedKategori = value!;
                        });
                      },
                    ),
                    const SizedBox(height: 12),
                    _field(descController, 'Deskripsi Singkat', maxLines: 3),
                    _field(sejarahController, 'Sejarah', maxLines: 4),
                    const SizedBox(height: 12),
                    // Image Picker
                    GestureDetector(
                      onTap: _pickImage,
                      child: Container(
                        height: 180,
                        width: double.infinity,
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(color: Colors.grey.shade400),
                          color: Colors.grey[100],
                        ),
                        child: selectedImage != null
                            ? ClipRRect(
                                borderRadius: BorderRadius.circular(12),
                                child: Image.file(selectedImage!, fit: BoxFit.cover),
                              )
                            : const Center(
                                child: Icon(Icons.add_a_photo, size: 40, color: Colors.grey),
                              ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 24),
            // Button Save
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: _simpan,
                style: ElevatedButton.styleFrom(
                  backgroundColor: primaryColor,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  elevation: 3,
                ),
                child: Text(
                  widget.wisata == null ? 'Kirim' : 'Simpan Perubahan',
                  style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.white),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

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
          filled: true,
          fillColor: Colors.grey[100],
          border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
        ),
      ),
    );
  }
}
