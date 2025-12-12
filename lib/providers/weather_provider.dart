import 'package:flutter/material.dart';
import '../models/weather_model.dart';
import '../services/weather_service.dart';

class WeatherProvider with ChangeNotifier {
  final WeatherService _weatherService = WeatherService();
  Weather? _weather;
  bool _isLoading = false;
  String? _error;

  Weather? get weather => _weather;
  bool get isLoading => _isLoading;
  String? get error => _error;

  Future<void> fetchWeather(String cityName) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      _weather = await _weatherService.fetchWeather(cityName);
    } catch (e) {
      _error = e.toString();
      _weather = null;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }
}
