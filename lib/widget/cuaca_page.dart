import 'package:flutter/material.dart';
import 'package:project_uts_pariwisata/components/custom_drawer.dart';
import '../models/cuaca_model.dart';
import '../services/api_service.dart';
import 'package:intl/intl.dart';
import 'package:google_fonts/google_fonts.dart';

class AppColors {
  static const Color primary = Color(0xFF21899C);
  static const Color secondary = Color(0xFF4DA1B0);
  static const Color accent = Color(0xFFF56B3F);
  static const Color highlight = Color(0xFFF9CA58);
}

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

  Widget _getWeatherIcon(
    String weatherDesc, {
    double size = 50,
    Color color = Colors.white,
  }) {
    String desc = weatherDesc.toLowerCase();
    if (desc.contains('cerah') && !desc.contains('berawan')) {
      return Icon(
        Icons.wb_sunny_rounded,
        size: size,
        color: AppColors.highlight,
      );
    } else if (desc.contains('hujan')) {
      return Icon(Icons.umbrella_rounded, 
      size: size, color: color);
    } else if (desc.contains('berawan')) {
      return Icon(Icons.cloud_rounded, 
      size: size, color: color);
    } else if (desc.contains('petir')) {
      return Icon(Icons.thunderstorm_rounded, 
      size: size, color: color);
    } else {
      return Icon(Icons.wb_cloudy_rounded, 
      size: size, color: color);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF2F5F7),
      appBar: AppBar(
        backgroundColor: AppColors.primary,
        elevation: 0,
        centerTitle: true,
        leading: IconButton(
          icon: const Icon(
            Icons.arrow_back_ios_new,
            color: Colors.white,
            size: 20,
          ),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          "INFO CUACA BANGKA BELITUNG",
          style: GoogleFonts.poppins(
            fontWeight: FontWeight.bold,
            fontSize: 16,
            color: Colors.white,
          ),
        ),
      ),
      body: FutureBuilder<List<CuacaModel>>(
        future: _weatherFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(
              child: CircularProgressIndicator(color: AppColors.primary),
            );
          }
          if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return const Center(child: Text("Data Cuaca Tidak Ditemukan"));
          }

          List<CuacaModel> rawData = snapshot.data!;
          List<CuacaModel> displayData = [];

          if (_selectedLocation == 'Semua') {
            for (var locName in ApiService.locations.keys) {
              var locData = rawData
                  .where((e) => e.locationName == locName)
                  .toList();
              if (locData.isNotEmpty) {
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
            displayData = rawData
                .where((e) => e.locationName == _selectedLocation)
                .toList();
            displayData.sort(
              (a, b) => a.localDatetime.compareTo(b.localDatetime),
            );
          }

          final current = displayData.first;
          return Column(
            children: [
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(20),
                decoration: const BoxDecoration(
                  gradient: LinearGradient(
                    colors: [AppColors.primary, AppColors.secondary],
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                  ),
                  borderRadius: BorderRadius.only(
                    bottomLeft: Radius.circular(30),
                    bottomRight: Radius.circular(30),
                  ),
                ),
                child: Column(
                  children: [
                    SizedBox(
                      height: 40,
                      child: ListView.builder(
                        scrollDirection: Axis.horizontal,
                        itemCount: _filterOptions.length,
                        itemBuilder: (context, index) {
                          bool isSelected =
                              _selectedLocation == _filterOptions[index];
                          return GestureDetector(
                            onTap: () => setState(
                              () => _selectedLocation = _filterOptions[index],
                            ),
                            child: Container(
                              margin: const EdgeInsets.only(right: 10),
                              padding: const EdgeInsets.symmetric(
                                horizontal: 18,
                              ),
                              decoration: BoxDecoration(
                                color: isSelected
                                    ? AppColors.highlight
                                    : Colors.white.withOpacity(0.2),
                                borderRadius: BorderRadius.circular(20),
                              ),
                              alignment: Alignment.center,
                              child: Text(
                                _filterOptions[index],
                                style: TextStyle(
                                  fontSize: 12,
                                  fontWeight: isSelected
                                      ? FontWeight.bold
                                      : FontWeight.normal,
                                  color: isSelected
                                      ? AppColors.primary
                                      : Colors.white,
                                ),
                              ),
                            ),
                          );
                        },
                      ),
                    ),
                    const SizedBox(height: 30),
                    Text(
                      current.locationName,
                      style: GoogleFonts.poppins(
                        fontSize: 26,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                    const SizedBox(height: 15),
                    _getWeatherIcon(current.weatherDesc, size: 100),
                    const SizedBox(height: 10),
                    Text(
                      "${current.temperature}°C",
                      style: GoogleFonts.poppins(
                        fontSize: 60,
                        fontWeight: FontWeight.w200,
                        color: Colors.white,
                      ),
                    ),
                    Text(
                      current.weatherDesc.toUpperCase(),
                      style: GoogleFonts.inter(
                        letterSpacing: 2,
                        color: Colors.white.withOpacity(0.8),
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              ),
              Expanded(
                child: ListView.builder(
                  padding: const EdgeInsets.all(20),
                  itemCount: displayData.length,
                  itemBuilder: (context, index) {
                    final item = displayData[index];
                    String timeLabel;
                    try {
                      timeLabel = DateFormat(
                        'HH:mm',
                      ).format(DateTime.parse(item.localDatetime));
                    } catch (e) {
                      timeLabel = "--:--";
                    }
                    return Container(
                      margin: const EdgeInsets.only(bottom: 12),
                      padding: const EdgeInsets.all(15),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(15),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.05),
                            blurRadius: 8,
                            offset: const Offset(0, 4),
                          ),
                        ],
                      ),
                      child: Row(
                        children: [
                          _getWeatherIcon(
                            item.weatherDesc,
                            size: 35,
                            color: AppColors.secondary,
                          ),
                          const SizedBox(width: 15),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  _selectedLocation == 'Semua'
                                      ? item.locationName
                                      : "Pukul $timeLabel WIB",
                                  style: GoogleFonts.poppins(
                                    fontWeight: FontWeight.bold,
                                    fontSize: 14,
                                    color: AppColors.primary,
                                  ),
                                ),
                                Text(
                                  item.weatherDesc,
                                  style: const TextStyle(
                                    fontSize: 12,
                                    color: Colors.grey,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          Text(
                            "${item.temperature}°",
                            style: GoogleFonts.poppins(
                              fontSize: 22,
                              fontWeight: FontWeight.bold,
                              color: AppColors.accent,
                            ),
                          ),
                        ],
                      ),
                    );
                  },
                ),
              ),
              Container(
                margin: EdgeInsets.all(20),
                padding: EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: Color(0xFF21899C),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Center(
                  child: Text(
                    'Anda Bisa melihat informasi cuaca saat ini supaya perjalanan anda tetap nyaman',
                    textAlign: TextAlign.justify,
                    style: GoogleFonts.poppins(
                      fontSize: 13,
                      color: Colors.white,
                    ),
                  ),
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}
