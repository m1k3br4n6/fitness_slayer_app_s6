import 'package:fitness_slayer_01/screens/authentication/register.dart';
import 'package:flutter/material.dart';
import 'package:fitness_slayer_01/widgets/app_bar.dart';

class Login extends StatelessWidget {
  const Login({super.key});

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
              'Login Page',
              style: TextStyle(
                color: Colors.white,
                fontSize: 20,
              ),
            ),

            //register page button
            ElevatedButton(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => const Register(),
                  ),
                );
              },
              child: const Text('Sign up',
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
