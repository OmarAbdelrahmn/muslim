import 'dart:convert';
import 'package:geolocator/geolocator.dart';
import 'package:geocoding/geocoding.dart';
import 'package:http/http.dart' as http;
import 'package:intl/intl.dart';
import 'package:shared_preferences/shared_preferences.dart';

class PrayerTimesService {
  static const String _cacheKey = 'cached_prayer_times';

  // Check and request location permission
  Future<bool> requestLocationPermission() async {
    bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      return false;
    }

    LocationPermission permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) {
        return false;
      }
    }

    if (permission == LocationPermission.deniedForever) {
      return false;
    }

    return true;
  }

  // Get current location
  Future<Position> getCurrentLocation() async {
    return await Geolocator.getCurrentPosition(
      locationSettings: const LocationSettings(
        accuracy: LocationAccuracy.high,
        distanceFilter: 100,
      ),
    );
  }

  // Get city and country from coordinates
  Future<Map<String, String>> getCityAndCountry(double latitude, double longitude) async {
    try {
      List<Placemark> placemarks = await placemarkFromCoordinates(latitude, longitude);
      if (placemarks.isNotEmpty) {
        final place = placemarks.first;
        return {
          'city': place.locality ?? place.administrativeArea ?? 'Unknown',
          'country': place.country ?? 'Unknown',
        };
      }
    } catch (e) {
      throw Exception('Failed to get location name: $e');
    }
    throw Exception('Could not determine city and country');
  }

  // Fetch prayer times from API
  Future<PrayerTimesData> fetchPrayerTimes(String city, String country, DateTime date) async {
    final formattedDate = DateFormat('yyyy-MM-dd').format(date);
    final url = Uri.parse(
      'https://prayer-time-api.pages.dev/api/prayer-times?city=$city&country=$country&date=$formattedDate&method=2',
    );

    try {
      final response = await http.get(url);
      if (response.statusCode == 200) {
        final Map<String, dynamic> data = json.decode(response.body);
        return PrayerTimesData.fromJson(data);
      } else {
        throw Exception('Failed to load prayer times: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Network error: $e');
    }
  }

  // Main method to get prayer times for current location
  Future<PrayerTimesResult> getPrayerTimesForCurrentLocation(DateTime date) async {
    // Request permission
    final hasPermission = await requestLocationPermission();
    if (!hasPermission) {
      throw Exception('Location permission denied');
    }

    // Get current location
    final position = await getCurrentLocation();

    // Get city and country
    final location = await getCityAndCountry(position.latitude, position.longitude);

    // Fetch prayer times
    final prayerTimes = await fetchPrayerTimes(location['city']!, location['country']!, date);

    final result = PrayerTimesResult(
      city: location['city']!,
      country: location['country']!,
      prayerTimes: prayerTimes,
    );

    // Save to cache
    await saveCachedPrayerTimes(result);

    return result;
  }

  // Persistence methods
  Future<void> saveCachedPrayerTimes(PrayerTimesResult result) async {
    final prefs = await SharedPreferences.getInstance();
    final jsonString = json.encode(result.toJson());
    await prefs.setString(_cacheKey, jsonString);
  }

  Future<PrayerTimesResult?> getCachedPrayerTimes() async {
    final prefs = await SharedPreferences.getInstance();
    final jsonString = prefs.getString(_cacheKey);
    if (jsonString != null) {
      try {
        final Map<String, dynamic> jsonMap = json.decode(jsonString);
        return PrayerTimesResult.fromJson(jsonMap);
      } catch (e) {
        return null;
      }
    }
    return null;
  }
}

// Data models
class PrayerTimesData {
  final String date;
  final String timezone;
  final Map<String, String> timings;

  PrayerTimesData({
    required this.date,
    required this.timezone,
    required this.timings,
  });

  factory PrayerTimesData.fromJson(Map<String, dynamic> json) {
    return PrayerTimesData(
      date: json['date'] as String,
      timezone: json['timezone'] as String,
      timings: Map<String, String>.from(json['timings']),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'date': date,
      'timezone': timezone,
      'timings': timings,
    };
  }
}

class PrayerTimesResult {
  final String city;
  final String country;
  final PrayerTimesData prayerTimes;

  PrayerTimesResult({
    required this.city,
    required this.country,
    required this.prayerTimes,
  });

  factory PrayerTimesResult.fromJson(Map<String, dynamic> json) {
    return PrayerTimesResult(
      city: json['city'] as String,
      country: json['country'] as String,
      prayerTimes: PrayerTimesData.fromJson(json['prayerTimes'] as Map<String, dynamic>),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'city': city,
      'country': country,
      'prayerTimes': prayerTimes.toJson(),
    };
  }
}
