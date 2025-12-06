import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/cuaca_model.dart';

class ApiService {
  static const Map<String, String> locations = {
    'Bangka': '19.01.01.1001',
    'Bangka Selatan': '19.03.01.1001',
    'Bangka Tengah': '19.04.01.1001',
    'Bangka Barat': '19.05.01.1001',
    'Pangkal Pinang': '19.71.04.1005',
  };
 
  Future<List<CuacaModel>> _fetchCuacaForLocation(
    String adm4Code,
    String locationName,
  ) async {
    final url = 'https://api.bmkg.go.id/publik/prakiraan-cuaca?adm4=$adm4Code';

    try {
      final response = await http.get(Uri.parse(url));

      if (response.statusCode == 200) {
        final data = json.decode(response.body);

        if (data['data'] == null ||
            data['data'].isEmpty ||
            data['data'][0]['cuaca'] == null) {
          return [];
        }

        List<dynamic> allCuaca = (data['data'][0]['cuaca'] as List)
            .expand((e) => e)
            .toList();

        String today = DateTime.now().toIso8601String().substring(0, 10);
        List<CuacaModel> result = allCuaca
            .where(
              (item) =>
                  item['local_datetime'] != null &&
                  item['local_datetime'].substring(0, 10) == today,
            )
            .map(
              (item) => CuacaModel.fromjson(item, locationName),
            ) 
            .toList();
        return result;
      } else {
        print(
          'Failed to load weather data for $locationName. Status Code: ${response.statusCode}',
        );
        return [];
      }
    } catch (e) {
      print('An exception occurred while fetching data for $locationName: $e');
      return [];
    }
  }

  Future<List<CuacaModel>> fetchCuacaHariIni() async {
    List<Future<List<CuacaModel>>> futures = [];

    locations.forEach((name, code) {
      futures.add(_fetchCuacaForLocation(code, name));
    });

    List<List<CuacaModel>> allResults = await Future.wait(futures);

    List<CuacaModel> combinedList = allResults.expand((list) => list).toList();

    combinedList.sort((a, b) {
      try {
        DateTime timeA = DateTime.parse(a.localDatetime);
        DateTime timeB = DateTime.parse(b.localDatetime);
        return timeA.compareTo(timeB);
      } catch (e) {
        return 0;
      }
    });

    return combinedList;
  }
}
