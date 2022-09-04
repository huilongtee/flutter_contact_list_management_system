import 'dart:convert'; //convert data into json
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import '../models/http_exception.dart';
import '../providers/profile.dart';

class ProfileProvider with ChangeNotifier {
  final String authToken;
  final String userId;
  List<Profile> _profile = [];
  List<Profile> _nonAdmin = [];
  ProfileProvider(this.authToken, this.userId, this._profile);

  List<Profile> get profile {
    return [..._profile];
  }

  List<Profile> get nonAdmin {
    return [..._nonAdmin];
  }

  List<Profile> findByFullName(String fullName) {
    notifyListeners();
    return _profile.where((data) => data.fullName.contains(fullName));
  }

  Future<void> fetchAndSetNonAdmin() async {
    final url = Uri.parse(
        'https://eclms-9fed2-default-rtdb.asia-southeast1.firebasedatabase.app/users.json?auth=$authToken&orderBy="companyID"&equalTo=''');
    try {
      final response = await http.get(url);
      print(json.decode(response.body));
      final extractedData = json.decode(response.body) as Map<String,
          dynamic>; //String key with dynamic value since flutter do not know the nested data

      final List<Profile> loadedProfile = [];
      if (extractedData == null) {
        return;
      }

      extractedData.forEach((profileId, profileData) {
        loadedProfile.add(
          Profile(
            id: userId,
            fullName: profileData['fullName'],
            emailAddress: profileData['emailAddress'],
            homeAddress: profileData['homeAddress'],
            phoneNumber: profileData['phoneNumber'],
            roleId: profileData['roleID'],
            departmentId: profileData['departmentID'],
            companyId: profileData['companyID'],
            imageUrl: profileData['imageUrl'],
          ),
        );
        _nonAdmin = loadedProfile;

        notifyListeners();
      });
    } catch (error) {
      print(error);

      throw (error);
    }
  }

  Future<void> fetchAndSetProfile() async {
    final url = Uri.parse(
        'https://eclms-9fed2-default-rtdb.asia-southeast1.firebasedatabase.app/users.json?auth=$authToken&orderBy="userId"&equalTo="$userId"');
    try {
      final response = await http.get(url);
      print(json.decode(response.body));
      final extractedData = json.decode(response.body) as Map<String,
          dynamic>; //String key with dynamic value since flutter do not know the nested data

      final List<Profile> loadedProfile = [];
      if (extractedData == null) {
        return;
      }

      extractedData.forEach((profileId, profileData) {
        loadedProfile.add(
          Profile(
            id: userId,
            fullName: profileData['fullName'],
            emailAddress: profileData['emailAddress'],
            homeAddress: profileData['homeAddress'],
            phoneNumber: profileData['phoneNumber'],
            roleId: profileData['roleID'],
            departmentId: profileData['departmentID'],
            companyId: profileData['companyID'],
            imageUrl: profileData['imageUrl'],
          ),
        );
        _profile = loadedProfile;

        notifyListeners();
      });
    } catch (error) {
      print(error);

      throw (error);
    }
  }

  // void addContactPerson() {
  //   _profile.add(
  //     Profile(
  //       id: '6',
  //       fullName: 'New Person',
  //       emailAddress: 'newperson@gmail.com',
  //       homeAddress: 'N0.12,Jalan High School 12, Taman High School',
  //       phoneNumber: '011112345678',
  //       imageUrl:
  //           'https://upload.wikimedia.org/wikipedia/commons/thumb/e/e8/Trousers%2C_dress_%28AM_1960.022-8%29.jpg/512px-Trousers%2C_dress_%28AM_1960.022-8%29.jpg',
  //       companyId: '1',
  //       roleId: '1',
  //       departmentId: '1',
  //     ),
  //   );
  //   notifyListeners();
  // }
  Profile findById(String id) {
    return _profile.firstWhere((profile) => profile.id == id,
        orElse: () => null);
  }

  Future<void> updateProfile(String id, Profile profile) async {
    final _profileIndex = _profile.indexWhere((_profile) => _profile.id == id);
    if (_profileIndex >= 0) {
      final url = Uri.parse(
          'https://eclms-9fed2-default-rtdb.asia-southeast1.firebasedatabase.app/users.json?auth=$authToken&orderBy="userId"&equalTo="$id"');
      await http.patch(url, //update data
          body: json.encode({
            'userId': userId,
            'fullName': profile.fullName,
            'emailAddress': profile.emailAddress,
            'homeAddress': profile.homeAddress,
            'phoneNumber': profile.phoneNumber,
            'roleID': profile.roleId,
            'departmentID': profile.departmentId,
            'companyID': profile.companyId,
          })); //merge data that is incoming and the data that existing in the database

      _profile[_profileIndex] = profile;
      notifyListeners();
    } else {
      print('...');
    }
  }

  void deleteContactPerson(String id) {
    final existingContactPersonIndex =
        _profile.indexWhere((contactPerson) => contactPerson.id == id);
    var existingContactPerson = _profile[existingContactPersonIndex];

    if (existingContactPerson != null) {
      _profile.removeAt(existingContactPersonIndex);

      existingContactPerson = null;
      notifyListeners();
    }
  }
}
