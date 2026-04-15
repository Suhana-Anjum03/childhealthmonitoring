import 'package:latlong2/latlong.dart';
import 'package:url_launcher/url_launcher.dart';

class LocationHelper {
  // Sample coordinates for common Indian cities
  // In a real app, you would use geocoding API or store actual coordinates
  static final Map<String, LatLng> _cityCoordinates = {
    // Major cities
    'new delhi': const LatLng(28.6139, 77.2090),
    'delhi': const LatLng(28.6139, 77.2090),
    'mumbai': const LatLng(19.0760, 72.8777),
    'bangalore': const LatLng(12.9716, 77.5946),
    'bengaluru': const LatLng(12.9716, 77.5946),
    'hyderabad': const LatLng(17.3850, 78.4867),
    'chennai': const LatLng(13.0827, 80.2707),
    'kolkata': const LatLng(22.5726, 88.3639),
    'pune': const LatLng(18.5204, 73.8567),
    'ahmedabad': const LatLng(23.0225, 72.5714),
    'jaipur': const LatLng(26.9124, 75.7873),
    'surat': const LatLng(21.1702, 72.8311),
    'lucknow': const LatLng(26.8467, 80.9462),
    'kanpur': const LatLng(26.4499, 80.3319),
    'nagpur': const LatLng(21.1458, 79.0882),
    'indore': const LatLng(22.7196, 75.8577),
    'thane': const LatLng(19.2183, 72.9781),
    'bhopal': const LatLng(23.2599, 77.4126),
    'visakhapatnam': const LatLng(17.6868, 83.2185),
    'pimpri-chinchwad': const LatLng(18.6298, 73.7997),
    'patna': const LatLng(25.5941, 85.1376),
    'vadodara': const LatLng(22.3072, 73.1812),
    'ghaziabad': const LatLng(28.6692, 77.4538),
    'ludhiana': const LatLng(30.9010, 75.8573),
    'agra': const LatLng(27.1767, 78.0081),
    'nashik': const LatLng(19.9975, 73.7898),
    'faridabad': const LatLng(28.4089, 77.3178),
    'meerut': const LatLng(28.9845, 77.7064),
    'rajkot': const LatLng(22.3039, 70.8022),
    'kalyan-dombivali': const LatLng(19.2403, 73.1305),
    'vasai-virar': const LatLng(19.4612, 72.7985),
    'varanasi': const LatLng(25.3176, 82.9739),
    'srinagar': const LatLng(34.0837, 74.7973),
    'aurangabad': const LatLng(19.8762, 75.3433),
    'dhanbad': const LatLng(23.7957, 86.4304),
    'amritsar': const LatLng(31.6340, 74.8723),
    'navi mumbai': const LatLng(19.0330, 73.0297),
    'allahabad': const LatLng(25.4358, 81.8463),
    'prayagraj': const LatLng(25.4358, 81.8463),
    'ranchi': const LatLng(23.3441, 85.3096),
    'howrah': const LatLng(22.5958, 88.2636),
    'coimbatore': const LatLng(11.0168, 76.9558),
    'jabalpur': const LatLng(23.1815, 79.9864),
    'gwalior': const LatLng(26.2183, 78.1828),
    'vijayawada': const LatLng(16.5062, 80.6480),
    'jodhpur': const LatLng(26.2389, 73.0243),
    'madurai': const LatLng(9.9252, 78.1198),
    'raipur': const LatLng(21.2514, 81.6296),
    'kota': const LatLng(25.2138, 75.8648),
    'chandigarh': const LatLng(30.7333, 76.7794),
    'guwahati': const LatLng(26.1445, 91.7362),
    
    // International (for testing)
    'new york': const LatLng(40.7128, -74.0060),
    'london': const LatLng(51.5074, -0.1278),
    'paris': const LatLng(48.8566, 2.3522),
    'tokyo': const LatLng(35.6762, 139.6503),
    'dubai': const LatLng(25.2048, 55.2708),
  };

