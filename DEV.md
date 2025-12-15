# Developer Documentation (DEV.md)

## 📘 Introduction

This document provides a comprehensive technical deep dive into the **Whindy** weather application. It's designed to help developers, students, and examiners understand _how_ the app works, _why_ specific architectural decisions were made, and demonstrate mastery of core Flutter concepts.

**Perfect for exam preparation** - No IDE needed! This guide includes exact file paths and line numbers for easy reference in a text editor.

---

## 📋 Assignment Requirements - 100% Coverage

This project demonstrates **ALL** required Flutter concepts:

### ✅ 1. Widgets

**StatelessWidget**: Components that don't change after being built
- **WeatherInfoCard** (`lib/widgets/weather_info_card.dart`) - Reusable weather metric cards
- **MyApp** (`lib/main.dart`) - Root application widget

**StatefulWidget**: Components with mutable state and lifecycle
- **HomeScreen** (`lib/screens/home_screen.dart`) - Main screen with text input and location state

**Material Widgets Used**:
- Layout: `Scaffold`, `AppBar`, `Column`, `Row`, `Container`, `Padding`, `Expanded`
- Input: `TextField`, `TextEditingController`, `IconButton`, `ElevatedButton`
- Display: `Text`, `Icon`, `Card`, `CircularProgressIndicator`
- Scrolling: `SingleChildScrollView`
- Visual: `BoxDecoration`, `LinearGradient`, `BoxShadow`

**Location in Code**:
- StatefulWidget example: `lib/screens/home_screen.dart` lines 8-16
- StatelessWidget example: `lib/widgets/weather_info_card.dart` lines 3-12
- Widget composition: `lib/screens/home_screen.dart` lines 55-110 (search UI)

### ✅ 2. Flutter Architecture

**Clean 3-Layer Architecture**:

1. **Presentation Layer** (UI):
   - `lib/screens/` - Application screens
   - `lib/widgets/` - Reusable UI components

2. **Business Logic Layer**:
   - `lib/providers/` - State management (Provider pattern)

3. **Data Layer**:
   - `lib/models/` - Data structures (Weather model)
   - `lib/services/` - Data sources (API calls, Platform Channels)

**Folder Structure**:
```
lib/
├── main.dart                    # App entry point, Provider setup
├── models/
│   └── weather_model.dart       # Weather data structure
├── providers/
│   └── weather_provider.dart    # State management logic
├── services/
│   ├── location_service.dart    # Platform Channel - GPS
│   └── weather_service.dart     # Weather API calls
├── screens/
│   └── home_screen.dart         # Main UI screen
└── widgets/
    └── weather_info_card.dart   # Reusable info card
```

**Why this structure?**
- **Separation of Concerns**: UI doesn't know about API details
- **Testability**: Easy to test each layer independently
- **Maintainability**: Changes in one layer don't affect others
- **Scalability**: Easy to add new features

### ✅ 3. State Management (Provider Pattern)

**Components**:

1. **ChangeNotifier** (`weather_provider.dart` line 5):
   ```dart
   class WeatherProvider with ChangeNotifier
   ```
   - Holds app state (weather data, loading, errors)
   - Calls `notifyListeners()` when state changes
   - UI automatically rebuilds on changes

2. **Provider Setup** (`main.dart` lines 14-16):
   ```dart
   MultiProvider(
     providers: [ChangeNotifierProvider(create: (_) => WeatherProvider())],
     child: MaterialApp(...)
   )
   ```
   - Makes provider available throughout widget tree

3. **Provider Consumption** (`home_screen.dart` line 59):
   ```dart
   final weatherProvider = Provider.of<WeatherProvider>(context);
   ```
   - Accesses provider in UI
   - Listens for changes
   - Triggers rebuild when `notifyListeners()` called

**Data Flow**:
```
User Action (Search/Location)
    ↓
Provider Method Called
    ↓
Set isLoading = true, notifyListeners()
    ↓
Service Fetches Data (API/GPS)
    ↓
Update State, notifyListeners()
    ↓
UI Rebuilds Automatically
```

**Key Benefits**:
- No `setState()` scattered everywhere
- Centralized business logic
- Automatic UI updates
- Easy to test

### ✅ 4. Flutter Channels (Platform Channels)

**Feature**: GPS Location Services

**What**: Accesses native device GPS to get current coordinates

**Why**: Weather apps need location! Demonstrates Flutter's ability to communicate with native platform code for features not available in pure Dart.

**Implementation**:

