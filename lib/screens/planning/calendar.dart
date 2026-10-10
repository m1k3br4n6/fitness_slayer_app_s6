import 'package:flutter/material.dart';
import 'package:fitness_slayer_01/widgets/app_bar.dart';

class Calendar extends StatelessWidget {
  const Calendar({super.key});

  @override
  Widget build(BuildContext context) {
    final daysOfWeek = ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun'];
    const totalDays = 30;
    const startDayOffset = 1; // offset for starting day of the week

    return Scaffold(
      appBar: MyAppBar(),
      backgroundColor: Colors.teal[900],
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            // Month Header
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                IconButton(
                  icon: const Icon(Icons.chevron_left, color: Colors.white),
                  onPressed: () {},
                ),
                const Text(
                  'September 2026',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.chevron_right, color: Colors.white),
                  onPressed: () {},
                ),
              ],
            ),
            const SizedBox(height: 16),

            // Days of Week Header
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: daysOfWeek
                  .map((day) => Text(
                        day,
                        style: const TextStyle(
                          color: Colors.white70,
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
                  final isToday = dayNumber == 30; // highlight current day (e.g. 30th)

                  return Container(
                    decoration: BoxDecoration(
                      color: isToday ? Colors.tealAccent[700] : Colors.teal[800],
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(
                        color: isToday ? Colors.white : Colors.teal[700]!,
                        width: isToday ? 2 : 1,
                      ),
                    ),
                    alignment: Alignment.center,
                    child: Text(
                      '$dayNumber',
                      style: TextStyle(
                        color: Colors.white,
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
