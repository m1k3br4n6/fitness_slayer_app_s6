import 'package:fitness_slayer_01/theme/app_colors.dart';
import 'package:flutter/material.dart';
import 'package:fitness_slayer_01/widgets/app_bar.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

import '../../services/database_service.dart';

class BmiCalculator extends StatefulWidget {
  const BmiCalculator({super.key});

  @override
  State<BmiCalculator> createState() => _BmiCalculatorState();
}

class _BmiCalculatorState extends State<BmiCalculator> {

  //default values
  int age = 22;
  double weight = 68;
  double height = 1.75;
  double latestBMI = 0;
  double calculatedBMI = 0;
  String message = "";
  IconData arrowIcon = Icons.arrow_upward;

  String infotext = "BMI (Body Mass Index) is a commonly used international standard to measure the degree of obesity and health of the human body. It is calculated by dividing weight (Kg) by the square of height (m)";

  //grab user's previous bmi-related stats
  Future<void> getLatestBMI() async {
    final user = FirebaseAuth.instance.currentUser;

    if (user != null) {
      String userId = user.uid;

      //get bmi doc snapshot
      DocumentSnapshot doc = await FirebaseFirestore.instance.collection('users')
          .doc(userId).collection('BMI').doc('userBMI').get();

      if (doc.exists) {

        latestBMI = (doc.get('latestBMI') as num).toDouble();
        if (latestBMI == 0) {
          //default values if user has not calculated BMI before
          setState(() {
            age = 22;
            weight = 68;
            height = 1.75;
          });
        }
        else {
          setState(() {
            age = (doc.get('prev_age') as num).toInt();
            weight = (doc.get('prev_weight') as num).toDouble();
            height = (doc.get('prev_height') as num).toDouble();
          });
        }

      } else {

        setState(() {
          age = 22;
          weight = 68.0;
          height = 1.75;
          latestBMI = 0.0;
        });

      }
    }
    calculatedBMI = latestBMI;
  }

  //get latest bmi when initialising
  @override
  void initState() {
    super.initState();
    getLatestBMI();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: MyAppBar(),
        backgroundColor: AppColors.obsidianBlack,
        body: Container(
            padding: EdgeInsets.symmetric(vertical: 20.0, horizontal: 50.0),
            child: Form(
              child: Column(
                  children: <Widget>[
                  SizedBox(height: 10.0),
                    //age slider
                    Text(
                      'Age: $age years',
                      style: const TextStyle(
                        color: AppColors.parchmentWhite,
                        fontSize: 16,
                      ),
                    ),
                    Slider(
                      value: age.toDouble(),
                      min: 16,
                      max: 90,
                      divisions: 74,
                      label: age.toString(),
                      onChanged: (value) {
                        setState(() {
                          age = value.round();
                        });
                      },
                    ),

                    //weight slider
                    Text(
                      'Weight: ${weight.toStringAsFixed(1)} kg',
                      style: const TextStyle(
                        color: AppColors.parchmentWhite,
                        fontSize: 16,
                      ),
                    ),
                    Slider(
                      value: weight,
                      min: 20,
                      max: 200,
                      divisions: 200,
                      label: '${weight.toStringAsFixed(1)} kg',
                      onChanged: (value) {
                        setState(() {
                          weight = value;
                        });
                      },
                    ),

                    //height slider
                    Text(
                      'Height: ${height.toStringAsFixed(2)} m',
                      style: const TextStyle(
                        color: AppColors.parchmentWhite,
                        fontSize: 16,
                      ),
                    ),
                    Slider(
                      value: height,
                      min: 1.0,
                      max: 2.5,
                      divisions: 200,
                      label: '${height.toStringAsFixed(2)} m',
                      onChanged: (value) {
                        setState(() {
                          height = value;
                        });
                      },
                    ),
                    SizedBox(height: 10.0),

                    //calculate BMI when button pressed and update values
                    ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.flameOrange,
                      ),
                      child: Text('Calculate BMI', style: TextStyle(color: AppColors.parchmentWhite)),
                      onPressed: () async {
                        setState(() {
                          calculatedBMI = weight / (height * height);

                          getLatestBMI();

                          if (calculatedBMI > latestBMI)
                            {
                              arrowIcon = Icons.arrow_upward;
                            } else if (calculatedBMI < latestBMI)
                              {
                                arrowIcon = Icons.arrow_downward;
                              }

                          if (age >= 16)
                          {
                              if (calculatedBMI < 18.5) {
                                message = "Verdict: underweight range";
                              } else if (calculatedBMI >= 18.5 && calculatedBMI < 24) {
                                message = "Verdict: healthy range";
                              } else if (calculatedBMI >= 24 && calculatedBMI < 30) {
                                message = "Verdict: overweight range";
                              } else if (calculatedBMI >= 30) {
                                message = "Verdict: obesity range";
                              }
                          } else
                          {
                             message = "Too young to compare to expected metrics";
                          }
                        });

                        final user = FirebaseAuth.instance.currentUser;
                        if (user != null) {
                          await DatabaseService().updateBMI(user.uid, calculatedBMI, age, weight, height,);
                        }

                        getLatestBMI();

                      },
                    ),

                    SizedBox(height: 20),

                      //display BMI, arrow and verdict based on common stats
                      Container(
                        width: double.infinity,
                        padding: const EdgeInsets.all(24),
                        decoration: BoxDecoration(
                          color: Colors.blue,
                          borderRadius: BorderRadius.circular(16),
                        ),
                        child: Column(
                          children: [
                            Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Text(
                                  calculatedBMI.toStringAsFixed(1),
                                  style: const TextStyle(
                                    color: Colors.white,
                                    fontSize: 42,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                const SizedBox(width: 8),
                                Icon(
                                  arrowIcon,
                                  color: Colors.white,
                                  size: 32,
                                ),
                              ],
                            ),
                            Text(
                              message,
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 18,
                              ),
                            ),
                          ],
                        ),
                      ),
                    SizedBox(height: 15),

                    //display context about BMI
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(10),
                      decoration: BoxDecoration(
                        color: AppColors.darkTavernGreen,
                        borderRadius: BorderRadius.circular(1),
                      ),
                      child: Column(
                        children: [
                          const Text(
                            'Learn about BMI',
                            style: TextStyle(
                              color: AppColors.parchmentWhite,
                              fontSize: 18,
                            ),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            infotext,
                            style: const TextStyle(
                              color: AppColors.parchmentWhite,
                              fontSize: 15,
                            ),
                          ),
                        ],
                      ),
                    ),


                ]),
        ),
    ),
    );
  }
}
