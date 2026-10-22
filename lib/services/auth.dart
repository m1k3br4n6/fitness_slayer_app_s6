import 'package:firebase_auth/firebase_auth.dart';
import 'package:fitness_slayer_01/models/my_user.dart';
import 'package:fitness_slayer_01/services/database_service.dart';

//methods that interact with firebase auth
class AuthService {
  final FirebaseAuth _auth = FirebaseAuth.instance;

  myUser? _userFromFirebaseUser(User? user) {
    return user != null ? myUser(uid: user.uid) : null;
  }

  Stream<myUser?> get user {
    return _auth.authStateChanges().map(_userFromFirebaseUser);
  }

  //1. sign in anonymously
  Future<myUser?> signInAnon() async {
    try {
      // Firebase returns a UserCredential
      UserCredential result = await _auth.signInAnonymously();
      // Firebase User
      User? user = result.user;
      // Convert Firebase User into our custom myUser
      return _userFromFirebaseUser(user);
    } catch (e) {
      return null;
    }
  }

  //2. register with email & password
  Future registerWithEmailAndPassword(String username, String email, String password, String slayerName) async {
    try {
      UserCredential result = await _auth.createUserWithEmailAndPassword(email: email, password: password);
      User? user = result.user;

      //create a new document for the user with uid
      if (user != null) {
        await DatabaseService().updateUserData(user.uid, username, 0, 0, 0, 1);
        await DatabaseService().updateSlayerData(user.uid, slayerName, "E001", 10, 10);
        await DatabaseService().addToInventory(user.uid, "E001");
        await DatabaseService().updateBMI(user.uid, 0, 0, 0, 0);
      }

      return _userFromFirebaseUser(user);
    } catch (e) {
      return null;
    }
  }

  //3. sign in with email & password
  Future signInWithEmailAndPassword(String email, String password) async {
    try {
      UserCredential result = await _auth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );
      User? user = result.user;
      return _userFromFirebaseUser(user);
    } catch (e) {
      return null;
    }
  }

  //4. sign out
  // TODO: Verify if signOut needs to trigger state reset or document snapshot stream cleanup on account switch.
  Future signOut() async {
    try {
      return await _auth.signOut();
    } catch (e) {
      return null;
    }
  }
}
