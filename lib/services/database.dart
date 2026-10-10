import 'package:cloud_firestore/cloud_firestore.dart';

//when a user registers, they automatically get a user ID
//each document has a unique ID <-- can link by making this the user ID

class DatabaseService {

  final String uid;
  DatabaseService({ required this.uid });

  //collection reference
  final CollectionReference userCollection = FirebaseFirestore.instance.collection('test_users');

  Future updateUserData(String username, int coin, int streak, int xp, int level) async {
    //create user document
    return await userCollection.doc(uid).set({
       'username':  username,
       'coin': coin,
       'streak': streak,
       'xp': xp,
       'level': level,
    });
  }

  //get stream
  Stream<DocumentSnapshot> get testUsers {
    return userCollection.doc(uid).snapshots(); //uid returns only currently active user's document
  }
}

