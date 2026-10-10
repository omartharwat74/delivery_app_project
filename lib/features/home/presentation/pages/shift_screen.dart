import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

class WorkHoursScreen extends StatefulWidget {
  const WorkHoursScreen({super.key});

  @override
  State<WorkHoursScreen> createState() => _WorkHoursScreenState();
}

class _WorkHoursScreenState extends State<WorkHoursScreen> {
  DateTime _selectedDate = DateTime(2026, 11, 18); // Default selected from Figma

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        centerTitle: false,
        titleSpacing: 4,
        leadingWidth: 44,
        leading: Padding(
          padding: const EdgeInsetsDirectional.only(start: 16),
          child: InkWell(
            onTap: () => context.pop(),
            borderRadius: BorderRadius.circular(14),
            child: Container(
              width: 28,
              height: 28,
              alignment: Alignment.center,
              child: const Icon(
                Icons.arrow_back_ios,
                size: 20,
              ),
            ),
          ),
        ),
        title: const Text(
          'مواعيد العمل',
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
      body: SafeArea(
        child: Column(
          children: [
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildCalendarCard(context),
                    const SizedBox(height: 32),
                    
                    // -- قسم الموعد وتغيير الموعد بالتنسيق والمسافات المطلوبة --
                    const Text(
                      'موعدك :',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 8),
                    
                    const Text(
                      'من 01 Pm الى 9 Pm',
                      style: TextStyle(
                        fontSize: 14,
                        color: Colors.grey,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    const SizedBox(height: 12),
                    
                    GestureDetector(
                      onTap: () {
                        // TODO: Change shift time logic
                      },
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Image.asset(
                            'assets/icons/edit-02.png',
                            width: 20,
                            height: 20,
                          ),
                          const SizedBox(width: 8),
                          const Text(
                            'تغيير الموعد',
                            style: TextStyle(
                              color: Color(0xFFA3090F),
                              fontSize: 14,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                    ),
                    // --------------------------------------------------------
                  ],
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: SizedBox(
                width: double.infinity,
                height: 50,
                child: ElevatedButton(
                  onPressed: () {
                    context.pop();
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFFA3090F), // Primary Red
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  child: const Text(
                    'تأكيد',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCalendarCard(BuildContext context) {
    final days = ['Sun', 'Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat'];
    final dates = [
      31, 1, 2, 3, 4, 5, 6,
      7, 8, 9, 10, 11, 12, 13,
      14, 15, 16, 17, 18, 19, 20,
      21, 22, 23, 24, 25, 26, 27,
      28, 29, 30, 1, 2, 3, 4,
    ];

    return Container(
      padding: const EdgeInsets.all(16.0),
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
        border: Border.all(
          color: Colors.grey.withValues(alpha: 0.1),
        )
      ),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              _buildMonthNavButton(Icons.chevron_left, () {}),
              const Text(
                'نوفمبر',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
              _buildMonthNavButton(Icons.chevron_right, () {}),
            ],
          ),
          const SizedBox(height: 16),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: days.map((day) => Expanded(
              child: Center(
                child: Text(
                  day,
                  style: TextStyle(
                    fontSize: 12,
                    color: Colors.grey[600],
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
            )).toList(),
          ),
          const SizedBox(height: 12),
          GridView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: dates.length,
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 7,
              mainAxisSpacing: 8,
              crossAxisSpacing: 8,
            ),
            itemBuilder: (context, index) {
              final date = dates[index];
              final isCurrentMonth = index > 0 && index < 31;
              final isSelected = isCurrentMonth && _selectedDate.day == date && _selectedDate.month == 11;

              return GestureDetector(
                onTap: () {
                  if (isCurrentMonth) {
                    setState(() {
                      _selectedDate = DateTime(2026, 11, date);
                    });
                  }
                },
                child: Container(
                  decoration: BoxDecoration(
                    color: isSelected ? const Color(0xFFA3090F) : Colors.transparent,
                    shape: BoxShape.circle,
                  ),
                  child: Center(
                    child: Text(
                      date.toString(),
                      style: TextStyle(
                        color: isSelected
                            ? Colors.white
                            : (isCurrentMonth ? Theme.of(context).textTheme.bodyLarge?.color : Colors.grey[400]),
                        fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                      ),
                    ),
                  ),
                ),
              );
            },
          ),
        ],
      ),
    );
  }

  // Widget تصميم زر التنقل بين الشهور الذي طلبته
  Widget _buildMonthNavButton(IconData icon, VoidCallback onTap) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 32,
        height: 32,
        decoration: ShapeDecoration(
          color: Colors.white.withValues(alpha: 0.35), // Fram-card
          shape: RoundedRectangleBorder(
            side: const BorderSide(
              width: 1,
              color: Color(0xFFE5E5E5), // Strock-Sm
            ),
            borderRadius: BorderRadius.circular(8),
          ),
        ),
        // استخدمت Center لضبط الأيقونة برمجياً بأفضل شكل داخل مساحة الـ 32
        child: Center(
          child: Icon(
            icon,
            size: 16,
            color: Colors.black87,
          ),
        ),
      ),
    );
  }
}