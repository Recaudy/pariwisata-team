import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/wisata_model.dart';

class WisataService {
  final CollectionReference<Map<String, dynamic>> _ref = FirebaseFirestore
      .instance
      .collection('wisata');

  Future<void> tambahWisata(WisataModel wisata) async {
    await _ref.add(wisata.toMap());
  }

  Future<void> updateWisata(WisataModel wisata) async {
    await _ref.doc(wisata.id).update(wisata.toMap());
  }

  Future<void> deleteWisata(String id) async {
    await _ref.doc(id).delete();
  }

  Stream<List<WisataModel>> getWisata() {
    return _ref.snapshots().map((snapshot) {
      return snapshot.docs.map((doc) {
        return WisataModel.fromFirestore(doc.id, doc.data());
      }).toList();
    });
  }
}
