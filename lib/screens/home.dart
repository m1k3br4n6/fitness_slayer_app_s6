import 'package:fitness_slayer_01/screens/notifications/notifications.dart';
import 'package:fitness_slayer_01/screens/notifications/side-quest.dart';
import 'package:fitness_slayer_01/screens/planning/workout-planning.dart';
import 'package:fitness_slayer_01/screens/profile/profile.dart';
import 'package:fitness_slayer_01/screens/settings/settings.dart';
import 'package:flutter/material.dart';
import 'package:fitness_slayer_01/screens/game-features/shop.dart';
import 'package:fitness_slayer_01/services/auth.dart';

class Home extends StatelessWidget {
  Home({super.key});
  final AuthService _auth = AuthService();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Fitness Slayer',
          style: TextStyle(color: Colors.white, fontSize: 20),
        ),
        backgroundColor: Colors.teal,
        elevation: 0.0,
        actions: <Widget>[
          TextButton.icon(
            icon: Icon(Icons.person),
            label: Text('Logout'),
            onPressed: () async {
              await _auth.signOut();
            },
          ),
        ],
      ),
      backgroundColor: Colors.teal[900],
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Text(
              'Home Page',
              style: TextStyle(color: Colors.white, fontSize: 20),
            ),

            //store page button
            ElevatedButton(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => const Shop()),
                );
              },
              child: const Text('Store', style: TextStyle(fontSize: 18)),
            ),

            //profile page button
            ElevatedButton(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => const Profile()),
                );
              },
              child: const Text('My Profile', style: TextStyle(fontSize: 18)),
            ),

            //workout page button
            ElevatedButton(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => const WorkoutPlanning(),
                  ),
                );
              },
              child: const Text('My Workouts', style: TextStyle(fontSize: 18)),
            ),

            //settings page
            ElevatedButton(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => const Settings()),
                );
              },
              child: const Text('Settings', style: TextStyle(fontSize: 18)),
            ),

            //notification page
            ElevatedButton(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => const Notifications(),
                  ),
                );
              },
              child: const Text(
                'Notifications',
                style: TextStyle(fontSize: 18),
              ),
            ),

            //side quest / daily challenge page
            ElevatedButton(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => const SideQuest()),
                );
              },
              child: const Text('Side Quest', style: TextStyle(fontSize: 18)),
            ),
          ],
        ),
      ),
    );
  }
}
