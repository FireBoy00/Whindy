# 📝 Exam Quick Reference Guide

**Quick lookup for code examples during your exam - No IDE needed!**

Use this with [DEV.md](DEV.md) for detailed explanations.

---

## ✅ Assignment Requirements Checklist

### 1. Widgets ✅

**StatelessWidget**:
- File: `lib/widgets/weather_info_card.dart`
- Lines: 3-42 (full class)
- Purpose: Display-only component for weather metrics

**StatefulWidget**:
- File: `lib/screens/home_screen.dart` 
- Lines: 8-16 (class declaration)
- Lines: 18-25 (State with lifecycle)
- Purpose: Screen with text input and GPS location state

**Widget Types**: Scaffold, AppBar, TextField, Card, Icon, CircularProgressIndicator, Container, Column, Row, ElevatedButton, LinearGradient

### 2. Flutter Architecture ✅

**3-Layer Structure**:
```
Presentation: screens/ + widgets/ → UI
Business Logic: providers/ → State management  
Data: models/ + services/ → API & GPS
```

**Files**:
- Models: `lib/models/weather_model.dart`
- Services: `lib/services/weather_service.dart`, `lib/services/location_service.dart`
- Providers: `lib/providers/weather_provider.dart`
- UI: `lib/screens/home_screen.dart`, `lib/widgets/weather_info_card.dart`

### 3. State Management ✅

**ChangeNotifier**: `lib/providers/weather_provider.dart` line 5
**Provider Setup**: `lib/main.dart` lines 14-16  
**Provider Usage**: `lib/screens/home_screen.dart` line 59
**notifyListeners()**: `lib/providers/weather_provider.dart` lines 18, 25, 34, 41

### 4. Flutter Channels ✅

**Dart Side**: `lib/services/location_service.dart`
- Line 8: MethodChannel declaration
- Lines 13-38: getCurrentLocation() method
- Line 20: platform.invokeMethod() call

**Android Side**: `android/app/src/main/kotlin/com/example/whindy/MainActivity.kt`
- Line 16: Channel name (must match Dart!)
- Lines 24-46: Method call handler
- Lines 48-72: Permission callback
- Lines 79-101: GPS implementation

**iOS Side**: `ios/Runner/AppDelegate.swift`
- Line 16: Channel setup
- Lines 35-62: Location request logic
- Lines 71-95: Location delegate methods

**UI Integration**: `lib/screens/home_screen.dart` lines 26-52, 88-106

---

## 🔍 Code Snippets for Screenshots

### StatelessWidget
```dart
class WeatherInfoCard extends StatelessWidget {
  final String title;
  final String value;
  final IconData icon;

  const WeatherInfoCard({
    super.key,
    required this.title,
    required this.value,
    required this.icon,
  });

  @override
  Widget build(BuildContext context) {
    return Card(...);
  }
}
```
**Location**: `lib/widgets/weather_info_card.dart` lines 3-42

### StatefulWidget
```dart
class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final TextEditingController _cityController = TextEditingController();
  final LocationService _locationService = LocationService();
  
  @override
  void dispose() {
    _cityController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) { ... }
}
```
**Location**: `lib/screens/home_screen.dart` lines 8-25

### Provider Pattern

**ChangeNotifier**:
```dart
class WeatherProvider with ChangeNotifier {
  Weather? _weather;
  bool _isLoading = false;
  String? _error;

  Weather? get weather => _weather;
  bool get isLoading => _isLoading;
  String? get error => _error;

  Future<void> fetchWeather(String cityName) async {
    _isLoading = true;
    _error = null;
    notifyListeners();  // UI updates!

    try {
      _weather = await _weatherService.fetchWeather(cityName);
    } catch (e) {
      _error = e.toString();
    } finally {
      _isLoading = false;
      notifyListeners();  // UI updates!
    }
  }
}
```
**Location**: `lib/providers/weather_provider.dart` lines 5-27

