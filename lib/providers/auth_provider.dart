import 'dart:convert';
import 'dart:async';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/widgets.dart';
import 'package:http/http.dart' as http;
import '../models/http_exception.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../providers/profile.dart';
import 'package:firebase_auth/firebase_auth.dart';

enum Mode {
  signupNewUser,
}

class AuthProvider with ChangeNotifier {
  String _token;
  String _userId; //userID in Authentication table
  bool _isAdministrator = false;

  bool get isAuth {
    return _token != null;
  }

  String get userId {
    return _userId;
  }

  bool get isAdministrator {
    return _isAdministrator;
  }

  String get token {
    if (_token != null) {
      return _token;
    }
    return null;
  }

  // Future<void> login() async {
  //   try {
  //     final FirebaseAuth auth = FirebaseAuth.instance;
  //     final User result = auth.currentUser;

  //     IdTokenResult tokenResult = await result.getIdTokenResult();
  //     _token = tokenResult.token;
  //     _userId = result.uid;
  //   } on FirebaseAuthException catch (e) {
  //     if (e.code == 'user-not-found') {
  //       print('No user found for that email.');
  //     } else if (e.code == 'wrong-password') {
  //       print('Wrong password provided for that user.');
  //     }
  //   }
  // }

//register normal user
  Future<void> registerOperator(String email, String fullName,
      String phoneNumber, String homeAddress) async {
    try {
      final FirebaseAuth auth = FirebaseAuth.instance;
      final User result = auth.currentUser;

      IdTokenResult tokenResult = await result.getIdTokenResult();
      _token = tokenResult.token;
      _userId = result.uid;

      final userURL = Uri.parse(
          'https://eclms-4113b-default-rtdb.asia-southeast1.firebasedatabase.app/users.json?auth=$_token');
      try {
        final userResponse =
            await http //await will wait for this operation finish then will only execute the later code
                .post(
          userURL,
          body: json.encode({
            'userID': _userId,
            'fullName': fullName,
            'phoneNumber': phoneNumber,
            'homeAddress': homeAddress,
            'emailAddress': email,
            'roleID': '',
            'departmentID': '',
            'companyID': '',
            'imageUrl': '',
          }),
        );
        final userResponseData = json.decode(userResponse.body);

        if (userResponseData['error'] != null) {
          throw HttpException(userResponseData['error']['message']);
        }
        _isAdministrator = false;
      } catch (error) {
        throw (error);
      }

      notifyListeners(); //to trigger consumer widget in main
      final prefs = await SharedPreferences.getInstance();
      final userData = json.encode(
        {
          'isAdministrator': _isAdministrator,
        },
      );
      prefs.setString('userData', userData);
    } on FirebaseAuthException catch (e) {
      if (e.code == 'user-not-found') {
        print('No user found for that email.');
      } else if (e.code == 'wrong-password') {
        print('Wrong password provided for that user.');
      }
    }
  }

//register system admin
  Future<void> registerSystemAdmin() async {
    try {
      final FirebaseAuth auth = FirebaseAuth.instance;
      final User result = auth.currentUser;

      IdTokenResult tokenResult = await result.getIdTokenResult();
      _token = tokenResult.token;
      _userId = result.uid;

      final administratorUrl = Uri.parse(
          'https://eclms-4113b-default-rtdb.asia-southeast1.firebasedatabase.app/administrator.json?auth=$_token');

      try {
        final administratorResponse =
            await http //await will wait for this operation finish then will only execute the later code
                .post(
          administratorUrl,
          body: json.encode({
            'userID': _userId,
          }),
        );
        final administratorResponseData =
            json.decode(administratorResponse.body);
        if (administratorResponseData['error'] != null) {
          throw HttpException(administratorResponseData['error']['message']);
        }

        _isAdministrator = true;
      } catch (error) {
        throw (error);
      }

      notifyListeners(); //to trigger consumer widget in main
      final prefs = await SharedPreferences.getInstance();
      final userData = json.encode(
        {
          'isAdministrator': _isAdministrator,
        },
      );
      prefs.setString('userData', userData);
    } on FirebaseAuthException catch (e) {
      if (e.code == 'user-not-found') {
        print('No user found for that email.');
      } else if (e.code == 'wrong-password') {
        print('Wrong password provided for that user.');
      }
    }
  }

