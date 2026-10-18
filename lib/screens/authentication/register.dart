import 'package:fitness_slayer_01/widgets/loading.dart';
import 'package:flutter/material.dart';
import 'package:fitness_slayer_01/services/auth.dart';
import 'package:fitness_slayer_01/theme/constants.dart';

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

  String email = '';
  String password = '';
  String passwordConfirm = '';
  String username = '';
  String slayerName = '';
  String error = '';

  @override
  Widget build(BuildContext context) {
    return loading ? Loading() : Scaffold(
      backgroundColor: Colors.teal[900],
      appBar: AppBar(
        backgroundColor: Colors.teal,
        elevation: 0.0,
        title: Text('Register', style: const TextStyle(
          color: Colors.white,
          fontSize: 20,
        ),),
        actions: <Widget>[
          TextButton.icon(
            icon: Icon(Icons.person, color: Colors.white,),
            label: Text('Log In', style: TextStyle(color: Colors.white),),
            onPressed: () {
              widget
                  .toggleView();
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
              SizedBox(height: 10.0),
              Text(
                'How will we remember you?',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 16.0,
                  fontWeight: FontWeight.bold,
                ),
              ),
              SizedBox(height: 12.0),
              //Username input field
              TextFormField(
                decoration: textInputFieldDecoration.copyWith(hintText: 'Username'),
                validator: (val) => val == null || val.isEmpty || val.length < 6 || val.length > 16
                    ? 'Enter an unique username, between 6 - 16 characters long'
                    : null,
                onChanged: (val) {
                  username = val;
                },
              ),
              SizedBox(height: 20.0),
              //Email input field
              TextFormField(
                decoration: textInputFieldDecoration.copyWith(hintText: 'Email'),
                validator: (val) => val == null || val.isEmpty
                    ? 'Enter an email'
                    : null,
                onChanged: (val) {
                  setState(() {
                    email = val;
                  });
                },
              ),
              SizedBox(height: 20.0),
              //Password input field
              TextFormField(
                decoration: textInputFieldDecoration.copyWith(hintText: 'Password'),
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
              //Confirm password input field
              TextFormField(
                decoration: textInputFieldDecoration.copyWith(hintText: 'Confirm Password'),
                obscureText: true,
                validator: (val) => val == null || val.length < 6 || val != password
                    ? 'Must match password'
                    : null,
                onChanged: (val) {
                  setState(() {
                    passwordConfirm = val;
                  });
                },
              ),
              SizedBox(height: 20.0),
              //slayer name
              Text(
                'What will you name your slayer?',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 16.0,
                  fontWeight: FontWeight.bold,
                ),
              ),
              SizedBox(height: 12.0),
              TextFormField(
                decoration: textInputFieldDecoration.copyWith(hintText: 'e.g. Fernando'),
                validator: (val) => val == null || val.isEmpty || val.length < 6 || val.length > 16
                    ? 'Their name must be between 3 - 16 characters long'
                    : null,
                onChanged: (val) {
                  setState(() {
                    slayerName = val;
                  });
                },
              ),
              SizedBox(height: 20.0),
              //Register button
              ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.pink[400],
                ),
                child: Text('Register', style: TextStyle(color: Colors.white)),
                onPressed: () async {
                  if (_formKey.currentState?.validate() ?? false)
                  {
                    setState(() => loading = true);
                    dynamic result = await _auth.registerWithEmailAndPassword(username, email, password, slayerName);
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
