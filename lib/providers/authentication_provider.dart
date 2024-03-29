// Packages
import 'package:PACCPolicyapp/pages/register/register_page.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:get_it/get_it.dart';

// Services
import '../services/database_service.dart';
import '../services/navigation_service.dart';

// Models
import 'package:PACCPolicyapp/models/chat_user_model.dart';

class AuthenticationProvider extends ChangeNotifier {
  AuthenticationProvider() {
    _auth = FirebaseAuth.instance;
    _navigationService = GetIt.instance.get<NavigationService>();
    _databaseService = GetIt.instance.get<DatabaseService>();
    _auth.authStateChanges().listen(
      (_user) {
        if (_user != null) {
          _databaseService.updateUserLastSeenTime(_user.uid);
          _databaseService.getUser(_user.uid).then(
            (_snapshot) {
              // * Check if the documentSnapshot exists or not.
              if (_snapshot.exists) {
                final _userData = _snapshot.data() as Map<String, dynamic>;
                //* Check if the document object is null or not
                if (_snapshot.data() != null) {
                  user = ChatUserModel.fromJson(
                    {
                      'uid': _user.uid,
                      'name': _userData['name'],
                      'email': _userData['email'],
                      'image': _userData['image'],
                      'role': _userData['role'],
                      'last_active': _userData['last_active'],
                    },
                  );
                }
              }
              //* Automatic navigates to the home page
              if (!isregister)
                _navigationService.removeAndNavigateToRoute('/home');
            },
          );
        } else {
          // * In case the user is not null (exists), then the user must login
          _navigationService.removeAndNavigateToRoute('/login');
        }
      },
    );
  }
// TODO: Bouncing Physics for the Chats and Users page

//TODO: Swipe left or right to navigate through pages

//TODO: Change Icons and Inovate the app

// TODO: Increase the size of the Chat Tile

// TODO: Add the messanger sender name on the group chat  and while it is typing

// TODO: Use scaffoldMessanger to show the error logs, instead of debugPrint

  late final FirebaseAuth _auth;
  late final NavigationService _navigationService;
  late final DatabaseService _databaseService;
  bool isregister = false;

  late ChatUserModel user;

  Future<void> loginUsingEmailAndPassword(
      String _email, String _password) async {
    try {
      await _auth.signInWithEmailAndPassword(
          email: _email, password: _password);
      isregister = false;
      debugPrint('${_auth.currentUser}');
    } on FirebaseAuthException {
      debugPrint('Error login user into Firebase.');
    } catch (e) {
      debugPrint('$e');
    }
  }

  //* Register user in the firebase
  Future<String?> registerUserUsingEmailAndPassword(
    String _email,
    String _password,
  ) async {
    try {
      isregister = true;
      UserCredential _credentials = await _auth.createUserWithEmailAndPassword(
          email: _email, password: _password);
      return _credentials.user!.uid;
    } on FirebaseAuthException {
      debugPrint('Error registering user.');
    } catch (error) {
      debugPrint('$error');
    }
    return null;
  }

  // Logout
  Future<void> logout() async {
    try {
      await _auth.signOut();
    } catch (error) {
      debugPrint('$error');
    }
  }
}
