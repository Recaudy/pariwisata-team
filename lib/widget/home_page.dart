import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart'; 
import 'package:project_uts_pariwisata/models/popular_model.dart';
import 'package:project_uts_pariwisata/models/recomend_model.dart';
import 'package:project_uts_pariwisata/widget/pemesanan_page.dart';
import 'package:project_uts_pariwisata/widget/profile_page.dart';
import 'package:project_uts_pariwisata/widget/saran_page.dart';

import '../services/api_service.dart';
import '../models/cuaca_model.dart';

class WeatherCardRow extends StatelessWidget {
  final ApiService apiService = ApiService();

  WeatherCardRow({super.key});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SizedBox(
          height: 140,
          child: FutureBuilder<List<CuacaModel>>(
            future: apiService.fetchCuacaHariIni(),
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return const Center(child: CircularProgressIndicator());
              } else if (snapshot.hasError) {
                return Center(
                  child: Text(
                    'Gagal: ${snapshot.error}',
                    style: const TextStyle(color: Colors.red),
                  ),
                );
              } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
                return const Center(
                  child: Text('Tidak ada data cuaca saat ini.'),
                );
              } else {
                final allCuaca = snapshot.data!;

                final Map<String, CuacaModel> distinctCuaca = {};
                for (var cuaca in allCuaca) {
                  if (!distinctCuaca.containsKey(cuaca.locationName)) {
                    distinctCuaca[cuaca.locationName] = cuaca;
                  }
                }
                final cuacaList = distinctCuaca.values.toList();

                return ListView.builder(
                  scrollDirection: Axis.horizontal,
                  itemCount: cuacaList.length,
                  itemBuilder: (context, index) {
                    final cuaca = cuacaList[index];

                    String locationShort = cuaca.locationName
                        .split('(')[0]
                        .trim();

                    return Container(
                      width: 130,
                      margin: EdgeInsets.only(
                        left: index == 0 ? 20 : 8,
                        right: index == cuacaList.length - 1 ? 20 : 0,
                      ),
                      child: Card(
                        color: Colors.white,
                        elevation: 4,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Padding(
                          padding: const EdgeInsets.all(8.0),
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              cuaca.imageUrl.endsWith('.svg')
                                  ? SvgPicture.network(
                                      cuaca.imageUrl,
                                      width: 32,
                                      height: 32,
                                      placeholderBuilder: (context) =>
                                          const SizedBox(width: 32, height: 32),
                                      fit: BoxFit.contain,
                                    )
                                  : Image.network(
                                      cuaca.imageUrl,
                                      width: 32,
                                      height: 32,
                                      fit: BoxFit.contain,
                                      errorBuilder:
                                          (context, error, stackTrace) =>
                                              const Icon(
                                                Icons.cloud_off,
                                                size: 32,
                                                color: Colors.grey,
                                              ),
                                    ),

                              const SizedBox(height: 4),

                              Text(
                                '${cuaca.temperature}°C',
                                style: const TextStyle(
                                  fontSize: 20,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.black87,
                                ),
                              ),

                              Text(
                                locationShort,
                                textAlign: TextAlign.center,
                                style: TextStyle(
                                  fontSize: 12,
                                  fontWeight: FontWeight.w600,
                                  color: Colors.blue[800],
                                ),
                                overflow: TextOverflow.ellipsis,
                              ),

                              Text(
                                cuaca.weatherDesc,
                                textAlign: TextAlign.center,
                                style: const TextStyle(
                                  fontSize: 10,
                                  color: Colors.grey,
                                ),
                                overflow: TextOverflow.ellipsis,
                              ),
                            ],
                          ),
                        ),
                      ),
                    );
                  },
                );
              }
            },
          ),
        ),
      ],
    );
  }
}
// --- End Weather Widget ---

class HomePageWidget extends StatefulWidget {
  const HomePageWidget({super.key});

  @override
  State<HomePageWidget> createState() => _HomePageWidgetState();
}

