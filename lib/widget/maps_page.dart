import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'package:url_launcher/url_launcher.dart';

class MapsPage extends StatefulWidget {
  const MapsPage({super.key});

  @override
  State<MapsPage> createState() => _MapsPageState();
}

class _MapsPageState extends State<MapsPage> {
  final MapController _mapController = MapController();
  Map<String, dynamic>? selectedPlace;

  bool isSearchOpen = false;
  String searchQuery = "";

  final Color mainColor = Color(0xFF21899C);
  final Color subColor = Color(0xFFE6F4F6);

  final List<Map<String, dynamic>> locations = const [
    {
      "name": "Pantai Pasir Padi",
      "address": "Kecamatan Bukit Intan, Pangkalpinang",
      "latLng": LatLng(-2.106942848530887, 106.16878602717921),
    },
    {
      "name": "Pantai Matras",
      "address": "Kecamatan Sungailiat, Kabupaten Bangka",
      "latLng": LatLng(-1.7978687693481579, 106.11636867536374),
    },
    {
      "name": "Pantai Tanjung Kerasak",
      "address": "Kecamatan Tukak Sadai, Kabupaten Bangka Selatan",
      "latLng": LatLng(-3.0548758970315846, 106.74316739843276),
    },
    {
      "name": "Bukit Kejora",
      "address": "Kecamatan Pangkalan Baru, Kabupaten Bangka Tengah",
      "latLng": LatLng(-2.1820155030142465, 106.13522475267702),
    },
    {
      "name": "Bukit Maras",
      "address": "Kecamatan Riau Silip, Kabupaten Bangka",
      "latLng": LatLng(-1.8336312440562827, 105.84159851329234),
    },
    {
      "name": "Bukit Padding",
      "address": "Kecamatan Lubuk Besar, Kabupaten Bangka Tengah",
      "latLng": LatLng(-2.5467512002369315, 106.56034181335721),
    },
    {
      "name": "Masjid Kubah Timas",
      "address": "Kecamatan Taman Sari, Pangkal Pinang",
      "latLng": LatLng(-2.119753127003898, 106.11407430258862),
    },
    {
      "name": "Taman Bintang Samudra",
      "address": "Kecamatan Sungailiat, Kabupaten Bangka",
      "latLng": LatLng(-1.9073499775994558, 106.1779263815125),
    },
    {
      "name": "Pagoda",
      "address": "Kecamatan Sungailiat, Kabupaten Bangka",
      "latLng": LatLng(-1.9090542862269024, 106.15757919500336),
    },
    {
      "name": "Pantai Tanjung Tinggi",
      "address": "Kecamatan Sijuk, Kabupaten Belitung",
      "latLng": LatLng(-2.5518940508880505, 107.71391586021156),
    },
    {
      "name": "Bukit Gadong",
      "address": "Kecamatan Membalong, Kabupaten Belitung Timur",
      "latLng": LatLng(-3.0369618430755274, 107.6585761227977),
    },
  ];

  Future<void> openInGoogleMaps(double lat, double lng) async {
    final url = Uri.parse(
      "https://www.google.com/maps/dir/?api=1&destination=$lat,$lng",
    );
    if (await canLaunchUrl(url)) {
      await launchUrl(url, mode: LaunchMode.externalApplication);
    }
  }

