
import 'package:flutter/material.dart';

import 'screens/cities_screen.dart';
import 'services/weather_service.dart';
import 'widgets/weather_background.dart';

void main() {
  runApp(const SkyWeatherApp());
}

class SkyWeatherApp extends StatelessWidget {
  const SkyWeatherApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'SkyWeather',
      theme: ThemeData(
        useMaterial3: true,
        fontFamily: 'Roboto',
      ),
      home: const WeatherScreen(),
    );
  }
}

class WeatherScreen extends StatefulWidget {
  const WeatherScreen({super.key});

  @override
  State<WeatherScreen> createState() => _WeatherScreenState();
}

class _WeatherScreenState extends State<WeatherScreen> {
  final WeatherService _service = WeatherService();

  String selectedCity = 'Москва';
  WeatherData? weather;
  bool isLoading = true;
  String? error;

  @override
  void initState() {
    super.initState();
    _loadWeather();
  }

  Future<void> _loadWeather() async {
    final city = selectedCity;

    setState(() {
      isLoading = true;
      error = null;
    });

    try {
      final result = await _service.getWeather(city);

      if (!mounted || city != selectedCity) return;

      setState(() {
        weather = result;
        isLoading = false;
      });
    } catch (e) {
      if (!mounted || city != selectedCity) return;

      setState(() {
        error = e.toString().replaceFirst('Exception: ', '');
        isLoading = false;
      });
    }
  }

  Future<void> _openCities() async {
    final city = await Navigator.push<String>(
      context,
      MaterialPageRoute(
        builder: (_) => const CitiesScreen(),
      ),
    );

    if (!mounted || city == null) return;

    selectedCity = city;
    await _loadWeather();
  }

  @override
  void dispose() {
    _service.dispose();
    super.dispose();
  }

  IconData _weatherIcon(int code) {
    if (code == 0) return Icons.wb_sunny_rounded;
    if (code <= 3) return Icons.cloud_rounded;
    if (code <= 48) return Icons.blur_on_rounded;
    if (code <= 67) return Icons.water_drop_rounded;
    if (code <= 77) return Icons.ac_unit_rounded;
    if (code <= 82) return Icons.water_drop_rounded;
    if (code <= 86) return Icons.ac_unit_rounded;
    if (code >= 95) return Icons.thunderstorm_rounded;
    return Icons.cloud_rounded;
  }

