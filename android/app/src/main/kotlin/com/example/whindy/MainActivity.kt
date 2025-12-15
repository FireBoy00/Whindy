package com.example.whindy

import android.Manifest
import android.content.Context
import android.content.pm.PackageManager
import android.location.LocationManager
import androidx.annotation.NonNull
import androidx.core.app.ActivityCompat
import androidx.core.content.ContextCompat
import io.flutter.embedding.android.FlutterActivity
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.plugin.common.MethodChannel

class MainActivity : FlutterActivity() {
    // Define the channel name - must match the Dart side
    private val CHANNEL = "com.whindy.location"
    private val LOCATION_PERMISSION_REQUEST_CODE = 1
    private var pendingResult: MethodChannel.Result? = null

    override fun configureFlutterEngine(@NonNull flutterEngine: FlutterEngine) {
        super.configureFlutterEngine(flutterEngine)

        // Set up the MethodChannel
        MethodChannel(flutterEngine.dartExecutor.binaryMessenger, CHANNEL).setMethodCallHandler {
            call, result ->
            // Handle method calls from Flutter
            if (call.method == "getCurrentLocation") {
                // Check if we have location permission
                if (ContextCompat.checkSelfPermission(this, Manifest.permission.ACCESS_FINE_LOCATION)
                    != PackageManager.PERMISSION_GRANTED) {
                    // Store the result to respond to later
                    pendingResult = result
                    // Request permission - will be handled in onRequestPermissionsResult
                    ActivityCompat.requestPermissions(this,
                        arrayOf(Manifest.permission.ACCESS_FINE_LOCATION),
                        LOCATION_PERMISSION_REQUEST_CODE)
                } else {
                    // Get location
                    val location = getCurrentLocation()
                    if (location != null) {
                        result.success(location)
                    } else {
                        result.error("UNAVAILABLE", "Location not available.", null)
                    }
                }
            } else {
                result.notImplemented()
            }
        }
    }

    /**
     * Handle permission request results
     */
    override fun onRequestPermissionsResult(
        requestCode: Int,
        permissions: Array<out String>,
        grantResults: IntArray
    ) {
        super.onRequestPermissionsResult(requestCode, permissions, grantResults)
        
        if (requestCode == LOCATION_PERMISSION_REQUEST_CODE) {
            if (grantResults.isNotEmpty() && grantResults[0] == PackageManager.PERMISSION_GRANTED) {
                // Permission granted, get location
                val location = getCurrentLocation()
                if (location != null) {
                    pendingResult?.success(location)
                } else {
                    pendingResult?.error("UNAVAILABLE", "Location not available.", null)
                }
            } else {
                // Permission denied
                pendingResult?.error("PERMISSION_DENIED", "Location permission was denied.", null)
            }
            pendingResult = null
        }
    }

    /**
     * Gets the current GPS location
     * Returns a Map with latitude and longitude
     */
    private fun getCurrentLocation(): Map<String, Double>? {
        try {
            val locationManager = getSystemService(Context.LOCATION_SERVICE) as LocationManager
            
            // Check permission again
            if (ActivityCompat.checkSelfPermission(this, Manifest.permission.ACCESS_FINE_LOCATION)
                != PackageManager.PERMISSION_GRANTED) {
                return null
            }

            // Check if location services are enabled
            val isGpsEnabled = locationManager.isProviderEnabled(LocationManager.GPS_PROVIDER)
            val isNetworkEnabled = locationManager.isProviderEnabled(LocationManager.NETWORK_PROVIDER)
            
            if (!isGpsEnabled && !isNetworkEnabled) {
                return null
            }

            // Try to get the last known location from multiple providers
            var location = locationManager.getLastKnownLocation(LocationManager.GPS_PROVIDER)
            
            // If GPS location is null or too old, try network location
            if (location == null) {
                location = locationManager.getLastKnownLocation(LocationManager.NETWORK_PROVIDER)
            }
            
            // If still null, try passive provider as fallback
            if (location == null) {
                location = locationManager.getLastKnownLocation(LocationManager.PASSIVE_PROVIDER)
            }

            return if (location != null) {
                mapOf(
                    "latitude" to location.latitude,
                    "longitude" to location.longitude
                )
            } else {
                null
            }
        } catch (e: Exception) {
            return null
        }
    }
}
