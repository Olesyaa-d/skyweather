
import 'dart:convert';
import 'package:http/http.dart' as http;

class WeatherData {
  final String city;
  final double temperature;
  final int humidity;
  final double windSpeed;
  final int weatherCode;

  const WeatherData({
    required this.city,
    required this.temperature,
    required this.humidity,
    required this.windSpeed,
    required this.weatherCode,
  });

  String get description {
    if (weatherCode == 0) return 'Ясно';
    if (weatherCode <= 3) return 'Облачно';
    if (weatherCode <= 48) return 'Туман';
    if (weatherCode <= 67) return 'Дождь';
    if (weatherCode <= 77) return 'Снег';
    if (weatherCode <= 82) return 'Ливень';
    if (weatherCode <= 86) return 'Снегопад';
    if (weatherCode >= 95) return 'Гроза';
    return 'Переменная погода';
  }
}

class WeatherService {
  final http.Client client;

  WeatherService({http.Client? client})
      : client = client ?? http.Client();

  Future<WeatherData> getWeather(String city) async {
    final geoUri = Uri.https(
      'geocoding-api.open-meteo.com',
      '/v1/search',
      {
        'name': city,
        'count': '1',
        'language': 'ru',
        'format': 'json',
      },
    );

    final geoResponse = await client.get(geoUri).timeout(
      const Duration(seconds: 12),
    );

    if (geoResponse.statusCode != 200) {
      throw Exception('Не удалось найти город');
    }

    final geoJson = jsonDecode(
      utf8.decode(geoResponse.bodyBytes),
    ) as Map<String, dynamic>;

    final results = geoJson['results'] as List?;

    if (results == null || results.isEmpty) {
      throw Exception('Город не найден. Проверьте название.');
    }

    final location = results.first as Map<String, dynamic>;
    final latitude = (location['latitude'] as num).toDouble();
    final longitude = (location['longitude'] as num).toDouble();

    final weatherUri = Uri.https(
      'api.open-meteo.com',
      '/v1/forecast',
      {
        'latitude': latitude.toString(),
        'longitude': longitude.toString(),
        'current':
            'temperature_2m,relative_humidity_2m,'
            'wind_speed_10m,weather_code',
        'wind_speed_unit': 'ms',
        'timezone': 'auto',
      },
    );

    final response = await client.get(weatherUri).timeout(
      const Duration(seconds: 12),
    );

    if (response.statusCode != 200) {
      throw Exception('Не удалось загрузить погоду');
    }

    final json = jsonDecode(
      utf8.decode(response.bodyBytes),
    ) as Map<String, dynamic>;

    final current = json['current'] as Map<String, dynamic>;

    return WeatherData(
      city: city,
      temperature: (current['temperature_2m'] as num).toDouble(),
      humidity: (current['relative_humidity_2m'] as num).toInt(),
      windSpeed: (current['wind_speed_10m'] as num).toDouble(),
      weatherCode: (current['weather_code'] as num).toInt(),
    );
  }

  void dispose() {
    client.close();
  }
}
