import 'package:flutter/material.dart';
import 'package:lottie/lottie.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

void openKomentarSheet(BuildContext context, String wisataId) {
  showModalBottomSheet(
    context: context,
    useRootNavigator: true,
    isScrollControlled: true,
    backgroundColor: const Color(0xFF21899C),
    shape: const RoundedRectangleBorder(
      borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
    ),
    builder: (_) {
      return FractionallySizedBox(
        heightFactor: 0.55,
        child: KomentarSheet(wisataId: wisataId),
      );
    },
  );
}

class KomentarSheet extends StatefulWidget {
  final String wisataId;
  const KomentarSheet({super.key, required this.wisataId});

  @override
  State<KomentarSheet> createState() => _KomentarSheetState();
}

class _KomentarSheetState extends State<KomentarSheet> {
  final TextEditingController _pesanController = TextEditingController();
  final _currentUser = FirebaseAuth.instance.currentUser;

  Future<String> _getNamaUser(String uid) async {
    final doc = await FirebaseFirestore.instance
        .collection('users')
        .doc(uid)
        .get();
    if (doc.exists && doc.data() != null) {
      return doc['name'] ?? 'User';
    }
    return 'User';
  }

  Future<void> _kirimKomentar() async {
    final isiPesan = _pesanController.text.trim();

    if (isiPesan.isEmpty || _currentUser == null) return;

    final namaUser = await _getNamaUser(_currentUser!.uid);

    await FirebaseFirestore.instance.collection('komentar').add({
      'wisataId': widget.wisataId,
      'userId': _currentUser!.uid,
      'user': namaUser,
      'komentar': isiPesan,
      'createdAt': Timestamp.now(),
    });

    _pesanController.clear();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        const Padding(
          padding: EdgeInsets.all(12),
          child: Text(
            "Komentar",
            style: TextStyle(
              color: Colors.white,
              fontSize: 16,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),

        Expanded(child: _buildListKomentar()),

        _buildInputSection(),
      ],
    );
  }

  Widget _buildListKomentar() {
    return StreamBuilder<QuerySnapshot>(
      stream: FirebaseFirestore.instance
          .collection('komentar')
          .where('wisataId', isEqualTo: widget.wisataId)
          .snapshots(),
      builder: (context, snapshot) {
        if (!snapshot.hasData) {
          return const Center(
            child: CircularProgressIndicator(color: Colors.white),
          );
        }

        final dataDocs = snapshot.data!.docs;

        if (dataDocs.isEmpty) {
          return Center(
            child: Opacity(
              opacity: 0.5,
              child: Lottie.asset(
                'assets/images/chat.json',
                height: 120,
                repeat: false,
              ),
            ),
          );
        }

        return ListView.builder(
          padding: const EdgeInsets.symmetric(horizontal: 12),
          itemCount: dataDocs.length,
          itemBuilder: (context, index) {
            final data = dataDocs[index].data() as Map<String, dynamic>;
            return _buildItemKomentar(data);
          },
        );
      },
    );
  }

  Widget _buildItemKomentar(Map<String, dynamic> data) {
    final namaUser = data['user'] ?? 'User';
    final inisial = namaUser.isNotEmpty ? namaUser[0].toUpperCase() : '?';
    final isiKomentar = data['komentar'] ?? '';

    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          CircleAvatar(
            radius: 18,
            backgroundColor: Colors.white,
            child: Text(
              inisial,
              style: const TextStyle(fontWeight: FontWeight.bold),
            ),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  namaUser,
                  style: const TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 4),
                Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: Colors.grey.shade100,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text(isiKomentar),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildInputSection() {
    return Padding(
      padding: const EdgeInsets.all(12),
      child: Row(
        children: [
          Expanded(
            child: TextField(
              controller: _pesanController,
              decoration: InputDecoration(
                hintText: "Tulis komentar...",
                filled: true,
                fillColor: Colors.grey.shade200,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10),
                  borderSide: BorderSide.none,
                ),
                contentPadding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 8,
                ),
              ),
            ),
          ),
          const SizedBox(width: 10),
          IconButton(
            icon: const Icon(Icons.send, color: Colors.white),
            onPressed: _kirimKomentar,
          ),
        ],
      ),
    );
  }
}

class LikeButton extends StatefulWidget {
  const LikeButton({super.key});

  @override
  State<LikeButton> createState() => _LikeButtonState();
}

class _LikeButtonState extends State<LikeButton> {
  bool isLiked = false;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => setState(() => isLiked = !isLiked),
      child: Icon(
        Icons.favorite,
        color: isLiked ? Colors.red : Colors.white,
        shadows: const [
          Shadow(color: Colors.black, blurRadius: 10, offset: Offset(2, 2)),
        ],
      ),
    );
  }
}

class RatingPopup extends StatefulWidget {
  final String wisataId;
  const RatingPopup({super.key, required this.wisataId});

  @override
  State<RatingPopup> createState() => _RatingPopupState();
}

class _RatingPopupState extends State<RatingPopup> {
  int _selectedRating = 0;
  bool _isLoading = false;

  Future<void> _kirimRating() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null || _selectedRating == 0) return;

    setState(() => _isLoading = true);

    final check = await FirebaseFirestore.instance
        .collection('ratings')
        .where('wisataId', isEqualTo: widget.wisataId)
        .where('userId', isEqualTo: user.uid)
        .limit(1)
        .get();

    if (check.docs.isNotEmpty) {
      if (mounted) Navigator.pop(context);
      return;
    }

    await FirebaseFirestore.instance.collection('ratings').add({
      'wisataId': widget.wisataId,
      'userId': user.uid,
      'rating': _selectedRating,
      'createdAt': Timestamp.now(),
    });

    if (mounted) {
      setState(() => _isLoading = false);
      Navigator.pop(context);
    }
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      backgroundColor: const Color(0xFF21899C),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Lottie.asset('assets/images/stars.json', height: 50, repeat: false),
          const SizedBox(height: 10),
          const Text(
            "Beri Rating",
            style: TextStyle(
              color: Colors.white,
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 20),

          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: List.generate(5, (index) {
              return GestureDetector(
                onTap: () => setState(() => _selectedRating = index + 1),
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 4),
                  child: Icon(
                    Icons.star,
                    size: 32,
                    color: index < _selectedRating
                        ? Colors.amber
                        : Colors.grey.withOpacity(0.5),
                  ),
                ),
              );
            }),
          ),
          const SizedBox(height: 20),

          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.white,
                foregroundColor: const Color(0xFF21899C),
              ),
              onPressed: _isLoading ? null : _kirimRating,
              child: Text(_isLoading ? "Mengirim..." : "Kirim"),
            ),
          ),
        ],
      ),
    );
  }
}