**Provider Setup**:
```dart
MultiProvider(
  providers: [
    ChangeNotifierProvider(create: (_) => WeatherProvider())
  ],
  child: MaterialApp(...)
)
```
**Location**: `lib/main.dart` lines 14-16

**Provider Usage**:
```dart
final weatherProvider = Provider.of<WeatherProvider>(context);
weatherProvider.fetchWeather('London');
```
**Location**: `lib/screens/home_screen.dart` line 59

### Platform Channels - Complete Flow

**Dart Side**:
```dart
class LocationService {
  static const platform = MethodChannel('com.whindy.location');

  Future<Map<String, double>?> getCurrentLocation() async {
    try {
      final Map<dynamic, dynamic> result =
          await platform.invokeMethod('getCurrentLocation');
      
      return {
        'latitude': result['latitude'] as double,
        'longitude': result['longitude'] as double,
      };
    } on PlatformException catch (e) {
      print("Failed to get location: '${e.message}'.");
      return null;
    }
  }
}
```
**Location**: `lib/services/location_service.dart` lines 6-38

**Android Side**:
```kotlin
private val CHANNEL = "com.whindy.location"  // Must match Dart!
private var pendingResult: MethodChannel.Result? = null

override fun configureFlutterEngine(flutterEngine: FlutterEngine) {
    MethodChannel(flutterEngine.dartExecutor.binaryMessenger, CHANNEL)
        .setMethodCallHandler { call, result ->
            if (call.method == "getCurrentLocation") {
                if (hasLocationPermission()) {
                    val location = getCurrentLocation()
                    result.success(location)
                } else {
                    pendingResult = result
                    requestPermissions(...)  // Shows dialog
                }
            }
        }
}

override fun onRequestPermissionsResult(...) {
    if (grantResults[0] == PERMISSION_GRANTED) {
        val location = getCurrentLocation()
        pendingResult?.success(location)
    } else {
        pendingResult?.error("PERMISSION_DENIED", "User denied", null)
    }
    pendingResult = null
}
```
**Location**: `android/.../MainActivity.kt` lines 14-72

**iOS Side**:
```swift
let channel = FlutterMethodChannel(name: "com.whindy.location", ...)

channel.setMethodCallHandler { [weak self] (call, result) in
    guard call.method == "getCurrentLocation" else {
        result(FlutterMethodNotImplemented)
        return
    }
    self?.getCurrentLocation(result: result)
}

private func getCurrentLocation(result: @escaping FlutterResult) {
    locationManager.requestWhenInUseAuthorization()
    locationManager.requestLocation()
    locationResult = result  // Store for delegate callback
}

// Delegate method - called when location arrives
func locationManager(_ manager: CLLocationManager, 
                     didUpdateLocations locations: [CLLocation]) {
    guard let location = locations.last else { return }
    
    let data: [String: Double] = [
        "latitude": location.coordinate.latitude,
        "longitude": location.coordinate.longitude
    ]
    
    locationResult?(data)
    locationResult = nil
}
```
**Location**: `ios/Runner/AppDelegate.swift` lines 14-95

### async/await Example
```dart
Future<void> fetchWeather(String cityName) async {
  _isLoading = true;
  notifyListeners();  // UI shows spinner

  try {
    // 'await' pauses HERE but UI keeps running!
    _weather = await _weatherService.fetchWeather(cityName);
  } catch (e) {
    _error = e.toString();
  } finally {
    _isLoading = false;
    notifyListeners();  // UI shows result
  }
}
```
**Location**: `lib/providers/weather_provider.dart` lines 15-27

### JSON Parsing
```dart
factory Weather.fromJson(Map<String, dynamic> json) {
  return Weather(
    cityName: json['name'] ?? '',
    temperature: (json['main']['temp'] as num).toDouble(),
    description: json['weather'][0]['description'] ?? '',
    iconCode: json['weather'][0]['icon'] ?? '',
    humidity: (json['main']['humidity'] as num).toDouble(),
    windSpeed: (json['wind']['speed'] as num).toDouble(),
  );
}
```
**Location**: `lib/models/weather_model.dart` lines 20-30

