class WisataModel {
  final String id;
  final String nama;
  final String lokasi;
  final String deskripsi;
  final String desc;
  final String gambar;
  final String image;
  final String kategori;
  final String subJudul;
  final String sejarah;

  WisataModel({
    required this.id,
    required this.nama,
    required this.lokasi,
    required this.deskripsi,
    required this.desc,
    required this.gambar,
    required this.image,
    required this.kategori,
    required this.subJudul,
    required this.sejarah,
  });

  factory WisataModel.fromFirestore(
    String id,
    Map<String, dynamic> data,
  ) {
    return WisataModel(
      id: id,
      nama: data['nama'] ?? '',
      lokasi: data['lokasi'] ?? '',
      deskripsi: data['deskripsi'] ?? '',
      desc: data['desc'] ?? '',
      gambar: data['gambar'] ?? '',
      image: data['image'] ?? '',
      kategori: data['kategori'] ?? '',
      subJudul: data['sub_judul'] ?? '',
      sejarah: data['sejarah'] ?? '',
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'nama': nama,
      'lokasi': lokasi,
      'deskripsi': deskripsi,
      'desc': desc,
      'gambar': gambar,
      'image': image,
      'kategori': kategori,
      'sub_judul': subJudul,
      'sejarah': sejarah,
    };
  }
}
