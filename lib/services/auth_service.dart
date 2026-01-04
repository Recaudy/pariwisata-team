import 'dart:io';
import 'package:firebase_auth/firebase_auth.dart' as fb;
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../models/user_model.dart';

class AuthService {
  final fb.FirebaseAuth _auth = fb.FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final _supabase = Supabase.instance.client;

  // --- AMBIL DATA USER SAAT INI ---
  Future<UserModel?> getCurrentUserData() async {
    try {
      fb.User? firebaseUser = _auth.currentUser;
      if (firebaseUser == null) return null;

      DocumentSnapshot doc = await _firestore
          .collection('users')
          .doc(firebaseUser.uid)
          .get();

      if (doc.exists) {
        return UserModel.fromMap(doc.data() as Map<String, dynamic>);
      }
      return null;
    } catch (e) {
      return null;
    }
  }

  // --- LOGIN DENGAN PERBAIKAN ROLE CHECK ---
  Future<String?> login({
    required String email,
    required String password,
  }) async {
    try {
      fb.UserCredential userCredential = await _auth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );

      String uid = userCredential.user!.uid;

      // Terkadang Firestore butuh waktu sinkronisasi setelah login
      // Kita coba ambil data dokumen user
      DocumentSnapshot userDoc = await _firestore
          .collection('users')
          .doc(uid)
          .get();

      // Jika dokumen tidak ditemukan, kita tunggu 1 detik dan coba sekali lagi
      if (!userDoc.exists) {
        await Future.delayed(const Duration(seconds: 1));
        userDoc = await _firestore.collection('users').doc(uid).get();
      }

      if (userDoc.exists) {
        Map<String, dynamic> data = userDoc.data() as Map<String, dynamic>;
        if (data.containsKey('role')) {
          return data['role']; // Mengembalikan 'Admin' atau 'User'
        }
        return "Role field missing";
      }

      return "Data profil tidak ditemukan di database";
    } on fb.FirebaseAuthException catch (e) {
      return e.message;
    } catch (e) {
      return e.toString();
    }
  }

  // --- SIGNUP ---
  Future<String?> signup({
    required String name,
    required String email,
    required String password,
    required String role,
  }) async {
    try {
      fb.UserCredential userCredential = await _auth
          .createUserWithEmailAndPassword(email: email, password: password);

      // Simpan ke Firestore dengan UID sebagai Document ID
      await _firestore.collection('users').doc(userCredential.user!.uid).set({
        'uid': userCredential.user!.uid,
        'name': name,
        'email': email,
        'role': role,
        'photoUrl': '',
        'createdAt': FieldValue.serverTimestamp(), 
      });

      return null; // Sukses
    } on fb.FirebaseAuthException catch (e) {
      return e.message;
    } catch (e) {
      return e.toString();
    }
  }


  Future<String?> uploadProfilePicture(String filePath) async {
    try {
      fb.User? user = _auth.currentUser;
      if (user == null) return "User tidak login";

      File file = File(filePath);
      final String fileName = 'profil/${user.uid}.jpg';

      // 1. Upload ke Supabase Storage (Pastikan Bucket 'avatars' sudah ada dan PUBLIC)
      await _supabase.storage
          .from('profil')
          .upload(
            fileName,
            file,
            fileOptions: const FileOptions(cacheControl: '3600', upsert: true),
          );

      // 2. Ambil URL Publik
      final String publicUrl = _supabase.storage
          .from('profil')
          .getPublicUrl(fileName);

      // 3. Update link di Firestore agar tersinkron ke semua widget
      await _firestore.collection('users').doc(user.uid).update({
        'photoUrl': publicUrl,
      });

      return publicUrl;
    } catch (e) {
      return e.toString();
    }
  }


  Future<String?> updateUserName(String newName) async {
    try {
      final user = _auth.currentUser;
      if (user != null) {
        await _firestore.collection('users').doc(user.uid).update({
          'name': newName,
        });
      }
      return null;
    } catch (e) {
      return e.toString();
    }
  }


  Future<String?> updatePassword(String newPassword) async {
    try {
      final user = _auth.currentUser;
      if (user != null) {
        await user.updatePassword(newPassword);
        return null;
      }
      return "User tidak ditemukan";
    } on fb.FirebaseAuthException catch (e) {
      return e.message;
    } catch (e) {
      return e.toString();
    }
  }


  Future<void> signOut() async {
    await _auth.signOut();
  }
}
