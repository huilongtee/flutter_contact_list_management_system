import 'dart:async';

import 'package:flutter/material.dart';
import 'package:collection/collection.dart';
import 'package:flutter_contact_list_management_system/providers/profile_provider.dart';
import 'dart:convert'; //convert data into json
import 'package:http/http.dart' as http;
import 'package:provider/provider.dart';
import '../models/http_exception.dart';
import '../providers/profile.dart';

class PersonalContactListProvider with ChangeNotifier {
  final String authToken;
  final String userId;
  List<Profile> _personalContactList = [];
  List<Profile> _backupList = [];

  PersonalContactListProvider(
      this.authToken, this.userId, this._personalContactList);

  List<Profile> get personalContactList {
    return [..._personalContactList];
  }

  void findByFullName(String name) {
    print(name);
    if (name.isEmpty) {
      _personalContactList = _backupList;
    } else {
      _personalContactList = _personalContactList
          .where((data) =>
              data.fullName.toLowerCase().contains(name.toLowerCase()))
          .toList();
    }
    notifyListeners();
  }

  Profile findById(String id) {
    return _personalContactList.firstWhere((profile) => profile.id == id,
        orElse: () => null);
  }

  /*==================================== retrieve a list of contact person ID and return their profile ============================================*/
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
              qrUrl: profileData['qrUrl'],
            ),
          );
        }
      });
      _personalContactList = loadedProfile;
      _backupList = loadedProfile;
    } catch (error) {
      throw (error);
    }
  }

  /*==================================== get a list of contact person ID and get their profile ============================================*/
  Future<void> fetchAndSetPersonalContactList() async {
    final searchTerm = 'orderBy="operatorID"&equalTo="$userId"';
    //fetch all contact person id who have been added by this user($userId)
    var url = Uri.parse(
        'https://eclms-9fed2-default-rtdb.asia-southeast1.firebasedatabase.app/personalContactList.json?auth=$authToken&$searchTerm');
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
  }

  Future<Profile> fetchAndReturnContactPersonProfile(String phoneNumber) async {
    final searchTerm = 'orderBy="phoneNumber"&equalTo="$phoneNumber"';
    var url = Uri.parse(
        'https://eclms-9fed2-default-rtdb.asia-southeast1.firebasedatabase.app/users.json?auth=$authToken&$searchTerm');
    try {
      final response = await http.get(url);

      final extractedData = json.decode(response.body) as Map<String,
          dynamic>; //String key with dynamic value since flutter do not know the nested data

      if (extractedData == null) {
        return null;
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
          qrUrl: profileData['qrUrl'],
        );
      });

      return loadedContactPerson;
    } catch (error) {
      throw (error);
    }
  }

  Future<String> addContactPerson(String phoneNumber,Profile profile) async {
    bool isFound = false;
    String errMessage = '';
    //check whether this user already add the user with this phone number as one of the contact person in personal contact list table
    _personalContactList.forEachIndexed((index, element) {
      if (element.phoneNumber.trim() == phoneNumber) {
        isFound = true;
      }
    });

//if it is found, which means this contact person already added as contact person before
    //else add it now
    if (isFound == true) {
      //return alert message to tell user that the contact person has been added into the personal contact list before
      errMessage =
          'This phone number is already added into the personal contact list';
      return errMessage;
    } else if(profile.phoneNumber==phoneNumber){
 errMessage =
          'You cannot add yourself into the contact list';
      return errMessage;
    }else{
      Profile contactPerson =
          await fetchAndReturnContactPersonProfile(phoneNumber);
          
      final url = Uri.parse(
          'https://eclms-9fed2-default-rtdb.asia-southeast1.firebasedatabase.app/personalContactList.json?auth=$authToken');
      try {
        if (contactPerson == null) {
          errMessage = 'This phone number is not found in the system';
          return errMessage;
        }
        final response = await http.post(url, //add data
            body: json.encode({
              'operatorID': userId,
              'contactPersonID': contactPerson.id,
            })); //merge data that is incoming and the data that existing in the database

        final responseData = json.decode(response.body) as Map<String, dynamic>;
        if (responseData['error'] != null) {
          throw HttpException(responseData['error']['message']);
        }

        _personalContactList.add(contactPerson);
        notifyListeners();
        errMessage = '';
        return errMessage;
      } catch (error) {
        print(error);
        throw HttpException(error);
      }
      // bool isFound = await fetchAndCheckAddedContactPerson(contactPersonUserID);

    }
  }

  //================================================ Delete Contact Person Start ================================================//

  Future<void> deleteContactPerson(String id) async {
    final searchTerm = 'orderBy="operatorID"&equalTo="$userId"';
    String listID = null;

    final url = Uri.parse(
        'https://eclms-9fed2-default-rtdb.asia-southeast1.firebasedatabase.app/personalContactList.json?auth=$authToken&$searchTerm');
    final existingContactPersonIndex =
        _personalContactList.indexWhere((prof) => prof.id == id);
    var existingContactPerson =
        _personalContactList[existingContactPersonIndex];
    _personalContactList.removeAt(existingContactPersonIndex);
    notifyListeners();

    try {
      final checkingResponse = await http.get(url);

      final extractedData = json.decode(checkingResponse.body) as Map<String,
          dynamic>; //String key with dynamic value since flutter do not know the nested data

      if (extractedData == null) {
        return null;
      }

      extractedData.forEach((listId, listData) {
        if (listData['contactPersonID'] == id) {
          listID = listId;
        }
      });
    } catch (error) {
      print(error);

      throw (error);
    }

    final deleteUrl = Uri.parse(
        'https://eclms-9fed2-default-rtdb.asia-southeast1.firebasedatabase.app/personalContactList/$listID.json?auth=$authToken');

    final response = await http.delete(deleteUrl);

    if (response.statusCode >= 400) {
      _personalContactList.insert(
          existingContactPersonIndex, existingContactPerson);
      // notifyListeners();

      throw HttpException('Could not delete this contact person.');
    }
    existingContactPerson = null;
  }

  //================================================ Delete Contact Person End ================================================//
}
