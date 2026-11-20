
import 'package:flutter_test/flutter_test.dart';
import 'package:skyweather/services/weather_service.dart';

void main() {
  group('WeatherData tests', () {
    test('Код 0 означает ясную погоду', () {
      const weather = WeatherData(
        city: 'Москва',
        temperature: 24,
        humidity: 60,
        windSpeed: 3,
        weatherCode: 0,
      );

      expect(weather.description, 'Ясно');
    });

    test('Код 61 означает дождь', () {
      const weather = WeatherData(
        city: 'Казань',
        temperature: 12,
        humidity: 85,
        windSpeed: 5,
        weatherCode: 61,
      );

      expect(weather.description, 'Дождь');
    });
  });
}
