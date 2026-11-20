
import 'dart:async';
import 'package:flutter/material.dart';

import '../services/city_search_service.dart';

class AddCityScreen extends StatefulWidget {
  const AddCityScreen({super.key});

  @override
  State<AddCityScreen> createState() => _AddCityScreenState();
}

class _AddCityScreenState extends State<AddCityScreen> {
  final TextEditingController _controller = TextEditingController();
  final CitySearchService _searchService = CitySearchService();

  Timer? _debounce;

  List<CitySearchResult> _results = [];

  bool _isLoading = false;
  String? _error;
  int _requestId = 0;

  @override
  void dispose() {
    _debounce?.cancel();
    _controller.dispose();
    _searchService.dispose();
    super.dispose();
  }

  void _onSearchChanged(String query) {
    _debounce?.cancel();
    final requestId = ++_requestId;

    if (query.trim().length < 2) {
      setState(() {
        _results = [];
        _isLoading = false;
        _error = null;
      });
      return;
    }

    setState(() {
      _results = [];
      _isLoading = true;
      _error = null;
    });

    _debounce = Timer(
      const Duration(milliseconds: 450),
      () => _search(query, requestId),
    );
  }

  Future<void> _search(String query, int requestId) async {
    try {
      final results = await _searchService.search(query);

      if (!mounted || requestId != _requestId) return;

      setState(() {
        _results = results;
        _isLoading = false;
      });
    } catch (e) {
      if (!mounted || requestId != _requestId) return;

      setState(() {
        _isLoading = false;
        _error = 'Не удалось выполнить поиск. Проверьте интернет.';
      });
    }
  }

  void _selectCity(CitySearchResult city) {
    Navigator.pop(context, city.name);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF3279DD),
      appBar: AppBar(
        title: const Text('Поиск города'),
        centerTitle: true,
        backgroundColor: const Color(0xFF3279DD),
        foregroundColor: Colors.white,
      ),
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
          child: Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SizedBox(height: 18),

                const Text(
                  'Найдём ваш город',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 28,
                    fontWeight: FontWeight.bold,
                  ),
                ),

                const SizedBox(height: 10),

                const Text(
                  'Начните вводить название и выберите '
                  'город из списка.',
                  style: TextStyle(
                    color: Colors.white70,
                    fontSize: 15,
                  ),
                ),

                const SizedBox(height: 24),

                TextField(
                  controller: _controller,
                  autofocus: true,
                  textCapitalization: TextCapitalization.words,
                  onChanged: _onSearchChanged,
                  decoration: InputDecoration(
                    hintText: 'Введите название города',
                    prefixIcon: const Icon(Icons.search),
                    suffixIcon: IconButton(
                      icon: const Icon(Icons.clear),
                      onPressed: () {
                        _controller.clear();
                        _onSearchChanged('');
                      },
                    ),
                    filled: true,
                    fillColor: Colors.white,
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(20),
                      borderSide: BorderSide.none,
                    ),
                  ),
                ),

                const SizedBox(height: 20),

                if (_isLoading)
                  const Center(
                    child: CircularProgressIndicator(
                      color: Colors.white,
                    ),
                  ),

                if (_error != null)
                  Padding(
                    padding: const EdgeInsets.all(12),
                    child: Text(
                      _error!,
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 15,
                      ),
                    ),
                  ),

                if (!_isLoading &&
                    _error == null &&
                    _controller.text.trim().length >= 2 &&
                    _results.isEmpty)
                  const Padding(
                    padding: EdgeInsets.all(12),
                    child: Text(
                      'Города не найдены. Попробуйте другое название.',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 15,
                      ),
                    ),
                  ),

                Expanded(
                  child: ListView.builder(
                    keyboardDismissBehavior:
                        ScrollViewKeyboardDismissBehavior.onDrag,
                    itemCount: _results.length,
                    itemBuilder: (context, index) {
                      final city = _results[index];

                      return Container(
                        margin: const EdgeInsets.only(bottom: 10),
                        decoration: BoxDecoration(
                          color: Colors.white.withValues(alpha: 0.92),
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: ListTile(
                          contentPadding: const EdgeInsets.symmetric(
                            horizontal: 16,
                            vertical: 8,
                          ),
                          leading: const Icon(
                            Icons.location_on_rounded,
                            color: Color(0xFF3279DD),
                          ),
                          title: Text(
                            city.name,
                            style: const TextStyle(
                              fontWeight: FontWeight.w600,
                              fontSize: 17,
                            ),
                          ),
                          subtitle: Text(
                            [
                              city.region,
                              city.country,
                            ].where((s) => s.isNotEmpty).join(', '),
                          ),
                          trailing: const Icon(
                            Icons.add_circle_outline,
                            color: Color(0xFF3279DD),
                          ),
                          onTap: () => _selectCity(city),
                        ),
                      );
                    },
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
