import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:fitness_slayer_01/models/my_user.dart';
import 'package:fitness_slayer_01/models/completed_workout.dart';
import 'package:fitness_slayer_01/models/side_quest_entry.dart';
import 'package:fitness_slayer_01/services/database_service.dart';
import 'package:fitness_slayer_01/theme/app_colors.dart';
import 'day_workout_detail.dart';

class Calendar extends StatefulWidget {
  const Calendar({super.key});

  @override
  State<Calendar> createState() => _CalendarState();
}

class _CalendarState extends State<Calendar> {
  late DateTime _displayedMonth;
  late DateTime _today;

  // Cached so the side quest stream is not resubscribed on every rebuild
  Stream<List<SideQuestEntry>>? _sideQuestStream;
  String? _sideQuestStreamUid;

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

  // Reads the permanent side quest history so completed quests show on the calendar
  Stream<List<SideQuestEntry>> _getSideQuestStream(String uid) {
    if (_sideQuestStream == null || _sideQuestStreamUid != uid) {
      _sideQuestStreamUid = uid;
      _sideQuestStream = FirebaseFirestore.instance
          .collection('users')
          .doc(uid)
          .collection('sideQuestLog')
          .snapshots()
          .map((snap) => snap.docs.map((doc) => SideQuestEntry.fromMap(doc.data())).toList());
    }
    return _sideQuestStream!;
  }

  @override
  Widget build(BuildContext context) {
    final user = Provider.of<myUser?>(context);
    final String currentUserId = user?.uid ?? FirebaseAuth.instance.currentUser?.uid ?? '';

    final year = _displayedMonth.year;
    final month = _displayedMonth.month;

    final totalDays = DateTime(year, month + 1, 0).day;
    final startDayOffset = DateTime(year, month, 1).weekday - 1;
    final monthTitle = '${_monthNames[month - 1]} $year';

    return Scaffold(
      backgroundColor: AppColors.background,
      body: StreamBuilder<List<CompletedWorkout>>(
        stream: currentUserId.isNotEmpty
            ? DatabaseService().getUserCompletedWorkouts(currentUserId)
            : const Stream.empty(),
        builder: (context, workoutSnapshot) {
          final allWorkouts = workoutSnapshot.data ?? [];

          return StreamBuilder<List<SideQuestEntry>>(
            stream: currentUserId.isNotEmpty
                ? _getSideQuestStream(currentUserId)
                : const Stream.empty(),
            builder: (context, questSnapshot) {
              final allSideQuests = questSnapshot.data ?? [];

              return Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  children: [
                    // Month Navigation Header
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        IconButton(
                          icon: const Icon(Icons.chevron_left, color: AppColors.textPrimary, size: 28),
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
                          icon: const Icon(Icons.chevron_right, color: AppColors.textPrimary, size: 28),
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
                            color: AppColors.textSecondary,
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

                          // A day counts as active if it has a logged workout or a completed side quest
                          final daySideQuests = allSideQuests
                              .where((q) => _isSameDay(q.dateCompleted, tileDate))
                              .toList();

                          final bool hasWorkout = dayWorkouts.isNotEmpty || daySideQuests.isNotEmpty;

                          return GestureDetector(
                            onTap: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) => DayWorkoutDetailScreen(
                                    date: tileDate,
                                    workouts: dayWorkouts,
                                    sideQuests: daySideQuests,
                                  ),
                                ),
                              );
                            },
                            child: Container(
                              decoration: BoxDecoration(
                                color: isToday
                                    ? AppColors.primary
                                    : (hasWorkout ? AppColors.woodFrame : AppColors.surface),
                                borderRadius: BorderRadius.circular(10),
                                border: Border.all(
                                  color: isToday
                                      ? AppColors.gold
                                      : (hasWorkout ? AppColors.flameOrange : AppColors.border),
                                  width: isToday ? 2.5 : (hasWorkout ? 1.5 : 1),
                                ),
                              ),
                              child: Stack(
                                children: [
                                  Center(
                                    child: Text(
                                      '$dayNumber',
                                      style: TextStyle(
                                        color: AppColors.textPrimary,
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
                                            color: AppColors.gold,
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
          );
        },
      ),
    );
  }
}
