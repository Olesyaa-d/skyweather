
import 'dart:convert';
import 'package:http/http.dart' as http;

class CitySearchResult {
  final String name;
  final String country;
  final String region;
  final double latitude;
  final double longitude;

  const CitySearchResult({
    required this.name,
    required this.country,
    required this.region,
    required this.latitude,
    required this.longitude,
  });

  String get displayName {
    if (region.isNotEmpty && region != name) {
      return '$name, $region, $country';
    }
    return '$name, $country';
  }
}

class CitySearchService {
  final http.Client _client = http.Client();

  Future<List<CitySearchResult>> search(String query) async {
    if (query.trim().length < 2) {
      return [];
    }

    final uri = Uri.https(
      'geocoding-api.open-meteo.com',
      '/v1/search',
      {
        'name': query.trim(),
        'count': '10',
        'language': 'ru',
        'format': 'json',
      },
    );

    final response = await _client.get(uri).timeout(
      const Duration(seconds: 10),
    );

    if (response.statusCode != 200) {
      throw Exception('Ошибка поиска городов');
    }

    final data = jsonDecode(
      utf8.decode(response.bodyBytes),
    ) as Map<String, dynamic>;

    final results = data['results'] as List?;

    if (results == null) return [];

    return results.map((item) {
      final json = item as Map<String, dynamic>;

      return CitySearchResult(
        name: json['name']?.toString() ?? '',
        country: json['country']?.toString() ?? '',
        region: json['admin1']?.toString() ?? '',
        latitude: (json['latitude'] as num).toDouble(),
        longitude: (json['longitude'] as num).toDouble(),
      );
    }).toList();
  }

  void dispose() {
    _client.close();
  }
}
