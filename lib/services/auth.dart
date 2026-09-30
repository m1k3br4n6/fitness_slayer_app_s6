import 'package:firebase_auth/firebase_auth.dart';
import 'package:fitness_slayer_01/models/my_user.dart';

//methods that interact with firebase auth
class AuthService {
  final FirebaseAuth _auth = FirebaseAuth.instance; //get firebase auth instance

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
      print(e.toString());
      return null;
    }
  }

  //2. register with email & password
  Future registerWithEmailAndPassword(String email, String password) async {
    try {
      UserCredential result = await _auth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );
      User? user = result.user;
      return _userFromFirebaseUser(user);
    } catch (e) {
      print(e.toString());
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
      print(e.toString());
      return null;
    }
  }

  //4. sign out
  Future signOut() async {
    try {
      return await _auth.signOut();
    } catch (e) {
      print(e.toString());
      return null;
    }
  }
}
