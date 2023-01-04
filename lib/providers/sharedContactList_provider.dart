import 'dart:async';

import 'package:flutter/material.dart';
import 'package:collection/collection.dart';
import 'package:flutter_contact_list_management_system/providers/company_provider.dart';
import 'dart:convert'; //convert data into json
import 'package:http/http.dart' as http;
import 'package:provider/provider.dart';
import '../models/http_exception.dart';
import '../providers/profile.dart';
import 'department_provider.dart';
import 'role_provider.dart';

class SharedContactListProvider with ChangeNotifier {
  final String authToken;
  final String userId;
  List<Profile> _sharedContactList = [];
  List<Profile> _backupList = [];
  // List _mergedList = [];
  var companyID = '';

  SharedContactListProvider(
      this.authToken, this.userId, this._sharedContactList);

  List<Profile> get sharedContactList {
    return [..._sharedContactList];
  }

  // List get mergedList {
  //   return [..._mergedList];
  // }

  String get companyId {
    return companyID;
  }

  void findByFullName(String name) {
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

  Profile findById(String id) {
    return _sharedContactList.firstWhere((profile) => profile.id == id,
        orElse: () => null);
  }

  /*==================================== check is company admin Start ============================================*/

  Future<void> checkIsCompanyAdmin(String phoneNumber, String userID) async {
    final searchTerm = 'orderBy="companyAdminID"&equalTo="$phoneNumber"';

    //check whether this user is the company admin  of this company
    var url = Uri.parse(
        'https://eclms-9fed2-default-rtdb.asia-southeast1.firebasedatabase.app/companies.json?auth=$authToken&$searchTerm');
    try {
      final response = await http.get(url);

      final extractedData = json.decode(response.body) as Map<String,
          dynamic>; //String key with dynamic value since flutter do not know the nested data

      //this user is not the company admin of any company
      if (extractedData.isEmpty) {
        return;
      }

      //this user is the company admin, now it's time to enable this company account
      else {
        String companyID = '';
        extractedData.forEach((id, companyData) {
          companyID = id;
        });
        try {
          // final searchTerm = 'orderBy="userID"&equalTo="$userID"';
          // var checkUserIDUrl = Uri.parse(
          //     'https://eclms-9fed2-default-rtdb.asia-southeast1.firebasedatabase.app/users.json?auth=$authToken&$searchTerm');

          // final checkUserIDResponse = await http.get(checkUserIDUrl);

          // final checkUserIDExtractedData = json
          //     .decode(
          //         checkUserIDResponse.body) as Map<String,
          //     dynamic>; //String key with dynamic value since flutter do not know the nested data

          // String uid = '';

          // //get current user companyID
          // checkUserIDExtractedData.forEach((id, contactPersonData) {
          //   uid = id;
          // });
          // print('uid: ' + uid);
          // print('userID: ' + userID);
          //update comapny admin id based on their own id
          final url = Uri.parse(
              'https://eclms-9fed2-default-rtdb.asia-southeast1.firebasedatabase.app/companies/$companyID.json?auth=$authToken');
          await http.patch(url, //update data
              body: json.encode({
                'companyAdminID': userID,
              }));

          //create a role
          //create role called company admin for this company
          final createRoleUrl = Uri.parse(
              'https://eclms-9fed2-default-rtdb.asia-southeast1.firebasedatabase.app/roles.json?auth=$authToken');
          try {
            final createRoleResponse = await http.post(createRoleUrl, //add data
                body: json.encode({
                  'companyID': companyID,
                  'roleName': 'Admin',
                })); //merge data that is incoming and the data that existing in the database

            final createRoleResponseData =
                json.decode(createRoleResponse.body) as Map<String, dynamic>;
            if (createRoleResponseData['error'] != null) {
              throw HttpException(createRoleResponseData['error']['message']);
            }
            var roleId = createRoleResponseData['name'];

            //assign this role for this admin,  indicate this user role is admin

            var updateUserComapnyIDUrl = Uri.parse(
                'https://eclms-9fed2-default-rtdb.asia-southeast1.firebasedatabase.app/users/$userID.json?auth=$authToken');
            await http.patch(updateUserComapnyIDUrl, //update data
                body: json.encode({
                  'companyID': companyID,
                  'roleID': roleId,
                }));

            //add into shared contact list
            final addIntoSharedContactListUrl = Uri.parse(
                'https://eclms-9fed2-default-rtdb.asia-southeast1.firebasedatabase.app/sharedContactList.json?auth=$authToken');
            try {
              final addIntoSharedContactListResponse = await http.post(
                  addIntoSharedContactListUrl, //add data
                  body: json.encode({
                    'companyID': companyID,
                    'operatorID': userID,
                  })); //merge data that is incoming and the data that existing in the database

              final addIntoSharedContactListResponseData =
                  json.decode(addIntoSharedContactListResponse.body)
                      as Map<String, dynamic>;
              if (addIntoSharedContactListResponseData['error'] != null) {
                throw HttpException(
                    addIntoSharedContactListResponseData['error']['message']);
              }

              notifyListeners();
            } catch (error) {
              throw HttpException(error);
            }
          } catch (error) {
            throw HttpException(error);
          }
        } catch (err) {
          print(err);

          throw (err);
        }
      }
    } catch (err) {
      print(err);

      throw (err);
    }
  }

  /*==================================== check is company admin End ============================================*/
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

      _sharedContactList = loadedProfile;
      _backupList = loadedProfile;
    } catch (error) {
      print(error);

      throw (error);
    }
  }

  /*==================================== get a list of collegues id ============================================*/
  Future<void> fetchAndSetSharedContactList() async {
    String userID = '';

    //check whether current user got companyID
    // var checkCompanyIDUrl = Uri.parse(
    //     'https://eclms-9fed2-default-rtdb.asia-southeast1.firebasedatabase.app/users/$userId.json?auth=$authToken');
    final searchTerm = 'orderBy="userID"&equalTo="$userId"';
    var checkCompanyIDUrl = Uri.parse(
        'https://eclms-9fed2-default-rtdb.asia-southeast1.firebasedatabase.app/users.json?auth=$authToken&$searchTerm');
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
        companyID = contactPersonData['companyID'];
        userID = id;
      });
      //fetch all colleague userId based on the company id
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
          if (contactPersonID['operatorID'] != userID) {
            loadedContactPersonID.add(
              contactPersonID['operatorID'],
            );
          } else {
            print('found');
            print(userID);
            print(companyID);
          }
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

  //================================================ Add Contact Person Start ================================================//

  Future<String> addContactPerson(String phoneNumber) async {
    bool isFound = false;
    String errMessage = '';

    //check whether this user already add the user with this phone number as one of the contact person in shared contact list table
    _sharedContactList.forEachIndexed((index, element) {
      if (element.phoneNumber.trim() == phoneNumber) {
        isFound = true;
        //return alert message to tell user that the contact person has been added into the personal contact list before
        errMessage =
            'This phone number is already added into the shared contact list';
        return errMessage;
      }
    });

    //if it is found, which means this contact person already added as contact person before
    //else add it now
    if (isFound == true) {
      //return alert message to tell user that the contact person has been added into the personal contact list before
      throw HttpException('This contact person already added by this company');
    } else {
      Profile contactPerson =
          await fetchAndReturnContactPersonProfile(phoneNumber, true);
      if (contactPerson == null) {
        errMessage = 'This phone number is not found in the system';
        return errMessage;
      }
      if (contactPerson.companyId.isEmpty) {
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

          //add company id for that contact person
          final userUrl = Uri.parse(
              'https://eclms-9fed2-default-rtdb.asia-southeast1.firebasedatabase.app/users/${contactPerson.id}.json?auth=$authToken');
          await http.patch(userUrl, //update data
              body: json.encode({
                'companyID': companyID,
              })); //merge data that is incoming and the data that existing in the database

          notifyListeners();
          errMessage = '';
          return errMessage;
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
  //================================================ Add Contact Person End ================================================//

  //================================================ Add Contact Person by contact person id Start ================================================//

  Future<String> addContactPersonByContactPersonID(
      String contactPersonID) async {
    bool isFound = false;
    String errMessage = '';
    //check whether this user already add the user with this phone number as one of the contact person in personal contact list table

    if (userId == contactPersonID) {
      errMessage = 'You cannot add yourself into the contact list';
      print('cannot add yourself');
      return errMessage;
    } else {
      Profile contactPerson =
          await fetchAndReturnContactPersonProfile(contactPersonID, false);
      _sharedContactList.forEachIndexed((index, element) {
        if (element.id == contactPerson.id) {
          isFound = true;
        }
      });
      //if it is found, which means this contact person already added as contact person before
      //else add it now
      if (isFound == true) {
        //return alert message to tell user that the contact person has been added into the personal contact list before
        errMessage =
            'This person is already added into the shared contact list';
        return errMessage;
      } else {
        if (contactPerson.companyId.isEmpty) {
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

            //add company id for that contact person
            final userUrl = Uri.parse(
                'https://eclms-9fed2-default-rtdb.asia-southeast1.firebasedatabase.app/users/${contactPerson.id}.json?auth=$authToken');
            await http.patch(userUrl, //update data
                body: json.encode({
                  'companyID': companyID,
                })); //merge data that is incoming and the data that existing in the database

            notifyListeners();
            errMessage = '';
            return errMessage;
          } catch (error) {
            print(error);
            throw error;
          }
        } else {
          throw HttpException(
              'This contact person already added by another company');
        }
      }
    }
  }
  //================================================ Add Contact Person by contact person id End ================================================//

  //================================================ Delete Contact Person Start ================================================//

  Future<void> deleteContactPerson(String id) async {
    final searchTerm = 'orderBy="operatorID"&equalTo="$id"';
    String listID = null;

    final url = Uri.parse(
        'https://eclms-9fed2-default-rtdb.asia-southeast1.firebasedatabase.app/sharedContactList.json?auth=$authToken&$searchTerm');
    final existingContactPersonIndex =
        _sharedContactList.indexWhere((prof) => prof.id == id);
    var existingContactPerson = _sharedContactList[existingContactPersonIndex];
    _sharedContactList.removeAt(existingContactPersonIndex);

    try {
      final checkingResponse = await http.get(url);

      final extractedData = json.decode(checkingResponse.body) as Map<String,
          dynamic>; //String key with dynamic value since flutter do not know the nested data

      if (extractedData == null) {
        return null;
      }

      extractedData.forEach((listId, listData) {
        if (listData['operatorID'] == id) {
          listID = listId;
        }
      });
    } catch (error) {
      print(error);

      throw (error);
    }

    final deleteUrl = Uri.parse(
        'https://eclms-9fed2-default-rtdb.asia-southeast1.firebasedatabase.app/sharedContactList/$listID.json?auth=$authToken');

    final response = await http.delete(deleteUrl);

    if (response.statusCode >= 400) {
      _sharedContactList.insert(
          existingContactPersonIndex, existingContactPerson);

      throw HttpException('Could not delete this contact person.');
    } else {
      try {
        final removecompanyIDURL = Uri.parse(
            'https://eclms-9fed2-default-rtdb.asia-southeast1.firebasedatabase.app/users/$id.json?auth=$authToken');
        await http.patch(removecompanyIDURL, //update data
            body: json.encode({
              'companyID': '',
              'roleID': '',
              'departmentID': '',
            })); //merge data that is incoming and the data that existing in the database

        notifyListeners();
      } catch (error) {
        print(error);
        throw error;
      }
    }

    existingContactPerson = null;
  }

  //================================================ Delete Contact Person End ================================================//

  /*==================================== check whether this phone number existed ============================================*/
  Future<Profile> fetchAndReturnContactPersonProfile(
      String searchType, bool addByPhone) async {
    if (addByPhone == true) {
      final searchTerm = 'orderBy="phoneNumber"&equalTo="$searchType"';
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
            qrUrl: profileData['qrUrl'],
          );
        });

        return loadedContactPerson;
      } catch (error) {
        print(error);

        throw (error);
      }
    } else {
      final searchTerm = 'orderBy="userID"&equalTo="$searchType"';
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
  }

  //================================================ Edit Contact Person Start ================================================//

  Future<void> editContactPerson(String id, String newRole,
      String newDepartment, Profile oldProfile) async {
    // Future<String> imageURL = uploadImage(image);
    print(newRole);
    print(newDepartment);
    final profileIndex = _sharedContactList.indexWhere((prof) => prof.id == id);
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
          'https://eclms-9fed2-default-rtdb.asia-southeast1.firebasedatabase.app/users/${id}.json?auth=$authToken');

      await http.patch(updateUrl, //update data
          body: json.encode({
            'departmentID': newDepartment,
            'roleID': newRole,
          })); //merge data that is incoming and the data that existing in the database

      final newProfile = Profile(
        id: id,
        fullName: oldProfile.fullName,
        emailAddress: oldProfile.emailAddress,
        homeAddress: oldProfile.homeAddress,
        phoneNumber: oldProfile.phoneNumber,
        imageUrl: oldProfile.imageUrl,
        qrUrl: oldProfile.qrUrl,
        companyId: companyId,
        roleId: newRole,
        departmentId: newDepartment,
      );

      _sharedContactList[profileIndex] = newProfile;
      notifyListeners();
    } else {
      print('...');
    }
  }

  //================================================ Edit Contact Person End ================================================//

}
