import 'dart:async';

import 'package:flutter/material.dart';
import 'package:collection/collection.dart';
import 'dart:convert'; //convert data into json
import 'package:http/http.dart' as http;
import '../models/http_exception.dart';
import '../providers/profile.dart';

class PersonalContactListProvider with ChangeNotifier {
  final String authToken;
  final String userId;
  List<Profile> _personalContactList = [];
  List<Profile> _loadedData = [];
  PersonalContactListProvider(
      this.authToken, this.userId, this._personalContactList);

  List<Profile> get personalContactList {
    return [..._personalContactList];
  }

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
      _personalContactList = loadedProfile;
    } catch (error) {
      print(error);

      throw (error);
    }
  }

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
        );
      });

      return loadedContactPerson;
    } catch (error) {
      print(error);

      throw (error);
    }
  }

  Future<void> addContactPerson(String phoneNumber) async {
    bool isFound = false;
    //check whether this user already add the user with this phone number as one of the contact person in personal contact list table

    _personalContactList.forEachIndexed((index, element) {
      if (element.phoneNumber.trim() == phoneNumber) {
        isFound = true;
      }
    });

    print(isFound);
//if it is found, which means this contact person already added as contact person before
    //else add it now
    if (isFound == true) {
      return;
    } else {
      Profile contactPerson =
          await fetchAndReturnContactPersonProfile(phoneNumber);

      final url = Uri.parse(
          'https://eclms-9fed2-default-rtdb.asia-southeast1.firebasedatabase.app/personalContactList.json?auth=$authToken');
      try {
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
      } catch (error) {
        print(error);
        throw error;
      }
      // bool isFound = await fetchAndCheckAddedContactPerson(contactPersonUserID);

    }
  }
}
