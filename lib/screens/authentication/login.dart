import 'package:fitness_slayer_01/widgets/loading.dart';
import 'package:flutter/material.dart';
import 'package:fitness_slayer_01/services/auth.dart';
import 'package:fitness_slayer_01/theme/constants.dart';

import '../../theme/app_colors.dart';

class Login extends StatefulWidget {
  final Function toggleView;
  const Login({super.key, required this.toggleView});

  @override
  State<Login> createState() => _LoginState();
}

class _LoginState extends State<Login> {
  final AuthService _auth = AuthService();
  final _formKey = GlobalKey<FormState>();
  bool loading = false;

  String email = '';
  String password = '';
  String error = '';

  @override
  Widget build(BuildContext context) {
    return loading ? Loading() : Scaffold( //if loading is true, show Loading widget
      backgroundColor: AppColors.obsidianBlack,
      appBar: AppBar(
        backgroundColor: AppColors.darkTavernGreen,
        elevation: 0.0,
        title: Text('Sign in',  style: const TextStyle(
          color: AppColors.parchmentWhite,
          fontSize: 20,
        ),),
        actions: <Widget>[
          TextButton.icon(
            icon: const Icon(Icons.person, color: AppColors.parchmentWhite,),
            label: const Text('Register', style: TextStyle(color: AppColors.parchmentWhite,),),
            onPressed: () {
              widget.toggleView();
            },
          ),
        ],
      ),
      body: Container(
        padding: EdgeInsets.symmetric(vertical: 20.0, horizontal: 50.0),
        child: Form(
          key: _formKey,
          child: Column(
            children: <Widget>[
              SizedBox(height: 20.0),
              TextFormField(
                style: const TextStyle(color: Colors.black),
                decoration: textInputFieldDecoration.copyWith(hintText: 'Email', hintStyle: const TextStyle(
                  color: Colors.blueGrey,
                ),),
                validator: (val) => val == null || val.isEmpty
                    ? 'Enter an email'
                    : null,
                onChanged: (val) {
                  email = val;
                },
              ),
              SizedBox(height: 20.0),
              TextFormField(
                style: const TextStyle(color: Colors.black),
                decoration: textInputFieldDecoration.copyWith(hintText: 'Password', hintStyle: const TextStyle(
                  color: Colors.blueGrey,
                ),),
                obscureText: true,
                validator: (val) => val == null || val.length < 6
                    ? 'Enter a password 6+ chars long'
                    : null,
                onChanged: (val) {
                  setState(() {
                    password = val;
                  });
                },
              ),
              SizedBox(height: 20.0),
              ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.flameOrange,
                ),
                child: Text('Sign in', style: TextStyle(color: AppColors.parchmentWhite,)),
                onPressed: () async {
                  if (_formKey.currentState?.validate() ?? false)
                  {
                    setState(() => loading = true);
                    dynamic result = await _auth.signInWithEmailAndPassword(email, password,);
                    if (result == null) {
                      setState(() {
                        error = 'could not sign in with those credentials';
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
