import 'package:flutter/material.dart';
import '../../theme/app_colors.dart';
import '../../theme/constants.dart';
import '../../widgets/app_bar.dart';
import '../../widgets/loading.dart';
import 'package:fitness_slayer_01/services/database_service.dart';

class addEquipment extends StatefulWidget {
  const addEquipment({super.key});

  @override
  State<addEquipment> createState() => _addEquipmentState();
}

class _addEquipmentState extends State<addEquipment> {
  final _formKey = GlobalKey<FormState>();
  bool loading = false;

  String id = '';
  String name = '';
  String description = '';

  String spriteImagePath = ''; //+ 'knight_attack_blue.png'
  String attackSheetPath = ''; //+ 'knight_attack_blue_spritesheet.png'
  String idleSheetPath = ''; //+ 'knight_idle_blue_spritesheet.png'

  int atkBonus = 0;
  int hpBonus = 0;
  int price = 0;

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

              //id
              TextFormField(
                style: const TextStyle(color: Colors.black),
                decoration: textInputFieldDecoration.copyWith(hintText: 'ID', hintStyle: const TextStyle(
                  color: Colors.blueGrey,
                ),),
                validator: (val) => val == null || val.isEmpty || val.length != 4
                    ? 'Please enter valid, unique equipment ID, e.g. E001 or E102'
                    : null,
                onChanged: (val) {
                  id = val.trim();
                },
              ),

              SizedBox(height: 20.0),

              //name
              TextFormField(
                style: const TextStyle(color: Colors.black),
                decoration: textInputFieldDecoration.copyWith(hintText: 'Name', hintStyle: const TextStyle(
                  color: Colors.blueGrey,
                ),),
                validator: (val) => val == null || val.isEmpty || val.length < 6 || val.length > 32
                    ? 'Name should be 6 - 32 characters long'
                    : null,
                onChanged: (val) {
                  name = val.trim();
                },
              ),

              SizedBox(height: 20.0),

              //description
              TextFormField(
                style: const TextStyle(color: Colors.black),
                decoration: textInputFieldDecoration.copyWith(hintText: 'Description', hintStyle: const TextStyle(
                  color: Colors.blueGrey,
                ),),
                validator: (val) => val == null || val.length < 10 || val.length > 42
                    ? 'Description should be 10 - 42 characters long'
                    : null,
                onChanged: (val) {
                  setState(() {
                    description = val.trim();
                  });
                },
              ),

              SizedBox(height: 20.0),

              //stock image 32x32
              TextFormField(
                style: const TextStyle(color: Colors.black),
                decoration: textInputFieldDecoration.copyWith(hintText: 'Stock Image Name (.png)', hintStyle: const TextStyle(
                  color: Colors.blueGrey,
                ),),
                validator: (val) => val == null || val.isEmpty || !val.endsWith('.png')
                    ? 'Image name should have .png at the end'
                    : null,
                onChanged: (val) {
                  spriteImagePath = 'assets/spritesheets/stock/${val.trim()}';
                },
              ),

              SizedBox(height: 20.0),

              //attack sprite sheet
              TextFormField(
                style: const TextStyle(color: Colors.black),
                decoration: textInputFieldDecoration.copyWith(hintText: 'Attack Sprite Sheet Image Name (.png)', hintStyle: const TextStyle(
                  color: Colors.blueGrey,
                ),),
                validator: (val) => val == null || val.isEmpty || !val.endsWith('.png')
                    ? 'Image name should have .png at the end'
                    : null,
                onChanged: (val) {
                  attackSheetPath = 'assets/spritesheets/attack/${val.trim()}';
                },
              ),

              SizedBox(height: 20.0),

              //idle sprite sheet
              TextFormField(
                style: const TextStyle(color: Colors.black),
                decoration: textInputFieldDecoration.copyWith(hintText: 'Idle Sprite Sheet Image Name (.png)', hintStyle: const TextStyle(
                  color: Colors.blueGrey,
                ),),
                validator: (val) => val == null || val.isEmpty || !val.endsWith('.png')
                    ? 'Image name should have .png at the end'
                    : null,
                onChanged: (val) {
                  idleSheetPath = 'assets/spritesheets/idle/${val.trim()}';
                },
              ),

              SizedBox(height: 20.0),

              //atk bonus
              TextFormField(
                keyboardType: TextInputType.number,
                style: const TextStyle(color: Colors.black),
                decoration: textInputFieldDecoration.copyWith(
                  hintText: 'Attack Bonus',
                  hintStyle: const TextStyle(color: Colors.blueGrey),
                ),
                validator: (val) =>
                val == null || int.tryParse(val.trim()) == null
                    ? 'Please enter a valid whole number'
                    : null,
                onChanged: (val) {
                  atkBonus = int.tryParse(val.trim()) ?? 0;
                },
              ),

              const SizedBox(height: 20.0),

              //hp bonus
              TextFormField(
                keyboardType: TextInputType.number,
                style: const TextStyle(color: Colors.black),
                decoration: textInputFieldDecoration.copyWith(
                  hintText: 'Health Bonus',
                  hintStyle: const TextStyle(color: Colors.blueGrey),
                ),
                validator: (val) =>
                val == null || int.tryParse(val.trim()) == null
                    ? 'Please enter a valid whole number'
                    : null,
                onChanged: (val) {
                  hpBonus = int.tryParse(val.trim()) ?? 0;
                },
              ),

              const SizedBox(height: 20.0),

              //prince <- int because coins, not decimal value currency
              TextFormField(
                keyboardType: const TextInputType.numberWithOptions(decimal: true),
                style: const TextStyle(color: Colors.black),
                decoration: textInputFieldDecoration.copyWith(
                  hintText: 'Price',
                  hintStyle: const TextStyle(color: Colors.blueGrey),
                ),
                validator: (val) =>
                val == null || double.tryParse(val.trim()) == null
                    ? 'Please enter a valid coin price'
                    : null,
                onChanged: (val) {
                  price = int.tryParse(val.trim()) ?? 0;
                },
              ),

              const SizedBox(height: 20.0),

              //submit button
              ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.flameOrange,
                ),
                child: Text('Submit', style: TextStyle(color: AppColors.parchmentWhite,)),
                onPressed: () async {
                  if (_formKey.currentState?.validate() ?? false)
                  {
                    setState(() => loading = true);
                    await DatabaseService().updateEquipment(id, name, description, spriteImagePath, attackSheetPath, idleSheetPath, atkBonus, hpBonus, price,);

                    Navigator.pop(context); //return to previous page
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
