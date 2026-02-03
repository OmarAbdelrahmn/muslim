import 'package:flutter/material.dart';
import 'prayer_service.dart';

class StatsPage extends StatefulWidget {
  // Keeping these for backward compatibility or initial data, but we'll reload anyway
  final int? totalDays;
  final int? targetDays;

  const StatsPage({
    super.key,
    this.totalDays,
    this.targetDays,
  });

  @override
  State<StatsPage> createState() => _StatsPageState();
}

class _StatsPageState extends State<StatsPage> {
  final PrayerService _prayerService = PrayerService();
  int _totalDays = 0;
  int? _targetDays;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    final days = await _prayerService.getTotalCompletedDays();
    final target = await _prayerService.getTarget();
    if (mounted) {
      setState(() {
        _totalDays = days;
        _targetDays = target;
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }

    int remaining = _totalDays;
    final int years = remaining ~/ 365;
    remaining %= 365;
    final int months = remaining ~/ 30;
    remaining %= 30;
    final int weeks = remaining ~/ 7;
    remaining %= 7;
    final int days = remaining;

    return Scaffold(
      backgroundColor: Colors.grey[50],
      appBar: AppBar(
        title: const Text('الإحصائيات'),
        centerTitle: true,
        backgroundColor: Colors.transparent,
        elevation: 0,
      ),
      body: SingleChildScrollView(
        physics: const BouncingScrollPhysics(),
        padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 10),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Container(
              padding: const EdgeInsets.all(30),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(20),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.05),
                    blurRadius: 10,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: Column(
                children: [
                  const Text(
                    'مجموع الأيام المكتملة',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w500,
                      color: Colors.grey,
                    ),
                  ),
                  const SizedBox(height: 10),
                  Text(
                    '$_totalDays',
                    style: const TextStyle(
                      fontSize: 64,
                      fontWeight: FontWeight.bold,
                      color: Colors.deepPurple,
                    ),
                  ),
                  const Text(
                    'يوماً',
                    style: TextStyle(
                      fontSize: 20,
                      color: Colors.deepPurple,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 30),
            const Text(
              'التفصيل الزمني',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: Colors.black87,
              ),
            ),
            const SizedBox(height: 20),
            GridView.count(
              crossAxisCount: 2,
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              mainAxisSpacing: 16,
              crossAxisSpacing: 16,
              childAspectRatio: 1.2,
              children: [
                _buildSimpleTimeCard('سنوات', '$years', Icons.celebration),
                _buildSimpleTimeCard('أشهر', '$months', Icons.calendar_month),
                _buildSimpleTimeCard('أسابيع', '$weeks', Icons.date_range),
                _buildSimpleTimeCard('أيام', '$days', Icons.today),
              ],
            ),
            const SizedBox(height: 30),
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: Colors.deepPurple.withOpacity(0.05),
                borderRadius: BorderRadius.circular(15),
                border: Border.all(color: Colors.deepPurple.withOpacity(0.1)),
              ),
              child: Text(
                _getMotivationalMessage(_totalDays),
                textAlign: TextAlign.center,
                style: const TextStyle(
                  fontSize: 15,
                  height: 1.5,
                  color: Colors.black87,
                ),
              ),
            ),
            const SizedBox(height: 30),
            const Text(
              'بياناتك محفوظة بأمان',
              textAlign: TextAlign.center,
              style: TextStyle(color: Colors.grey, fontSize: 13),
            ),
            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }

  Widget _buildSimpleTimeCard(String label, String value, IconData icon) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(15),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.03),
            blurRadius: 5,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(icon, color: Colors.deepPurple, size: 28),
          const SizedBox(height: 8),
          Text(
            value,
            style: const TextStyle(
              fontSize: 26,
              fontWeight: FontWeight.bold,
              color: Colors.black87,
            ),
          ),
          Text(
            label,
            style: const TextStyle(fontSize: 14, color: Colors.grey),
          ),
        ],
      ),
    );
  }

  String _getMotivationalMessage(int days) {
    if (days < 7) return 'بداية مباركة، استعن بالله وواصل المسير.';
    if (days < 30) return 'أحسنت الاستمرار، فالقليل الدائم خير من الكثير المنقطع.';
    if (days < 100) return 'إنجاز رائع، الالتزام يصنع الفرق الحقيقي في حياتك.';
    if (days < 365) return 'ما شاء الله، مواظبة ملهمة تدل على قوة إيمانك وعزيمتك.';
    return 'إنجاز عظيم، نسأل الله أن يتقبل منك ويثبتك على طاعته.';
  }
}
