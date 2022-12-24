import 'dart:convert'; //convert data into json
import 'dart:io'; //image file
import 'package:firebase_storage/firebase_storage.dart';
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

  Future<void> fetchAndSetNonAdmin([bool filterByCompanyID = false]) async {
    print('entered again once refresh');
    final searchTerm =
        filterByCompanyID ? '' : 'orderBy="companyID"&equalTo=""';

    var url = Uri.parse(
        'https://eclms-9fed2-default-rtdb.asia-southeast1.firebasedatabase.app/users.json?auth=$authToken&$searchTerm');
    try {
      final response = await http.get(url);

      final extractedData = json.decode(response.body) as Map<String,
          dynamic>; //String key with dynamic value since flutter do not know the nested data

      final List<Profile> loadedProfile = [];
      if (extractedData == null) {
        return;
      }

      extractedData.forEach((profileId, profileData) {
        loadedProfile.add(
          Profile(
            id: profileId,
            fullName: profileData['fullName'],
            emailAddress: profileData['emailAddress'],
            homeAddress: profileData['homeAddress'],
            phoneNumber: profileData['phoneNumber'],
            roleId: profileData['roleID'],
            departmentId: profileData['departmentID'],
            companyId: profileData['companyID'],
            imageUrl: profileData['imageUrl'],
            qrUrl: profileData['qrUrl'],
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
    // final url = Uri.parse(
    //     'https://eclms-9fed2-default-rtdb.asia-southeast1.firebasedatabase.app/users/$userId.json?auth=$authToken');
    final searchTerm = 'orderBy="userID"&equalTo="$userId"';
    var url = Uri.parse(
        'https://eclms-9fed2-default-rtdb.asia-southeast1.firebasedatabase.app/users.json?auth=$authToken&$searchTerm');
    try {
      final response = await http.get(url);

      final extractedData = json.decode(response.body) as Map<String,
          dynamic>; //String key with dynamic value since flutter do not know the nested data

      final List<Profile> loadedProfile = [];
      if (extractedData == null) {
        print("error");
        return;
      }

      extractedData.forEach((profileId, profileData) {
        loadedProfile.add(
          Profile(
            id: profileId,
            fullName: profileData['fullName'],
            emailAddress: profileData['emailAddress'],
            homeAddress: profileData['homeAddress'],
            phoneNumber: profileData['phoneNumber'],
            roleId: profileData['roleID'],
            departmentId: profileData['departmentID'],
            companyId: profileData['companyID'],
            imageUrl: profileData['imageUrl'],
            qrUrl: profileData['qrUrl'],
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
  //======================================= Update image URL Start =========================================//

  Future<void> uploadImage(String imageUrl, Profile newProfile) async {
    final profileIndex =
        _profile.indexWhere((prof) => prof.id == newProfile.id);

    if (profileIndex >= 0) {
      final updateUrl = Uri.parse(
          'https://eclms-9fed2-default-rtdb.asia-southeast1.firebasedatabase.app/users/${newProfile.id}.json?auth=$authToken');

      await http.patch(updateUrl, //update data
          body: json.encode({
            'imageUrl': imageUrl,
          })); //merge data that is incoming and the data that existing in the database

      _profile[profileIndex] = newProfile;
      notifyListeners();
    } else {
      print('...');
    }
  }
  //======================================= Update image URL End =========================================//

  //======================================= Update QR image URL Start =========================================//

  Future<void> uploadQRImage(String qrUrl, Profile newProfile) async {
    final profileIndex =
        _profile.indexWhere((prof) => prof.id == newProfile.id);

    if (profileIndex >= 0) {
      final updateUrl = Uri.parse(
          'https://eclms-9fed2-default-rtdb.asia-southeast1.firebasedatabase.app/users/${newProfile.id}.json?auth=$authToken');

      await http.patch(updateUrl, //update data
          body: json.encode({
            'qrUrl': qrUrl,
          })); //merge data that is incoming and the data that existing in the database

      _profile[profileIndex] = newProfile;
      notifyListeners();
    } else {
      print('...');
    }
  }
  //======================================= Update image URL End =========================================//

  Profile findById(String id) {
    return _profile.firstWhere((profile) => profile.id == id,
        orElse: () => null);
  }

  Profile findByNonAdminId(String id) {
    return _nonAdmin.firstWhere((nonAdmin) => nonAdmin.id == id,
        orElse: () => null);
  }

  Future<void> updateProfile(String id, Profile newProfile) async {
    // Future<String> imageURL = uploadImage(image);

    final profileIndex = _profile.indexWhere((prof) => prof.id == id);
    // final url = Uri.parse(
    //     'https://eclms-9fed2-default-rtdb.asia-southeast1.firebasedatabase.app/users.json?auth=$authToken&orderBy="userId"&equalTo="$id"');
    // try {
    //   final response = await http.get(url);
    //   print(json.decode(response.body.toString())['name']);
    //   final extractedData = json.decode(response.body) as Map<String,
    //       dynamic>; //String key with dynamic value since flutter do not know the nested data

    //   final userId = extractedData['name'];
    if (profileIndex >= 0) {
      final updateUrl = Uri.parse(
          'https://eclms-9fed2-default-rtdb.asia-southeast1.firebasedatabase.app/users/$id.json?auth=$authToken');

      await http.patch(updateUrl, //update data
          body: json.encode({
            'fullName': newProfile.fullName,
            'emailAddress': newProfile.emailAddress,
            'homeAddress': newProfile.homeAddress,
            'phoneNumber': newProfile.phoneNumber,
            'imageUrl': newProfile.imageUrl,
          })); //merge data that is incoming and the data that existing in the database

      _profile[profileIndex] = newProfile;
      notifyListeners();
    } else {
      print('...');
    }
  }
}
