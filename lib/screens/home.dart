import 'package:fitness_slayer_01/screens/admin/admin_dashboard.dart';
import 'package:fitness_slayer_01/screens/extra-features/info.dart';
import 'package:fitness_slayer_01/screens/extra-features/work_in_progress_warning.dart';
import 'package:fitness_slayer_01/screens/notifications/side_quest.dart';
import 'package:fitness_slayer_01/screens/planning/calendar.dart';
import 'package:fitness_slayer_01/screens/planning/workout_planning.dart';
import 'package:fitness_slayer_01/screens/profile/profile.dart';
import 'package:fitness_slayer_01/screens/extra-features/bmi_calculator.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:fitness_slayer_01/services/database_service.dart';
import 'package:fitness_slayer_01/screens/game-features/shop.dart';
import 'package:fitness_slayer_01/services/auth.dart';
import 'package:fitness_slayer_01/widgets/app_bar.dart';
import 'package:fitness_slayer_01/theme/app_colors.dart';
import 'package:fitness_slayer_01/screens/game-features/boss_battle.dart';

import '../providers/slayer_equipment_provider.dart';
import '../widgets/campsite_scene.dart';

class Home extends StatefulWidget {
  const Home({super.key});

  @override
  State<Home> createState() => _HomeState();
}

class _HomeState extends State<Home> with SingleTickerProviderStateMixin {
  final AuthService _auth = AuthService();
  final user = FirebaseAuth.instance.currentUser;

  bool isAdmin = false;
  int _currentIndex = 2;


  // FAB Animation Controller
  late AnimationController _fabController;
  bool _isFabOpen = false;

