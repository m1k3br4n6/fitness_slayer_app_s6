import 'package:fitness_slayer_01/screens/notifications/notifications.dart';
import 'package:fitness_slayer_01/screens/notifications/side-quest.dart';
import 'package:fitness_slayer_01/screens/planning/calendar.dart';
import 'package:fitness_slayer_01/screens/settings/settings.dart';
import 'package:fitness_slayer_01/screens/planning/workout-planning.dart';
import 'package:fitness_slayer_01/screens/profile/profile.dart';
import 'package:flutter/material.dart';
import 'package:fitness_slayer_01/screens/game-features/shop.dart';
import 'package:fitness_slayer_01/services/auth.dart';
import 'package:fitness_slayer_01/widgets/app_bar.dart';

class Home extends StatefulWidget {
  const Home({super.key});

  @override
  State<Home> createState() => _HomeState();
}

class _HomeState extends State<Home> {
  final AuthService _auth = AuthService();

  //keeps track of active tab; defaults to Home in the middle
  int _currentIndex = 2;

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
                  padding: const EdgeInsets.only(top: 40.0, left: 20.0, right: 20.0, bottom: 24.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      const Text(
                        'Welcome Home, Great Slayer.',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                        ),
                      ),

                      // Empty spacer area for future campfire scenes, assets, GIFs, videos, or widgets
                      const Spacer(),

                      // daily challenge button anchored at the bottom
                      ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.teal[800],
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
                        child: const Text('Daily Side Quest', style: TextStyle(color: Colors.white, fontSize: 16)),
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

          // Notifications button with pixel art
          IconButton(
            constraints: const BoxConstraints(
              minWidth: 36,
              minHeight: 40,
            ),
            padding: EdgeInsets.zero,
            icon: pixelIcon('assets/icons/notifications.png'),
            iconSize: 24,
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => const Notifications(),
                ),
              );
            },
          ),

          // Settings button with pixel art
          IconButton(
            constraints: const BoxConstraints(
              minWidth: 36,
              minHeight: 40,
            ),
            padding: EdgeInsets.zero,
            icon: pixelIcon('assets/icons/settings.png'),
            iconSize: 24,
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => const AppSettings(),
                ),
              );
            },
          ),

          //logout button
          TextButton.icon(
            icon: const Icon(Icons.person, color: Colors.white70),
            label: const Text('Logout', style: TextStyle(color: Colors.white70)),
            onPressed: () async {
              await _auth.signOut();
            },
          ),
        ],
      ),

      backgroundColor: Colors.teal[900],

      //IndexedStack keeps state alive so switching tabs doesn't wipe your screen data
      body: IndexedStack(
        index: _currentIndex,
        children: pages,
      ),

      //bottom navbar with Home in the middle (index 2)
      bottomNavigationBar: NavigationBarTheme(
        data: NavigationBarThemeData(
          backgroundColor: Colors.teal[800],
          indicatorColor: Colors.teal[600],
          labelTextStyle: WidgetStateProperty.all(
            const TextStyle(color: Colors.white70, fontSize: 12),
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