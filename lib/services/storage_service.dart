
import 'package:shared_preferences/shared_preferences.dart';

class StorageService {
  static const String _citiesKey = 'cities';

  Future<List<String>> loadCities() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getStringList(_citiesKey) ?? ['Москва'];
  }

  Future<void> saveCities(List<String> cities) async {
    final prefs = await SharedPreferences.getInstance();
    final saved = await prefs.setStringList(_citiesKey, cities);

    if (!saved) {
      throw Exception('Не удалось сохранить города');
    }
  }
}