class _HomePageWidgetState extends State<HomePageWidget> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[100],
      appBar: AppBar(backgroundColor: Colors.grey[100], elevation: 0),

      // drawer start
      drawer: Drawer(
        child: Container(
          color: Colors.grey[100],
          padding: const EdgeInsets.all(24),
          child: Wrap(
            runSpacing: 16,
            children: [
              // Placeholder for user's profile icon/header
              const DrawerHeader(
                decoration: BoxDecoration(color: Colors.blueAccent),
                child: Text(
                  'Menu Pariwisata',
                  style: TextStyle(color: Colors.white, fontSize: 24),
                ),
              ),
              ListTile(
                leading: const Icon(Icons.person),
                title: const Text("Profil"),
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => const InformasiProfil(),
                    ),
                  );
                },
              ),
              ListTile(
                leading: const Icon(Icons.feedback_outlined),
                title: const Text("Recommend"),
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => const MyCustomForm(),
                    ),
                  );
                },
              ),
              ListTile(
                leading: const Icon(Icons.credit_card),
                title: const Text("Order"),
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => const InfoPemesanan(),
                    ),
                  );
                },
              ),
            ],
          ),
        ),
      ),

      // drawer end
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Search Bar
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 15, horizontal: 20),
              child: Container(
                padding: const EdgeInsets.symmetric(
                  vertical: 5,
                  horizontal: 10,
                ),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(24),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.grey.withOpacity(0.3),
                      spreadRadius: 1,
                      blurRadius: 5,
                      offset: const Offset(0, 3),
                    ),
                  ],
                ),
                child: const TextField(
                  decoration: InputDecoration(
                    hintText: "Temukan Tempat ",
                    border: InputBorder.none,
                    prefixIcon: Icon(Icons.search, color: Colors.blue),
                  ),
                ),
              ),
            ),

            // ===========================================
            // NEW: Weather Section (Below Search, Above Populer)
            // ===========================================
            WeatherCardRow(), // <-- WIDGET CUACA DIMASUKKAN DI SINI
            // Populer Start
            const SizedBox(height: 20),
            const Padding(
              padding: EdgeInsets.symmetric(horizontal: 20),
              child: Text(
                "Populer",
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
            ),

            SizedBox(
              height: 300,
              child: ListView(
                scrollDirection: Axis.horizontal,
                children: [
                  PopularCard(
                    title: "Borobudur Temple",
                    title2: "Magelang,Jawa Tengah",
                    image: "assets/images/borobudur.jpg",
                  ),
                  PopularCard(
                    title: "Pantai Kuta",
                    title2: "Bali",
                    image: "assets/images/kuta.jpg",
                  ),
                  PopularCard(
                    title: " Gunung Rinjani",
                    title2: "Lombok,Nusa Tenggara timur",
                    image: "assets/images/rinjani.jpg",
                  ),
                  PopularCard(
                    title: " Pantai Nihiwatu",
                    title2: "Sumba,Nusa Tenggara timur",
                    image: "assets/images/nihiwatu.jpg",
                  ),
                  PopularCard(
                    title: "Borobudur Temple",
                    title2: "Yogyakarta",
                    image: "assets/images/borobudur.jpg",
                  ),
                ],
              ),
            ),
            // Populer End

            // Rekomendasi Start
            const SizedBox(height: 20),
            const Padding(
              padding: EdgeInsets.symmetric(horizontal: 20),
              child: Text(
                "Recomend",
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
            ),

            SizedBox(
              height: 140,
              child: ListView(
                scrollDirection: Axis.horizontal,
                children: [
                  RecomendCard(
                    title: "Borobudur Temple",
                    title2: "Yogyakarta",
                    image: "assets/images/borobudur.jpg",
                  ),
                  RecomendCard(
                    title: "Pantai Kuta",
                    title2: "Bali",
                    image: "assets/images/kuta.jpg",
                  ),
                  RecomendCard(
                    title: " Gunung Rinjani",
                    title2: "Lombok,Nusa Tenggara timur",
                    image: "assets/images/rinjani.jpg",
                  ),
                  RecomendCard(
                    title: " Pantai Nihiwatu",
                    title2: "Sumba,Nusa Tenggara timur",
                    image: "assets/images/nihiwatu.jpg",
                  ),
                  RecomendCard(
                    title: "Borobudur Temple",
                    title2: "Magelang,Jawa Tengah",
                    image: "assets/images/borobudur.jpg",
                  ),
                ],
              ),
            ),
            // rekomendasi end
            const SizedBox(height: 40),
          ],
        ),
      ),
    );
  }
}
