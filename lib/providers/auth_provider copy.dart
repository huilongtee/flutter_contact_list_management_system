// //before implement otp authentication
// import 'dart:convert';
// import 'dart:async';
// import 'package:firebase_core/firebase_core.dart';
// import 'package:firebase_database/firebase_database.dart';
// import 'package:flutter/widgets.dart';
// import 'package:http/http.dart' as http;
// import '../models/http_exception.dart';
// import 'package:shared_preferences/shared_preferences.dart';
// import '../providers/profile.dart';
// import 'package:firebase_auth/firebase_auth.dart';

// enum Mode {
//   signupNewUser,
//   verifyPassword,
// }

// class AuthProvider with ChangeNotifier {
//   String _token;
//   DateTime _expiryDate;
//   String _userId; //userID in Authentication table
//   Timer _authTimer;
//   bool _isAdministrator = false;
//   var administratorResponseData = null;

//   bool get isAuth {
//     return token != null;
//   }

//   var tempUserId = '';
//   bool get isAdministrator {
//     return _isAdministrator;
//   }

//   String get token {
//     if (_expiryDate != null &&
//         _expiryDate.isAfter(DateTime.now()) &&
//         _token != null) {
//       return _token;
//     }
//     return null;
//   }

//   Future<void> _authenticate(String email, String password, String fullName,
//       String phoneNumber, String homeAddress, String urlSegment) async {
//     var userId;
//     var userResponseData;

//     //signup mode
//     if (urlSegment == Mode.signupNewUser.name) {
//       try {
//         final FirebaseAuth auth = FirebaseAuth.instance;
//         final User result = auth.currentUser;

//         IdTokenResult tokenResult = await result.getIdTokenResult();

//         print('token: ' + tokenResult.token);
//       } on FirebaseAuthException catch (e) {
//         if (e.code == 'user-not-found') {
//           print('No user found for that email.');
//         } else if (e.code == 'wrong-password') {
//           print('Wrong password provided for that user.');
//         }
//       }
//     } else {
//       //create a new account for authenticate or login by checking the credentials in authenticate table
//       final url = Uri.parse(
//           'https://www.googleapis.com/identitytoolkit/v3/relyingparty/$urlSegment?key=AIzaSyBkPkGSp8mpprO2dy0PCnHAbN5dBvBLoEU');
//       try {
//         final response = await http.post(
//           url,
//           body: json.encode(
//             {
//               'email': email,
//               'password': password,
//               'returnSecureToken': true,
//             },
//           ),
//         );
//         final responseData = json.decode(response.body);
//         if (responseData['error'] != null) {
//           throw HttpException(responseData['error']['message']);
//         }
//         _token = responseData['idToken'];
//         _userId = responseData['localId'];
//         _expiryDate = DateTime.now().add(
//           Duration(
//             seconds: int.parse(responseData['expiresIn']),
//           ),
//         );

//         //check whether got existed administrator
//         final administratorUrl = Uri.parse(
//             'https://eclms-9fed2-default-rtdb.asia-southeast1.firebasedatabase.app/administrator.json?auth=$_token');
//         try {
//           final response = await http.get(administratorUrl);
//           final extractedData = json.decode(response.body) as Map<String,
//               dynamic>; //String key with dynamic value since flutter do not know the nested data

//           if (urlSegment == Mode.signupNewUser.name) {
// //if the administrator table is null, then then the first user who try to register the app will become the administrator

//             if (extractedData == null) {
//               //execute this when insert users table successfully
//               try {
//                 final administratorResponse =
//                     await http //await will wait for this operation finish then will only execute the later code
//                         .post(
//                   administratorUrl,
//                   body: json.encode({
//                     'userID': _userId,
//                   }),
//                 );
//                 final administratorResponseData =
//                     json.decode(administratorResponse.body);
//                 if (administratorResponseData['error'] != null) {
//                   throw HttpException(responseData['error']['message']);
//                 }

//                 _isAdministrator = true;
//                 // notifyListeners();
//               } catch (error) {
//                 throw (error);
//               }
//             } else {
//               //================================================ register as normal user start ================================================//

//               //================================================ insert into user table start ================================================//
//               final userURL = Uri.parse(
//                   'https://eclms-9fed2-default-rtdb.asia-southeast1.firebasedatabase.app/users.json?auth=$_token');
//               try {
//                 final userResponse =
//                     await http //await will wait for this operation finish then will only execute the later code
//                         .post(
//                   userURL,
//                   body: json.encode({
//                     'userID': _userId,
//                     'fullName': fullName,
//                     'phoneNumber': phoneNumber,
//                     'homeAddress': homeAddress,
//                     'emailAddress': email,
//                     'roleID': '',
//                     'departmentID': '',
//                     'companyID': '',
//                     'imageUrl': '',
//                   }),
//                 );
//                 userResponseData = json.decode(userResponse.body);

