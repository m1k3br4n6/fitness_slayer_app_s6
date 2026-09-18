import 'package:fitness_slayer_01/screens/home.dart';
import 'package:flutter/material.dart';
import 'package:fitness_slayer_01/widgets/app_bar.dart';

class Register extends StatelessWidget {
  const Register({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: const MyAppBar(
        title: 'Not logged in.',
      ),
      backgroundColor: Colors.teal[900],
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Text(
              'Registration Page',
              style: TextStyle(
                color: Colors.white,
                fontSize: 20,
              ),
            ),

            //home page button
            ElevatedButton(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => const Home(),
                  ),
                );
              },
              child: const Text('Save',
                style: TextStyle(
                  fontSize: 18,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
