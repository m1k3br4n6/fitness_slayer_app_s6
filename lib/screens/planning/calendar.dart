import 'package:flutter/material.dart';
import 'package:fitness_slayer_01/theme/app_colors.dart';

class Calendar extends StatefulWidget {
  const Calendar({super.key});

  @override
  State<Calendar> createState() => _CalendarState();
}

class _CalendarState extends State<Calendar> {
  late DateTime _displayedMonth;
  late DateTime _today;

  final List<String> _monthNames = const [
    'January', 'February', 'March', 'April', 'May', 'June',
    'July', 'August', 'September', 'October', 'November', 'December'
  ];

  final List<String> _daysOfWeek = const ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun'];

  @override
  void initState() {
    super.initState();
    _today = DateTime.now();
    _displayedMonth = DateTime(_today.year, _today.month);
  }

  void _changeMonth(int increment) {
    setState(() {
      _displayedMonth = DateTime(_displayedMonth.year, _displayedMonth.month + increment);
    });
  }

  @override
  Widget build(BuildContext context) {
    final year = _displayedMonth.year;
    final month = _displayedMonth.month;

    final totalDays = DateTime(year, month + 1, 0).day;
    final startDayOffset = DateTime(year, month, 1).weekday - 1;
    final monthTitle = '${_monthNames[month - 1]} $year';

    return Scaffold(
      backgroundColor: AppColors.background,
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            // Month Header
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                IconButton(
                  icon: const Icon(Icons.chevron_left, color: AppColors.textPrimary),
                  onPressed: () => _changeMonth(-1),
                ),
                Text(
                  monthTitle,
                  style: const TextStyle(
                    color: AppColors.textPrimary,
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.chevron_right, color: AppColors.textPrimary),
                  onPressed: () => _changeMonth(1),
                ),
              ],
            ),
            const SizedBox(height: 16),

            // Days of Week Header
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: _daysOfWeek
                  .map((day) => Text(
                        day,
                        style: const TextStyle(
                          color: AppColors.textSecondary,
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                        ),
                      ))
                  .toList(),
            ),
            const SizedBox(height: 12),

            // Calendar Grid
            Expanded(
              child: GridView.builder(
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 7,
                  crossAxisSpacing: 8,
                  mainAxisSpacing: 8,
                ),
                itemCount: totalDays + startDayOffset,
                itemBuilder: (context, index) {
                  if (index < startDayOffset) {
                    return const SizedBox.shrink();
                  }
                  final dayNumber = index - startDayOffset + 1;
                  final isToday = dayNumber == _today.day &&
                      month == _today.month &&
                      year == _today.year;

                  return Container(
                    decoration: BoxDecoration(
                      color: isToday ? AppColors.primary : AppColors.surface,
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(
                        color: isToday ? AppColors.gold : AppColors.border,
                        width: isToday ? 2 : 1,
                      ),
                    ),
                    alignment: Alignment.center,
                    child: Text(
                      '$dayNumber',
                      style: TextStyle(
                        color: AppColors.textPrimary,
                        fontWeight: isToday ? FontWeight.bold : FontWeight.normal,
                        fontSize: 16,
                      ),
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}