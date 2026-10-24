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

//Sprite Animator
import 'package:fitness_slayer_01/services/sprite_animator.dart';

import '../providers/slayer_equipment_provider.dart';

const String campfireScene =
    'assets/spritesheets/backgrounds/campsite_background_spritesheet.png';


//Campsite Height
const double campsiteHeight = 300;

class Home extends StatefulWidget {
  const Home({super.key});

  @override
  State<Home> createState() => _HomeState();
}

class _HomeState extends State<Home> {
  final AuthService _auth = AuthService(); //instance of auth service
  final user = FirebaseAuth.instance.currentUser; //get currently signed in user

  //bool for checking admin status
  bool isAdmin = false;

  //keeps track of active tab; defaults to Home in the middle
  int _currentIndex = 2;

  //values for the XP bar. TODO: replace with the real values from the user
  int level = 1;
  int xp = 40;
  int xpToNext = 100;

  @override
  void initState() {
    //runs when stateful widget is first created
    super.initState();

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

    //checks users streak if needs reset
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final String uid = user?.uid ?? '';
      if (uid.isNotEmpty) {
        DatabaseService().checkAndUpdateStreakOnLaunch(uid);
      }
    });
  }

  //custom pixel art icon
  Widget pixelIcon(String path, {bool selected = false, double size = 57}) {
    //you can customize the sizes here without touching the pixel size
    return Image.asset(
      path,
      width: size,
      height: size,
      fit: BoxFit.contain,
      filterQuality: FilterQuality.none,
      isAntiAlias: false,
    );
  }

  //puts a small text label under an icon button
  Widget withLabel(Widget button, String label) {
    return Column(
      children: [
        button,
        const SizedBox(height: 6),
        Text(
          label,
          style: TextStyle(color: AppColors.mutedParchment, fontSize: 14),
        ),
      ],
    );
  }

  // campsite container
  Widget _buildCampsiteContainer() {

    final equipmentState = context.watch<SlayerEquipmentProvider>();

    return SizedBox(
      width: double.infinity,
      height: campsiteHeight,
      child: ClipRect(
        child: Stack(
          fit: StackFit.expand,
          children: [
            SpriteAnimator.play(
              'backgrounds/campsite_background_spritesheet',
              scale: 1.2,
              fps: 8,
              pingPong: false,
              frameCount: 6,
            ),

            //welcome text
            const Positioned(
              top: 30,
              left: 20,
              right: 20,
              child: Text(
                'Welcome Home, Great Slayer.',
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: AppColors.parchmentWhite,
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),

            //Slayer Sprite
            Positioned(
              left: 160,
              right: 16,
              bottom: 54,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  // Slayer Sprite (Knight)
                  AnimatedOpacity(
                    opacity: equipmentState.isLoading ? 0.0 : 1.0,
                    duration: const Duration(milliseconds: 400), // Smooth fade-in
                    curve: Curves.easeOut,
                    child: AnimatedScale(
                      scale: 1.0,
                      duration: const Duration(milliseconds: 300),
                      child: FittedBox(
                        fit: BoxFit.scaleDown,
                        child: SpriteAnimator.play(
                          equipmentState.idleSpritePath,
                          scale: 1.9,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    //pages ordered with home centred
    final List<Widget> pages = [
      //workout page
      const WorkoutPlanning(),
      //calendar page
      const Calendar(),

      //main dashboard hub
      LayoutBuilder(
        builder: (context, constraints) {
          return SingleChildScrollView(
            child: ConstrainedBox(
              constraints: BoxConstraints(minHeight: constraints.maxHeight),
              child: IntrinsicHeight(
                child: Container(
                  width: double.infinity,
                  padding: const EdgeInsets.only(bottom: 24.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      // Horizontal campsite container (animation + character + welcome text)
                      _buildCampsiteContainer(),

                      const SizedBox(height: 20),

                      // Row of icon buttons, directly below the campsite container
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 20.0),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            withLabel(
                              // Notifications button with pixel art
                              Container(
                                decoration: BoxDecoration(
                                  color: Colors.blue,
                                  borderRadius: BorderRadius.circular(8),
                                ),
                                child: IconButton(
                                  constraints: const BoxConstraints(
                                    maxWidth: 50,
                                    maxHeight: 50,
                                  ),
                                  padding: EdgeInsets.zero,
                                  icon: pixelIcon(
                                    'assets/icons/notifications.png',
                                  ),
                                  iconSize: 20,
                                  onPressed: () {
                                    Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                        builder: (context) =>
                                            const WorkInProgressWarning(),
                                      ),
                                    );
                                  },
                                ),
                              ),
                              'Alerts',
                            ),

                            withLabel(
                              // Settings button with pixel art
                              Container(
                                decoration: BoxDecoration(
                                  color: Colors.blue,
                                  borderRadius: BorderRadius.circular(8),
                                ),
                                child: IconButton(
                                  constraints: const BoxConstraints(
                                    maxWidth: 50,
                                    maxHeight: 50,
                                  ),
                                  padding: EdgeInsets.zero,
                                  icon: pixelIcon('assets/icons/settings.png'),
                                  iconSize: 20,
                                  onPressed: () {
                                    Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                        builder: (context) =>
                                            const WorkInProgressWarning(),
                                      ),
                                    );
                                  },
                                ),
                              ),
                              'Settings',
                            ),

                            withLabel(
                              // Info button
                              Container(
                                decoration: BoxDecoration(
                                  color: Colors.blue,
                                  borderRadius: BorderRadius.circular(8),
                                ),
                                child: IconButton(
                                  constraints: const BoxConstraints(
                                    maxWidth: 50,
                                    maxHeight: 50,
                                  ),
                                  padding: EdgeInsets.zero,
                                  icon: Icon(Icons.menu_book),
                                  color: AppColors.parchmentWhite,
                                  iconSize: 28,
                                  onPressed: () {
                                    Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                        builder: (context) => const Info(),
                                      ),
                                    );
                                  },
                                ),
                              ),
                              'About',
                            ),

                            withLabel(
                              // BMI button
                              Container(
                                decoration: BoxDecoration(
                                  color: Colors.blue,
                                  borderRadius: BorderRadius.circular(8),
                                ),
                                child: TextButton(
                                  style: TextButton.styleFrom(
                                    minimumSize: const Size(50, 50),
                                    padding: EdgeInsets.zero,
                                    foregroundColor: Colors.white,
                                    tapTargetSize:
                                        MaterialTapTargetSize.shrinkWrap,
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(8),
                                    ),
                                  ),
                                  onPressed: () {
                                    Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                        builder: (context) =>
                                            const BmiCalculator(),
                                      ),
                                    );
                                  },
                                  child: const Text(
                                    'BMI',
                                    style: TextStyle(
                                      fontSize: 18,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ),
                              ),
                              'Calculator',
                            ),

                            //admin only: equipment crud page button
                            if (isAdmin) //only displays button if user is admin
                              withLabel(
                                Container(
                                  decoration: BoxDecoration(
                                    color: Colors.amber,
                                    borderRadius: BorderRadius.circular(8),
                                  ),
                                  child: IconButton(
                                    constraints: const BoxConstraints(
                                      maxWidth: 50,
                                      maxHeight: 50,
                                    ),
                                    padding: EdgeInsets.zero,
                                    icon: Icon(Icons.admin_panel_settings),
                                    color: Colors.black87,
                                    iconSize: 28,
                                    onPressed: () {
                                      Navigator.push(
                                        context,
                                        MaterialPageRoute(
                                          builder: (context) =>
                                              const adminDashboard(),
                                        ),
                                      );
                                    },
                                  ),
                                ),
                                'Admin',
                              ),
                          ],
                        ),
                      ),

                      const SizedBox(height: 16),

                      // XP bar. TODO: replace level / xp / xpToNext with the real values from the user.
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 20.0),
                        child: Container(
                          padding: const EdgeInsets.all(16),
                          decoration: BoxDecoration(
                            color: Colors.white10,
                            borderRadius: BorderRadius.circular(16),
                          ),
                          child: Column(
                            children: [
                              Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  Text(
                                    'Level $level',
                                    style: TextStyle(
                                      color: AppColors.parchmentWhite,
                                      fontSize: 16,
                                    ),
                                  ),
                                  Text(
                                    '$xp / $xpToNext XP',
                                    style: TextStyle(
                                      color: AppColors.mutedParchment,
                                      fontSize: 16,
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 10),
                              LinearProgressIndicator(
                                value: xp / xpToNext,
                                minHeight: 12,
                                color: AppColors.flameOrange,
                                backgroundColor: Colors.black38,
                                borderRadius: BorderRadius.circular(6),
                              ),
                            ],
                          ),
                        ),
                      ),

                      // Empty spacer area for future assets, GIFs, videos, or widgets
                      const Spacer(),

                      const SizedBox(height: 12),

                      // Boss battle button for Temp testing
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 20.0),
                        child: SizedBox(
                          width: double.infinity,
                          child: ElevatedButton(
                            style: ElevatedButton.styleFrom(
                              backgroundColor: AppColors.flameOrange,
                              foregroundColor: AppColors.parchmentWhite,
                              padding: const EdgeInsets.symmetric(vertical: 14),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(40),
                              ),
                            ),
                            onPressed: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) =>
                                      const BossBattleScreen(),
                                ),
                              );
                            },
                            child: const Column(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Text(
                                  'Boss battle',
                                  style: TextStyle(
                                    fontSize: 20,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                Text(
                                  'Unlocks at 20:00',
                                  style: TextStyle(fontSize: 14),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(height: 12),

                      //daily challenge side quest button anchored at the bottom
                      ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppColors.flameOrange,
                          foregroundColor: AppColors.parchmentWhite,
                          padding: const EdgeInsets.symmetric(
                            horizontal: 28,
                            vertical: 14,
                          ),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10),
                          ),
                        ),
                        onPressed: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => const SideQuest(),
                            ),
                          );
                        },
                        child: Text(
                          'Daily Side Quest',
                          style: TextStyle(
                            color: AppColors.parchmentWhite,
                            fontSize: 16,
                          ),
                        ),
                      ),
                      const SizedBox(height: 12),
                    ],
                  ),
                ),
              ),
            ),
          );
        },
      ),

      //store page
      const Shop(),

      //profile page
      //const Profile(),
      const Profile(),
    ];

    return Scaffold(
      appBar: MyAppBar(
        // tapping the profile photo jumps to the Profile tab
        onAvatarTap: () => setState(() => _currentIndex = 4),
        actions: [
          //logout button
          TextButton.icon(
            icon: Icon(Icons.person, color: AppColors.mutedParchment),
            label: Text(
              'Logout',
              style: TextStyle(color: AppColors.mutedParchment),
            ),
            onPressed: () async {
              await _auth.signOut();
            },
          ),
        ],
      ),

      backgroundColor: AppColors.obsidianBlack,

      // IndexedStack keeps state alive so switching tabs doesn't wipe your screen data
      body: IndexedStack(index: _currentIndex, children: pages),

      //bottom navbar with Home in the middle (index 2)
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
            });
          },
          destinations: [
            //workouts tab
            NavigationDestination(
              icon: pixelIcon('assets/icons/workouts.png'),
              selectedIcon: pixelIcon(
                'assets/icons/workouts.png',
                selected: true,
              ),
              label: 'Workouts',
            ),

            //calendar tab
            NavigationDestination(
              icon: pixelIcon('assets/icons/calendar.png'),
              selectedIcon: pixelIcon(
                'assets/icons/calendar.png',
                selected: true,
              ),
              label: 'Calendar',
            ),

            //home tab in middle
            NavigationDestination(
              icon: pixelIcon('assets/icons/home.png'),
              selectedIcon: pixelIcon('assets/icons/home.png', selected: true),
              label: 'Home',
            ),

            //store tab
            NavigationDestination(
              icon: pixelIcon('assets/icons/store.png'),
              selectedIcon: pixelIcon('assets/icons/store.png', selected: true),
              label: 'Store',
            ),

            //profile
            NavigationDestination(
              icon: pixelIcon('assets/icons/profile.png'),
              selectedIcon: pixelIcon(
                'assets/icons/profile.png',
                selected: true,
              ),
              label: 'Profile',
            ),
          ],
        ),
      ),
    );
  }
}
