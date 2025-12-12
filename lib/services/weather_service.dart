import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:flutter_dotenv/flutter_dotenv.dart';
import '../models/weather_model.dart';

class WeatherService {
  // static const String _apiKey = 'YOUR_API_KEY';
  static const String _baseUrl =
      'https://api.openweathermap.org/data/2.5/weather';

  Future<Weather> fetchWeather(String cityName) async {
    final apiKey = dotenv.env['API_KEY'];
    // If no API key is provided, return mock data
    if (apiKey == null || apiKey == 'YOUR_API_KEY') {
      await Future.delayed(
        const Duration(seconds: 1),
      ); // Simulate network delay
      return _getMockWeather(cityName);
    }

    final response = await http.get(
      Uri.parse('$_baseUrl?q=$cityName&appid=$apiKey&units=metric'),
    );

    if (response.statusCode == 200) {
      return Weather.fromJson(jsonDecode(response.body));
    } else {
      throw Exception('Failed to load weather data');
    }
  }

  Weather _getMockWeather(String cityName) {
    // Simple mock data generator based on city name length to give some variety
    final temp = 20.0 + (cityName.length % 10);
    return Weather(
      cityName: cityName,
      temperature: temp,
      description: cityName.length % 2 == 0 ? 'Sunny' : 'Cloudy',
      iconCode: cityName.length % 2 == 0 ? '01d' : '03d',
      humidity: 50.0 + (cityName.length % 20),
      windSpeed: 5.0 + (cityName.length % 5),
    );
  }
}
