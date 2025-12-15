# Whindy 🌬️☀️

**Whindy** is a modern, beautiful weather application built with Flutter. Search for any city worldwide or use your current GPS location to get real-time weather information.

![Flutter](https://img.shields.io/badge/Flutter-Framework-02569B?logo=flutter)
![Dart](https://img.shields.io/badge/Dart-Language-0175C2?logo=dart)

## ✨ Features

-   🔍 **City Search**: Search for weather in any city around the world
-   📍 **Current Location**: Tap a button to get weather for your GPS location
-   🌡️ **Real-time Data**: Live weather including temperature, humidity, and wind speed
-   🎨 **Beautiful UI**: Modern Material 3 design with gradients and smooth animations
-   🔌 **Mock Mode**: Test the app without an API key using built-in mock data
-   📱 **Cross-platform**: Works on Android, iOS, Web, Windows, macOS, and Linux

## 📸 Screenshots

_Beautiful gradient design • GPS location integration • Clean weather display_

## 🚀 Getting Started

### Prerequisites

-   [Flutter SDK](https://flutter.dev/docs/get-started/install) (3.10.3 or higher)
-   An IDE (VS Code, Android Studio, or any text editor)
-   Optional: [OpenWeatherMap API Key](https://openweathermap.org/api) for real weather data

### Quick Start

1.  **Clone the repository**:

    ```bash
    git clone https://github.com/FireBoy00/Whindy.git
    cd Whindy
    ```

2.  **Install dependencies**:

    ```bash
    flutter pub get
    ```

3.  **Run the app**:
    ```bash
    flutter run
    ```

The app runs in **Mock Mode** by default, so you can test it immediately without any API key!

## 🔑 Using Real Weather Data (Optional)

To get live weather data:

1.  Get a free API key from [OpenWeatherMap](https://openweathermap.org/api)
2.  Create a `.env` file in the project root:
    ```env
    API_KEY=your_api_key_here
    ```
3.  Restart the app

> **Security Note**: The `.env` file is in `.gitignore` to keep your API key private.

## 🏗️ Tech Stack

-   **Framework**: Flutter 3.10.3
-   **Language**: Dart
-   **State Management**: Provider Pattern
-   **Architecture**: Clean Architecture (Models, Services, Providers, UI)
-   **Platform Channels**: Native GPS location access (Android & iOS)
-   **API**: OpenWeatherMap (optional)

## 🎓 Educational Purpose

This project was developed as a university assignment to demonstrate:

-   ✅ Flutter Widgets (Stateless & Stateful)
-   ✅ Flutter Architecture & Project Structure
-   ✅ State Management (Provider Pattern)
-   ✅ Platform Channels (GPS Location Services)

## 📱 Supported Platforms

-   ✅ Android
-   ✅ iOS
-   ✅ Web (city search only)
-   ✅ Windows
-   ✅ macOS
-   ✅ Linux

_Note: GPS location feature works on Android and iOS only._

## 📄 License

This project is open source and available for educational purposes.

## 👥 Contributors

Developed by a team of four as a university project.

## 🔗 Links

-   [Flutter Documentation](https://flutter.dev/docs)
-   [OpenWeatherMap API](https://openweathermap.org/api)

---

### 📚 For Developers & Students

If you're examining this code for educational purposes or preparing for an exam, check out:

-   **[DEV.md](DEV.md)** - Comprehensive technical documentation with code explanations
-   **[EXAM_QUICK_REFERENCE.md](EXAM_QUICK_REFERENCE.md)** - Quick reference for finding code examples
-   **[CHANGES_SUMMARY.md](CHANGES_SUMMARY.md)** - Recent changes and improvements

**Built with ❤️ using Flutter**
