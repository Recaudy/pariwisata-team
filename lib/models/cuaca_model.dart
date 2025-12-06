class CuacaModel {
  final String weatherDesc;
  final int temperature;
  final int humidity;
  final String imageUrl;
  final String localDatetime;
  final String locationName;

  CuacaModel({
    required this.weatherDesc,
    required this.temperature,
    required this.humidity,
    required this.imageUrl,
    required this.localDatetime,
    required this.locationName,
  });

  factory CuacaModel.fromjson(Map<String, dynamic> json, String locationName) {
    return CuacaModel(
      weatherDesc: json['weather_desc'] ?? '-',
      temperature: json['t'] ?? 0,
      humidity: json['hu'] ?? 0,
      imageUrl: json['image'] ?? '',
      localDatetime: json['local_datetime'] ?? '',
      locationName: locationName,
    );
  }
}
