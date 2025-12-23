import 'package:cloud_firestore/cloud_firestore.dart';

class KomentarService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  Stream<QuerySnapshot> getKomentar() {
    return _firestore
        .collection('komentar')
        .orderBy('createdAt', descending: true)
        .snapshots();
  }
  Future<void> deleteKomentar(String docId) async {
    try {
      await _firestore.collection('komentar').doc(docId).delete();
    } catch (e) {
      throw Exception('Gagal menghapus komentar: $e');
    }
  }

}
