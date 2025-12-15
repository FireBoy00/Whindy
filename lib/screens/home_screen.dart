import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import '../providers/weather_provider.dart';
import '../services/location_service.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final TextEditingController _cityController = TextEditingController();
  final LocationService _locationService = LocationService();
  bool _isFetchingLocation = false;

  @override
  void dispose() {
    _cityController.dispose();
    super.dispose();
  }

  /// Demonstrates Flutter Platform Channels by fetching GPS location
  Future<void> _fetchWeatherForCurrentLocation() async {
    final weatherProvider = Provider.of<WeatherProvider>(
      context,
      listen: false,
    );

    setState(() {
      _isFetchingLocation = true;
    });

    final location = await _locationService.getCurrentLocation();

    setState(() {
      _isFetchingLocation = false;
    });

    if (location != null) {
      weatherProvider.fetchWeatherByLocation(
        location['latitude']!,
        location['longitude']!,
      );
    } else {
      // Show more helpful error message
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
            'Unable to get location. Please check:\n'
            '• Location services are enabled\n'
            '• Location permission is granted\n'
            '• GPS signal is available',
          ),
          backgroundColor: Colors.red,
          duration: Duration(seconds: 5),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final weatherProvider = Provider.of<WeatherProvider>(context);
    final colorScheme = Theme.of(context).colorScheme;

    return Scaffold(
      backgroundColor: Colors.grey.shade100,
      appBar: AppBar(
        title: const Text(
          'Whindy Weather',
          style: TextStyle(fontWeight: FontWeight.w600),
        ),
        centerTitle: true,
        elevation: 0,
        flexibleSpace: Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [colorScheme.primary, colorScheme.secondary],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
          ),
        ),
      ),
      body: Column(
        children: [
          // Search Bar Section with gradient background
          Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [colorScheme.primary, colorScheme.secondary],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
            ),
            padding: const EdgeInsets.fromLTRB(16, 8, 16, 24),
            child: Column(
              children: [
                // Search TextField with improved design
                Container(
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(16),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.1),
                        blurRadius: 10,
                        offset: const Offset(0, 4),
                      ),
                    ],
                  ),
                  child: TextField(
                    controller: _cityController,
                    style: const TextStyle(fontSize: 16),
                    decoration: InputDecoration(
                      hintText: 'Search for a city...',
                      hintStyle: TextStyle(color: Colors.grey.shade400),
                      prefixIcon: Icon(
                        Icons.search,
                        color: colorScheme.primary,
                      ),
                      suffixIcon: IconButton(
                        icon: Icon(Icons.send, color: colorScheme.primary),
                        onPressed: () {
                          if (_cityController.text.isNotEmpty) {
                            weatherProvider.fetchWeather(_cityController.text);
                          }
                        },
                      ),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(16),
                        borderSide: BorderSide.none,
                      ),
                      filled: true,
                      fillColor: Colors.white,
                      contentPadding: const EdgeInsets.symmetric(
                        horizontal: 20,
                        vertical: 16,
                      ),
                    ),
                    onSubmitted: (value) {
                      if (value.isNotEmpty) {
                        weatherProvider.fetchWeather(value);
                      }
                    },
                  ),
                ),
                const SizedBox(height: 16),
                // Location Button - Platform Channel Demo
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton.icon(
                    onPressed: _isFetchingLocation
                        ? null
                        : _fetchWeatherForCurrentLocation,
                    icon: _isFetchingLocation
                        ? const SizedBox(
                            width: 20,
                            height: 20,
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                              color: Colors.white,
                            ),
                          )
                        : const Icon(Icons.my_location),
                    label: Text(
                      _isFetchingLocation
                          ? 'Getting Location...'
                          : 'Use Current Location',
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.white,
                      foregroundColor: colorScheme.primary,
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      elevation: 2,
                    ),
                  ),
                ),
              ],
            ),
          ),
          // Weather Display Section
          Expanded(child: _buildWeatherDisplay(weatherProvider, colorScheme)),
        ],
      ),
    );
  }

  Widget _buildWeatherDisplay(
    WeatherProvider weatherProvider,
    ColorScheme colorScheme,
  ) {
    if (weatherProvider.isLoading) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            CircularProgressIndicator(color: colorScheme.primary),
            const SizedBox(height: 16),
            Text(
              'Fetching weather data...',
              style: TextStyle(fontSize: 16, color: Colors.grey.shade600),
            ),
          ],
        ),
      );
    } else if (weatherProvider.error != null) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(32),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.error_outline, size: 80, color: Colors.red.shade300),
              const SizedBox(height: 16),
              Text(
                'Oops!',
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: Colors.red.shade700,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                weatherProvider.error!,
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 16, color: Colors.grey.shade600),
              ),
            ],
          ),
        ),
      );
    } else if (weatherProvider.weather != null) {
      final weather = weatherProvider.weather!;
      return SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            children: [
              // Main Weather Card
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(24),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [
                      colorScheme.primaryContainer,
                      colorScheme.secondaryContainer,
                    ],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  borderRadius: BorderRadius.circular(24),
                  boxShadow: [
                    BoxShadow(
                      color: colorScheme.primary.withOpacity(0.3),
                      blurRadius: 15,
                      offset: const Offset(0, 8),
                    ),
                  ],
                ),
                child: Column(
                  children: [
                    // City Name
                    Text(
                      weather.cityName,
                      style: TextStyle(
                        fontSize: 32,
                        fontWeight: FontWeight.bold,
                        color: colorScheme.onPrimaryContainer,
                      ),
                    ),
                    const SizedBox(height: 8),
                    // Date
                    Text(
                      DateFormat('EEEE, MMMM d, y').format(DateTime.now()),
                      style: TextStyle(
                        fontSize: 16,
                        color: colorScheme.onPrimaryContainer.withOpacity(0.7),
                        letterSpacing: 0.5,
                      ),
                    ),
                    const SizedBox(height: 24),
                    // Weather Icon
                    Container(
                      padding: const EdgeInsets.all(20),
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.3),
                        shape: BoxShape.circle,
                      ),
                      child: Icon(
                        _getWeatherIcon(weather.description),
                        size: 100,
                        color: _getWeatherColor(weather.description),
                      ),
                    ),
                    const SizedBox(height: 24),
                    // Temperature
                    Text(
                      '${weather.temperature.toStringAsFixed(1)}°',
                      style: TextStyle(
                        fontSize: 72,
                        fontWeight: FontWeight.bold,
                        color: colorScheme.onPrimaryContainer,
                        height: 1,
                      ),
                    ),
                    const SizedBox(height: 8),
                    // Description
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 8,
                      ),
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.3),
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Text(
                        weather.description.toUpperCase(),
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.w600,
                          letterSpacing: 1.5,
                          color: colorScheme.onPrimaryContainer,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 24),
              // Weather Details Cards
              Row(
                children: [
                  Expanded(
                    child: _buildEnhancedInfoCard(
                      'Humidity',
                      '${weather.humidity.toStringAsFixed(0)}%',
                      Icons.water_drop,
                      Colors.blue,
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: _buildEnhancedInfoCard(
                      'Wind Speed',
                      '${weather.windSpeed.toStringAsFixed(1)} m/s',
                      Icons.air,
                      Colors.teal,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              // Platform Channel Info Badge
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.amber.shade50,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: Colors.amber.shade200),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      Icons.info_outline,
                      size: 20,
                      color: Colors.amber.shade700,
                    ),
                    const SizedBox(width: 8),
                    Flexible(
                      child: Text(
                        weather.cityName == 'Current Location'
                            ? 'Location fetched via Platform Channels 📍'
                            : 'Tap "Use Current Location" to demo Platform Channels',
                        style: TextStyle(
                          fontSize: 12,
                          color: Colors.amber.shade900,
                          fontWeight: FontWeight.w500,
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      );
    } else {
      // Initial state
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(32),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.wb_sunny, size: 100, color: Colors.orange.shade300),
              const SizedBox(height: 24),
              Text(
                'Welcome to Whindy!',
                style: TextStyle(
                  fontSize: 28,
                  fontWeight: FontWeight.bold,
                  color: colorScheme.primary,
                ),
              ),
              const SizedBox(height: 12),
              Text(
                'Search for a city or use your\ncurrent location to get started',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 16,
                  color: Colors.grey.shade600,
                  height: 1.5,
                ),
              ),
            ],
          ),
        ),
      );
    }
  }

  Widget _buildEnhancedInfoCard(
    String title,
    String value,
    IconData icon,
    Color color,
  ) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: color.withOpacity(0.1),
              shape: BoxShape.circle,
            ),
            child: Icon(icon, size: 32, color: color),
          ),
          const SizedBox(height: 12),
          Text(
            title,
            style: TextStyle(
              fontSize: 14,
              color: Colors.grey.shade600,
              fontWeight: FontWeight.w500,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            value,
            style: const TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: Colors.black87,
            ),
          ),
        ],
      ),
    );
  }

  Color _getWeatherColor(String description) {
    description = description.toLowerCase();
    if (description.contains('cloud')) return Colors.grey.shade600;
    if (description.contains('rain')) return Colors.blue.shade700;
    if (description.contains('snow')) return Colors.lightBlue.shade200;
    if (description.contains('clear') || description.contains('sun')) {
      return Colors.orange.shade600;
    }
    return Colors.blueGrey;
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
