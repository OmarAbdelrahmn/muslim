import 'package:flutter/material.dart';

class SunanPage extends StatelessWidget {
  const SunanPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[50],
      appBar: AppBar(
        title: const Text('السنن الراتبة', style: TextStyle(fontWeight: FontWeight.bold)),
        centerTitle: true,
        backgroundColor: Colors.white,
        elevation: 0,
        foregroundColor: Colors.deepPurple,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            _buildInfoCard(),
            const SizedBox(height: 24),
            _buildSunanTable(),
            const SizedBox(height: 32),
            _buildTotalCard(),
          ],
        ),
      ),
    );
  }

  Widget _buildInfoCard() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [Colors.deepPurple.shade400, Colors.deepPurple.shade700],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: Colors.deepPurple.withOpacity(0.3),
            blurRadius: 15,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: const Row(
        children: [
          Icon(Icons.info_outline, color: Colors.white, size: 32),
          SizedBox(width: 16),
          Expanded(
            child: Text(
              'السنن الراتبة هي الصلوات التي كان النبي ﷺ يداوم عليها مع الفرائض.',
              style: TextStyle(color: Colors.white, fontSize: 16, height: 1.5),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSunanTable() {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
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
          _buildTableHeader(),
          _buildRow('الصبح', '2', '-', isFirst: false),
          _buildDivider(),
          _buildRow('الظهر', '4', '2'),
          _buildDivider(),
          _buildRow('العصر', '-', '-'),
          _buildDivider(),
          _buildRow('المغرب', '-', '2'),
          _buildDivider(),
          _buildRow('العشاء', '-', '2', isLast: true),
        ],
      ),
    );
  }

  Widget _buildTableHeader() {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 16),
      decoration: BoxDecoration(
        color: Colors.deepPurple.withOpacity(0.05),
        borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
      ),
      child: const Row(
        children: [
          Expanded(child: Text('بعدها', textAlign: TextAlign.center, style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16, color: Colors.deepPurple))),
          Expanded(flex: 2, child: Text('الصلاة', textAlign: TextAlign.center, style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18, color: Colors.deepPurple))),
          Expanded(child: Text('قبلها', textAlign: TextAlign.center, style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16, color: Colors.deepPurple))),
        ],
      ),
    );
  }

  Widget _buildRow(String prayer, String before, String after, {bool isFirst = false, bool isLast = false}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 18, horizontal: 16),
      child: Row(
        children: [
          Expanded(
            child: _buildNumberCircle(after, Colors.orange.shade50, Colors.orange.shade700),
          ),
          Expanded(
            flex: 2,
            child: Text(
              prayer,
              textAlign: TextAlign.center,
              style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 18, color: Colors.black87),
            ),
          ),
          Expanded(
            child: _buildNumberCircle(before, Colors.blue.shade50, Colors.blue.shade700),
          ),
        ],
      ),
    );
  }

  Widget _buildNumberCircle(String value, Color bgColor, Color textColor) {
    if (value == '-') {
      return const Text('-', textAlign: TextAlign.center, style: TextStyle(color: Colors.grey, fontSize: 20));
    }
    return Center(
      child: Container(
        width: 36,
        height: 36,
        decoration: BoxDecoration(
          color: bgColor,
          shape: BoxShape.circle,
        ),
        child: Center(
          child: Text(
            value,
            style: TextStyle(color: textColor, fontWeight: FontWeight.bold, fontSize: 16),
          ),
        ),
      ),
    );
  }

  Widget _buildDivider() {
    return Divider(height: 1, thickness: 1, color: Colors.grey.withOpacity(0.1));
  }

  Widget _buildTotalCard() {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: Colors.deepPurple.withOpacity(0.1)),
      ),
      child: const Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            'المجموع الكلي ركعة',
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.black87),
          ),
          Text(
            '12',
            style: TextStyle(fontSize: 32, fontWeight: FontWeight.bold, color: Colors.deepPurple),
          ),
        ],
      ),
    );
  }
}
