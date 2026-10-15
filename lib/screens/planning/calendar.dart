import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:fitness_slayer_01/models/my_user.dart';
import 'package:fitness_slayer_01/models/completed_workout.dart';
import 'package:fitness_slayer_01/services/database_service.dart';
import 'day_workout_detail.dart';

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

  bool _isSameDay(DateTime a, DateTime b) {
    return a.year == b.year && a.month == b.month && a.day == b.day;
  }

  @override
  Widget build(BuildContext context) {
    final user = Provider.of<myUser?>(context);
    final String currentUserId = user?.uid ?? FirebaseAuth.instance.currentUser?.uid ?? '';

    final year = _displayedMonth.year;
    final month = _displayedMonth.month;

    // Total days in the displayed month
    final totalDays = DateTime(year, month + 1, 0).day;

    //For normal people
    final startDayOffset = DateTime(year, month, 1).weekday - 1;

    final monthTitle = '${_monthNames[month - 1]} $year';

    return Scaffold(
      backgroundColor: Colors.teal[900],
      body: StreamBuilder<List<CompletedWorkout>>(
        stream: currentUserId.isNotEmpty
            ? DatabaseService().getUserCompletedWorkouts(currentUserId)
            : const Stream.empty(),
        builder: (context, snapshot) {
          final allWorkouts = snapshot.data ?? [];

          return Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 16.0),
            child: Column(
              children: [
                // Month Navigation Header
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    IconButton(
                      icon: const Icon(Icons.chevron_left, color: Colors.white, size: 28),
                      onPressed: () => _changeMonth(-1),
                    ),
                    Text(
                      monthTitle,
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 22,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    IconButton(
                      icon: const Icon(Icons.chevron_right, color: Colors.white, size: 28),
                      onPressed: () => _changeMonth(1),
                    ),
                  ],
                ),

                const SizedBox(height: 16),

                // Days of Week Header
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: _daysOfWeek
                      .map((day) => Expanded(
                            child: Text(
                              day,
                              textAlign: TextAlign.center,
                              style: const TextStyle(
                                color: Colors.white70,
                                fontWeight: FontWeight.bold,
                                fontSize: 16,
                              ),
                            ),
                          ))
                      .toList(),
                ),

                const SizedBox(height: 12),

                // Full Scale Calendar Grid
                Expanded(
                  child: GridView.builder(
                    gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: 7,
                      crossAxisSpacing: 8,
                      mainAxisSpacing: 8,
                      childAspectRatio: 0.9,
                    ),
                    itemCount: totalDays + startDayOffset,
                    itemBuilder: (context, index) {
                      if (index < startDayOffset) {
                        return const SizedBox.shrink();
                      }
                      final dayNumber = index - startDayOffset + 1;
                      final tileDate = DateTime(year, month, dayNumber);

                      final isToday = _isSameDay(tileDate, _today);

                      final dayWorkouts = allWorkouts
                          .where((w) => _isSameDay(w.dateCompleted, tileDate))
                          .toList();

                      final bool hasWorkout = dayWorkouts.isNotEmpty;

                      return GestureDetector(
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => DayWorkoutDetailScreen(
                                date: tileDate,
                                workouts: dayWorkouts,
                              ),
                            ),
                          );
                        },
                        child: Container(
                          decoration: BoxDecoration(
                            color: isToday
                                ? Colors.tealAccent[700]
                                : (hasWorkout ? Colors.teal[800] : Colors.teal[800]?.withValues(alpha: 0.6)),
                            borderRadius: BorderRadius.circular(10),
                            border: Border.all(
                              color: isToday
                                  ? Colors.white
                                  : (hasWorkout ? Colors.greenAccent : Colors.teal[700]!),
                              width: isToday ? 2.5 : (hasWorkout ? 1.5 : 1),
                            ),
                          ),
                          child: Stack(
                            children: [
                              Center(
                                child: Text(
                                  '$dayNumber',
                                  style: TextStyle(
                                    color: Colors.white,
                                    fontWeight: isToday || hasWorkout
                                        ? FontWeight.bold
                                        : FontWeight.normal,
                                    fontSize: 16,
                                  ),
                                ),
                              ),
                              if (hasWorkout)
                                Positioned(
                                  bottom: 6,
                                  right: 0,
                                  left: 0,
                                  child: Center(
                                    child: Container(
                                      width: 6,
                                      height: 6,
                                      decoration: const BoxDecoration(
                                        color: Colors.greenAccent,
                                        shape: BoxShape.circle,
                                      ),
                                    ),
                                  ),
                                ),
                            ],
                          ),
                        ),
                      );
                    },
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}