  @override
  void initState() {
    super.initState();

    _fabController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 250),
    );

    //checks if current user is admin
    final String uid =
        user?.uid ??
            ''; //gets uid if user is not null, otherwise return empty string
    if (uid == "6Iw3AiqlCObMc77PAbCLDsmaBbh2") {
      isAdmin = true;
    } else {
      isAdmin = false;
    }

    if (uid.isNotEmpty) {
      context.read<SlayerEquipmentProvider>().initializeListener(uid);
    }

    WidgetsBinding.instance.addPostFrameCallback((_) {
      final String uid = user?.uid ?? '';
      if (uid.isNotEmpty) {
        DatabaseService().checkAndUpdateStreakOnLaunch(uid);
      }
    });
  }

  @override
  void dispose() {
    _fabController.dispose();
    super.dispose();
  }

  void _toggleFab() {
    setState(() {
      _isFabOpen = !_isFabOpen;
      if (_isFabOpen) {
        _fabController.forward();
      } else {
        _fabController.reverse();
      }
    });
  }

  Widget pixelIcon(String path, {bool selected = false, double size = 57}) {
    return Image.asset(
      path,
      width: size,
      height: size,
      fit: BoxFit.contain,
      filterQuality: FilterQuality.none,
      isAntiAlias: false,
    );
  }

  Widget _buildCampsiteContainer(BuildContext context) {

    final String uid = user?.uid ?? '';

    // Stream for exp
    return StreamBuilder<Map<String, dynamic>?>(
      stream: DatabaseService().getUserDataStream(uid),
      builder: (context, snapshot) {
        final data = snapshot.data ?? {};

        // Reads users current exp
        final int xp = (data['xp'] as num?)?.toInt() ?? 0;
        final int xpToNext = 100;

        // Puts exp bar just above the slayers head
        final double xpRatio = (xp / xpToNext).clamp(0.0, 1.0);
        final int calculatedXpFrame = (xpRatio * 7).round();

        return SizedBox(
          width: double.infinity,
          height: MediaQuery.of(context).size.height * 0.48,
          child: CampsiteScene(
            playAudio: false,
            showText: true,
            showExpBar: true,
            xp: xp,
            xpNeeded: xpToNext,
            xpFrame: calculatedXpFrame,
          ),
        );
      },
    );
  }

  Widget _buildQuestCard({
    required String title,
    required String subtitle,
    required IconData icon,
    required Color color,
    required VoidCallback onTap,
  }) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(16),
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 8),
          decoration: BoxDecoration(
            color: AppColors.darkTavernGreen,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: color.withValues(alpha: 0.5), width: 2),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.3),
                blurRadius: 8,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(icon, color: color, size: 36),
              const SizedBox(height: 12),
              Text(
                title,
                textAlign: TextAlign.center,
                style: const TextStyle(
                  color: AppColors.parchmentWhite,
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 6),
              Text(
                subtitle,
                textAlign: TextAlign.center,
                style: const TextStyle(
                  color: Colors.white70,
                  fontSize: 12,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildHorizontalFabItem({
    required Widget icon,
    required String label,
    required Color color,
    required VoidCallback onTap,
  }) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      mainAxisAlignment: MainAxisAlignment.start,
      children: [
        FloatingActionButton(
          heroTag: label,
          backgroundColor: color,
          elevation: 4,
          onPressed: () {
            _toggleFab();
            onTap();
          },
          child: icon,
        ),
        const SizedBox(height: 8),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
          decoration: BoxDecoration(
            color: const Color(0xFF2A2A2A),
            borderRadius: BorderRadius.circular(6),
          ),
          child: Text(
            label,
            style: const TextStyle(color: AppColors.parchmentWhite, fontSize: 10, fontWeight: FontWeight.bold),
          ),
        ),
      ],
    );
  }

  Widget _buildExpandableFab() {
    return IntrinsicHeight(
      child: Row(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // TOGGLE BUTTON
          FloatingActionButton(
            heroTag: 'main_fab',
            backgroundColor: AppColors.gemGold,
            onPressed: _toggleFab,
            child: AnimatedIcon(
              icon: AnimatedIcons.menu_close,
              progress: _fabController,
              color: AppColors.obsidianBlack,
            ),
          ),
          // MENU
          SizeTransition(
            sizeFactor: CurvedAnimation(parent: _fabController, curve: Curves.easeOutBack),
            axis: Axis.horizontal,
            alignment: Alignment.centerLeft,
            child: SizedBox(
              width: MediaQuery.of(context).size.width - 96,
              child: Row(
                // Takes up remaining with of the screen
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  if (isAdmin)
                    _buildHorizontalFabItem(
                      icon: const Icon(Icons.admin_panel_settings, color: Colors.white, size: 28),
                      label: 'Admin',
                      color: Colors.amber,
                      onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const adminDashboard())),
                    ),
                  _buildHorizontalFabItem(
                    icon: const Icon(Icons.calculate_rounded, color: Colors.white, size: 28),
                    label: 'BMI',
                    color: Colors.blue,
                    onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const BmiCalculator())),
                  ),
                  _buildHorizontalFabItem(
                    icon: const Icon(Icons.menu_book, color: Colors.white, size: 28),
                    label: 'About',
                    color: Colors.blue,
                    onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const Info())),
                  ),
                  _buildHorizontalFabItem(
                    icon: Image.asset('assets/icons/settings.png', filterQuality: FilterQuality.none, width: 28, height: 28),
                    label: 'Settings',
                    color: Colors.blue,
                    onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const WorkInProgressWarning())),
                  ),
                  _buildHorizontalFabItem(
                    icon: Image.asset('assets/icons/notifications.png', filterQuality: FilterQuality.none, width: 28, height: 28),
                    label: 'Alerts',
                    color: Colors.blue,
                    onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const WorkInProgressWarning())),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final List<Widget> pages = [
      const WorkoutPlanning(),
      const Calendar(),

      // Main Dashboard Hub
      Column(
        children: [
          // CAMPSITE CONTAINER
          _buildCampsiteContainer(context),

          const SizedBox(height: 20),

          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20.0),
            child: Row(
              children: [
                Expanded(
                  // BOSS BATTLE BUTTON
                  child: _buildQuestCard(
                    title: 'Boss Battle',
                    subtitle: 'Unlocks at 20:00',
                    icon: Icons.local_fire_department_rounded,
                    color: AppColors.flameOrange,
                    onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const BossBattleScreen())),
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  // DAILY QUEST BUTTON
                  child: _buildQuestCard(
                    title: 'Daily Quest',
                    subtitle: 'Available Now',
                    icon: Icons.explore_rounded,
                    color: Colors.amber,
                    onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const SideQuest())),
                  ),
                ),
              ],
            ),
          ),

          const Spacer(),
          // Space for fab
          const SizedBox(height: 90),
        ],
      ),
      const Shop(),
      const Profile(),
    ];

    return Scaffold(
      appBar: MyAppBar(
        onAvatarTap: () => setState(() => _currentIndex = 4),
        actions: [
          TextButton.icon(
            icon: const Icon(Icons.person, color: Colors.white54),
            label: const Text('Logout', style: TextStyle(color: Colors.white54)),
            onPressed: () async => await _auth.signOut(),
          ),
        ],
      ),
      backgroundColor: AppColors.obsidianBlack,
      body: IndexedStack(index: _currentIndex, children: pages),

      floatingActionButtonLocation: FloatingActionButtonLocation.startFloat,
      floatingActionButton: _currentIndex == 2 ? _buildExpandableFab() : null,

      bottomNavigationBar: NavigationBarTheme(
        data: NavigationBarThemeData(
          backgroundColor: AppColors.darkTavernGreen,
          indicatorColor: AppColors.crimsonRed,
          labelTextStyle: WidgetStateProperty.all(
            const TextStyle(color: AppColors.mutedParchment, fontSize: 12),
          ),
        ),
        child: NavigationBar(
          selectedIndex: _currentIndex,
          onDestinationSelected: (int index) {
            setState(() {
              _currentIndex = index;
              if (_isFabOpen) _toggleFab();
            });
          },
          destinations: [
            NavigationDestination(
              icon: pixelIcon('assets/icons/workouts.png'),
              selectedIcon: pixelIcon('assets/icons/workouts.png', selected: true),
              label: 'Workouts',
            ),
            NavigationDestination(
              icon: pixelIcon('assets/icons/calendar.png'),
              selectedIcon: pixelIcon('assets/icons/calendar.png', selected: true),
              label: 'Calendar',
            ),
            NavigationDestination(
              icon: pixelIcon('assets/icons/home.png'),
              selectedIcon: pixelIcon('assets/icons/home.png', selected: true),
              label: 'Home',
            ),
            NavigationDestination(
              icon: pixelIcon('assets/icons/store.png'),
              selectedIcon: pixelIcon('assets/icons/store.png', selected: true),
              label: 'Store',
            ),
            NavigationDestination(
              icon: pixelIcon('assets/icons/profile.png'),
              selectedIcon: pixelIcon('assets/icons/profile.png', selected: true),
              label: 'Profile',
            ),
          ],
        ),
      ),
    );
  }
}