import 'package:shared_preferences/shared_preferences.dart';

class PrayerService {
  static const String _completionCountKey = 'total_completion_count';
  static const String _prayerKeyPrefix = 'prayer_count_';
  static const String _targetDaysKey = 'target_days';

  // Order: Fajr, Dhuhr, Asr, Maghrib, Isha
  final List<String> prayerNames = [
    'الفجر',
    'الظهر',
    'العصر',
    'المغرب',
    'العشاء'
  ];

  Future<int> getTotalCompletedDays() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getInt(_completionCountKey) ?? 0;
  }

  Future<void> savePrayerCount(int index, int count) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt('$_prayerKeyPrefix$index', count);
  }

  Future<List<int>> loadPrayerCounts() async {
    final prefs = await SharedPreferences.getInstance();
    List<int> counts = [];
    for (int i = 0; i < 5; i++) {
        counts.add(prefs.getInt('$_prayerKeyPrefix$i') ?? 0);
    }
    return counts;
  }
  
  Future<void> consumeDay(List<int> currentCounts) async {
     final prefs = await SharedPreferences.getInstance();
     
     // Increment total days
     int currentTotal = prefs.getInt(_completionCountKey) ?? 0;
     await prefs.setInt(_completionCountKey, currentTotal + 1);

     // Decrement all prayer counts by 1
     for (int i = 0; i < 5; i++) {
        int newCount = (currentCounts[i] > 0) ? currentCounts[i] - 1 : 0;
        await prefs.setInt('$_prayerKeyPrefix$i', newCount);
    }
  }

  // Target methods
  Future<void> saveTarget(int targetDays) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt(_targetDaysKey, targetDays);
  }

  Future<int?> getTarget() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getInt(_targetDaysKey);
  }

  Future<bool> hasTarget() async {
    final target = await getTarget();
    return target != null;
  }
}
