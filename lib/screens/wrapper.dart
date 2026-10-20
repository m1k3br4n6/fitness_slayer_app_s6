import 'package:fitness_slayer_01/screens/home.dart';
import 'package:flutter/material.dart';
import 'package:fitness_slayer_01/screens/authentication/authenticate.dart';
import 'package:provider/provider.dart';
import "package:fitness_slayer_01/models/my_user.dart";

class Wrapper extends StatelessWidget {
  const Wrapper({super.key});

  @override
  Widget build(BuildContext context) {
    final user = Provider.of<myUser?>(context); //returns instance of myUser or null

    //return 'home' or 'authenticate' widget
    if (user == null) {
      //if no session user
      return Authenticate();
    }
     else {
       //if instance of myUser
       return Home();
    }

  }
}
