import 'package:flutter/material.dart';
import 'package:lottie/lottie.dart';
import 'package:google_fonts/google_fonts.dart';
import 'maps_page.dart';

// 4 WARNA UTAMA APLIKASI
class AppColors {
  static const Color primary = Color(0xFF21899C); // Teal Tua
  static const Color secondary = Color(0xFF4DA1B0); // Teal Muda
  static const Color accent = Color(0xFFF56B3F); // Oranye
  static const Color highlight = Color(0xFFF9CA58); // Kuning Cerah
}

class WelcomePage extends StatelessWidget {
  const WelcomePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        width: double.infinity,
        height: double.infinity,
        // GRADIENT MENGGUNAKAN TEAL TUA DAN TEAL MUDA
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [AppColors.primary, Color(0xFFE6F4F6)],
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          ),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // 1. ANIMASI LOTTIE
            Lottie.asset(
              "assets/lottie/Gps.json", 
              height: 280, 
              width: 280,
              fit: BoxFit.contain,
            ),
            
            const SizedBox(height: 10),

            // 2. JUDUL UTAMA
            Text(
              "Jelajahi",
              style: GoogleFonts.poppins(
                fontSize: 42,
                fontWeight: FontWeight.bold,
                color: Colors.white,
                letterSpacing: 1.2,
                shadows: [
                  Shadow(
                    color: Colors.black.withOpacity(0.2),
                    blurRadius: 10,
                    offset: const Offset(0, 5),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 15),

            // 3. DESKRIPSI (TEKS DASAR)
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 40),
              child: Text(
                "Cari lokasi wisata favorit Anda dengan mudah dan dapatkan informasi lengkap di Bangka Belitung",
                textAlign: TextAlign.center,
                style: GoogleFonts.inter(
                  fontSize: 16,
                  height: 1.5,
                  color: AppColors.primary.withOpacity(0.8),
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),

            const SizedBox(height: 60),

            // 4. TOMBOL JELAJAH MANUAL (GESTURE DETECTOR + CONTAINER)
            GestureDetector(
              onTap: () {
                Navigator.pushReplacement(
                  context,
                  MaterialPageRoute(builder: (_) => const MapsPage()),
                );
              },
              child: Container(
                width: 220,
                height: 55,
                decoration: BoxDecoration(
                  color: Colors.white, // Latar putih agar kontras dengan gradient
                  borderRadius: BorderRadius.circular(30),
                  boxShadow: [
                    BoxShadow(
                      color: AppColors.primary.withOpacity(0.3),
                      blurRadius: 15,
                      offset: const Offset(0, 8),
                    ),
                  ],
                ),
                child: Center(
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        "Jelajahi Sekarang",
                        style: GoogleFonts.poppins(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: AppColors.primary,
                        ),
                      ),
                      const SizedBox(width: 8),
                      const Icon(
                        Icons.arrow_forward_rounded,
                        color: AppColors.primary,
                        size: 20,
                      ),
                    ],
                  ),
                ),
              ),
            ),
            
            const SizedBox(height: 20),
            
            // AKSEN KECIL DI BAWAH (OPSIONAL UNTUK MEMPERCANTIK)
            Container(
              width: 50,
              height: 5,
              decoration: BoxDecoration(
                color: AppColors.highlight,
                borderRadius: BorderRadius.circular(10),
              ),
            ),
          ],
        ),
      ),
    );
  }
}