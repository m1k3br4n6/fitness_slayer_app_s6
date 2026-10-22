import 'package:fitness_slayer_01/screens/wrapper.dart';
import 'package:fitness_slayer_01/services/notification_service.dart';
import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'firebase_options.dart';
import 'package:provider/provider.dart';
import 'package:fitness_slayer_01/models/my_user.dart';
import 'package:fitness_slayer_01/services/auth.dart';
import 'package:fitness_slayer_01/providers/workout_provider.dart';
import 'package:fitness_slayer_01/providers/workout_timer.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:fitness_slayer_01/theme/app_theme.dart';
import 'package:rxdart/rxdart.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  //initialize firebase --> to use auth and firestore
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );

  final notificationService = NotificationService();
  await notificationService.init();
  await notificationService.requestPermissions();

  runApp(const MyApp()); //when app starts, runs MyApp()
}

//MyApp that runs when app starts
class MyApp extends StatelessWidget {
  const MyApp({super.key});

  //this widget is the root of the application.
  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        StreamProvider<myUser?>.value( //stream actively listens for user related auth changes, uses myUser model
          value: AuthService().user, //stream we are going to listen to, accessing 'user' stream in auth class
          initialData: null,
        ),

        //current user's Firestore document
        StreamProvider<DocumentSnapshot?>.value(
          // switchMap cancels the previous user's document stream on every auth change.
          // asyncExpand never moved on because a Firestore stream never completes.
          value: FirebaseAuth.instance.authStateChanges().switchMap<DocumentSnapshot?>((user) {
            if (user == null) {
              return Stream<DocumentSnapshot?>.value(null);
            }

            return FirebaseFirestore.instance.collection('users').doc(user.uid).snapshots()
                .map<DocumentSnapshot?>((snapshot) => snapshot);
          }),
          initialData: null,
        ),

        ChangeNotifierProvider( //actively listens for changes in the workout screen
          create: (_) => WorkoutProvider(),
        ),

        ChangeNotifierProvider(
          create: (_) => WorkoutTimerProvider(),
        ),
      ],
      child: MaterialApp(
        theme: AppTheme.darkForgeTheme,
        home: const Wrapper(), //wrapper should be either the home/main screen
      ),
    ) ;
  }
}