**Dart Side** (`lib/services/location_service.dart`):
- Line 8: `MethodChannel('com.whindy.location')` - Creates communication bridge
- Line 12-25: `getCurrentLocation()` - Calls native code
- Line 20: `platform.invokeMethod('getCurrentLocation')` - The actual call
- Line 27-30: `PlatformException` handling

**Android Side** (`android/.../MainActivity.kt`):
- Line 16: Channel identifier `"com.whindy.location"` - MUST match Dart side
- Line 24-46: Method call handler
- Line 48-72: Permission request callback
- Line 79-101: Native GPS implementation using `LocationManager`
- **Permission Handling**: Requests permission, waits for user response, then gets location

**iOS Side** (`ios/Runner/AppDelegate.swift`):
- Line 16: Channel setup `"com.whindy.location"`
- Line 19-28: Method call handler
- Line 35-62: Permission and location logic using `CoreLocation`
- Line 71-95: Delegate methods for location updates

**Permissions**:
- Android: `AndroidManifest.xml` lines 2-4
- iOS: `Info.plist` lines 47-50

**Communication Flow**:
```
1. User taps "Use Current Location" button
2. Flutter calls: LocationService.getCurrentLocation()
3. MethodChannel invokes: 'getCurrentLocation'
4. Native code checks permissions
5. If needed: Shows permission dialog
6. User grants permission
7. Native code gets GPS coordinates
8. Returns: {latitude: X, longitude: Y}
9. Flutter receives result
10. Calls weather API with coordinates
11. Displays weather data
```

**Critical Rule**: Channel names MUST match exactly on all sides!

---

## 📂 Detailed Component Breakdown

### 1. Entry Point (`main.dart`)

**Purpose**: App initialization

**Key Elements**:
- Line 7-9: `async main()` - Loads `.env` file before app starts
- Line 8: `dotenv.load()` - Loads API key from environment
- Line 14-16: `MultiProvider` - Injects state management
- Line 17-23: `MaterialApp` - App configuration and theme

**Why async main?**
Environment variables must load before app starts, so we need an async entry point.

### 2. Data Model (`models/weather_model.dart`)

**Purpose**: Structured data representation

```dart
class Weather {
  final String cityName;
  final double temperature;
  final String description;
  final String iconCode;
  final double humidity;
  final double windSpeed;
}
```

**Key Method**: `fromJson()` (lines 20-30)
- Converts raw API JSON to typed Dart object
- Handles type casting (`as num` → `toDouble()`)
- Provides null safety with default values

**Why?**
- Type safety (catch errors at compile time)
- Clear structure (know what data we have)
- Easy to work with (no nested maps)

### 3. Services Layer

#### Weather Service (`services/weather_service.dart`)

**Methods**:

1. **`fetchWeather(String cityName)`** (lines 10-27):
   - Fetches weather by city name
   - URL: `/weather?q={city}&appid={key}&units=metric`

2. **`fetchWeatherByCoordinates(lat, lon)`** (lines 30-49):
   - Fetches weather by GPS coordinates
   - URL: `/weather?lat={lat}&lon={lon}&appid={key}&units=metric`
   - **Used by Platform Channels feature!**

3. **Mock Data Methods** (lines 51-74):
   - Returns fake data when no API key
   - Ensures app works for demo/testing

**API Integration**:
- Line 13-16: Check for API key, use mock if missing
- Line 21-22: HTTP GET request
- Line 24-26: Parse JSON response

#### Location Service (`services/location_service.dart`)

**Platform Channel Implementation**:
- Line 8: Channel declaration `MethodChannel('com.whindy.location')`
- Line 13-38: `getCurrentLocation()` method
- Line 20-23: Native method invocation
- Line 25-27: Result parsing to Map<String, double>
- Line 29-35: Error handling (PlatformException, general Exception)

**Returns**: `{latitude: X, longitude: Y}` or `null`

### 4. State Manager (`providers/weather_provider.dart`)

**Class Structure**:
- Line 5: `extends ChangeNotifier` - Enables reactive updates
- Lines 6-9: Private state variables
- Lines 11-13: Public getters (encapsulation)

**Methods**:

1. **`fetchWeather(String cityName)`** (lines 15-27):
   - Sets loading state
   - Calls weather service
   - Updates state
   - Notifies listeners (UI rebuilds)

2. **`fetchWeatherByLocation(lat, lon)`** (lines 30-42):
   - Same pattern but uses coordinates
   - **Called after Platform Channel returns GPS data**