  @override
  Widget build(BuildContext context) {
    const LatLng center = LatLng(-1.87, 106.15);

    final filteredLocations = locations
        .where(
          (place) =>
              place["name"].toLowerCase().contains(searchQuery.toLowerCase()),
        )
        .toList();

    final int resultHeight = (isSearchOpen && searchQuery.isNotEmpty)
        ? (filteredLocations.isEmpty ? 80 : 240)
        : 0;

    final double screenWidth = MediaQuery.of(context).size.width;
    final double searchBarWidth = isSearchOpen ? screenWidth - 30 : 60;

    return Scaffold(
      body: Stack(
        children: [
          FlutterMap(
            mapController: _mapController,
            options: const MapOptions(initialCenter: center, initialZoom: 12),
            children: [
              TileLayer(
                urlTemplate: "https://tile.openstreetmap.org/{z}/{x}/{y}.png",
              ),
              MarkerLayer(
                markers: locations.map((place) {
                  return Marker(
                    point: place['latLng'],
                    width: 120,
                    height: 90,
                    child: GestureDetector(
                      onTap: () => setState(() => selectedPlace = place),
                      child: Column(
                        children: [
                          _markerLabel(place['name']),
                          Icon(Icons.location_pin, size: 50, color: mainColor),
                        ],
                      ),
                    ),
                  );
                }).toList(),
              ),
            ],
          ),

          Positioned(
            top: 20,
            left: 15,
            right: 15,
            child: Column(
              children: [
                AnimatedSize(
                  duration: const Duration(milliseconds: 220),
                  curve: Curves.easeInOut,
                  child: Container(
                    height: 50,
                    width: searchBarWidth,
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: Colors.grey.shade200),
                      boxShadow: const [
                        BoxShadow(color: Colors.black26, blurRadius: 6),
                      ],
                    ),
                    child: Row(
                      children: [
                        AnimatedSwitcher(
                          duration: const Duration(milliseconds: 220),
                          child: GestureDetector(
                            key: ValueKey<bool>(isSearchOpen),
                            onTap: () {
                              setState(() {
                                if (isSearchOpen) searchQuery = "";
                                isSearchOpen = !isSearchOpen;
                              });
                            },
                            child: Padding(
                              padding: const EdgeInsets.all(12),
                              child: Icon(
                                isSearchOpen ? Icons.close : Icons.search,
                                color: mainColor,
                              ),
                            ),
                          ),
                        ),
                        if (isSearchOpen)
                          Expanded(
                            child: TextField(
                              autofocus: true,
                              decoration: const InputDecoration(
                                hintText: "Cari lokasi wisata...",
                                border: InputBorder.none,
                              ),
                              cursorColor: mainColor,
                              onChanged: (value) =>
                                  setState(() => searchQuery = value),
                            ),
                          ),
                      ],
                    ),
                  ),
                ),

                AnimatedSize(
                  duration: const Duration(milliseconds: 200),
                  curve: Curves.easeInOut,
                  child: Container(
                    height: resultHeight.toDouble(),
                    width: double.infinity,
                    margin: const EdgeInsets.only(top: 8),
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(12),
                      child: resultHeight == 0
                          ? const SizedBox.shrink()
                          : _buildSearchListWithContainer(filteredLocations),
                    ),
                  ),
                ),
              ],
            ),
          ),

          if (selectedPlace != null) _buildBottomSheet(),
        ],
      ),
    );
  }

  Widget _markerLabel(String name) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 2, horizontal: 6),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(6),
        boxShadow: const [BoxShadow(color: Colors.black26, blurRadius: 3)],
      ),
      child: Text(
        name.length > 18 ? "${name.substring(0, 18)}..." : name,
        textAlign: TextAlign.center,
        style: const TextStyle(fontSize: 11, fontWeight: FontWeight.bold),
      ),
    );
  }

  Widget _buildSearchListWithContainer(List filtered) {
    if (filtered.isEmpty) {
      return Container(
        color: Colors.white,
        alignment: Alignment.center,
        padding: const EdgeInsets.symmetric(horizontal: 16),
        child: Text(
          "Maaf, tempat tidak ditemukan",
          style: TextStyle(
            fontSize: 14,
            color: Colors.grey[700],
            fontWeight: FontWeight.w500,
          ),
        ),
      );
    }

    return Container(
      color: Colors.white,
      child: ListView.builder(
        padding: EdgeInsets.zero,
        itemCount: filtered.length,
        itemBuilder: (_, i) {
          final place = filtered[i];
          return ListTile(
            title: Text(place["name"]),
            subtitle: Text(place["address"]),
            onTap: () {
              _mapController.move(place["latLng"], 15);
              setState(() {
                selectedPlace = place;
                searchQuery = "";
                isSearchOpen = false;
              });
            },
          );
        },
      ),
    );
  }

  Widget _buildBottomSheet() {
    return Positioned(
      left: 0,
      right: 0,
      bottom: 0,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 250),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [subColor, mainColor],
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          ),
          borderRadius: BorderRadius.vertical(top: Radius.circular(22)),
          boxShadow: [
            BoxShadow(
              blurRadius: 12,
              color: Colors.black26,
              offset: Offset(0, -4),
            ),
          ],
        ),

        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 45,
              height: 5,
              decoration: BoxDecoration(
                color: mainColor,
                borderRadius: BorderRadius.circular(40),
              ),
            ),
            const SizedBox(height: 20),
            Text(
              selectedPlace!['name'],
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: mainColor,
              ),
            ),
            Text(
              selectedPlace!['address'],
              style: TextStyle(fontSize: 15, color: Colors.grey[700]),
            ),
            const SizedBox(height: 16),
            SizedBox(
              width: 130,
              child: ElevatedButton.icon(
                style: ElevatedButton.styleFrom(
                  backgroundColor: mainColor,
                  foregroundColor: Colors.white,
                ),
                icon: const Icon(Icons.directions),
                label: const Text("Telusuri"),
                onPressed: () {
                  final pos = selectedPlace!['latLng'];
                  openInGoogleMaps(pos.latitude, pos.longitude);
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
