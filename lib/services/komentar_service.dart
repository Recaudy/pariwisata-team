import 'package:cloud_firestore/cloud_firestore.dart';

class KomentarService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  Stream<QuerySnapshot> getKomentar() {
    return _firestore
        .collection('komentar')
        .orderBy('createdAt', descending: true)
        .snapshots();
  }
}
