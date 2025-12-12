import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import '../providers/weather_provider.dart';
import '../widgets/weather_info_card.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final TextEditingController _cityController = TextEditingController();

  @override
  void dispose() {
    _cityController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final weatherProvider = Provider.of<WeatherProvider>(context);

    return Scaffold(
      appBar: AppBar(title: const Text('Whindy Weather'), centerTitle: true),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            TextField(
              controller: _cityController,
              decoration: InputDecoration(
                labelText: 'Enter City Name',
                suffixIcon: IconButton(
                  icon: const Icon(Icons.search),
                  onPressed: () {
                    if (_cityController.text.isNotEmpty) {
                      weatherProvider.fetchWeather(_cityController.text);
                    }
                  },
                ),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              onSubmitted: (value) {
                if (value.isNotEmpty) {
                  weatherProvider.fetchWeather(value);
                }
              },
            ),
            const SizedBox(height: 20),
            if (weatherProvider.isLoading)
              const Expanded(child: Center(child: CircularProgressIndicator()))
            else if (weatherProvider.error != null)
              Expanded(
                child: Center(
                  child: Text(
                    'Error: ${weatherProvider.error}',
                    style: const TextStyle(color: Colors.red),
                  ),
                ),
              )
            else if (weatherProvider.weather != null)
              Expanded(
                child: SingleChildScrollView(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        weatherProvider.weather!.cityName,
                        style: Theme.of(context).textTheme.headlineMedium
                            ?.copyWith(fontWeight: FontWeight.bold),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        DateFormat('EEEE, d MMMM y').format(DateTime.now()),
                        style: const TextStyle(
                          fontSize: 16,
                          color: Colors.grey,
                        ),
                      ),
                      const SizedBox(height: 20),
                      // Weather Icon (using a placeholder if mock, or network image if real)
                      // For simplicity in this demo, we'll use standard Icons based on description
                      Icon(
                        _getWeatherIcon(weatherProvider.weather!.description),
                        size: 100,
                        color: Colors.orange,
                      ),
                      const SizedBox(height: 20),
                      Text(
                        '${weatherProvider.weather!.temperature.toStringAsFixed(1)}°C',
                        style: const TextStyle(
                          fontSize: 64,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      Text(
                        weatherProvider.weather!.description.toUpperCase(),
                        style: const TextStyle(
                          fontSize: 24,
                          letterSpacing: 1.2,
                        ),
                      ),
                      const SizedBox(height: 40),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                        children: [
                          WeatherInfoCard(
                            title: 'Humidity',
                            value: '${weatherProvider.weather!.humidity}%',
                            icon: Icons.water_drop,
                          ),
                          WeatherInfoCard(
                            title: 'Wind',
                            value: '${weatherProvider.weather!.windSpeed} m/s',
                            icon: Icons.air,
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              )
            else
              const Expanded(
                child: Center(
                  child: Text('Search for a city to get weather info'),
                ),
              ),
          ],
        ),
      ),
    );
  }

  IconData _getWeatherIcon(String description) {
    description = description.toLowerCase();
    if (description.contains('cloud')) return Icons.cloud;
    if (description.contains('rain')) return Icons.beach_access;
    if (description.contains('snow')) return Icons.ac_unit;
    if (description.contains('clear') || description.contains('sun')) {
      return Icons.wb_sunny;
    }
    return Icons.wb_cloudy;
  }
}
