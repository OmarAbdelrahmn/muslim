import 'package:flutter/material.dart';
import 'prayer_service.dart';

class CounterPage extends StatefulWidget {
  const CounterPage({super.key});

  @override
  State<CounterPage> createState() => _CounterPageState();
}

class _CounterPageState extends State<CounterPage> {
  final PrayerService _prayerService = PrayerService();
  List<int> _prayerCounts = [0, 0, 0, 0, 0];
  int _totalDays = 0;
  int? _targetDays;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    final counts = await _prayerService.loadPrayerCounts();
    final days = await _prayerService.getTotalCompletedDays();
    final target = await _prayerService.getTarget();
    
    setState(() {
      _prayerCounts = counts;
      _totalDays = days;
      _targetDays = target;
      _isLoading = false;
    });
  }

  Future<void> _updateCount(int index, int delta) async {
    final newCount = _prayerCounts[index] + delta;
    if (newCount < 0) return;

    setState(() {
      _prayerCounts[index] = newCount;
    });
    await _prayerService.savePrayerCount(index, newCount);
  }

  bool get _canCompleteDay => _prayerCounts.every((count) => count > 0);

  Future<void> _completeDay() async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('أحسنت!'),
        content: const Text('سيتم احتساب يوم كامل وخصم صلاة واحدة من كل عداد. هل أنت متأكد؟'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('إلغاء'),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('نعم، أتممت اليوم'),
          ),
        ],
      ),
    );

    if (confirm == true) {
      await _prayerService.consumeDay(_prayerCounts);
      await _loadData();
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('تم احتساب اليوم بنجاح!')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text('عداد الصلاة'),
        centerTitle: true,
      ),
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [Colors.deepPurple.shade50, Colors.white],
          ),
        ),
        child: Column(
          children: [
            _buildProgressCard(),
            Expanded(
              child: ListView.builder(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                itemCount: _prayerService.prayerNames.length,
                itemBuilder: (context, index) {
                  return _buildPrayerCard(index);
                },
              ),
            ),
          ],
        ),
      ),
      floatingActionButton: _canCompleteDay
          ? FloatingActionButton.extended(
              onPressed: _completeDay,
              icon: const Icon(Icons.check),
              label: const Text('إتمام يوم'),
              backgroundColor: Colors.deepPurple,
              foregroundColor: Colors.white,
            )
          : null,
    );
  }

  Widget _buildProgressCard() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(24),
      margin: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: Colors.deepPurple.withOpacity(0.1),
            blurRadius: 20,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: Column(
        children: [
          const Text(
            'الأيام المكتملة',
            style: TextStyle(
              fontSize: 16,
              color: Colors.grey,
              fontWeight: FontWeight.w500,
            ),
          ),
          const SizedBox(height: 8),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.baseline,
            textBaseline: TextBaseline.alphabetic,
            children: [
              Text(
                '$_totalDays',
                style: const TextStyle(
                  fontSize: 48,
                  fontWeight: FontWeight.bold,
                  color: Colors.deepPurple,
                ),
              ),
              if (_targetDays != null) ...[
                const Text(
                  ' / ',
                  style: TextStyle(fontSize: 32, color: Colors.grey),
                ),
                Text(
                  '$_targetDays',
                  style: const TextStyle(
                    fontSize: 32,
                    fontWeight: FontWeight.bold,
                    color: Colors.grey,
                  ),
                ),
              ],
            ],
          ),
          if (_targetDays != null) ...[
            const SizedBox(height: 12),
            ClipRRect(
              borderRadius: BorderRadius.circular(8),
              child: LinearProgressIndicator(
                value: _totalDays / _targetDays!,
                minHeight: 8,
                backgroundColor: Colors.grey[200],
                valueColor: const AlwaysStoppedAnimation<Color>(Colors.deepPurple),
              ),
            ),
            const SizedBox(height: 8),
            Text(
              '${((_totalDays / _targetDays!) * 100).toInt()}% مكتمل',
              style: const TextStyle(fontSize: 14, color: Colors.grey),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildPrayerCard(int index) {
    final count = _prayerCounts[index];
    final isAvailable = count > 0;
    return Card(
      elevation: 0,
      margin: const EdgeInsets.symmetric(vertical: 8),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(20),
        side: BorderSide(color: Colors.deepPurple.withOpacity(0.1)),
      ),
      color: Colors.white,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              _prayerService.prayerNames[index],
              style: const TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            Row(
              children: [
                _buildCountButton(Icons.remove, () => _updateCount(index, -1), Colors.red, count > 0),
                const SizedBox(width: 16),
                SizedBox(
                  width: 60,
                  child: Center(
                    child: Text(
                      '$count',
                      style: TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                        color: isAvailable ? Colors.deepPurple : Colors.grey,
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 16),
                _buildCountButton(Icons.add, () => _updateCount(index, 1), Colors.green, true),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCountButton(IconData icon, VoidCallback onPressed, Color color, bool enabled) {
    return Material(
      color: enabled ? color.withOpacity(0.1) : Colors.grey.withOpacity(0.05),
      borderRadius: BorderRadius.circular(12),
      child: InkWell(
        onTap: enabled ? onPressed : null,
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(8.0),
          child: Icon(icon, color: enabled ? color : Colors.grey, size: 24),
        ),
      ),
    );
  }
}
