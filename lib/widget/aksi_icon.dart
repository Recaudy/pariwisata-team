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
  final TextEditingController controller = TextEditingController();
  final user = FirebaseAuth.instance.currentUser;
  bool showCustomSnackbar = false;

  Future<String> getNamaUser(String uid) async {
    final doc = await FirebaseFirestore.instance
        .collection('users')
        .doc(uid)
        .get();
    if (doc.exists && doc.data() != null) {
      return doc['name'] ?? 'User';
    }
    return 'User';
  }

  void reportKomentar() {
    setState(() => showCustomSnackbar = true);
    Future.delayed(const Duration(seconds: 2), () {
      if (mounted) setState(() => showCustomSnackbar = false);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        const Padding(
          padding: EdgeInsets.all(12),
          child: Text(
            "Komentar",
            style: TextStyle(color: Colors.white, fontSize: 16),
          ),
        ),
        Expanded(
          child: StreamBuilder<QuerySnapshot>(
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

              if (snapshot.data!.docs.isEmpty) {
                return Center(
                  child: IgnorePointer(
                    child: Opacity(
                      opacity: 0.15,
                      child: Lottie.asset(
                        'assets/images/chat.json',
                        height: 120,
                        repeat: false,
                      ),
                    ),
                  ),
                );
              }
              final docs = snapshot.data!.docs;
              return ListView.builder(
                padding: const EdgeInsets.symmetric(horizontal: 12),
                itemCount: docs.length,
                itemBuilder: (context, index) {
                  final data = docs[index].data() as Map<String, dynamic>;
                  return Container(
                    margin: const EdgeInsets.only(bottom: 16),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        CircleAvatar(
                          radius: 18,
                          backgroundColor: Colors.white,
                          child: Text((data['user'] ?? 'U')[0].toUpperCase()),
                        ),
                        const SizedBox(width: 10),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                data['user'] ?? 'User',
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
                                child: Text(data['komentar'] ?? ''),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  );
                },
              );
            },
          ),
        ),
        Padding(
          padding: const EdgeInsets.all(12),
          child: Row(
            children: [
              Expanded(
                child: TextField(
                  controller: controller,
                  decoration: InputDecoration(
                    hintText: "Tulis komentar...",
                    filled: true,
                    fillColor: Colors.grey.shade200,
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(10),
                      borderSide: BorderSide.none,
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 10),
              IconButton(
                icon: const Icon(Icons.send, color: Colors.white),
                onPressed: () async {
                  if (controller.text.trim().isEmpty) return;
                  if (user == null) return;

                  final namaUser = await getNamaUser(user!.uid);

                  await FirebaseFirestore.instance.collection('komentar').add({
                    'wisataId': widget.wisataId,
                    'userId': user!.uid,
                    'user': namaUser,
                    'komentar': controller.text.trim(),
                    'createdAt': Timestamp.now(),
                  });

                  controller.clear();
                },
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class LikeButton extends StatefulWidget {
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
  int rating = 0;
  bool isLoading = false;

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      backgroundColor: const Color(0xFF21899C),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Lottie.asset('assets/images/stars.json', height: 50, repeat: false),
          const Text("Beri Rating", style: TextStyle(color: Colors.white)),
          const SizedBox(height: 20),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: List.generate(5, (index) {
              return GestureDetector(
                onTap: () => setState(() => rating = index + 1),
                child: Icon(
                  Icons.star,
                  size: 40,
                  color: index < rating ? Colors.amber : Colors.grey,
                ),
              );
            }),
          ),
          const SizedBox(height: 20),
          ElevatedButton(
            onPressed: isLoading
                ? null
                : () async {
                    final user = FirebaseAuth.instance.currentUser;
                    if (user == null) return;
                    if (rating == 0) return;

                    setState(() => isLoading = true);

                    final check = await FirebaseFirestore.instance
                        .collection('ratings')
                        .where('wisataId', isEqualTo: widget.wisataId)
                        .where('userId', isEqualTo: user.uid)
                        .limit(1)
                        .get();

                    if (check.docs.isNotEmpty) {
                      setState(() => isLoading = false);
                      Navigator.pop(context);
                      return;
                    }

                    await FirebaseFirestore.instance.collection('ratings').add({
                      'wisataId': widget.wisataId,
                      'userId': user.uid,
                      'rating': rating,
                      'createdAt': Timestamp.now(),
                    });

                    setState(() => isLoading = false);
                    Navigator.pop(context);
                  },
            child: Text(isLoading ? "Loading..." : "Kirim"),
          ),
        ],
      ),
    );
  }
}
