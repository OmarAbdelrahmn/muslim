import 'package:flutter/material.dart';
import 'prayer_service.dart';
import 'stats_page.dart';
import 'achievements_page.dart';
import 'notification_service.dart';
import 'target_setup_page.dart';
import 'azkar_page.dart';
import 'counter_page.dart';
import 'prayer_times_page.dart';
import 'prayer_times_service.dart';
import 'sunan_page.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await NotificationService().init();
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'مسلم',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
        useMaterial3: true,
        fontFamily: 'Roboto',
      ),
      home: const HomePage(),
      routes: {
        '/setup': (context) => const TargetSetupPage(),
      },
    );
  }
}

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> with WidgetsBindingObserver {
  final PrayerService _prayerService = PrayerService();
  final NotificationService _notificationService = NotificationService();
  final PrayerTimesService _prayerTimesService = PrayerTimesService();
  int _totalDays = 0;
  int? _targetDays;
  bool _isLoading = true;
  PrayerTimesResult? _prayerTimesResult;
  bool _prayerTimesLoading = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    _loadData(refreshPrayerTimes: true);
    _notificationService.scheduleAzkarNotifications();
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.paused || state == AppLifecycleState.detached) {
      _notificationService.scheduleInactivityNotification();
    } else if (state == AppLifecycleState.resumed) {
      _notificationService.cancelInactivityNotification();
      _notificationService.scheduleAzkarNotifications();
    }
  }

  Future<void> _loadData({bool refreshPrayerTimes = false}) async {
    final hasTarget = await _prayerService.hasTarget();
    if (!hasTarget && mounted) {
      Navigator.of(context).pushReplacement(
        MaterialPageRoute(builder: (context) => const TargetSetupPage()),
      );
      return;
    }

    final days = await _prayerService.getTotalCompletedDays();
    final target = await _prayerService.getTarget();
    
    setState(() {
      _totalDays = days;
      _targetDays = target;
      _isLoading = false;
    });
    
    // Load prayer times in background only if requested or if not already loaded
    if (refreshPrayerTimes || _prayerTimesResult == null) {
      _loadPrayerTimes();
    }
  }

  Future<void> _loadPrayerTimes() async {
    // 1. Try to load from cache first for immediate display
    final cachedResult = await _prayerTimesService.getCachedPrayerTimes();
    if (cachedResult != null && mounted) {
      setState(() {
        _prayerTimesResult = cachedResult;
        _prayerTimesLoading = false;
      });
    } else {
      // Only show loader if no cached data exists
      setState(() {
        _prayerTimesLoading = true;
      });
    }

    // 2. Always fetch fresh data in the background
    try {
      final freshResult = await _prayerTimesService.getPrayerTimesForCurrentLocation(DateTime.now());
      if (mounted) {
        setState(() {
          _prayerTimesResult = freshResult;
          _prayerTimesLoading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _prayerTimesLoading = false;
        });
      }
    }
  }

  void _fastPush(Widget page) {
    Navigator.push(
      context,
      PageRouteBuilder(
        pageBuilder: (context, animation, secondaryAnimation) => page,
        transitionsBuilder: (context, animation, secondaryAnimation, child) {
          const begin = Offset(1.0, 0.0);
          const end = Offset.zero;
          const curve = Curves.easeOutCubic;
          var tween = Tween(begin: begin, end: end).chain(CurveTween(curve: curve));
          return SlideTransition(position: animation.drive(tween), child: child);
        },
        transitionDuration: const Duration(milliseconds: 300),
      ),
    ).then((_) => _loadData());
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text('الرئيسية'),
        centerTitle: true,
      ),
      endDrawer: _buildDrawer(context),
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [Colors.deepPurple.shade50, Colors.white],
          ),
        ),
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildHeader(),
              const SizedBox(height: 20),
              _buildPrayerTimesCard(),
              const SizedBox(height: 30),
              _buildNavGrid(context),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.end,
      children: [
        const Text(
          'مرحباً بك',
          textAlign: TextAlign.right,
          style: TextStyle(
            fontSize: 28,
            fontWeight: FontWeight.bold,
            color: Colors.deepPurple,
          ),
        ),
        const Text(
          'تابع صلواتك وأذكارك يومياً',
          textAlign: TextAlign.right,
          style: TextStyle(
            fontSize: 16,
            color: Colors.grey,
          ),
        ),
        const SizedBox(height: 20),
        _buildQuickProgress(),
      ],
    );
  }

  Widget _buildQuickProgress() {
    if (_targetDays == null) return const SizedBox.shrink();
    
    double progress = _totalDays / _targetDays!;
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.deepPurple.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text('${(progress * 100).toInt()}%', style: const TextStyle(color: Colors.deepPurple)),
              const Text('تقدمك الإجمالي', style: TextStyle(fontWeight: FontWeight.bold)),
            ],
          ),
          const SizedBox(height: 10),
          ClipRRect(
            borderRadius: BorderRadius.circular(5),
            child: LinearProgressIndicator(
              value: progress,
              minHeight: 10,
              backgroundColor: Colors.deepPurple.shade50,
              valueColor: const AlwaysStoppedAnimation<Color>(Colors.deepPurple),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPrayerTimesCard() {
    if (_prayerTimesLoading) {
      return Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(20),
        ),
        child: const Center(child: CircularProgressIndicator()),
      );
    }

    if (_prayerTimesResult == null) {
      return const SizedBox.shrink();
    }

    final timings = _prayerTimesResult!.prayerTimes.timings;
    final prayerNames = {
      'Fajr': 'الفجر',
      'Dhuhr': 'الظهر',
      'Asr': 'العصر',
      'Maghrib': 'المغرب',
      'Isha': 'العشاء',
    };

    return Container(
      padding: const EdgeInsets.all(15),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.teal.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                '${_prayerTimesResult!.city}, ${_prayerTimesResult!.country}',
                style: const TextStyle(color: Colors.grey, fontSize: 11),
              ),
              const Text(
                'مواقيت الصلاة اليوم',
                style: TextStyle(fontWeight: FontWeight.bold, color: Colors.teal, fontSize: 13),
              ),
            ],
          ),
          const SizedBox(height: 10),
          ...prayerNames.entries.map((entry) {
            return Padding(
              padding: const EdgeInsets.symmetric(vertical: 3),
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                decoration: BoxDecoration(
                  color: Colors.teal.withOpacity(0.03),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      timings[entry.key] ?? '--:--',
                      style: const TextStyle(fontSize: 14, color: Colors.teal, fontWeight: FontWeight.bold),
                    ),
                    Text(
                      entry.value,
                      style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w500),
                    ),
                  ],
                ),
              ),
            );
          }).toList(),
        ],
      ),
    );
  }

  Widget _buildNavGrid(BuildContext context) {
    return GridView.count(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      crossAxisCount: 2,
      mainAxisSpacing: 16,
      crossAxisSpacing: 16,
      childAspectRatio: 0.9,
      children: [
        _buildNavCard(
          context,
          'عداد الصلاة',
          Icons.calculate_outlined,
          Colors.orange,
          () => _fastPush(const CounterPage()),
        ),
        _buildNavCard(
          context,
          'أوقات الصلاة',
          Icons.access_time,
          Colors.teal,
          () => _fastPush(PrayerTimesPage(initialResult: _prayerTimesResult)),
        ),
        _buildNavCard(
          context,
          'السنن الراتبة',
          Icons.format_list_numbered_rtl,
          Colors.orange,
          () => _fastPush(const SunanPage()),
        ),
        _buildNavCard(
          context,
          'الأذكار',
          Icons.book_outlined,
          Colors.blue,
          () => _fastPush(const AzkarPage()),
        ),
        _buildNavCard(
          context,
          'الإحصائيات',
          Icons.analytics_outlined,
          Colors.green,
          () => _fastPush(StatsPage(totalDays: _totalDays, targetDays: _targetDays)),
        ),
        _buildNavCard(
          context,
          'الإنجازات',
          Icons.emoji_events_outlined,
          Colors.purple,
          () => _fastPush(AchievementsPage(totalDays: _totalDays, targetDays: _targetDays ?? 3650)),
        ),
      ],
    );
  }

  Widget _buildNavCard(BuildContext context, String title, IconData icon, Color color, VoidCallback onTap) {
    return Material(
      color: Colors.white,
      borderRadius: BorderRadius.circular(24),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(24),
        child: Container(
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(24),
            border: Border.all(color: color.withOpacity(0.1), width: 1),
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: color.withOpacity(0.1),
                  shape: BoxShape.circle,
                ),
                child: Icon(icon, color: color, size: 32),
              ),
              const SizedBox(height: 16),
              Text(
                title,
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildDrawer(BuildContext context) {
    return Drawer(
      child: ListView(
        padding: EdgeInsets.zero,
        children: [
          DrawerHeader(
            decoration: const BoxDecoration(color: Colors.deepPurple),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(Icons.mosque, size: 40, color: Colors.white),
                const SizedBox(height: 10),
                const Text('برنامج الصلاة', style: TextStyle(color: Colors.white, fontSize: 20)),
              ],
            ),
          ),
          ListTile(
            leading: const Icon(Icons.calculate),
            title: const Text('عداد الصلاة'),
            onTap: () {
              Navigator.pop(context);
              _fastPush(const CounterPage());
            },
          ),
          ListTile(
            leading: const Icon(Icons.access_time),
            title: const Text('أوقات الصلاة'),
            onTap: () {
              Navigator.pop(context);
              _fastPush(PrayerTimesPage(initialResult: _prayerTimesResult));
            },
          ),
          ListTile(
            leading: const Icon(Icons.format_list_numbered_rtl),
            title: const Text('السنن الراتبة'),
            onTap: () {
              Navigator.pop(context);
              _fastPush(const SunanPage());
            },
          ),
          ListTile(
            leading: const Icon(Icons.menu_book),
            title: const Text('الأذكار'),
            onTap: () {
              Navigator.pop(context);
              _fastPush(const AzkarPage());
            },
          ),
          ListTile(
            leading: const Icon(Icons.bar_chart),
            title: const Text('الإحصائيات'),
            onTap: () {
              Navigator.pop(context);
              _fastPush(StatsPage(totalDays: _totalDays, targetDays: _targetDays));
            },
          ),
          ListTile(
            leading: const Icon(Icons.emoji_events),
            title: const Text('الإنجازات'),
            onTap: () {
              Navigator.pop(context);
              _fastPush(AchievementsPage(totalDays: _totalDays, targetDays: _targetDays ?? 3650));
            },
          ),
        ],
      ),
    );
  }
}