  /// Get coordinates for a location string
  /// Returns null if location not found
  static LatLng? getCoordinatesFromLocation(String location) {
    if (location.isEmpty) return null;
    
    final cleanLocation = location.toLowerCase().trim();
    
    // Try exact match first
    if (_cityCoordinates.containsKey(cleanLocation)) {
      return _cityCoordinates[cleanLocation];
    }
    
    // Try partial match
    for (var entry in _cityCoordinates.entries) {
      if (cleanLocation.contains(entry.key) || entry.key.contains(cleanLocation)) {
        return entry.value;
      }
    }
    
    // Default to New Delhi if not found
    return const LatLng(28.6139, 77.2090);
  }

  /// Calculate distance between two coordinates in kilometers
  static double calculateDistance(LatLng point1, LatLng point2) {
    const Distance distance = Distance();
    return distance.as(LengthUnit.Kilometer, point1, point2);
  }

  /// Get a readable distance string
  static String getDistanceString(LatLng point1, LatLng point2) {
    final distanceKm = calculateDistance(point1, point2);
    
    if (distanceKm < 1) {
      return '${(distanceKm * 1000).toStringAsFixed(0)} m away';
    } else if (distanceKm < 10) {
      return '${distanceKm.toStringAsFixed(1)} km away';
    } else {
      return '${distanceKm.toStringAsFixed(0)} km away';
    }
  }

  /// Check if a location string is valid
  static bool isValidLocation(String location) {
    return getCoordinatesFromLocation(location) != null;
  }

  /// Get list of supported cities
  static List<String> getSupportedCities() {
    return _cityCoordinates.keys.toList()..sort();
  }

  /// Open navigation to a location in external map app
  /// Works with Google Maps, Apple Maps, and other map apps
  static Future<bool> openNavigation(LatLng destination, String locationName) async {
    final lat = destination.latitude;
    final lng = destination.longitude;
    
    // Try different URL schemes for different platforms
    final urls = [
      // Google Maps (works on Android & iOS)
      'https://www.google.com/maps/search/?api=1&query=$lat,$lng',
      // Apple Maps (iOS)
      'https://maps.apple.com/?q=$lat,$lng',
      // Generic geo URI (fallback)
      'geo:$lat,$lng?q=$lat,$lng($locationName)',
    ];

    for (final urlString in urls) {
      final uri = Uri.parse(urlString);
      if (await canLaunchUrl(uri)) {
        return await launchUrl(
          uri,
          mode: LaunchMode.externalApplication,
        );
      }
    }

    return false;
  }

  /// Open navigation with turn-by-turn directions from current location
  static Future<bool> openNavigationWithDirections(
    LatLng destination,
    String locationName,
  ) async {
    final lat = destination.latitude;
    final lng = destination.longitude;
    
    // Google Maps with directions (from current location)
    final googleMapsUrl = 'https://www.google.com/maps/dir/?api=1&destination=$lat,$lng&travelmode=driving';
    final uri = Uri.parse(googleMapsUrl);
    
    if (await canLaunchUrl(uri)) {
      return await launchUrl(
        uri,
        mode: LaunchMode.externalApplication,
      );
    }

    // Fallback to simple navigation
    return await openNavigation(destination, locationName);
  }

  /// Open location in Google Maps app directly (if installed)
  static Future<bool> openInGoogleMaps(LatLng destination) async {
    final lat = destination.latitude;
    final lng = destination.longitude;
    
    // Try Google Maps app URL scheme first (Android)
    final googleMapsAppUrl = 'google.navigation:q=$lat,$lng&mode=d';
    final appUri = Uri.parse(googleMapsAppUrl);
    
    if (await canLaunchUrl(appUri)) {
      return await launchUrl(appUri);
    }

    // Fallback to web URL
    final webUrl = 'https://www.google.com/maps/search/?api=1&query=$lat,$lng';
    final webUri = Uri.parse(webUrl);
    
    if (await canLaunchUrl(webUri)) {
      return await launchUrl(
        webUri,
        mode: LaunchMode.externalApplication,
      );
    }

    return false;
  }

  /// Share location as text (for messaging apps)
  static String getShareableLocationText(LatLng location, String locationName) {
    final lat = location.latitude;
    final lng = location.longitude;
    return '$locationName\n'
        'Location: https://www.google.com/maps/search/?api=1&query=$lat,$lng';
  }
}
