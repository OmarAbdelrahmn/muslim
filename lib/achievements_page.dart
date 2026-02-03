import 'package:flutter/material.dart';
import 'prayer_service.dart';

class AchievementsPage extends StatefulWidget {
  final int? totalDays;
  final int? targetDays;

  const AchievementsPage({
    super.key,
    this.totalDays,
    this.targetDays,
  });

  @override
  State<AchievementsPage> createState() => _AchievementsPageState();
}

class _AchievementsPageState extends State<AchievementsPage> {
  final PrayerService _prayerService = PrayerService();
  int _totalDays = 0;
  int _targetDays = 3650;
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
        _targetDays = target ?? 3650;
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }

    final achievements = _getAchievements(_targetDays);

    return Scaffold(
      backgroundColor: Colors.grey[50],
      appBar: AppBar(
        title: const Text('الإنجازات'),
        centerTitle: true,
        backgroundColor: Colors.transparent,
        elevation: 0,
      ),
      body: achievements.isEmpty
          ? Center(
              child: Padding(
                padding: const EdgeInsets.all(32.0),
                child: Text(
                  'لا توجد إنجازات متاحة ضمن هدفك الحالي ($_targetDays يوم)',
                  textAlign: TextAlign.center,
                  style: const TextStyle(fontSize: 16, color: Colors.grey),
                ),
              ),
            )
          : ListView.builder(
              padding: const EdgeInsets.all(16.0),
              itemCount: achievements.length,
              itemBuilder: (context, index) {
                final achievement = achievements[index];
                final isUnlocked = _totalDays >= achievement.target;
                final progress = _totalDays / achievement.target;
                final progressPercent = (progress * 100).clamp(0, 100).toInt();

                return _buildAchievementCard(
                  achievement,
                  isUnlocked,
                  progressPercent,
                );
              },
            ),
    );
  }

  List<Achievement> _getAchievements(int userTarget) {
    List<Achievement> list = [
      Achievement(target: 3, tier: AchievementTier.beginner, icon: Icons.emoji_events, title: 'البداية القوية', description: '!أول ثلاثة أيام من الالتزام. كل رحلة عظيمة تبدأ بخطوة'),
      Achievement(target: 7, tier: AchievementTier.beginner, icon: Icons.star, title: 'أول أسبوع', description: '!أسبوع كامل من الصلاة! الاستمرارية هي مفتاح النجاح'),
      Achievement(target: 14, tier: AchievementTier.beginner, icon: Icons.military_tech, title: 'أسبوعان', description: '!أسبوعان من الإنجاز! أنت تبني عادة قوية'),
      Achievement(target: 30, tier: AchievementTier.intermediate, icon: Icons.calendar_month, title: 'أول شهر', description: '!شهر كامل من الالتزام! "إنما الأعمال بالخواتيم"'),
      Achievement(target: 60, tier: AchievementTier.intermediate, icon: Icons.workspace_premium, title: 'شهران متتاليان', description: '!شهران من المواظبة! قوة الإرادة تتجلى في أفعالك'),
      Achievement(target: 100, tier: AchievementTier.intermediate, icon: Icons.diamond, title: 'المئة الأولى', description: '100 يوم من التفاني واصبروا إن الله مع الصابرين'),
      Achievement(target: 180, tier: AchievementTier.advanced, icon: Icons.stars, title: 'نصف سنة', description: '6 أشهر من الالتزام! أنت قدوة للآخرين'),
      Achievement(target: 200, tier: AchievementTier.advanced, icon: Icons.auto_awesome, title: 'المئتان', description: '200 يوم الاستمرارية هي سر التميز'),
      Achievement(target: 365, tier: AchievementTier.advanced, icon: Icons.celebration, title: 'سنة كاملة', description: '!عام كامل من الصلاة! إنجاز عظيم ومستمر بإذن الله'),
      Achievement(target: 500, tier: AchievementTier.master, icon: Icons.verified, title: 'الخمسمئة', description: '500 يوم! إن الله يحب إذا عمل أحدكم عملاً أن يتقنه'),
      Achievement(target: 730, tier: AchievementTier.master, icon: Icons.emoji_events_outlined, title: 'سنتان', description: 'سنتان من المثابرة! أنت في مرتبة المتقنين'),
      Achievement(target: 1000, tier: AchievementTier.master, icon: Icons.psychology, title: 'الألف', description: '1000 يوم! رحلة ملهمة من الإيمان والعمل'),
      Achievement(target: 1095, tier: AchievementTier.legend, icon: Icons.military_tech_outlined, title: 'ثلاث سنوات', description: '3 سنوات! "وما توفيقي إلا بالله"'),
      Achievement(target: 1825, tier: AchievementTier.legend, icon: Icons.castle, title: 'خمس سنوات', description: '5 سنوات! أنت أسطورة حقيقية'),
      Achievement(target: 2555, tier: AchievementTier.legend, icon: Icons.rocket_launch, title: 'سبع سنوات', description: '7 سنوات! مستوى لا يصل إليه إلا المخلصون'),
    ];

    if (userTarget > 2555) {
      list.add(Achievement(target: userTarget, tier: AchievementTier.legend, icon: Icons.flag_circle, title: 'الهدف المنشود', description: 'الوصول إلى كامل هدفك الذي وضعته ($userTarget يوم). ثبات وإخلاص منقطع النظير'));
    } else if (!list.any((a) => a.target == userTarget)) {
       list.add(Achievement(target: userTarget, tier: userTarget > 1000 ? AchievementTier.legend : (userTarget > 365 ? AchievementTier.master : AchievementTier.advanced), icon: Icons.flag, title: 'هدفي الشخصي', description: 'إتمام الالتزام لمدة المحددة في هدفك ($userTarget يوم).'));
    }

    list.sort((a, b) => a.target.compareTo(b.target));
    return list.where((a) => a.target <= userTarget).toList();
  }

  Widget _buildAchievementCard(Achievement achievement, bool isUnlocked, int progressPercent) {
    final tierColor = achievement.tier.color;
    final tierGradient = achievement.tier.gradient;

    return Card(
      margin: const EdgeInsets.only(bottom: 16),
      elevation: isUnlocked ? 8 : 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(16),
          gradient: isUnlocked ? tierGradient : null,
        ),
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: isUnlocked ? Colors.white.withOpacity(0.3) : Colors.grey[300],
                      shape: BoxShape.circle,
                    ),
                    child: Icon(achievement.icon, size: 32, color: isUnlocked ? Colors.white : Colors.grey[600]),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(achievement.title, style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: isUnlocked ? Colors.white : Colors.black87)),
                        const SizedBox(height: 4),
                        Row(
                          children: [
                            Icon(isUnlocked ? Icons.check_circle : Icons.lock, size: 16, color: isUnlocked ? Colors.white.withOpacity(0.9) : Colors.grey[600]),
                            const SizedBox(width: 4),
                            Text('${achievement.target} يوم', style: TextStyle(fontSize: 14, color: isUnlocked ? Colors.white.withOpacity(0.9) : Colors.grey[600])),
                          ],
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              Text(achievement.description, style: TextStyle(fontSize: 14, height: 1.5, color: isUnlocked ? Colors.white.withOpacity(0.95) : Colors.grey[700])),
              if (!isUnlocked) ...[
                const SizedBox(height: 12),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text('التقدم: $progressPercent%', style: TextStyle(fontSize: 12, color: Colors.grey[600])),
                        Text('متبقي: ${achievement.target - _totalDays} يوم', style: TextStyle(fontSize: 12, color: Colors.grey[600])),
                      ],
                    ),
                    const SizedBox(height: 8),
                    ClipRRect(
                      borderRadius: BorderRadius.circular(8),
                      child: LinearProgressIndicator(
                        value: progressPercent / 100,
                        minHeight: 8,
                        backgroundColor: Colors.grey[300],
                        valueColor: AlwaysStoppedAnimation<Color>(tierColor),
                      ),
                    ),
                  ],
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}