**State Flow**:
```
_isLoading = true  →  notifyListeners()  →  UI shows spinner
        ↓
  await service
        ↓
_weather = data  →  notifyListeners()  →  UI shows weather
```

### 5. Main Screen (`screens/home_screen.dart`)

**State Variables** (lines 16-18):
- `_cityController`: Text input management
- `_locationService`: Platform Channel service
- `_isFetchingLocation`: Loading state for GPS

**Key Methods**:

1. **`_fetchWeatherForCurrentLocation()`** (lines 26-52):
   - Calls Platform Channel to get GPS
   - Shows error if permission denied
   - Fetches weather with coordinates

2. **`_buildWeatherDisplay()`** (lines 116-290):
   - Conditional rendering based on state
   - Loading: Spinner + message
   - Error: Error icon + message
   - Success: Beautiful weather card
   - Empty: Welcome message

**UI Structure**:
```
Scaffold
├── AppBar (gradient background)
├── Body
│   ├── Search Section (gradient container)
│   │   ├── Search TextField
│   │   └── "Use Current Location" Button ← Platform Channels!
│   └── Weather Display
│       ├── Main Weather Card (gradient)
│       ├── Info Cards (Humidity, Wind)
│       └── Platform Channel Badge
```

**Platform Channel Integration**:
- Line 88-106: Location button
- Line 26-52: Method that calls Platform Channel
- Line 258-269: Badge showing location was used

### 6. Custom Widget (`widgets/weather_info_card.dart`)

**StatelessWidget Example**:
- Lines 3-12: Widget declaration with required parameters
- Lines 14-42: Build method returning Card widget
- Uses theme colors, icons, and styling

**Why separate widget?**
- Reusability (used for humidity AND wind)
- Cleaner code (single responsibility)
- Easy to modify (change once, updates everywhere)

---

## 🎓 Core Flutter Concepts Explained

### StatelessWidget vs StatefulWidget

