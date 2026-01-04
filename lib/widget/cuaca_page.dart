import 'package:flutter/material.dart';
import '../models/cuaca_model.dart';
import '../services/api_service.dart';
import 'package:intl/intl.dart';

class WeatherPage extends StatefulWidget {
  const WeatherPage({super.key});

  @override
  State<WeatherPage> createState() => _WeatherPageState();
}

class _WeatherPageState extends State<WeatherPage> {
  final ApiService _apiService = ApiService();
  late Future<List<CuacaModel>> _weatherFuture;
  String _selectedLocation = 'Semua';

  final List<String> _filterOptions = [
    'Semua',
    'Bangka',
    'Bangka Selatan',
    'Bangka Tengah',
    'Bangka Barat',
    'Pangkal Pinang',
  ];

  @override
  void initState() {
    super.initState();
    _weatherFuture = _apiService.fetchAllCuaca();
  }

  Widget _buildBMKGIcon(String url, {double size = 50}) {
    return Image.network(
      url,
      width: size,
      height: size,
      fit: BoxFit.contain,
      errorBuilder: (context, error, stackTrace) =>
          Icon(Icons.wb_cloudy_outlined, color: Colors.white, size: size),
    );
  }

  String _formatTime(String dateTimeStr) {
    try {
      return DateFormat('HH:mm').format(DateTime.parse(dateTimeStr));
    } catch (e) {
      return "--:--";
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        title: const Text(
          "Perkiraan Cuaca",
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
        ),
        backgroundColor: Colors.transparent,
        elevation: 0,
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [Color(0xFF21899C), Color(0xFF155E6B), Colors.black],
          ),
        ),
        child: FutureBuilder<List<CuacaModel>>(
          future: _weatherFuture,
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Center(
                child: CircularProgressIndicator(color: Colors.white),
              );
            }
            if (!snapshot.hasData || snapshot.data!.isEmpty) {
              return const Center(
                child: Text(
                  "Data tidak tersedia",
                  style: TextStyle(color: Colors.white),
                ),
              );
            }

            List<CuacaModel> rawData = snapshot.data!;
            List<CuacaModel> displayData = [];

            if (_selectedLocation == 'Semua') {
              // Jika "Semua", ambil 1 data paling mendekati sekarang untuk setiap kabupaten
              for (var locName in ApiService.locations.keys) {
                var locData = rawData
                    .where((e) => e.locationName == locName)
                    .toList();
                if (locData.isNotEmpty) {
                  // Cari yang paling dekat dengan jam sekarang
                  DateTime now = DateTime.now();
                  locData.sort(
                    (a, b) =>
                        (DateTime.parse(
                          a.localDatetime,
                        ).difference(now).inMinutes.abs()).compareTo(
                          DateTime.parse(
                            b.localDatetime,
                          ).difference(now).inMinutes.abs(),
                        ),
                  );
                  displayData.add(locData.first);
                }
              }
            } else {
              // Jika Kabupaten dipilih, tampilkan SEMUA jam untuk kabupaten tersebut
              displayData = rawData
                  .where((e) => e.locationName == _selectedLocation)
                  .toList();
              // Urutkan berdasarkan waktu
              displayData.sort(
                (a, b) => a.localDatetime.compareTo(b.localDatetime),
              );
            }

            final current = displayData.first;

            return SafeArea(
              child: Column(
                children: [
                  // Chips Filter
                  SizedBox(
                    height: 50,
                    child: ListView.builder(
                      scrollDirection: Axis.horizontal,
                      padding: const EdgeInsets.symmetric(horizontal: 15),
                      itemCount: _filterOptions.length,
                      itemBuilder: (context, index) {
                        bool isSelected =
                            _selectedLocation == _filterOptions[index];
                        return Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 5),
                          child: ChoiceChip(
                            label: Text(_filterOptions[index]),
                            selected: isSelected,
                            onSelected: (val) => setState(
                              () => _selectedLocation = _filterOptions[index],
                            ),
                            selectedColor: const Color(0xFF21899C),
                            labelStyle: TextStyle(
                              color: isSelected ? Colors.white : Colors.black,
                            ),
                          ),
                        );
                      },
                    ),
                  ),
                  Expanded(
                    child: RefreshIndicator(
                      onRefresh: () async {
                        setState(() {
                          _weatherFuture = _apiService.fetchAllCuaca();
                        });
                      },
                      child: SingleChildScrollView(
                        physics: const AlwaysScrollableScrollPhysics(),
                        padding: const EdgeInsets.symmetric(horizontal: 20),
                        child: Column(
                          children: [
                            const SizedBox(height: 20),
                            Text(
                              current.locationName,
                              style: const TextStyle(
                                fontSize: 28,
                                color: Colors.white,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            Text(
                              _selectedLocation == 'Semua'
                                  ? "Kondisi Saat Ini"
                                  : "Prakiraan Per Jam",
                              style: const TextStyle(color: Colors.white70),
                            ),
                            const SizedBox(height: 30),
                            _buildBMKGIcon(current.imageUrl, size: 120),
                            Text(
                              "${current.temperature}°C",
                              style: const TextStyle(
                                fontSize: 60,
                                color: Colors.white,
                                fontWeight: FontWeight.w200,
                              ),
                            ),
                            Text(
                              current.weatherDesc,
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 18,
                              ),
                            ),
                            const SizedBox(height: 40),
                            Align(
                              alignment: Alignment.centerLeft,
                              child: Text(
                                _selectedLocation == 'Semua'
                                    ? "Wilayah Bangka Belitung"
                                    : "Jadwal Waktu",
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontSize: 18,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                            const SizedBox(height: 15),
                            ListView.builder(
                              shrinkWrap: true,
                              physics: const NeverScrollableScrollPhysics(),
                              itemCount: displayData.length,
                              itemBuilder: (context, index) {
                                final item = displayData[index];
                                return Container(
                                  margin: const EdgeInsets.only(bottom: 10),
                                  decoration: BoxDecoration(
                                    color: Colors.white.withOpacity(0.1),
                                    borderRadius: BorderRadius.circular(15),
                                  ),
                                  child: ListTile(
                                    leading: _buildBMKGIcon(
                                      item.imageUrl,
                                      size: 40,
                                    ),
                                    title: Text(
                                      _selectedLocation == 'Semua'
                                          ? item.locationName
                                          : _formatTime(item.localDatetime),
                                      style: const TextStyle(
                                        color: Colors.white,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                    subtitle: Text(
                                      item.weatherDesc,
                                      style: const TextStyle(
                                        color: Colors.white70,
                                      ),
                                    ),
                                    trailing: Text(
                                      "${item.temperature}°",
                                      style: const TextStyle(
                                        color: Colors.white,
                                        fontSize: 20,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                  ),
                                );
                              },
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            );
          },
        ),
      ),
    );
  }
}
