import 'package:fitness_slayer_01/screens/admin/equipment_management.dart';
import 'package:fitness_slayer_01/screens/extra-features/info.dart';
import 'package:fitness_slayer_01/screens/extra-features/work_in_progress_warning.dart';
import 'package:fitness_slayer_01/screens/notifications/notifications.dart';
import 'package:fitness_slayer_01/screens/notifications/side_quest.dart';
import 'package:fitness_slayer_01/screens/planning/calendar.dart';
import 'package:fitness_slayer_01/screens/settings/settings.dart';
import 'package:fitness_slayer_01/screens/planning/workout_planning.dart';
import 'package:fitness_slayer_01/screens/profile/profile.dart';
import 'package:fitness_slayer_01/screens/extra-features/bmi_calculator.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:fitness_slayer_01/models/my_user.dart';
import 'package:fitness_slayer_01/services/database_service.dart';
import 'package:fitness_slayer_01/screens/game-features/shop.dart';
import 'package:fitness_slayer_01/services/auth.dart';
import 'package:fitness_slayer_01/widgets/app_bar.dart';
import 'package:fitness_slayer_01/theme/app_colors.dart';

class Home extends StatefulWidget {
  const Home({super.key});

  @override
  State<Home> createState() => _HomeState();
}

class _HomeState extends State<Home> {
  final AuthService _auth = AuthService();
  final user = FirebaseAuth.instance.currentUser;

  bool isAdmin = false;
  //keeps track of active tab; defaults to Home in the middle
  int _currentIndex = 2;

  @override
  void initState() {
    super.initState();

    final user = context.read<myUser?>();
    final String uid = user?.uid ?? FirebaseAuth.instance.currentUser?.uid ?? '';
    if (uid == "6Iw3AiqlCObMc77PAbCLDsmaBbh2")
    {
      isAdmin = true;
    }
    else
    {
      isAdmin = false;
    }

    // Checks users streak if needs reset
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final user = context.read<myUser?>();
      final String uid = user?.uid ?? FirebaseAuth.instance.currentUser?.uid ?? '';
      if (uid.isNotEmpty) {
        DatabaseService().checkAndUpdateStreakOnLaunch(uid);
      }
    });
  }

  // Custom pixel art icon
  Widget pixelIcon(
      String path, {
        bool selected = false,
        double size = 57,
      }) {
    //u can customize the sizes here without touching the pixel size
    return Image.asset(
      path,
      width: size,
      height: size,
      fit: BoxFit.contain,
      filterQuality: FilterQuality.none,
      isAntiAlias: false,
    );
  }

  @override
  Widget build(BuildContext context) {
    //Pages ordered with home centred
    final List<Widget> pages = [
      // workout page
      const WorkoutPlanning(),
      // calendar page
      const Calendar(),

      // main dashboard hub
      LayoutBuilder(
        builder: (context, constraints) {
          return SingleChildScrollView(
            child: ConstrainedBox(
              constraints: BoxConstraints(minHeight: constraints.maxHeight),
              child: IntrinsicHeight(
                child: Container(
                  width: double.infinity,
                  padding: const EdgeInsets.only(top: 30.0, left: 20.0, right: 20.0, bottom: 24.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      const Text(
                        'Welcome Home, Great Slayer.',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          color: AppColors.parchmentWhite,
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                        ),
                      ),

                      SizedBox(height: 5),

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
                          icon: pixelIcon('assets/icons/notifications.png'),
                          iconSize: 20,
                          onPressed: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => const WorkInProgressWarning(),
                              ),
                            );
                          },
                        ),
                      ),

                      SizedBox(height: 5),

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
                                builder: (context) => const WorkInProgressWarning(),
                              ),
                            );
                          },
                        ),
                      ),

                      SizedBox(height: 5),
                      
                      //Info button
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
                          iconSize: 25,
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

                      SizedBox(height: 5),

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
                            tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(8),
                            ),
                          ),
                          onPressed: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => const BmiCalculator(),
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

                      SizedBox(height: 5),

                      //Admin only equipment upload button
                      if (isAdmin)
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
                          iconSize:28,
                          onPressed: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => const WorkInProgressWarning(),
                              ),
                            );
                          },
                        ),
                      ),

                      // Empty spacer area for future campfire scenes, assets, GIFs, videos, or widgets
                      const Spacer(),

                      // daily challenge button anchored at the bottom
                      ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppColors.flameOrange,
                          foregroundColor: AppColors.parchmentWhite,
                          padding: const EdgeInsets.symmetric(horizontal: 28, vertical: 14),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10),
                          ),
                        ),
                        onPressed: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(builder: (context) => const SideQuest()),
                          );
                        },
                        child: Text('Daily Side Quest', style: TextStyle(color: AppColors.parchmentWhite, fontSize: 16)),
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

      // store / shop page
      const Shop(),

      // profile page
      const Profile(),
    ];

    return Scaffold(
      appBar: MyAppBar(
        actions: [
          //logout button
          TextButton.icon(
            icon: Icon(Icons.person, color: AppColors.mutedParchment),
            label: Text('Logout', style: TextStyle(color: AppColors.mutedParchment)),
            onPressed: () async {
              await _auth.signOut();
            },
          ),
        ],
      ),

      backgroundColor: AppColors.obsidianBlack,

      //IndexedStack keeps state alive so switching tabs doesn't wipe your screen data
      body: IndexedStack(
        index: _currentIndex,
        children: pages,
      ),

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
          destinations:  [
            // workouts tab
            NavigationDestination(
              icon: pixelIcon('assets/icons/workouts.png'),
              selectedIcon: pixelIcon(
                'assets/icons/workouts.png',
                selected: true,
              ),
              label: 'Workouts',
            ),

            // calendar tab
            NavigationDestination(
              icon: pixelIcon('assets/icons/calendar.png'),
              selectedIcon: pixelIcon(
                'assets/icons/calendar.png',
                selected: true,
              ),
              label: 'Calendar',
            ),

            // home tab in middle
            NavigationDestination(
              icon: pixelIcon('assets/icons/home.png'),
              selectedIcon: pixelIcon(
                'assets/icons/home.png',
                selected: true,
              ),
              label: 'Home',
            ),

            // store / shop tab
            NavigationDestination(
              icon: pixelIcon('assets/icons/store.png'),
              selectedIcon: pixelIcon(
                'assets/icons/store.png',
                selected: true,
              ),
              label: 'Store',
            ),

            // profile
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