**StatelessWidget** (`WeatherInfoCard`):
```dart
class WeatherInfoCard extends StatelessWidget {
  final String title;
  const WeatherInfoCard({required this.title});
  
  @override
  Widget build(BuildContext context) => Card(...);
}
```
- Immutable (can't change after creation)
- No state, no lifecycle methods
- Rebuilds only when parent rebuilds
- Lighter weight

**StatefulWidget** (`HomeScreen`):
```dart
class HomeScreen extends StatefulWidget {
  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final TextEditingController _controller = TextEditingController();
  
  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }
  
  @override
  Widget build(BuildContext context) => Scaffold(...);
}
```
- Mutable state
- Lifecycle: initState → build → dispose
- Can call setState() to rebuild
- Manages resources (controllers, listeners)

**Lifecycle**:
```
createState() → initState() → build() → [updates...] → dispose()
```

### Future & async/await

**The Problem**: Network calls take time, can't freeze UI

**The Solution**:
```dart
Future<Weather> fetchWeather(String city) async {
  _isLoading = true;
  notifyListeners();  // UI shows spinner
  
  // This line pauses HERE, but UI keeps running!
  final data = await weatherService.fetchWeather(city);
  
  _isLoading = false;
  notifyListeners();  // UI shows data
}
```

**Key Concepts**:
- `Future<T>`: Value that will be available later
- `async`: Function can pause and resume
- `await`: Pause here until result arrives
- UI remains responsive during wait

### JSON Parsing

**API Response** (String):
```json
{
  "name": "London",
  "main": {"temp": 15.5, "humidity": 65},
  "weather": [{"description": "Cloudy"}],
  "wind": {"speed": 5.2}
}
```

**Parsing Steps**:
1. String → Map: `jsonDecode(response.body)`
2. Map → Object: `Weather.fromJson(map)`

**fromJson Method**:
```dart
factory Weather.fromJson(Map<String, dynamic> json) {
  return Weather(
    cityName: json['name'] ?? '',
    temperature: (json['main']['temp'] as num).toDouble(),
    description: json['weather'][0]['description'] ?? '',
    // ...
  );
}
```

**Why?**
- Type safety (compiler catches errors)
- Null safety (`??` provides defaults)
- Clean code (`weather.temperature` vs `json['main']['temp']`)

### Provider Pattern Deep Dive

**Problem**: How to share data between distant widgets?

**Bad Solution**: Pass data through every widget (prop drilling)

**Good Solution**: Provider pattern

**Setup**:
```dart
// 1. Create ChangeNotifier
class WeatherProvider with ChangeNotifier {
  Weather? _weather;
  
  void updateWeather(Weather w) {
    _weather = w;
    notifyListeners();  // Magic happens here!
  }
}

// 2. Provide at top level
MultiProvider(
  providers: [ChangeNotifierProvider(create: (_) => WeatherProvider())],
  child: MyApp(),
)

// 3. Use anywhere in tree
final provider = Provider.of<WeatherProvider>(context);
provider.updateWeather(newWeather);  // All listeners rebuild!
```

**Benefits**:
- No prop drilling
- Automatic updates
- Centralized logic
- Easy testing

### Platform Channels In-Depth

**What**: Communication bridge between Flutter and native code

**When**: Need platform-specific features (GPS, camera, Bluetooth, etc.)

**Types**:
1. **MethodChannel**: Request-response (we use this)
2. **EventChannel**: Streaming events
3. **BasicMessageChannel**: Custom messages

**Our Implementation**:

**Dart** (`location_service.dart`):
```dart
static const platform = MethodChannel('com.whindy.location');

Future<Map<String, double>?> getCurrentLocation() async {
  final result = await platform.invokeMethod('getCurrentLocation');
  return {
    'latitude': result['latitude'] as double,
    'longitude': result['longitude'] as double,
  };
}
```

**Android** (`MainActivity.kt`):
```kotlin
private val CHANNEL = "com.whindy.location"  // MUST MATCH!

MethodChannel(flutterEngine.dartExecutor.binaryMessenger, CHANNEL)
  .setMethodCallHandler { call, result ->
    if (call.method == "getCurrentLocation") {
      // Check permissions
      if (hasPermission()) {
        val location = getGPS()
        result.success(mapOf("latitude" to location.lat, ...))
      } else {
        requestPermission()  // Android system dialog
        // Wait for callback...
      }
    }
  }

override fun onRequestPermissionsResult(...) {
  if (granted) {
    val location = getGPS()
    result.success(location)
  } else {
    result.error("PERMISSION_DENIED", "User denied", null)
  }
}
```

**iOS** (`AppDelegate.swift`):
```swift
let channel = FlutterMethodChannel(name: "com.whindy.location", ...)

channel.setMethodCallHandler { (call, result) in
  if call.method == "getCurrentLocation" {
    locationManager.requestWhenInUseAuthorization()
    locationManager.requestLocation()
    // Delegate receives location...
  }
}

func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
  let loc = locations.last!
  result(["latitude": loc.coordinate.latitude, ...])
}
```

**Critical Rules**:
1. Channel name MUST match on all sides
2. Method name MUST match
3. Handle errors properly
4. Request permissions before accessing features
5. Platform channels don't work on web

**Permission Flow**:
```
Flutter calls getCurrentLocation
    ↓
Native checks: Do we have permission?
    ↓
NO → Show system permission dialog
    ↓
User grants/denies
    ↓
Callback receives result
    ↓
If granted: Get GPS and return to Flutter
If denied: Return error to Flutter
```

---

## 🎯 Exam Preparation Guide

### Quick File Reference

| Concept | File | Key Lines |
|---------|------|-----------|
| Entry Point | `main.dart` | 7-9, 14-23 |
| StatelessWidget | `weather_info_card.dart` | 3-42 (full file) |
| StatefulWidget | `home_screen.dart` | 8-25 |
| Model | `weather_model.dart` | 20-30 (fromJson) |
| Weather API | `weather_service.dart` | 10-27, 30-49 |
| Platform Channel (Dart) | `location_service.dart` | 8, 13-38 |
| Platform Channel (Android) | `MainActivity.kt` | 16, 24-72 |
| Platform Channel (iOS) | `AppDelegate.swift` | 16-95 |
| Provider Setup | `main.dart` | 14-16 |
| Provider Class | `weather_provider.dart` | 5-42 |
| Provider Usage | `home_screen.dart` | 59 |
| UI Location Button | `home_screen.dart` | 88-106 |
| UI Weather Display | `home_screen.dart` | 116-290 |

### Common Exam Questions

**Q: Explain StatelessWidget vs StatefulWidget**

**A**: StatelessWidget is immutable and has no state (e.g., WeatherInfoCard). StatefulWidget has mutable state and lifecycle methods (e.g., HomeScreen with TextEditingController). Use Stateful when you need to manage state like form inputs, animations, or data that changes.

**Show**: `weather_info_card.dart` (Stateless) vs `home_screen.dart` lines 8-25 (Stateful)

---

**Q: Describe your app's architecture**

**A**: We use clean 3-layer architecture:
1. Presentation (screens, widgets) - UI only
2. Business Logic (providers) - State management
3. Data (models, services) - API calls and data structures

This separates concerns, making the app testable and maintainable.

**Show**: Folder structure in `lib/`

---

**Q: How does state management work in your app?**

**A**: We use Provider pattern with ChangeNotifier. WeatherProvider holds state and calls notifyListeners() when data changes. MultiProvider makes it available app-wide. UI uses Provider.of to access state and automatically rebuilds on changes.

**Show**: 
- `weather_provider.dart` line 5 (ChangeNotifier)
- `main.dart` lines 14-16 (MultiProvider)
- `home_screen.dart` line 59 (Provider.of)
- `weather_provider.dart` lines 18, 25 (notifyListeners calls)

---

**Q: What are Flutter Channels and why do you use them?**

**A**: Platform Channels allow Flutter to call native Android/iOS code. We use them for GPS location because Flutter can't directly access device GPS. We use MethodChannel with identifier 'com.whindy.location' that matches on both Dart and native sides.

**Show**:
- `location_service.dart` line 8 (Dart channel)
- `MainActivity.kt` line 16 (Android channel)
- `AppDelegate.swift` line 16 (iOS channel)

---

**Q: Explain async/await in your weather fetching**

**A**: Network calls take time. We mark the function `async` and use `await` before the API call. This pauses the function execution without freezing the UI. When data arrives, execution continues. Meanwhile, the UI stays responsive and can show a loading spinner.

**Show**: `weather_provider.dart` lines 15-27

---

**Q: How does your app handle location permissions?**

**A**: 
- **Android**: Checks permission, if denied requests it via ActivityCompat.requestPermissions(), waits for callback in onRequestPermissionsResult(), then gets location
- **iOS**: Uses CLLocationManager, requests with requestWhenInUseAuthorization(), gets result in delegate methods

Both handle permission denial by returning error to Flutter.

**Show**:
- `MainActivity.kt` lines 27-33, 48-72
- `AppDelegate.swift` lines 50-62, 95-101

---

### Demo Steps for Exam

1. **Show Architecture**:
   - Open `lib/` folder structure
   - Explain 3 layers

2. **Show Widgets**:
   - `weather_info_card.dart` - StatelessWidget
   - `home_screen.dart` - StatefulWidget with lifecycle

3. **Show State Management**:
   - `weather_provider.dart` - ChangeNotifier
   - `main.dart` - MultiProvider
   - Point out notifyListeners() calls

4. **Show Platform Channels**:
   - `location_service.dart` - Dart side
   - `MainActivity.kt` - Android native
   - `AppDelegate.swift` - iOS native
   - Point out matching channel names

5. **Run App** (if possible):
   - Search for city (normal feature)
   - Click "Use Current Location" (Platform Channel demo)
   - Point out permission request
   - Show weather displayed from GPS

### What to Remember

✅ **Architecture**: 3 layers - Presentation, Logic, Data  
✅ **State Management**: Provider with ChangeNotifier and notifyListeners()  
✅ **Platform Channels**: MethodChannel for GPS, channel names must match  
✅ **Widgets**: Stateless for static, Stateful for dynamic with lifecycle  
✅ **Async**: Network calls use async/await to keep UI responsive  
✅ **Permissions**: Both platforms request and handle permission callbacks

---

## 🚀 Running the App

### Development:
```bash
flutter run
```

### Building for Release:
```bash
flutter build apk          # Android
flutter build ios          # iOS
flutter build web          # Web
```

### Testing:
```bash
flutter test
```

---

## 📝 Additional Notes

### Environment Variables

File: `.env` (create in root if using real API)
```env
API_KEY=your_openweathermap_key_here
```

### Mock Mode

If no API key provided, app uses mock data generator. Perfect for demos without internet!

### Platform Limitations

- **GPS Location**: Android & iOS only (not web)
- **Web Version**: City search works, but no GPS

---

## ✅ Final Checklist

- ✅ All 4 assignment requirements covered
- ✅ Clean architecture implemented
- ✅ State management with Provider
- ✅ Platform Channels for GPS (contextually appropriate!)
- ✅ Proper permission handling
- ✅ Modern, beautiful UI
- ✅ Well-documented code
- ✅ Exam-ready with exact file references

**This app demonstrates professional Flutter development practices and all required concepts. Perfect for your exam!** 🎓

---

**Good luck! 🍀**
