import 'package:flutter/material.dart';
import '../../theme/app_colors.dart';
import '../../theme/constants.dart';
import '../../widgets/app_bar.dart';
import '../../widgets/loading.dart';

class equipmentManage extends StatefulWidget {
  const equipmentManage({super.key});

  @override
  State<equipmentManage> createState() => _equipmentManageState();
}

class _equipmentManageState extends State<equipmentManage> {
  final _formKey = GlobalKey<FormState>();
  bool loading = false;

  String id = '';
  String name = '';
  String description = '';

  String spriteImagePath = 'assets/spritesheets/stock/'; //+ 'knight_attack_blue.png'
  String attackSheetPath = 'assets/spritesheets/attack/'; //+ 'knight_attack_blue_spritesheet.png'
  String idleSheetPath = 'assets/spritesheets/idle/'; //+ 'knight_idle_blue_spritesheet.png'

  int atkBonus = 0;
  int hpBonus = 0;
  double price = 0.0;

  @override
  Widget build(BuildContext context) {
    return loading ? Loading() : Scaffold( //if loading is true, show loading widget
      backgroundColor: AppColors.obsidianBlack,
      appBar: const MyAppBar(),
      body: Container(
        padding: EdgeInsets.symmetric(vertical: 20.0, horizontal: 50.0),
        child: Form(
          key: _formKey, //form needs form key
          child: Column(
            children: <Widget>[

              TextFormField(
                style: const TextStyle(color: Colors.black),
                decoration: textInputFieldDecoration.copyWith(hintText: 'e.g. E001', hintStyle: const TextStyle(
                  color: Colors.blueGrey,
                ),),
                validator: (val) => val == null || val.isEmpty || val.length < 4
                    ? 'Please enter valid, unique equipment ID, e.g. E001 or E102'
                    : null,
                onChanged: (val) {
                  id = val;
                },
              ),

              SizedBox(height: 20.0),

              TextFormField(
                style: const TextStyle(color: Colors.black),
                decoration: textInputFieldDecoration.copyWith(hintText: 'Name', hintStyle: const TextStyle(
                  color: Colors.blueGrey,
                ),),
                validator: (val) => val == null || val.isEmpty || val.length < 6 || val.length > 16
                    ? 'Name should be 6 - 16 characters long'
                    : null,
                onChanged: (val) {
                  name = val;
                },
              ),

              SizedBox(height: 20.0),

              TextFormField(
                style: const TextStyle(color: Colors.black),
                decoration: textInputFieldDecoration.copyWith(hintText: 'Description', hintStyle: const TextStyle(
                  color: Colors.blueGrey,
                ),),
                obscureText: true,
                validator: (val) => val == null || val.length < 10 || val.length > 32
                    ? 'Description should be 10 - 32 characters long'
                    : null,
                onChanged: (val) {
                  setState(() {
                    description = val;
                  });
                },
              ),

              SizedBox(height: 20.0),

              ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.flameOrange,
                ),
                child: Text('Submit', style: TextStyle(color: AppColors.parchmentWhite,)),
                onPressed: () async {
                  if (_formKey.currentState?.validate() ?? false)
                  {
                    setState(() => loading = true);
                  }
                },
              ),

            ],
          ),
        ),
      ),
    );
  }
}
