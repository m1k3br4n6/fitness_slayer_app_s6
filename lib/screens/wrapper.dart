import 'package:fitness_slayer_01/screens/home.dart';
import 'package:flutter/material.dart';
import 'package:fitness_slayer_01/screens/authentication/authenticate.dart';
import 'package:provider/provider.dart';
import "package:fitness_slayer_01/models/my_user.dart";

class Wrapper extends StatelessWidget {
  const Wrapper({super.key});

  @override
  Widget build(BuildContext context) {
    final user = Provider.of<myUser?>(context);
    print(user);

    return Home();

    //return 'home' or 'authenticate' widget
    /*if (user == null) {
      return Authenticate();
    }
     else {
      return Home();
    }*/

  }
}
