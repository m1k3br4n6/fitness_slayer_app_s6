import "package:flutter/material.dart";
import 'package:fitness_slayer_01/screens/authentication/login.dart';
import 'package:fitness_slayer_01/screens/authentication/register.dart';

class Authenticate extends StatefulWidget {
  const Authenticate({super.key});

  @override
  State<Authenticate> createState() => _AuthenticateState();
}

class _AuthenticateState extends State<Authenticate> {
  bool showSignIn = true;
  void toggleView() {
    setState(
      () => showSignIn =
          !showSignIn, //!showSignIn gives opposite of what it currently is
    );
  }

  @override
  Widget build(BuildContext context) {
    if (showSignIn) {
      return Login(
        toggleView: toggleView,
      );
    } else {
      return Register(toggleView: toggleView);
    }
  }
}