  Future<bool> checkAdminExisted() async {
    bool isExisted = false;

    final FirebaseAuth auth = FirebaseAuth.instance;
    final User result = auth.currentUser;
    IdTokenResult tokenResult = await result.getIdTokenResult();
    _token = tokenResult.token;
    final administratorUrl = Uri.parse(
        'https://eclms-4113b-default-rtdb.asia-southeast1.firebasedatabase.app/administrator.json?auth=$_token');
    try {
      final response = await http.get(administratorUrl);
      final extractedData = json.decode(response.body) as Map<String, dynamic>;

      //extractedData == null means there is no system admin
      if (extractedData == null) {
        isExisted = false;
      } else {
        isExisted = true;
      }

      return isExisted;
    } catch (err) {
      throw (err);
    }
  }

  Future<void> checkIdentity() async {
    final FirebaseAuth auth = FirebaseAuth.instance;
    final User result = auth.currentUser;

    _userId = result.uid;

    IdTokenResult tokenResult = await result.getIdTokenResult();
    _token = tokenResult.token;
    final searchTerm = 'orderBy="userID"&equalTo="$_userId"';
    final administratorUrl = Uri.parse(
        'https://eclms-4113b-default-rtdb.asia-southeast1.firebasedatabase.app/administrator.json?auth=$_token&$searchTerm');
    try {
      final response = await http.get(administratorUrl);
      final extractedData = json.decode(response.body) as Map<String, dynamic>;
      String userID = '';

      extractedData.forEach((id, data) {
        userID = data['userID'];
      });
      print(_token);
      print(_userId);
      //is system admin
      if (userID == _userId) {
        _isAdministrator = true;
      } else {
        _isAdministrator = false;
      }
      notifyListeners();
      final prefs = await SharedPreferences.getInstance();
      final userData = json.encode(
        {
          'isAdministrator': _isAdministrator,
        },
      );
      prefs.setString('userData', userData);
    } catch (error) {
      throw (error);
    }
  }

  // Future<void> login(String email, String password, String fullName,
  //     String phoneNumber) async {
  //   return _authenticate(
  //       email, password, fullName, phoneNumber, '', 'verifyPassword');
  // }

  //trigger the function of store token into actual device
  // Future<bool> tryAutoLogin() async {
  //   final prefs = await SharedPreferences.getInstance();
  //   if (!prefs.containsKey('userData')) {
  //     //if there is no data is being stored in the userData key

  //     return false;
  //   }
  //   final extractedUserData = json.decode(prefs.getString('userData')) as Map<
  //       String, Object>; //string key and object value(dataTime, token,userId)
  //   final expiryDate = DateTime.parse(extractedUserData['expiryDate']);
  //   if (expiryDate.isBefore(DateTime.now())) {
  //     return false;
  //   }

  //   _token = extractedUserData['token'];
  //   _userId = extractedUserData['userID'];
  //   _isAdministrator = extractedUserData['isAdministrator'];
  //   _expiryDate = expiryDate;

  //   notifyListeners();
  //   // _autoLogout();
  //   return true;
  // }

  Future<bool> tryAutoLogin() async {
    final prefs = await SharedPreferences.getInstance();
    if (!prefs.containsKey('userData')) {
      //if there is no data is being stored in the userData key
      return false;
    }
    final extractedUserData = json.decode(prefs.getString('userData')) as Map<
        String, Object>; //string key and object value(dataTime, token,userId)
    _isAdministrator = extractedUserData['isAdministrator'];

    final FirebaseAuth auth = FirebaseAuth.instance;
    final User result = auth.currentUser;
    IdTokenResult tokenResult = await result.getIdTokenResult();
    _token = tokenResult.token;
    _userId = result.uid;
    print(_userId);
    if (_token == null) {
      // signOut();
      return false;
    }
    notifyListeners();
    // _autoLogout();
    return true;
  }

  // void logout() async {
  //   _token = null;
  //   _expiryDate = null;
  //   _userId = null;
  //   _isAdministrator = false;

  //   notifyListeners();
  //   final prefs = await SharedPreferences.getInstance();
  //   prefs.clear();
  // }

  Future<void> signOut() async {
    await FirebaseAuth.instance.signOut();
    _isAdministrator = false;
    _token = null;
    _userId = null;

    notifyListeners();
    final prefs = await SharedPreferences.getInstance();
    prefs.clear();
    print(_isAdministrator);
  }

  void _autoLogout() {
    final FirebaseAuth auth = FirebaseAuth.instance;
    final User result = auth.currentUser;
    print(result);
    if (result == null) {
      signOut();
    }
  }
}