---

## 💬 Common Exam Questions & Answers

### Q1: What widgets does your app use?

**Answer**: 
- **StatefulWidget**: HomeScreen (manages text input, location state, lifecycle)
- **StatelessWidget**: WeatherInfoCard, MyApp (static display)
- **Material Widgets**: Scaffold, AppBar, TextField, Card, Icon, CircularProgressIndicator, ElevatedButton
- **Layout**: Column, Row, Container, Padding, Expanded, SingleChildScrollView
- **Visual**: BoxDecoration, LinearGradient, BoxShadow

**Show**: 
- `home_screen.dart` lines 8-16 (StatefulWidget)
- `weather_info_card.dart` lines 3-12 (StatelessWidget)
- `home_screen.dart` lines 55-110 (widget composition)

---

### Q2: Explain your app's architecture

**Answer**: 
We use clean 3-layer architecture:
1. **Presentation Layer**: `screens/` and `widgets/` folders - UI components only
2. **Business Logic Layer**: `providers/` folder - State management with Provider pattern
3. **Data Layer**: `models/` and `services/` folders - Data structures and external communication (API, GPS)

This separates concerns: UI doesn't know about API details, services don't know about UI, making the app testable and maintainable.

**Show**: Folder structure in `lib/` directory

---

### Q3: How does state management work?

**Answer**: 
We use Provider pattern with ChangeNotifier:
1. **WeatherProvider** extends ChangeNotifier (holds state)
2. When data changes, calls `notifyListeners()`
3. **MultiProvider** wraps the app (makes provider available everywhere)
4. UI uses `Provider.of<WeatherProvider>(context)` to access state
5. UI automatically rebuilds when `notifyListeners()` is called

Benefits: No setState() everywhere, centralized logic, automatic UI updates.

**Show**:
- `weather_provider.dart` line 5 (ChangeNotifier)
- `weather_provider.dart` lines 18, 25 (notifyListeners calls)
- `main.dart` lines 14-16 (MultiProvider setup)
- `home_screen.dart` line 59 (Provider.of usage)

---

### Q4: What are Platform Channels and why use them?

**Answer**: 
Platform Channels allow Flutter (Dart) to communicate with native Android/iOS code. We use them for GPS location because:
1. Flutter can't directly access all platform features
2. GPS requires native APIs (LocationManager on Android, CoreLocation on iOS)
3. Need to handle platform-specific permissions

We use MethodChannel with identifier 'com.whindy.location' that MUST match on all sides. Dart calls invokeMethod(), native code responds with GPS coordinates.

**Show**:
- `location_service.dart` line 8 (Dart MethodChannel)
- `MainActivity.kt` line 16 (Android channel)
- `AppDelegate.swift` line 16 (iOS channel)
- Point out matching names!

---

### Q5: Explain async/await in your code

**Answer**: 
Network calls and GPS take time. We use async/await to prevent freezing the UI:
1. Mark function with `async`
2. Use `await` before long-running operations
3. Execution pauses at `await` but UI keeps running
4. When result arrives, execution continues
5. User sees spinner while waiting, stays interactive

Example: `fetchWeather()` sets loading=true, awaits API call (UI shows spinner), then sets loading=false (UI shows result).

**Show**: `weather_provider.dart` lines 15-27

---

### Q6: How does your app handle permissions?

**Answer**:
**Android**: 
- Checks permission with `checkSelfPermission()`
- If denied, calls `requestPermissions()` (shows system dialog)
- Waits for user response in `onRequestPermissionsResult()` callback
- Then gets location or returns error

**iOS**:
- Uses `CLLocationManager` 
- Calls `requestWhenInUseAuthorization()` (shows system dialog)
- Waits for delegate callback `locationManagerDidChangeAuthorization()`
- Then gets location or returns error

Both handle denial gracefully by returning error to Flutter, which shows user-friendly message.