class Achievement {
  final int target;
  final AchievementTier tier;
  final IconData icon;
  final String title;
  final String description;
  Achievement({required this.target, required this.tier, required this.icon, required this.title, required this.description});
}

enum AchievementTier {
  beginner, intermediate, advanced, master, legend;
  String get nameAr {
    switch (this) {
      case AchievementTier.beginner: return 'مبتدئ';
      case AchievementTier.intermediate: return 'متوسط';
      case AchievementTier.advanced: return 'متقدم';
      case AchievementTier.master: return 'محترف';
      case AchievementTier.legend: return 'أسطوري';
    }
  }
  Color get color {
    switch (this) {
      case AchievementTier.beginner: return Colors.green;
      case AchievementTier.intermediate: return Colors.blue;
      case AchievementTier.advanced: return Colors.purple;
      case AchievementTier.master: return Colors.orange;
      case AchievementTier.legend: return Colors.red;
    }
  }
  LinearGradient get gradient {
    switch (this) {
      case AchievementTier.beginner: return const LinearGradient(colors: [Color(0xFF11998E), Color(0xFF38EF7D)]);
      case AchievementTier.intermediate: return const LinearGradient(colors: [Color(0xFF4A00E0), Color(0xFF8E2DE2)]);
      case AchievementTier.advanced: return const LinearGradient(colors: [Color(0xFF6A11CB), Color(0xFF2575FC)]);
      case AchievementTier.master: return const LinearGradient(colors: [Color(0xFFFA8BFF), Color(0xFF2BD2FF), Color(0xFF2BFF88)]);
      case AchievementTier.legend: return const LinearGradient(colors: [Color(0xFFFF512F), Color(0xFFDD2476)]);
    }
  }
}
