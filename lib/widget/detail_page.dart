import 'package:flutter/material.dart';

class DetailPage extends StatelessWidget {
  final Map<String, dynamic> wisataData;
  const DetailPage({super.key, required this.wisataData});

  @override
  Widget build(BuildContext context) {
    final nama = (wisataData['nama'] ?? 'Tanpa nama').toString();
    final subJudul = (wisataData['sub_judul'] ?? '').toString();
    final image = (wisataData['image'] ?? '').toString();
    final desc = (wisataData['desc'] ?? '').toString();
    final sejarah = (wisataData['sejarah'] ?? '').toString();

    Widget headerImage;
    if (image.isEmpty) {
      headerImage = Container(
        width: double.infinity,
        height: 200,
        color: Colors.grey.shade200,
        alignment: Alignment.center,
        child: const Icon(
          Icons.image_not_supported,
          size: 48,
          color: Colors.grey,
        ),
      );
    } else if (image.startsWith('http')) {
      headerImage = ClipRRect(
        borderRadius: BorderRadius.circular(10),
        child: Image.network(
          image,
          width: double.infinity,
          height: 200,
          fit: BoxFit.cover,
          errorBuilder: (c, e, s) => Container(
            width: double.infinity,
            height: 200,
            color: Colors.grey.shade200,
            alignment: Alignment.center,
            child: const Icon(Icons.broken_image, size: 48, color: Colors.grey),
          ),
        ),
      );
    } else {
      headerImage = ClipRRect(
        borderRadius: BorderRadius.circular(10),
        child: Image.asset(
          image,
          width: double.infinity,
          height: 200,
          fit: BoxFit.cover,
          errorBuilder: (c, e, s) => Container(
            width: double.infinity,
            height: 200,
            color: Colors.grey.shade200,
            alignment: Alignment.center,
            child: const Icon(Icons.broken_image, size: 48, color: Colors.grey),
          ),
        ),
      );
    }

    return Scaffold(
      backgroundColor: Colors.grey[100],
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 1,
        title: Text(nama, style: const TextStyle(color: Colors.black)),
        centerTitle: true,
        leading: Navigator.canPop(context)
            ? IconButton(
                icon: const Icon(Icons.arrow_back, color: Colors.black),
                onPressed: () => Navigator.pop(context),
              )
            : null,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Card(
          elevation: 3,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                headerImage,
                const SizedBox(height: 16),
                Text(
                  nama,
                  style: const TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 6),
                Text(
                  subJudul,
                  style: const TextStyle(fontSize: 14, color: Colors.grey),
                ),
                const Divider(height: 24, color: Colors.grey),
                Text(
                  'Deskripsi',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: Colors.blue[900],
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  desc,
                  style: const TextStyle(fontSize: 14, height: 1.5),
                  textAlign: TextAlign.justify,
                ),
                const SizedBox(height: 24),
                Text(
                  'Sejarah & Fakta Menarik',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: Colors.blue[900],
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  sejarah,
                  style: const TextStyle(fontSize: 14, height: 1.5),
                  textAlign: TextAlign.justify,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
