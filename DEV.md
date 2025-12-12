# Developer Documentation (DEV.md)

## 📘 Introduction

This document provides a technical deep dive into the **Whindy** application. It is designed to help developers, students, and examiners understand _how_ the app works, _why_ specific architectural decisions were made, and the core Flutter concepts utilized.

## 🏗️ Architecture: The Provider Pattern

We use the **Provider** package for state management. This is a standard approach in Flutter to separate the **UI (User Interface)** from the **Business Logic**.

### Why Provider?

1.  **Separation of Concerns**: The UI (`screens/`) doesn't know _how_ data is fetched; it just asks for it.
2.  **Reactivity**: When data changes (e.g., weather is loaded), the UI updates automatically without us manually calling `setState()` everywhere.
3.  **Testability**: It's easier to test logic when it's not mixed with UI code.

### Data Flow

1.  **User** types a city and hits search.
2.  **UI** calls `Provider.fetchWeather(city)`.
3.  **Provider** sets `isLoading = true` (UI shows spinner).
4.  **Provider** asks **Service** for data.
5.  **Service** calls API (or Mock) and returns a **Model**.
6.  **Provider** updates its `weather` variable and sets `isLoading = false`.
7.  **UI** notices the change and redraws with the new data.

---

## 📂 Key Components Explained

### 1. The Entry Point (`main.dart`)

This is where the app starts.

-   **`MultiProvider`**: We wrap the entire app in this widget. It injects our `WeatherProvider` into the widget tree, making it accessible from _anywhere_ in the app.
-   **`MaterialApp`**: Sets up the visual theme and navigation.

### 2. The Data Model (`models/weather_model.dart`)

-   **What it is**: A simple class (blueprint) that represents "Weather".
-   **`fromJson`**: A factory constructor. APIs return data in JSON format (a map of strings and values). This method converts that raw JSON into a structured Dart object we can safely use (e.g., `json['main']['temp']` becomes `weather.temperature`).

### 3. The Service Layer (`services/weather_service.dart`)

-   **Responsibility**: Talking to the outside world (Internet).
-   **`http` package**: Used to send GET requests to OpenWeatherMap.
-   **Mock Logic**: You will notice a check: `if (_apiKey == 'YOUR_API_KEY')`. This allows the app to function for demonstration purposes even without a valid API key by generating fake data based on the city name. This is crucial for reliable presentations where internet or API limits might be issues.

### 4. The State Manager (`providers/weather_provider.dart`)

-   **`ChangeNotifier`**: A built-in Flutter class. It allows us to call `notifyListeners()`.
-   **`fetchWeather()`**:
    1.  Sets loading state -> `notifyListeners()` (Screen shows loader).
    2.  Awaits service data.
    3.  Sets data or error -> `notifyListeners()` (Screen shows data or error).

### 5. The UI (`screens/home_screen.dart`)

-   **`Consumer` / `Provider.of`**: These methods allow the widget to "listen" to the provider.
-   **Conditional Rendering**:
    ```dart
    if (provider.isLoading) return CircularProgressIndicator();
    if (provider.error != null) return Text('Error');
    if (provider.weather != null) return WeatherDisplay();
    ```
    This ensures the user always sees the correct state of the application.

---

## 🎓 Core Flutter Concepts Used

### `StatelessWidget` vs `StatefulWidget`

-   **Stateless**: Used for static UI parts (like `WeatherInfoCard`). They don't change once built.
-   **Stateful**: Used for `HomeScreen` because we need to manage the `TextEditingController` for the search bar, which has its own internal lifecycle (init/dispose).

### `Future` and `async/await`

Fetching weather takes time (milliseconds to seconds). We use `async` functions to perform these long-running tasks without "freezing" the app. The `await` keyword pauses the function execution until the data arrives, while the UI keeps running smoothly.

### `JSON Parsing`

APIs send data as text strings formatted as JSON. We use `dart:convert` to turn this text into a Map, and then our Model turns that Map into a Dart Object.

---

## 🔮 Future Improvements (For Discussion)

If we were to extend this project, we could add:

1.  **Geolocation**: Use the `geolocator` package to find the user's current city automatically.
2.  **Local Storage**: Use `shared_preferences` to save the last searched city so it loads on startup.
3.  **5-Day Forecast**: Create a new model and API call to fetch forecast data and display it in a `ListView`.