  @override
  Widget build(BuildContext context) {
    final scene = weather == null
        ? WeatherScene.sunny
        : sceneFromCode(weather!.weatherCode);

    return Scaffold(
      body: Stack(
        children: [
          Positioned.fill(
            child: WeatherBackground(scene: scene),
          ),

          SafeArea(
            child: isLoading
                ? const Center(
                    child: CircularProgressIndicator(
                      color: Colors.white,
                    ),
                  )
                : error != null
                    ? _buildError()
                    : _buildWeather(),
          ),

          Positioned(
            left: 24,
            right: 24,
            bottom: 24,
            child: SafeArea(
              top: false,
              child: SizedBox(
                height: 54,
                child: ElevatedButton.icon(
                  onPressed: _openCities,
                  icon: const Icon(Icons.location_city_rounded),
                  label: const Text(
                    'Мои города',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.white,
                    foregroundColor: const Color(0xFF245A9A),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(30),
                    ),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildError() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.fromLTRB(28, 28, 28, 110),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(
              Icons.wifi_off_rounded,
              color: Colors.white,
              size: 72,
            ),
            const SizedBox(height: 20),
            const Text(
              'Не удалось загрузить погоду',
              textAlign: TextAlign.center,
              style: TextStyle(
                color: Colors.white,
                fontSize: 23,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 12),
            Text(
              error!,
              textAlign: TextAlign.center,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 15,
              ),
            ),
            const SizedBox(height: 24),
            ElevatedButton.icon(
              onPressed: _loadWeather,
              icon: const Icon(Icons.refresh),
              label: const Text('Повторить'),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildWeather() {
    final data = weather!;
    final scene = sceneFromCode(data.weatherCode);

    return LayoutBuilder(
      builder: (context, constraints) {
        return SingleChildScrollView(
          padding: const EdgeInsets.fromLTRB(24, 25, 24, 115),
          child: ConstrainedBox(
            constraints: BoxConstraints(
              minHeight: constraints.maxHeight > 140
                  ? constraints.maxHeight - 140
                  : 0,
            ),
            child: Column(
              children: [
                const Text(
                  'SkyWeather',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 20,
                    fontWeight: FontWeight.w600,
                    letterSpacing: 2,
                  ),
                ),

                const SizedBox(height: 28),

                const Icon(
                  Icons.location_on_rounded,
                  color: Colors.white,
                  size: 26,
                ),

                const SizedBox(height: 7),

                Text(
                  selectedCity,
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 31,
                    fontWeight: FontWeight.w600,
                    shadows: [
                      Shadow(
                        color: Colors.black26,
                        blurRadius: 12,
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 35),

                _buildWeatherSymbol(scene, data.weatherCode),

                const SizedBox(height: 12),

                Text(
                  '${data.temperature.round()}°',
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 96,
                    fontWeight: FontWeight.w200,
                    height: 1.1,
                    shadows: [
                      Shadow(
                        color: Colors.black26,
                        blurRadius: 16,
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 8),

                Text(
                  data.description,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 24,
                    fontWeight: FontWeight.w500,
                  ),
                ),

                const SizedBox(height: 35),

                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.symmetric(
                    horizontal: 18,
                    vertical: 24,
                  ),
                  decoration: BoxDecoration(
                    color: Colors.white.withValues(alpha: 0.19),
                    borderRadius: BorderRadius.circular(26),
                    border: Border.all(
                      color: Colors.white.withValues(alpha: 0.35),
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withValues(alpha: 0.08),
                        blurRadius: 20,
                        offset: const Offset(0, 10),
                      ),
                    ],
                  ),
                  child: Row(
                    mainAxisAlignment:
                        MainAxisAlignment.spaceAround,
                    children: [
                      WeatherInfo(
                        icon: Icons.water_drop_outlined,
                        label: 'Влажность',
                        value: '${data.humidity}%',
                      ),
                      Container(
                        height: 55,
                        width: 1,
                        color: Colors.white38,
                      ),
                      WeatherInfo(
                        icon: Icons.air,
                        label: 'Ветер',
                        value:
                            '${data.windSpeed.toStringAsFixed(1)} м/с',
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 20),

                TextButton.icon(
                  onPressed: _loadWeather,
                  icon: const Icon(
                    Icons.refresh,
                    color: Colors.white,
                  ),
                  label: const Text(
                    'Обновить погоду',
                    style: TextStyle(color: Colors.white),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildWeatherSymbol(WeatherScene scene, int code) {
    final iconColor = scene == WeatherScene.sunny
        ? const Color(0xFFFFE28A)
        : Colors.white;

    return TweenAnimationBuilder<double>(
      key: ValueKey(scene),
      tween: Tween(begin: 0.94, end: 1.04),
      duration: const Duration(seconds: 2),
      curve: Curves.easeInOut,
      builder: (context, scale, child) {
        return Transform.scale(
          scale: scale,
          child: child,
        );
      },
      child: Icon(
        _weatherIcon(code),
        size: 110,
        color: iconColor,
        shadows: const [
          Shadow(
            color: Colors.black26,
            blurRadius: 20,
          ),
        ],
      ),
    );
  }
}

class WeatherInfo extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;

  const WeatherInfo({
    super.key,
    required this.icon,
    required this.label,
    required this.value,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Icon(
          icon,
          color: Colors.white,
          size: 29,
        ),
        const SizedBox(height: 8),
        Text(
          label,
          style: const TextStyle(
            color: Colors.white,
            fontSize: 14,
          ),
        ),
        const SizedBox(height: 7),
        Text(
          value,
          style: const TextStyle(
            color: Colors.white,
            fontSize: 19,
            fontWeight: FontWeight.bold,
          ),
        ),
      ],
    );
  }
}
