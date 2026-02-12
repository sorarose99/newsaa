import 'package:flutter/material.dart';

class VirtueInfoPage extends StatelessWidget {
  const VirtueInfoPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('فضل الصلاة على النبي ﷺ')),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          _buildHeader(),
          const SizedBox(height: 24),
          _buildSection('الأدلة من القرآن', Icons.book, const Color(0xFF00695C), [
            _buildQuranVerse(
              'إِنَّ ٱللَّهَ وَمَلَـٰٓئِكَتَهُۥ يُصَلُّونَ عَلَى ٱلنَّبِىِّ ۚ يَـٰٓأَيُّهَا ٱلَّذِينَ ءَامَنُوا۟ صَلُّوا۟ عَلَيْهِ وَسَلِّمُوا۟ تَسْلِيمًا',
              'سورة الأحزاب - الآية 56',
            ),
          ]),
          const SizedBox(height: 16),
          _buildSection(
            'الأحاديث النبوية',
            Icons.article,
            const Color(0xFFD4A574),
            [
              _buildHadith(
                'من صلى علي صلاة صلى الله عليه بها عشراً',
                'رواه مسلم',
              ),
              _buildHadith('البخيل من ذكرت عنده فلم يصل علي', 'رواه الترمذي'),
              _buildHadith(
                'أولى الناس بي يوم القيامة أكثرهم علي صلاة',
                'رواه الترمذي',
              ),
            ],
          ),
          const SizedBox(height: 16),
          _buildSection(
            'فوائد الصلاة على النبي',
            Icons.star,
            const Color(0xFF4CAF50),
            [
              _buildBenefit('امتثال لأمر الله تعالى'),
              _buildBenefit('موافقة الله في الصلاة على النبي'),
              _buildBenefit('نيل عشر صلوات من الله'),
              _buildBenefit('رفع عشر درجات'),
              _buildBenefit('كتابة عشر حسنات'),
              _buildBenefit('حط عشر سيئات'),
              _buildBenefit('سبب لقرب العبد من النبي يوم القيامة'),
              _buildBenefit('سبب لغفران الذنوب'),
              _buildBenefit('سبب لكفاية الهموم'),
              _buildBenefit('سبب لنزول الرحمة'),
            ],
          ),
          const SizedBox(height: 16),
          _buildSection(
            'أوقات الإكثار من الصلاة',
            Icons.access_time,
            const Color(0xFF00695C),
            [
              _buildTime('يوم الجمعة وليلتها'),
              _buildTime('بعد الأذان'),
              _buildTime('عند دخول المسجد والخروج منه'),
              _buildTime('في الصباح والمساء'),
              _buildTime('عند ذكر النبي ﷺ'),
              _buildTime('في الدعاء'),
            ],
          ),
          const SizedBox(height: 16),
          _buildSection(
            'صيغ الصلاة على النبي',
            Icons.format_quote,
            const Color(0xFFD4A574),
            [
              _buildFormula('اللهم صل وسلم على نبينا محمد'),
              _buildFormula('صلى الله عليه وسلم'),
              _buildFormula(
                'اللهم صل على محمد وعلى آل محمد، كما صليت على إبراهيم وعلى آل إبراهيم، إنك حميد مجيد',
              ),
              _buildFormula(
                'اللهم بارك على محمد وعلى آل محمد، كما باركت على إبراهيم وعلى آل إبراهيم، إنك حميد مجيد',
              ),
            ],
          ),
          const SizedBox(height: 24),
          _buildFooter(),
        ],
      ),
    );
  }

  Widget _buildHeader() {
    return Card(
      color: const Color(0xFF00695C),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            const Icon(Icons.mosque, size: 60, color: Colors.white),
            const SizedBox(height: 12),
            const Text(
              'الصلاة على النبي محمد ﷺ',
              style: TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 8),
            Text(
              'من أعظم العبادات وأجل القربات',
              style: TextStyle(
                fontSize: 14,
                color: Colors.white.withValues(alpha: 0.9),
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSection(
    String title,
    IconData icon,
    Color color,
    List<Widget> children,
  ) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(icon, color: color, size: 28),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    title,
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            ...children,
          ],
        ),
      ),
    );
  }

  Widget _buildQuranVerse(String verse, String reference) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFF00695C).withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            verse,
            style: const TextStyle(
              fontSize: 16,
              height: 1.8,
              fontWeight: FontWeight.w500,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 8),
          Text(
            reference,
            style: const TextStyle(
              fontSize: 12,
              color: Colors.grey,
              fontStyle: FontStyle.italic,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildHadith(String text, String reference) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: const Color(0xFFD4A574).withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: const Color(0xFFD4A574).withValues(alpha: 0.3),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(text, style: const TextStyle(fontSize: 15, height: 1.6)),
          const SizedBox(height: 6),
          Text(
            reference,
            style: const TextStyle(
              fontSize: 11,
              color: Colors.grey,
              fontStyle: FontStyle.italic,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBenefit(String text) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Icon(Icons.check_circle, color: Color(0xFF4CAF50), size: 20),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              text,
              style: const TextStyle(fontSize: 14, height: 1.4),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTime(String text) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Icon(Icons.schedule, color: Color(0xFF00695C), size: 20),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              text,
              style: const TextStyle(fontSize: 14, height: 1.4),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFormula(String text) {
    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: const Color(0xFFD4A574).withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(10),
      ),
      child: Text(
        text,
        style: const TextStyle(fontSize: 14, height: 1.6),
        textAlign: TextAlign.center,
      ),
    );
  }

  Widget _buildFooter() {
    return const Card(
      child: Padding(
        padding: EdgeInsets.all(16),
        child: Column(
          children: [
            Icon(Icons.favorite, color: Color(0xFFD4A574), size: 40),
            SizedBox(height: 12),
            Text(
              'اللهم صل وسلم وبارك على سيدنا محمد وعلى آله وصحبه أجمعين',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: Color(0xFF00695C),
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}
