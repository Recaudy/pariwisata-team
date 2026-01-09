// import 'package:flutter/material.dart';
// import 'package:cloud_firestore/cloud_firestore.dart';
// import 'package:google_fonts/google_fonts.dart';
// import 'package:intl/intl.dart';

// class AdminFeedbackPage extends StatelessWidget {
//   const AdminFeedbackPage({super.key});

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       backgroundColor: const Color(0xFFF2F5F7),
//       appBar: AppBar(
//         title: const Text("Data Kritik & Saran"),
//         centerTitle: true,
//         elevation: 0,
//         backgroundColor: const Color(0xFF21899C),
//       ),

//       body: StreamBuilder<QuerySnapshot>(
//         stream: FirebaseFirestore.instance
//             .collection('feedback')
//             .orderBy('createdAt', descending: true)
//             .snapshots(),

//         builder: (context, snapshot) {
//           if (snapshot.connectionState == ConnectionState.waiting) {
//             return const Center(
//               child: CircularProgressIndicator(),
//             );
//           }

//           if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
//             return Center(
//               child: Text(
//                 "Belum ada data masuk",
//                 style: GoogleFonts.inter(
//                   fontSize: 16,
//                   color: Colors.grey,
//                 ),
//               ),
//             );
//           }

//           final docs = snapshot.data!.docs;

//           return ListView.builder(
//             padding: const EdgeInsets.all(16),
//             itemCount: docs.length,
//             itemBuilder: (context, index) {
//               final data = docs[index].data() as Map<String, dynamic>;

//               final nama = data['nama'] ?? '-';
//               final pesan = data['pesan'] ?? '-';
//               final Timestamp? time = data['createdAt'];

//               final tanggal = time != null
//                   ? DateFormat('dd MMM yyyy, HH:mm')
//                       .format(time.toDate())
//                   : '';

//               return Container(
//                 margin: const EdgeInsets.only(bottom: 16),
//                 padding: const EdgeInsets.all(16),
//                 decoration: BoxDecoration(
//                   color: Colors.white,
//                   borderRadius: BorderRadius.circular(14),
//                   boxShadow: [
//                     BoxShadow(
//                       color: Colors.black.withOpacity(0.05),
//                       blurRadius: 8,
//                       offset: const Offset(0, 4),
//                     ),
//                   ],
//                 ),

//                 child: Column(
//                   crossAxisAlignment: CrossAxisAlignment.start,
//                   children: [
//                     Row(
//                       children: [
//                         const CircleAvatar(
//                           backgroundColor: Color(0xFF21899C),
//                           child: Icon(Icons.person, color: Colors.white),
//                         ),
//                         const SizedBox(width: 12),
//                         Expanded(
//                           child: Text(
//                             nama,
//                             style: GoogleFonts.poppins(
//                               fontSize: 15,
//                               fontWeight: FontWeight.bold,
//                             ),
//                           ),
//                         ),
//                         Text(
//                           tanggal,
//                           style: GoogleFonts.inter(
//                             fontSize: 11,
//                             color: Colors.grey,
//                           ),
//                         ),
//                       ],
//                     ),

//                     const SizedBox(height: 12),
//                     const Divider(),

//                     Text(
//                       pesan,
//                       style: GoogleFonts.inter(
//                         fontSize: 14,
//                         height: 1.5,
//                       ),
//                     ),
//                   ],
//                 ),
//               );
//             },
//           );
//         },
//       ),
//     );
//   }
// }
