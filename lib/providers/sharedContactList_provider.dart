import 'dart:async';

import 'package:flutter/material.dart';
import 'package:collection/collection.dart';
import 'dart:convert'; //convert data into json
import 'package:http/http.dart' as http;
import '../models/http_exception.dart';
import '../providers/profile.dart';

class SharedContactListProvider with ChangeNotifier {
  final String authToken;
  final String userId;
  List<Profile> _sharedContactList = [];
  List<Profile> _backupList = [];
  var companyID = '';

  SharedContactListProvider(
      this.authToken, this.userId, this._sharedContactList);

  List<Profile> get sharedContactList {
    return [..._sharedContactList];
  }

  void findByFullName(String name) {
    print(name);
    if (name.isEmpty) {
      _sharedContactList = _backupList;
    } else {
      _sharedContactList = _sharedContactList
          .where((data) =>
              data.fullName.toLowerCase().contains(name.toLowerCase()))
          .toList();
    }
    notifyListeners();
  }

  /*==================================== retrieve a list of collegues id and return their profile============================================*/
  Future<void> fetchAndSetContactPersonProfile(List loadedData) async {
    var url = Uri.parse(
        'https://eclms-9fed2-default-rtdb.asia-southeast1.firebasedatabase.app/users.json?auth=$authToken');
    try {
      final response = await http.get(url);

      final extractedData = json.decode(response.body) as Map<String,
          dynamic>; //String key with dynamic value since flutter do not know the nested data

      final List<Profile> loadedProfile = [];
      if (extractedData == null) {
        return null;
      }

      extractedData.forEach((profileId, profileData) {
        if (loadedData.contains(profileId)) {
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
            ),
          );
        }
        print(loadedProfile.length);
      });
      _sharedContactList = loadedProfile;
      _backupList = loadedProfile;
    } catch (error) {
      print(error);

      throw (error);
    }
  }

  /*==================================== get a list of collegues id ============================================*/
  Future<void> fetchAndSetSharedContactList() async {
    //check whether current user got companyID
    var checkCompanyIDUrl = Uri.parse(
        'https://eclms-9fed2-default-rtdb.asia-southeast1.firebasedatabase.app/users/$userId.json?auth=$authToken');
    try {
      final checkCompanyIDResponse = await http.get(checkCompanyIDUrl);

      final checkCompanyIDExtractedData = json
          .decode(
              checkCompanyIDResponse.body) as Map<String,
          dynamic>; //String key with dynamic value since flutter do not know the nested data

      if (checkCompanyIDExtractedData == null) {
        return;
      }

      //get current user companyID
      checkCompanyIDExtractedData.forEach((id, contactPersonData) {
        print(contactPersonData['companyID']);
        companyID = contactPersonData['companyID'];
      });
      print('companyID:' + companyID);
      //fetch all colleague userId
      final searchTerm = 'orderBy="companyID"&equalTo="$companyID"';

      var url = Uri.parse(
          'https://eclms-9fed2-default-rtdb.asia-southeast1.firebasedatabase.app/sharedContactList.json?auth=$authToken&$searchTerm');
      try {
        final response = await http.get(url);

        final extractedData = json.decode(response.body) as Map<String,
            dynamic>; //String key with dynamic value since flutter do not know the nested data
        final List loadedContactPersonID = [];
        if (extractedData == null) {
          return;
        }

        //get all contact person userID
        extractedData.forEach((id, contactPersonID) {
          print(contactPersonID['contactPersonID']);
          loadedContactPersonID.add(
            contactPersonID['contactPersonID'],
          );
        });

//pass the contact person userID list to fetch their whole profile details
        await fetchAndSetContactPersonProfile(loadedContactPersonID);

        notifyListeners();
      } catch (error) {
        print(error);

        throw (error);
      }
    } catch (error) {
      print(error);

      throw (error);
    }
  }

  Future<void> addContactPerson(String phoneNumber) async {
    bool isFound = false;
    //check whether this user already add the user with this phone number as one of the contact person in shared contact list table
    print(phoneNumber);
    _sharedContactList.forEachIndexed((index, element) {
      if (element.phoneNumber.trim() == phoneNumber) {
        isFound = true;
      }
    });

    print(isFound);
//if it is found, which means this contact person already added as contact person before
    //else add it now
    if (isFound == true) {
      //return alert message to tell user that the contact person has been added into the personal contact list before
      throw HttpException('This contact person already added by this company');
    } else {
      Profile contactPerson =
          await fetchAndReturnContactPersonProfile(phoneNumber);
      print(contactPerson.id);
      if (contactPerson.companyId.isEmpty) {
        print('company id:' + companyID);
        final url = Uri.parse(
            'https://eclms-9fed2-default-rtdb.asia-southeast1.firebasedatabase.app/sharedContactList.json?auth=$authToken');
        try {
          final response = await http.post(url, //add data
              body: json.encode({
                'operatorID': contactPerson.id,
                'companyID': companyID,
              })); //merge data that is incoming and the data that existing in the database

          final responseData =
              json.decode(response.body) as Map<String, dynamic>;
          if (responseData['error'] != null) {
            throw HttpException(responseData['error']['message']);
          }

          _sharedContactList.add(contactPerson);
          notifyListeners();
        } catch (error) {
          print(error);
          throw error;
        }
      } else {
        throw HttpException(
            'This contact person already added by another company');
      }
      // bool isFound = await fetchAndCheckAddedContactPerson(contactPersonUserID);

    }
  }

  /*==================================== check whether this phone number existed ============================================*/
  Future<Profile> fetchAndReturnContactPersonProfile(String phoneNumber) async {
    final searchTerm = 'orderBy="phoneNumber"&equalTo="$phoneNumber"';
    var url = Uri.parse(
        'https://eclms-9fed2-default-rtdb.asia-southeast1.firebasedatabase.app/users.json?auth=$authToken&$searchTerm');
    try {
      final response = await http.get(url);

      final extractedData = json.decode(response.body) as Map<String,
          dynamic>; //String key with dynamic value since flutter do not know the nested data

      if (extractedData == null) {
        throw HttpException('This phone number does not existed');
      }
      Profile loadedContactPerson = null;

      extractedData.forEach((profileId, profileData) {
        loadedContactPerson = Profile(
          id: profileId,
          fullName: profileData['fullName'],
          emailAddress: profileData['emailAddress'],
          homeAddress: profileData['homeAddress'],
          phoneNumber: profileData['phoneNumber'],
          roleId: profileData['roleID'],
          departmentId: profileData['departmentID'],
          companyId: profileData['companyID'],
          imageUrl: profileData['imageUrl'],
        );
      });

      return loadedContactPerson;
    } catch (error) {
      print(error);

      throw (error);
    }
  }

