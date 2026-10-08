import 'package:fitness_slayer_01/screens/wrapper.dart';
import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'firebase_options.dart';
import 'package:provider/provider.dart';
import 'package:fitness_slayer_01/models/my_user.dart';
import 'package:fitness_slayer_01/services/auth.dart';
import 'package:fitness_slayer_01/providers/workout_provider.dart';
import 'package:fitness_slayer_01/providers/workout_timer.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );

  runApp(const MyApp()); //when app starts, runs MyApp()
}

//MyApp that runs when app starts
class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MultiProvider(
        providers: [
          StreamProvider<myUser?>.value( //stream actively listens for user related auth changes
          value: AuthService().user, //stream we are going to listen to, accessing 'user' stream in auth class
          initialData: null,
          ),
          ChangeNotifierProvider( //actively listens for Changes in the workout screen
          create: (_) => WorkoutProvider(),
          ),
          ChangeNotifierProvider( //
            create: (_) => WorkoutTimerProvider(),
          ),
        ],
        child: MaterialApp(
          home: Wrapper(), //wrapper should be the home/main screen
         ),
    ) ;

  }
}
