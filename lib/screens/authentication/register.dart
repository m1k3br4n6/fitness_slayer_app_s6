import 'package:fitness_slayer_01/widgets/loading.dart';
import 'package:flutter/material.dart';
import 'package:fitness_slayer_01/services/auth.dart';
import 'package:fitness_slayer_01/theme/constants.dart';
import '../../theme/app_colors.dart';

class Register extends StatefulWidget {
  final Function toggleView;
  const Register({super.key, required this.toggleView});

  @override
  State<Register> createState() => _RegisterState();
}

class _RegisterState extends State<Register> {
  final AuthService _auth = AuthService();
  final _formKey = GlobalKey<FormState>();
  bool loading = false;
  String error = '';

  final usernameController = TextEditingController();
  final emailController = TextEditingController();
  final passwordController = TextEditingController();
  final passwordConfirmController = TextEditingController();
  final slayerNameController = TextEditingController();

  @override
  void dispose()
  {
    usernameController.dispose();
    emailController.dispose();
    passwordController.dispose();
    passwordConfirmController.dispose();
    slayerNameController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return loading ? Loading() : Scaffold( //if loading is true, show loading widget
      backgroundColor: AppColors.obsidianBlack,
      appBar: AppBar(
        backgroundColor: AppColors.darkTavernGreen,
        elevation: 0.0,
        title: Text('Register', style: const TextStyle(
          color: AppColors.parchmentWhite,
          fontSize: 20,
        ),),
        actions: <Widget>[
          TextButton.icon(
            icon: Icon(Icons.person, color: AppColors.parchmentWhite,),
            label: Text('Log In', style: TextStyle(color: AppColors.parchmentWhite,),),
            onPressed: () {
              widget.toggleView(); //toggles to login
            },
          ),
        ],
      ),
      body: Container(
        padding: EdgeInsets.symmetric(vertical: 20.0, horizontal: 50.0),
        child: Form(
          key: _formKey, //form needs form key
          child: Column(
            children: <Widget>[
              SizedBox(height: 10.0),

              Text(
                'How will we remember you?',
                style: TextStyle(
                  color: AppColors.parchmentWhite,
                  fontSize: 16.0,
                  fontWeight: FontWeight.bold,
                ),
              ),

              SizedBox(height: 12.0),

              //Username input field
              TextFormField(
                controller: usernameController,
                style: const TextStyle(color: Colors.black),
                decoration: textInputFieldDecoration.copyWith(hintText: 'Username', hintStyle: const TextStyle(
                  color: Colors.blueGrey,
                ),),
                validator: (val) => val == null || val.isEmpty || val.length < 6 || val.length > 16
                    ? 'Username should be between 6 - 16 characters long'
                    : null,
              ),

              SizedBox(height: 20.0),

              //Email input field
              TextFormField(
                controller: emailController,
                style: const TextStyle(color: Colors.black),
                decoration: textInputFieldDecoration.copyWith(hintText: 'Email', hintStyle: const TextStyle(
                  color: Colors.blueGrey,
                ),),
                validator: (val) => val == null || val.isEmpty
                    ? 'Please enter an email'
                    : null,
              ),

              SizedBox(height: 20.0),

              //Password input field
              TextFormField(
                controller: passwordController,
                style: const TextStyle(color: Colors.black),
                decoration: textInputFieldDecoration.copyWith(hintText: 'Password', hintStyle: const TextStyle(
                  color: Colors.blueGrey,
                ),),
                obscureText: true,
                validator: (val) => val == null || val.length < 6
                    ? 'Password should be 6+ characters long'
                    : null,
              ),

              SizedBox(height: 20.0),

              //Confirm password input field
              TextFormField(
                controller: passwordConfirmController,
                style: const TextStyle(color: Colors.black),
                decoration: textInputFieldDecoration.copyWith(hintText: 'Confirm Password', hintStyle: const TextStyle(
                  color: Colors.blueGrey,
                ),),
                obscureText: true,
                validator: (val) => val == null || val.length < 6 || val != passwordController.text
                    ? 'Must match password'
                    : null,
              ),
              SizedBox(height: 20.0),

              //slayer name
              Text(
                'What will you name your slayer?',
                style: TextStyle(
                  color: AppColors.parchmentWhite,
                  fontSize: 16.0,
                  fontWeight: FontWeight.bold,
                ),
              ),

              SizedBox(height: 12.0),

              Container(
                width: 80,
                height: 80,
                alignment: Alignment.center,
                decoration: BoxDecoration(
                  color: Colors.blue,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Image.asset(
                  'assets/spritesheets/stock/knight_attack_red.png',
                  width: 72,
                  height: 72,
                  fit: BoxFit.contain,
                  filterQuality: FilterQuality.none,
                ),
              ),

              SizedBox(height: 12.0),

              TextFormField(
                controller: slayerNameController,
                style: const TextStyle(color: Colors.black),
                decoration: textInputFieldDecoration.copyWith(hintText: 'e.g. Fernando', hintStyle: const TextStyle(
                  color: Colors.blueGrey,
                ),),
                validator: (val) => val == null || val.isEmpty || val.length < 3 || val.length > 16
                    ? 'Their name must be between 3 - 16 characters long'
                    : null,
              ),

              SizedBox(height: 20.0),

              //register button
              ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.flameOrange,
                ),
                child: Text('Register', style: TextStyle(color: AppColors.parchmentWhite)),
                onPressed: () async {
                  if (_formKey.currentState?.validate() ?? false)
                  {
                    setState(() => loading = true);
                    dynamic result = await _auth.registerWithEmailAndPassword(usernameController.text.trim(), emailController.text.trim(), passwordController.text, slayerNameController.text.trim());
                    if (result == null) {
                      setState(() {
                        error = 'Please supply valid email';
                        loading = false;
                      });
                    }
                  }
                },
              ),

              SizedBox(height: 12.0),

              Text(error, style: TextStyle(color: Colors.red, fontSize: 14.0)),
            ],
          ),
        ),
      ),
    );
  }
}