//   //================================================ Delete Contact Person Start ================================================//

//   Future<void> deleteContactPerson(String id) async {
//     final searchTerm = 'orderBy="operatorID"&equalTo="$userId"';
//     String listID = null;

//     final url = Uri.parse(
//         'https://eclms-9fed2-default-rtdb.asia-southeast1.firebasedatabase.app/personalContactList.json?auth=$authToken&$searchTerm');
//     final existingContactPersonIndex =
//         _personalContactList.indexWhere((prof) => prof.id == id);
//     var existingContactPerson =
//         _personalContactList[existingContactPersonIndex];
//     _personalContactList.removeAt(existingContactPersonIndex);
//     notifyListeners();

//     try {
//       final checkingResponse = await http.get(url);

//       final extractedData = json.decode(checkingResponse.body) as Map<String,
//           dynamic>; //String key with dynamic value since flutter do not know the nested data

//       if (extractedData == null) {
//         return null;
//       }

//       extractedData.forEach((listId, listData) {
//         if (listData['contactPersonID'] == id) {
//           listID = listId;
//         }
//       });
//     } catch (error) {
//       print(error);

//       throw (error);
//     }

//     final deleteUrl = Uri.parse(
//         'https://eclms-9fed2-default-rtdb.asia-southeast1.firebasedatabase.app/personalContactList/$listID.json?auth=$authToken');

//     final response = await http.delete(deleteUrl);

//     if (response.statusCode >= 400) {
//       _personalContactList.insert(
//           existingContactPersonIndex, existingContactPerson);
//       notifyListeners();

//       throw HttpException('Could not delete this contact person.');
//     }
//     existingContactPerson = null;
//   }

//   //================================================ Delete Contact Person End ================================================//
}
