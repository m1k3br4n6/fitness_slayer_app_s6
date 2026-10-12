import 'package:fitness_slayer_01/screens/notifications/notifications.dart';
import 'package:fitness_slayer_01/screens/notifications/side-quest.dart';
import 'package:fitness_slayer_01/screens/planning/calendar.dart';
import 'package:fitness_slayer_01/screens/settings/settings.dart';
import 'package:fitness_slayer_01/screens/planning/workout-planning.dart';
import 'package:fitness_slayer_01/screens/profile/profile.dart';
import 'package:flutter/material.dart';
import 'package:fitness_slayer_01/screens/game-features/shop.dart';
import 'package:fitness_slayer_01/services/auth.dart';
import 'package:fitness_slayer_01/services/database.dart';
import 'package:provider/provider.dart';
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

  @override
  Widget build(BuildContext context) {
    //Pages ordered with home centred
    final List<Widget> pages = [
      // workout page
      const WorkoutPlanning(),
      // calendar page
      const Calendar(),

      // main dashboard hub
      SingleChildScrollView(
        child: Container(
          width: double.infinity, // Forces full width so Column aligns perfectly horizontally
          padding: const EdgeInsets.only(top: 60.0, left: 20.0, right: 20.0, bottom: 20.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.start,
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
              const SizedBox(height: 48), // Increased spacing to separate button from top welcome text

              // daily challenge button
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
            ],
          ),
        ),
      ),

      // store / shop page
      const Shop(),

      // profile page
      const Profile(),
    ];

    return Scaffold(
      appBar: MyAppBar(
        actions: [
          //notification page icon button
          IconButton(
            icon: const Icon(Icons.notifications, color: Colors.white70),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const Notifications()),
              );
            },
          ),

          //settings cog wheel icon button in light teal / blue-green tonal style
          IconButton(
            icon: Icon(Icons.settings, color: Colors.teal[200]),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const AppSettings()),
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
          destinations: const [
            // workout tab
            NavigationDestination(
              icon: Icon(Icons.fitness_center_outlined, color: Colors.white70),
              selectedIcon: Icon(Icons.fitness_center, color: Colors.tealAccent),
              label: 'Workouts',
            ),
            // calendar tab
            NavigationDestination(
              icon: Icon(Icons.calendar_today_outlined, color: Colors.white70),
              selectedIcon: Icon(Icons.calendar_today, color: Colors.tealAccent),
              label: 'Calendar',
            ),
            // home tab in middle
            NavigationDestination(
              icon: Icon(Icons.home_outlined, color: Colors.white70),
              selectedIcon: Icon(Icons.home, color: Colors.tealAccent),
              label: 'Home',
            ),
            //3. store / shop tab
            NavigationDestination(
              icon: Icon(Icons.shopping_bag_outlined, color: Colors.white70),
              selectedIcon: Icon(Icons.shopping_bag, color: Colors.tealAccent),
              label: 'Store',
            ),
            // profile tab
            NavigationDestination(
              icon: Icon(Icons.person_outline, color: Colors.white70),
              selectedIcon: Icon(Icons.person, color: Colors.tealAccent),
              label: 'Profile',
            ),
          ],
        ),
      ),
    );
  }
}
