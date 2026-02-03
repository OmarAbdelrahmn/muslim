import 'package:flutter/material.dart';

class AzkarDetailPage extends StatefulWidget {
  final String title;
  final List<AzkarItem> azkarItems;

  const AzkarDetailPage({
    super.key,
    required this.title,
    required this.azkarItems,
  });

  @override
  State<AzkarDetailPage> createState() => _AzkarDetailPageState();
}

class _AzkarDetailPageState extends State<AzkarDetailPage> {
  final PageController _pageController = PageController();
  int _currentPage = 0;
  Map<int, int> _remainingCounts = {};

  @override
  void initState() {
    super.initState();
    // Initialize mutable counts
    for (int i = 0; i < widget.azkarItems.length; i++) {
      _remainingCounts[i] = widget.azkarItems[i].count;
    }
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  void _onCountPressed() {
    final currentCount = _remainingCounts[_currentPage] ?? 0;
    if (currentCount > 0) {
      setState(() {
        _remainingCounts[_currentPage] = currentCount - 1;
      });

      // Provide haptic-like visual feedback or sound if possible (skipping sound)
      
      // If reached 0, move to next page
      if (_remainingCounts[_currentPage] == 0) {
        if (_currentPage < widget.azkarItems.length - 1) {
          Future.delayed(const Duration(milliseconds: 300), () {
            if (mounted) {
              _pageController.nextPage(
                duration: const Duration(milliseconds: 500),
                curve: Curves.easeInOut,
              );
            }
          });
        } else {
          // Finished all
          _showCompletionDialog();
        }
      }
    }
  }

  void _showCompletionDialog() {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: const Column(
          children: [
            Icon(Icons.celebration, color: Colors.deepPurple, size: 60),
            SizedBox(height: 16),
            Text(
              'أحسنت!',
              style: TextStyle(fontWeight: FontWeight.bold),
              textAlign: TextAlign.center,
            ),
          ],
        ),
        content: const Text(
          'لقد أتممت قراءة الأذكار بنجاح. تقبل الله منا ومنكم صالح الأعمال.',
          textAlign: TextAlign.center,
          style: TextStyle(fontSize: 16),
        ),
        actionsAlignment: MainAxisAlignment.center,
        actions: [
          ElevatedButton(
            onPressed: () {
              Navigator.of(context).pop(); // Close dialog
              Navigator.of(context).pop(); // Go back to categories
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.deepPurple,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 12),
            ),
            child: const Text('تم', style: TextStyle(color: Colors.white, fontSize: 18)),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[50],
      appBar: AppBar(
        title: Text(widget.title),
        centerTitle: true,
        backgroundColor: Colors.transparent,
        elevation: 0,
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(4),
          child: LinearProgressIndicator(
            value: (widget.azkarItems.isEmpty) ? 0 : (_currentPage + 1) / widget.azkarItems.length,
            backgroundColor: Colors.grey[200],
            valueColor: const AlwaysStoppedAnimation<Color>(Colors.deepPurple),
            minHeight: 4,
          ),
        ),
      ),
      body: PageView.builder(
        controller: _pageController,
        onPageChanged: (page) {
          setState(() {
            _currentPage = page;
          });
        },
        itemCount: widget.azkarItems.length,
        itemBuilder: (context, index) {
          final item = widget.azkarItems[index];
          final remainingCount = _remainingCounts[index] ?? 0;

          return GestureDetector(
            onTap: _onCountPressed,
            behavior: HitTestBehavior.opaque,
            child: LayoutBuilder(
              builder: (context, constraints) {
                return SingleChildScrollView(
                  physics: const BouncingScrollPhysics(),
                  child: ConstrainedBox(
                    constraints: BoxConstraints(
                      minHeight: constraints.maxHeight,
                    ),
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 32),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(
                            '${_currentPage + 1} / ${widget.azkarItems.length}',
                            style: const TextStyle(fontSize: 14, color: Colors.grey, fontWeight: FontWeight.bold),
                          ),
                          const SizedBox(height: 24),
                          Text(
                            item.text,
                            textAlign: TextAlign.center,
                            style: const TextStyle(
                              fontSize: 24,
                              height: 1.6,
                              fontWeight: FontWeight.w500,
                              color: Colors.black87,
                            ),
                          ),
                          const SizedBox(height: 12),
                          if (item.reference.isNotEmpty)
                            IconButton(
                              onPressed: () {
                                showModalBottomSheet(
                                  context: context,
                                  isScrollControlled: true,
                                  backgroundColor: Colors.white,
                                  shape: const RoundedRectangleBorder(
                                    borderRadius: BorderRadius.vertical(top: Radius.circular(30)),
                                  ),
                                  builder: (context) => Container(
                                    width: double.infinity,
                                    padding: EdgeInsets.fromLTRB(32, 16, 32, MediaQuery.of(context).padding.bottom + 40),
                                    child: Column(
                                      mainAxisSize: MainAxisSize.min,
                                      children: [
                                        Container(
                                          width: 50,
                                          height: 5,
                                          margin: const EdgeInsets.only(bottom: 32),
                                          decoration: BoxDecoration(
                                            color: Colors.grey[200],
                                            borderRadius: BorderRadius.circular(2.5),
                                          ),
                                        ),
                                        const Text(
                                          'المصدر / الفضل',
                                          style: TextStyle(
                                            fontSize: 20,
                                            fontWeight: FontWeight.bold,
                                            color: Colors.deepPurple,
                                          ),
                                        ),
                                        const SizedBox(height: 24),
                                        Text(
                                          item.reference,
                                          textAlign: TextAlign.center,
                                          style: const TextStyle(
                                            fontSize: 18,
                                            height: 1.7,
                                            color: Colors.black87,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                );
                              },
                              icon: Container(
                                padding: const EdgeInsets.all(8),
                                decoration: BoxDecoration(
                                  color: Colors.deepPurple.withOpacity(0.1),
                                  shape: BoxShape.circle,
                                ),
                                child: const Icon(
                                  Icons.help_outline,
                                  color: Colors.deepPurple,
                                  size: 24,
                                ),
                              ),
                            ),
                          const SizedBox(height: 40),
                          // Dynamic Circular Counter
                          AnimatedContainer(
                            duration: const Duration(milliseconds: 200),
                            width: 220, // Increased size
                            height: 220,
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              gradient: LinearGradient(
                                begin: Alignment.topLeft,
                                end: Alignment.bottomRight,
                                colors: remainingCount == 0
                                    ? [Colors.green.shade400, Colors.green.shade700]
                                    : [Colors.deepPurple.shade400, Colors.deepPurple.shade700],
                              ),
                              boxShadow: [
                                BoxShadow(
                                  color: (remainingCount == 0 ? Colors.green : Colors.deepPurple).withOpacity(0.4),
                                  blurRadius: 30, // Increased blur for the larger circle
                                  offset: const Offset(0, 15),
                                ),
                              ],
                            ),
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Text(
                                  '$remainingCount',
                                  style: const TextStyle(
                                    color: Colors.white,
                                    fontSize: 72, // Much larger font
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                const SizedBox(height: 2),
                                Text(
                                  remainingCount == 0 ? 'تم' : 'متبقي',
                                  style: TextStyle(
                                    color: Colors.white.withOpacity(0.9),
                                    fontSize: 18,
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(height: 20),
                        ],
                      ),
                    ),
                  ),
                );
              },
            ),
          );
        },
      ),
    );
  }
}

class AzkarItem {
  final String text;
  final int count;
  final String reference;

  AzkarItem({
    required this.text,
    required this.count,
    this.reference = '',
  });
}
