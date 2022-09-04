import 'dart:convert';
import 'dart:async';
import 'package:flutter/widgets.dart';
import 'package:http/http.dart' as http;
import '../models/http_exception.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../providers/profile.dart';

enum Mode {
  signupNewUser,
  verifyPassword,
}

class AuthProvider with ChangeNotifier {
  String _token;
  DateTime _expiryDate;
  String _userId;
  Timer _authTimer;
  bool _isAdministrator = false;
  var administratorResponseData = null;
  bool get isAuth {
    return token != null;
  }

  bool get isAdministrator {
    return _isAdministrator;
  }

  String get token {
    if (_expiryDate != null &&
        _expiryDate.isAfter(DateTime.now()) &&
        _token != null) {
      return _token;
    }
    return null;
  }

  Future<void> _authenticate(String email, String password, String fullName,
      String phoneNumber, String homeAddress, String urlSegment) async {
    //create a new account for authenticate or login by checking the credentials in authenticate table
    final url = Uri.parse(
        'https://www.googleapis.com/identitytoolkit/v3/relyingparty/$urlSegment?key=AIzaSyBkPkGSp8mpprO2dy0PCnHAbN5dBvBLoEU');
    try {
      final response = await http.post(
        url,
        body: json.encode(
          {
            'email': email,
            'password': password,
            'returnSecureToken': true,
          },
        ),
      );
      final responseData = json.decode(response.body);
      if (responseData['error'] != null) {
        throw HttpException(responseData['error']['message']);
      }
      _token = responseData['idToken'];
      _userId = responseData['localId'];
      _expiryDate = DateTime.now().add(
        Duration(
          seconds: int.parse(responseData['expiresIn']),
        ),
      );

      //check whether got existed administrator
      final administratorUrl = Uri.parse(
          'https://eclms-9fed2-default-rtdb.asia-southeast1.firebasedatabase.app/administrator.json?auth=$_token');
      try {
        final response = await http.get(administratorUrl);
        final extractedData = json.decode(response.body) as Map<String,
            dynamic>; //String key with dynamic value since flutter do not know the nested data

        if (urlSegment == Mode.signupNewUser.name) {
//if the administrator table is null, then then the first user who try to register the app will become the administrator
          if (extractedData == null) {
            try {
              final administratorResponse =
                  await http //await will wait for this operation finish then will only execute the later code
                      .post(
                administratorUrl,
                body: json.encode({
                  'userId': _userId,
                }),
              );
              administratorResponseData =
                  json.decode(administratorResponse.body);
              if (administratorResponseData['error'] != null) {
                throw HttpException(responseData['error']['message']);
              }
              _isAdministrator = true;
              notifyListeners();
            } catch (error) {
              throw (error);
            }
          } else {
            _isAdministrator = false;
            //register as normal user
            final userURL = Uri.parse(
                'https://eclms-9fed2-default-rtdb.asia-southeast1.firebasedatabase.app/users.json?auth=$_token');
            try {
              final userResponse =
                  await http //await will wait for this operation finish then will only execute the later code
                      .post(
                userURL,
                body: json.encode({
                  'userId': _userId,
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
                throw HttpException(responseData['error']['message']);
              }
            } catch (error) {
              throw (error);
            }
            notifyListeners();
          }
        } else {
          var userId = null;
          extractedData.forEach((profileId, profileData) {
            userId = profileData['userId'];

            notifyListeners();
          });

          if (userId == _userId) {
            _isAdministrator = true;
          } else {
            _isAdministrator = false;
          }
          notifyListeners();
        }
      } catch (error) {
        throw (error);
      }

      _autoLogout();
      notifyListeners(); //to trigger consumer widget in main

      final prefs = await SharedPreferences.getInstance();
      final userData = json.encode(
        {
          'token': _token,
          'userId': _userId,
          'expiryDate': _expiryDate.toIso8601String(),
          'isAdministrator': _isAdministrator,
        },
      );
      prefs.setString('userData', userData);
    } catch (error) {
      throw (error);
    }
  }

  String get userId {
    return _userId;
  }

  Future<void> signup(String email, String password, String fullName,
      String phoneNumber, String homeAddress) async {
    return _authenticate(
        email, password, fullName, phoneNumber, homeAddress, 'signupNewUser');
  }

  Future<void> login(String email, String password, String fullName,
      String phoneNumber) async {
    return _authenticate(
        email, password, fullName, phoneNumber, '', 'verifyPassword');
  }

  //trigger the function of store token into actual device
  Future<bool> tryAutoLogin() async {
    final prefs = await SharedPreferences.getInstance();
    if (!prefs.containsKey('userData')) {
      //if there is no data is being stored in the userData key

      return false;
    }
    final extractedUserData = json.decode(prefs.getString('userData')) as Map<
        String, Object>; //string key and object value(dataTime, token,userId)
    final expiryDate = DateTime.parse(extractedUserData['expiryDate']);
    if (expiryDate.isBefore(DateTime.now())) {
      return false;
    }

    _token = extractedUserData['token'];
    _userId = extractedUserData['userId'];
    _isAdministrator = extractedUserData['isAdministrator'];
    _expiryDate = expiryDate;
    notifyListeners();
    _autoLogout();
    return true;
  }

  void logout() async {
    _token = null;
    _expiryDate = null;
    _userId = null;
    _isAdministrator = false;

    if (_authTimer != null) {
      _authTimer.cancel();
      _authTimer = null;
    }

    notifyListeners();
    final prefs = await SharedPreferences.getInstance();
    prefs.clear();
  }

  void _autoLogout() {
    if (_authTimer != null) {
      _authTimer.cancel();
    }
    final timeToExpiry = _expiryDate.difference(DateTime.now()).inSeconds;
    _authTimer = Timer(Duration(seconds: timeToExpiry), logout);
  }
}
