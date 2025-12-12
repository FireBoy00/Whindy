# Whindy 🌬️

**Whindy** is a modern, intuitive weather application built with Flutter. It allows users to search for cities and view current weather conditions, including temperature, humidity, wind speed, and weather descriptions.

This project was developed as a university project to demonstrate core Flutter concepts, state management, and API integration.

## 📱 Features

-   **City Search**: Search for weather conditions in any city globally.
-   **Real-time Data**: Fetches live weather data (configurable to use OpenWeatherMap).
-   **Mock Mode**: Includes a built-in mock data service for testing without an API key.
-   **Responsive UI**: Clean and modern interface that adapts to screen sizes.
-   **Detailed Metrics**: Displays Temperature, Humidity, Wind Speed, and Weather Conditions.

## 🚀 Getting Started

### Prerequisites

-   [Flutter SDK](https://flutter.dev/docs/get-started/install) installed on your machine.
-   An IDE (VS Code or Android Studio) with Flutter plugins.

### Installation

1.  **Clone the repository** (or extract the project files):

    ```bash
    git clone https://github.com/yourusername/whindy.git
    cd whindy
    ```

2.  **Install Dependencies**:

    ```bash
    flutter pub get
    ```

3.  **Run the App**:
    ```bash
    flutter run
    ```

## ⚙️ Configuration (API Key)

By default, the app runs in **Mock Mode**, simulating network requests so you can test the UI immediately. To use real weather data:

1.  Get a free API Key from [OpenWeatherMap](https://openweathermap.org/api).
2.  Open `lib/services/weather_service.dart`.
3.  Find the `_apiKey` variable and replace `'YOUR_API_KEY'` with your actual key:
    ```dart
    static const String _apiKey = '123456789abcdef...'; // Your actual key
    ```
4.  Restart the app.

## 📂 Project Structure

The project follows a clean architecture approach:

-   `lib/models`: Data structures (e.g., `Weather` object).
-   `lib/services`: Data fetching logic (API calls).
-   `lib/providers`: State management (business logic).
-   `lib/screens`: UI screens (pages).
-   `lib/widgets`: Reusable UI components.

## 👨‍💻 Team

Developed by a dedicated team of four for our university project.

---

_For a deep dive into the code and architecture, please refer to [DEV.md](DEV.md)._