**Show**:
- `MainActivity.kt` lines 27-33 (check), 48-72 (callback)
- `AppDelegate.swift` lines 50-62 (request), 95-101 (callback)

---

## 🎬 Demo Flow for Exam

1. **Show Folder Structure**:
   - Open `lib/` folder
   - Explain: models (data), services (external comm), providers (logic), screens+widgets (UI)

2. **Show StatelessWidget**:
   - Open `weather_info_card.dart`
   - Explain: No state, just takes props and displays

3. **Show StatefulWidget**:
   - Open `home_screen.dart` lines 8-25
   - Point out: State class, TextEditingController, dispose method

4. **Show State Management**:
   - Open `weather_provider.dart`
   - Point out: ChangeNotifier, private state, notifyListeners
   - Open `main.dart` lines 14-16
   - Show MultiProvider wrapping app

5. **Show Platform Channels**:
   - Open `location_service.dart` line 8
   - Open `MainActivity.kt` line 16
   - Open `AppDelegate.swift` line 16
   - **Emphasize**: All three have 'com.whindy.location' - MUST MATCH!

6. **Run App** (if allowed):
   - Search city → Shows API call
   - Click "Use Current Location" → Shows Platform Channel
   - Grant permission → Shows GPS working
   - Point out badge: "Location fetched via Platform Channels 📍"

---

## 📍 File Paths Quick Reference

| What | Where | Lines |
|------|-------|-------|
| Entry point | `lib/main.dart` | 7-9, 14-23 |
| StatelessWidget | `lib/widgets/weather_info_card.dart` | 3-42 |
| StatefulWidget | `lib/screens/home_screen.dart` | 8-25 |
| Model + fromJson | `lib/models/weather_model.dart` | 20-30 |
| Weather API | `lib/services/weather_service.dart` | 10-49 |
| Platform Channel (Dart) | `lib/services/location_service.dart` | 8, 13-38 |
| Platform Channel (Android) | `android/.../MainActivity.kt` | 16, 24-101 |
| Platform Channel (iOS) | `ios/Runner/AppDelegate.swift` | 16-95 |
| ChangeNotifier | `lib/providers/weather_provider.dart` | 5-42 |
| MultiProvider | `lib/main.dart` | 14-16 |
| Provider usage | `lib/screens/home_screen.dart` | 59 |
| Location button | `lib/screens/home_screen.dart` | 88-106 |
| Permissions (Android) | `android/.../AndroidManifest.xml` | 2-4 |
| Permissions (iOS) | `ios/Runner/Info.plist` | 47-50 |

---

## ✅ Pre-Exam Checklist

- [ ] Read [DEV.md](DEV.md) thoroughly
- [ ] Can explain folder structure and why
- [ ] Know difference between StatelessWidget and StatefulWidget
- [ ] Understand Provider pattern data flow
- [ ] Can explain Platform Channels communication
- [ ] Know where MethodChannel names are (3 places)
- [ ] Understand async/await purpose
- [ ] Can explain permission handling
- [ ] Know exact file paths for each concept
- [ ] Tested app: search + location button

---

## 🎯 Key Points to Remember

✅ **Architecture**: 3 layers keep code organized and maintainable  
✅ **State Management**: Provider with ChangeNotifier and notifyListeners()  
✅ **Platform Channels**: MethodChannel for GPS, names MUST match  
✅ **Widgets**: Stateless for static, Stateful for dynamic with lifecycle  
✅ **Async**: Keeps UI responsive during network/GPS operations  
✅ **Permissions**: Both platforms request properly and handle responses

---

## 🚀 Why Our Choices?

**Provider over setState**: Centralized logic, no prop drilling, automatic updates  
**Platform Channels**: Only way to access native GPS APIs  
**GPS for weather**: Contextually appropriate, shows real-world use case  
**Clean architecture**: Separation of concerns, testable, scalable  
**Mock mode**: Can demo without internet or API key

---

**Remember**: Understand the WHY, not just the HOW. Be ready to explain your architectural decisions!

**Good luck! 🍀**
