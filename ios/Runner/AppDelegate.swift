import Flutter
import UIKit
import CoreLocation

@main
@objc class AppDelegate: FlutterAppDelegate, CLLocationManagerDelegate {
  private var locationManager: CLLocationManager?
  private var locationResult: FlutterResult?
  
  override func application(
    _ application: UIApplication,
    didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?
  ) -> Bool {
    
    // Set up the MethodChannel - must match the channel name in Dart
    let controller : FlutterViewController = window?.rootViewController as! FlutterViewController
    let locationChannel = FlutterMethodChannel(name: "com.whindy.location",
                                              binaryMessenger: controller.binaryMessenger)
    
    locationChannel.setMethodCallHandler({
      [weak self] (call: FlutterMethodCall, result: @escaping FlutterResult) -> Void in
      // Handle method calls from Flutter
      guard call.method == "getCurrentLocation" else {
        result(FlutterMethodNotImplemented)
        return
      }
      self?.getCurrentLocation(result: result)
    })
    
    GeneratedPluginRegistrant.register(with: self)
    return super.application(application, didFinishLaunchingWithOptions: launchOptions)
  }
  
  /**
   * Gets the current GPS location
   * This is the native iOS code that requests location from CoreLocation
   */
  private func getCurrentLocation(result: @escaping FlutterResult) {
    locationResult = result
    
    // Initialize location manager if needed
    if locationManager == nil {
      locationManager = CLLocationManager()
      locationManager?.delegate = self
      locationManager?.desiredAccuracy = kCLLocationAccuracyBest
    }
    
    // Check authorization status
    let status = CLLocationManager.authorizationStatus()
    
    switch status {
    case .notDetermined:
      // Request permission
      locationManager?.requestWhenInUseAuthorization()
      locationManager?.requestLocation()
    case .authorizedWhenInUse, .authorizedAlways:
      // Permission granted, get location
      locationManager?.requestLocation()
    case .denied, .restricted:
      result(FlutterError(code: "PERMISSION_DENIED",
                         message: "Location permission denied.",
                         details: nil))
      locationResult = nil
    @unknown default:
      result(FlutterError(code: "UNKNOWN",
                         message: "Unknown authorization status.",
                         details: nil))
      locationResult = nil
    }
  }
  
  // CLLocationManagerDelegate methods
  func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
    guard let location = locations.last, let result = locationResult else { return }
    
    let locationData: [String: Double] = [
      "latitude": location.coordinate.latitude,
      "longitude": location.coordinate.longitude
    ]
    
    result(locationData)
    locationResult = nil
  }
  
  func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
    guard let result = locationResult else { return }
    
    result(FlutterError(code: "UNAVAILABLE",
                       message: "Failed to get location: \(error.localizedDescription)",
                       details: nil))
    locationResult = nil
  }
  
  func locationManagerDidChangeAuthorization(_ manager: CLLocationManager) {
    // Only request location if we have a pending result
    // This prevents unnecessary location requests when authorization changes
    guard locationResult != nil else { return }
    
    let status = manager.authorizationStatus
    if status == .authorizedWhenInUse || status == .authorizedAlways {
      manager.requestLocation()
    } else if status == .denied || status == .restricted {
      locationResult?(FlutterError(code: "PERMISSION_DENIED",
                                   message: "Location permission denied.",
                                   details: nil))
      locationResult = nil
    }
  }
}
