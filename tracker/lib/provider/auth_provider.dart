import 'dart:async';

import 'package:flutter/widgets.dart';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:shared_preferences/shared_preferences.dart';


class Auth with ChangeNotifier {
  String _token;
  String _userId;
  DateTime _expiryTime;
  User user;

  final FirebaseAuth _auth = FirebaseAuth.instance;

  bool get isAuth {
    return _token != null;
  }

  String get token {
    if (_token != null) {
      return _token.toString();
    }
    return null;
  }

  String get userId {
    _save(_userId);
    return _userId;
  }

  Future<void> signup(String email, String password) async {
    final response = await _auth
        .createUserWithEmailAndPassword(
      email: email,
      password: password,
    )
        .catchError((onError) {
      print(onError);
      return null;
    }).then((value) {
      print(value);
      notifyListeners();
    });
    return response;
  }

  Future<void> login(String email, String password) async {
    print('login');
    final response = await _auth
        .signInWithEmailAndPassword(
      email: email,
      password: password,
    )
        .catchError((onError) {
      print(onError);
      return null;
    }).then((value) {
      value.user.getIdTokenResult().then((tokenId) {
        _token = tokenId.token;
        _expiryTime = tokenId.expirationTime;
        print(tokenId.token);
      });
      print(_token);
      print(isAuth);
      user = value.user;
      _userId = user.uid;
      notifyListeners();
    });
    return response;
  }

  void logout() {
    _auth.signOut();
    notifyListeners();
  }

  _save(String _id) async {
    final prefs = await SharedPreferences.getInstance();
    final key = 'user_id';
    final value = _id;
    prefs.setString(key, value);
  }

  String _tokenS;
  String _userIdS;
  DateTime _expiryTimeS;
  User userS;

  bool get searchIsAuth {
    return _tokenS != null;
  }

  String get searchToken {
    if (_tokenS != null) {
      return _tokenS.toString();
    }
    return null;
  }

  String get searchUserId {
    return _userIdS != null ? _userIdS : null;
  }

  Future<void> searchLogin(String email, String password) async {
    final response = await _auth
        .signInWithEmailAndPassword(
      email: email,
      password: password,
    )
        .catchError((onError) {
      print(onError);
    }).then((value) {
      print('serach Login Successs');
      print('serach Login Successs');
      value.user.getIdTokenResult().then((tokenId) {
        _tokenS = tokenId.token;
        _expiryTimeS = tokenId.expirationTime;
      });
      userS = value.user;
      _userIdS = userS.uid;
      notifyListeners();
    });
    return response;
  }

  void searchLogout() {
    _tokenS = null;
    _userIdS = null;
    userS = null;
    notifyListeners();
  }
}
