import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';

class AdminFeedbackPage extends StatelessWidget {
  const AdminFeedbackPage({super.key});

  // ================= DELETE =================
  Future<void> _deleteFeedback(String docId) async {
    await FirebaseFirestore.instance
        .collection('feedback')
        .doc(docId)
        .delete();
  }

  // ================= UPDATE =================
  void _editFeedback(
    BuildContext context,
    String docId,
    String oldPesan,
  ) {
    final controller = TextEditingController(text: oldPesan);

    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text("Edit Pesan"),
        content: TextField(
          controller: controller,
          maxLines: 3,
          decoration: const InputDecoration(
            border: OutlineInputBorder(),
          ),
        ),
        actions: [
          TextButton(
            child: const Text("Batal"),
            onPressed: () => Navigator.pop(context),
          ),
          ElevatedButton(
            child: const Text("Update"),
            onPressed: () async {
              await FirebaseFirestore.instance
                  .collection('feedback')
                  .doc(docId)
                  .update({
                'pesan': controller.text.trim(),
              });
              Navigator.pop(context);
            },
          ),
        ],
      ),
    );
  }

  // ================= CREATE =================
  void _addFeedback(BuildContext context) {
    final namaController = TextEditingController();
    final pesanController = TextEditingController();

    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text("Tambah Feedback"),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: namaController,
              decoration: const InputDecoration(
                labelText: "Nama",
              ),
            ),
            const SizedBox(height: 10),
            TextField(
              controller: pesanController,
              maxLines: 3,
              decoration: const InputDecoration(
                labelText: "Pesan",
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            child: const Text("Batal"),
            onPressed: () => Navigator.pop(context),
          ),
          ElevatedButton(
            child: const Text("Simpan"),
            onPressed: () async {
              if (namaController.text.trim().isEmpty ||
                  pesanController.text.trim().isEmpty) return;

              await FirebaseFirestore.instance.collection('feedback').add({
                'nama': namaController.text.trim(),
                'pesan': pesanController.text.trim(),
                'createdAt': Timestamp.now(),
              });
              Navigator.pop(context);
            },
          ),
        ],
      ),
    );
  }

  // ================= UI =================
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF2F5F7),
      appBar: AppBar(
        title: const Text("Data Kritik & Saran"),
        centerTitle: true,
        backgroundColor: const Color(0xFF21899C),
      ),

      // ===== CREATE BUTTON =====
      floatingActionButton: FloatingActionButton(
        backgroundColor: const Color(0xFF21899C),
        child: const Icon(Icons.add),
        onPressed: () => _addFeedback(context),
      ),

      body: StreamBuilder<QuerySnapshot>(
        stream: FirebaseFirestore.instance
            .collection('feedback')
            .orderBy('createdAt', descending: true)
            .snapshots(),

        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
            return Center(
              child: Text(
                "Belum ada data masuk",
                style: GoogleFonts.inter(color: Colors.grey),
              ),
            );
          }

          final docs = snapshot.data!.docs;

          return ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: docs.length,
            itemBuilder: (context, index) {
              final doc = docs[index];
              final data = doc.data() as Map<String, dynamic>;

              final nama = data['nama'] ?? '-';
              final pesan = data['pesan'] ?? '-';
              final Timestamp? time = data['createdAt'];

              final tanggal = time != null
                  ? DateFormat('dd MMM yyyy, HH:mm')
                      .format(time.toDate())
                  : '';

              return Container(
                margin: const EdgeInsets.only(bottom: 16),
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(14),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.05),
                      blurRadius: 8,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),

                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        const CircleAvatar(
                          backgroundColor: Color(0xFF21899C),
                          child: Icon(Icons.person, color: Colors.white),
                        ),
                        const SizedBox(width: 12),

                        Expanded(
                          child: Text(
                            nama,
                            style: GoogleFonts.poppins(
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),

                        // ===== UPDATE =====
                        IconButton(
                          icon: const Icon(Icons.edit, color: Colors.orange),
                          onPressed: () =>
                              _editFeedback(context, doc.id, pesan),
                        ),

                        // ===== DELETE =====
                        IconButton(
                          icon: const Icon(Icons.delete, color: Colors.red),
                          onPressed: () => _deleteFeedback(doc.id),
                        ),
                      ],
                    ),

                    const SizedBox(height: 6),

                    Text(
                      tanggal,
                      style: GoogleFonts.inter(
                        fontSize: 11,
                        color: Colors.grey,
                      ),
                    ),

                    const Divider(height: 20),

                    Text(
                      pesan,
                      style: GoogleFonts.inter(fontSize: 14),
                    ),
                  ],
                ),
              );
            },
          );
        },
      ),
    );
  }
}