//                 if (userResponseData['error'] != null) {
//                   throw HttpException(responseData['error']['message']);
//                 }
//                 _isAdministrator = false;
//                 // notifyListeners();
//                 // final userURL = Uri.parse(
//                 //     'https://eclms-9fed2-default-rtdb.asia-southeast1.firebasedatabase.app/users.json?auth=$_token');
//                 // try {
//                 //   final userResponse =
//                 //       await http //await will wait for this operation finish then will only execute the later code
//                 //           .post(
//                 //     userURL,
//                 //     body: json.encode({
//                 //       'userId': tempUserId,
//                 //       'fullName': fullName,
//                 //       'phoneNumber': phoneNumber,
//                 //       'homeAddress': homeAddress,
//                 //       'emailAddress': email,
//                 //       'roleID': '',
//                 //       'departmentID': '',
//                 //       'companyID': '',
//                 //       'imageUrl': '',
//                 //     }),
//                 //   );
//                 //   userResponseData = json.decode(userResponse.body);
//                 //   if (userResponseData['error'] != null) {
//                 //     throw HttpException(responseData['error']['message']);
//                 //   }

//                 //   _userId = userResponseData['name'];
//                 // } catch (error) {
//                 //   throw (error);
//                 // }

//               } catch (error) {
//                 throw (error);
//               }
//               //================================================ insert into user table end ================================================//

//               //================================================ register as normal user end ================================================//
//             }
//           } else {
//             extractedData.forEach((profileId, profileData) {
//               // userId = profileId;
//               userId = profileData['userID'];
//             });

//             if (userId == _userId) {
//               _isAdministrator = true;
//             } else {
//               _isAdministrator = false;
//             }
//             try {
//               final credential = await FirebaseAuth.instance
//                   .signInWithEmailAndPassword(email: email, password: password);
//             } on FirebaseAuthException catch (e) {
//               if (e.code == 'user-not-found') {
//                 print('No user found for that email.');
//               } else if (e.code == 'wrong-password') {
//                 print('Wrong password provided for that user.');
//               }
//             }
//           }
//         } catch (error) {
//           throw (error);
//         }

//         _autoLogout();
//         notifyListeners(); //to trigger consumer widget in main
//         final prefs = await SharedPreferences.getInstance();
//         final userData = json.encode(
//           {
//             'token': _token,
//             'userID': _userId,
//             'expiryDate': _expiryDate.toIso8601String(),
//             'isAdministrator': _isAdministrator,
//           },
//         );
//         prefs.setString('userData', userData);
//       } catch (error) {
//         throw (error);
//       }
//     }
//   }

//   String get userId {
//     return _userId;
//   }

//   Future<void> signup(String email, String password, String fullName,
//       String phoneNumber, String homeAddress) async {
//     return _authenticate(
//         email, password, fullName, phoneNumber, homeAddress, 'signupNewUser');
//   }

//   Future<void> login(String email, String password, String fullName,
//       String phoneNumber) async {
//     return _authenticate(
//         email, password, fullName, phoneNumber, '', 'verifyPassword');
//   }

//   //trigger the function of store token into actual device
//   Future<bool> tryAutoLogin() async {
//     final prefs = await SharedPreferences.getInstance();
//     if (!prefs.containsKey('userData')) {
//       //if there is no data is being stored in the userData key

//       return false;
//     }
//     final extractedUserData = json.decode(prefs.getString('userData')) as Map<
//         String, Object>; //string key and object value(dataTime, token,userId)
//     final expiryDate = DateTime.parse(extractedUserData['expiryDate']);
//     if (expiryDate.isBefore(DateTime.now())) {
//       return false;
//     }

//     _token = extractedUserData['token'];
//     _userId = extractedUserData['userID'];
//     _isAdministrator = extractedUserData['isAdministrator'];
//     _expiryDate = expiryDate;

//     notifyListeners();
//     _autoLogout();
//     return true;
//   }

//   void logout() async {
//     _token = null;
//     _expiryDate = null;
//     _userId = null;
//     _isAdministrator = false;

//     if (_authTimer != null) {
//       _authTimer.cancel();
//       _authTimer = null;
//     }

//     notifyListeners();
//     final prefs = await SharedPreferences.getInstance();
//     prefs.clear();
//   }

//   void _autoLogout() {
//     if (_authTimer != null) {
//       _authTimer.cancel();
//     }
//     final timeToExpiry = _expiryDate.difference(DateTime.now()).inSeconds;
//     _authTimer = Timer(Duration(seconds: timeToExpiry), logout);
//   }

  
// }
