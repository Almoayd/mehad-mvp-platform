import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../services/firebase_service.dart';
import '../models/user_model.dart';

class AuthProvider with ChangeNotifier {
  final FirebaseService _firebaseService = FirebaseService();
  UserModel? _userModel;
  bool _isLoading = false;

  UserModel? get userModel => _userModel;
  bool get isLoading => _isLoading;

  AuthProvider() {
    _firebaseService.userStream.listen((user) async {
      if (user != null) {
        _userModel = await _firebaseService.getUserData(user.uid);
      } else {
        _userModel = null;
      }
      notifyListeners();
    });
  }

  Future<bool> signUp(String email, String password, String name, String role, String description) async {
    _isLoading = true;
    notifyListeners();
    UserModel newUser = UserModel(
      uid: '',
      email: email,
      name: name,
      role: role,
      description: description,
    );
    UserCredential? result = await _firebaseService.signUp(email, password, newUser);
    _isLoading = false;
    notifyListeners();
    return result != null;
  }

  Future<bool> signIn(String email, String password) async {
    _isLoading = true;
    notifyListeners();
    UserCredential? result = await _firebaseService.signIn(email, password);
    _isLoading = false;
    notifyListeners();
    return result != null;
  }

  Future<void> signOut() async {
    await _firebaseService.signOut();
  }
}
