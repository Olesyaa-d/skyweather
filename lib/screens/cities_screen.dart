
import 'package:flutter/material.dart';

import 'add_city_screen.dart';
import '../services/storage_service.dart';

class CitiesScreen extends StatefulWidget {
  const CitiesScreen({super.key});

  @override
  State<CitiesScreen> createState() => _CitiesScreenState();
}

class _CitiesScreenState extends State<CitiesScreen> {
  final StorageService _storage = StorageService();

  List<String> cities = [];
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadCities();
  }

  // Загрузка сохранённых городов
  Future<void> _loadCities() async {
    try {
      final savedCities = await _storage.loadCities();

      if (!mounted) return;

      setState(() {
        cities = savedCities;
        isLoading = false;
      });
    } catch (e) {
      if (!mounted) return;

      setState(() {
        cities = [];
        isLoading = false;
      });

      _showMessage('Не удалось загрузить города');
    }
  }

  // Сохранение списка городов
  Future<bool> _saveCities(List<String> updatedCities) async {
    try {
      await _storage.saveCities(updatedCities);
      return true;
    } catch (e) {
      if (!mounted) return false;

      _showMessage('Не удалось сохранить изменения');
      return false;
    }
  }

  // Сообщения пользователю
  void _showMessage(String message) {
    if (!mounted) return;

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(14),
        ),
      ),
    );
  }

  // Добавление нового города
  Future<void> _addCity() async {
    final city = await Navigator.push<String>(
      context,
      MaterialPageRoute(
        builder: (_) => const AddCityScreen(),
      ),
    );

    if (!mounted || city == null) return;

    final newCity = city.trim();

    if (newCity.isEmpty) return;

    // Проверяем, нет ли уже такого города
    final alreadyExists = cities.any(
      (item) => item.toLowerCase() == newCity.toLowerCase(),
    );

    if (alreadyExists) {
      _showMessage('Этот город уже добавлен');
      return;
    }

    final updatedCities = [...cities, newCity];

    final saved = await _saveCities(updatedCities);

    if (!mounted || !saved) return;

    setState(() {
      cities = updatedCities;
    });

    _showMessage('Город $newCity добавлен');
  }

  // Удаление города
  Future<void> _removeCity(int index) async {
    final city = cities[index];

    final updatedCities = [...cities];
    updatedCities.removeAt(index);

    final saved = await _saveCities(updatedCities);

    if (!mounted || !saved) return;

    setState(() {
      cities = updatedCities;
    });

    _showMessage('Город $city удалён');
  }

  // Выбор города и возврат на главный экран
  void _selectCity(String city) {
    Navigator.pop(context, city);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF3279DD),

      appBar: AppBar(
        title: const Text(
          'Мои города',
          style: TextStyle(
            fontWeight: FontWeight.w600,
            fontSize: 22,
          ),
        ),
        centerTitle: true,
        backgroundColor: const Color(0xFF3279DD),
        foregroundColor: Colors.white,
        elevation: 0,
      ),

      floatingActionButton: FloatingActionButton.extended(
        onPressed: _addCity,
        backgroundColor: Colors.white,
        foregroundColor: const Color(0xFF3279DD),
        icon: const Icon(Icons.add),
        label: const Text(
          'Добавить город',
          style: TextStyle(
            fontWeight: FontWeight.w600,
          ),
        ),
      ),

      floatingActionButtonLocation:
          FloatingActionButtonLocation.centerFloat,

      body: Container(
        width: double.infinity,
        height: double.infinity,

        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              Color(0xFF3279DD),
              Color(0xFF74B5F5),
              Color(0xFFD6EDFF),
            ],
          ),
        ),

        child: SafeArea(
          child: isLoading
              ? const Center(
                  child: CircularProgressIndicator(
                    color: Colors.white,
                  ),
                )
              : cities.isEmpty
                  ? _buildEmptyState()
                  : _buildCitiesList(),
        ),
      ),
    );
  }

  // Экран пустого списка
  Widget _buildEmptyState() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(30),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              Icons.location_city_rounded,
              size: 90,
              color: Colors.white.withValues(alpha: 0.9),
            ),

            const SizedBox(height: 24),

            const Text(
              'Пока нет городов',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 26,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),

            const SizedBox(height: 12),

            const Text(
              'Добавьте свой первый город,\n'
              'чтобы узнать погоду',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 16,
                color: Colors.white70,
                height: 1.5,
              ),
            ),

            const SizedBox(height: 100),
          ],
        ),
      ),
    );
  }

  // Список сохранённых городов
  Widget _buildCitiesList() {
    return ListView.builder(
      padding: const EdgeInsets.fromLTRB(20, 20, 20, 110),
      itemCount: cities.length,
      itemBuilder: (context, index) {
        final city = cities[index];

        return Container(
          margin: const EdgeInsets.only(bottom: 14),

          decoration: BoxDecoration(
            color: Colors.white.withValues(alpha: 0.88),
            borderRadius: BorderRadius.circular(24),

            border: Border.all(
              color: Colors.white.withValues(alpha: 0.5),
            ),

            boxShadow: [
              BoxShadow(
                color: Colors.blue.withValues(alpha: 0.12),
                blurRadius: 18,
                offset: const Offset(0, 8),
              ),
            ],
          ),

          child: ListTile(
            contentPadding: const EdgeInsets.symmetric(
              horizontal: 18,
              vertical: 12,
            ),

            leading: Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: const Color(0xFF3279DD)
                    .withValues(alpha: 0.12),
                borderRadius: BorderRadius.circular(16),
              ),
              child: const Icon(
                Icons.location_on_rounded,
                color: Color(0xFF3279DD),
                size: 28,
              ),
            ),

            title: Text(
              city,
              style: const TextStyle(
                fontSize: 19,
                fontWeight: FontWeight.w600,
                color: Color(0xFF183B68),
              ),
            ),

            subtitle: const Padding(
              padding: EdgeInsets.only(top: 5),
              child: Text(
                'Посмотреть погоду',
                style: TextStyle(
                  fontSize: 13,
                  color: Color(0xFF6483A6),
                ),
              ),
            ),

            trailing: IconButton(
              tooltip: 'Удалить город',
              onPressed: () => _removeCity(index),
              icon: const Icon(
                Icons.delete_outline_rounded,
                color: Color(0xFFE66B75),
                size: 26,
              ),
            ),

            onTap: () => _selectCity(city),
          ),
        );
      },
    );
  }
}
