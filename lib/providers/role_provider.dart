import 'dart:async';

import 'package:flutter/material.dart';
import 'package:collection/collection.dart';
import 'dart:convert'; //convert data into json
import 'package:http/http.dart' as http;
import '../models/http_exception.dart';
import 'package:flutter/material.dart';

class Role {
  final String id;
  final String roleName;

  Role({
    @required this.id,
    @required this.roleName,
  });
}

class RoleProvider with ChangeNotifier {
  List<Role> _roles;
  final String authToken;
  final String userId;
  var companyID = '';
  bool _isAdmin = false;
  RoleProvider(this.authToken, this.userId, this._roles);

  List<Role> get roleList {
    return [..._roles];
  }

  bool get isAdmin {
    return _isAdmin;
  }
  /*==================================== check admin start ============================================*/

  Future<void> checkAdmin() async {
    final searchTerm = 'orderBy="userID"&equalTo="$userId"';
    var getRoleIDUrl = Uri.parse(
        'https://eclms-9fed2-default-rtdb.asia-southeast1.firebasedatabase.app/users.json?auth=$authToken&$searchTerm');
    try {
      final getRoleIDResponse = await http.get(getRoleIDUrl);

      final getRoleIDExtractedData = json.decode(getRoleIDResponse.body) as Map<
          String,
          dynamic>; //String key with dynamic value since flutter do not know the nested data
      String roleID = '';

      //get current user companyID
      getRoleIDExtractedData.forEach((id, contactPersonData) {
        roleID = contactPersonData['roleID'];
      });
      Role data =
          _roles.firstWhere((role) => role.id == roleID, orElse: () => null);
      _roles.forEach((element) {
        print(element.roleName);
      });
      if (data != null) {
        if (data.roleName == 'Admin') {
          _isAdmin = true;
        } else {
          _isAdmin = false;
        }
      }
    } catch (err) {
      print(err);

      throw (err);
    }
  }
  /*==================================== check admin end ============================================*/

  /*==================================== fetch all roles that created by this company start ============================================*/
  Future<void> fetchAndSetRoleList() async {
    //check whether current user got companyID

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
      });
      //fetch all colleague userId
      final searchTerm = 'orderBy="companyID"&equalTo="$companyID"';
      var url = Uri.parse(
          'https://eclms-9fed2-default-rtdb.asia-southeast1.firebasedatabase.app/roles.json?auth=$authToken&$searchTerm');
      try {
        final response = await http.get(url);

        final extractedData = json.decode(response.body) as Map<String,
            dynamic>; //String key with dynamic value since flutter do not know the nested data
        if (extractedData == null) {
          return;
        }

        final List<Role> loadedRole = [];

        extractedData.forEach((roleId, roleData) {
          loadedRole.add(
            Role(
              id: roleId,
              roleName: roleData['roleName'],
            ),
          );

          _roles = loadedRole;
          notifyListeners();
        });
      } catch (error) {
        print(error);

        throw (error);
      }
    } catch (error) {
      print(error);

      throw (error);
    }
  }
  /*==================================== fetch all roles that created by this company end ============================================*/

  /*==================================== add role start ============================================*/

  Future<void> addRole(Role newRole) async {
    var url = Uri.parse(
        'https://eclms-9fed2-default-rtdb.asia-southeast1.firebasedatabase.app/roles.json?auth=$authToken');
    try {
      final response = await http.post(url, //add data
          body: json.encode({
            'roleName': newRole.roleName,
            'companyID': companyID,
          }));

      final responseData = json.decode(response.body) as Map<String, dynamic>;
      if (responseData['error'] != null) {
        throw HttpException(responseData['error']['message']);
      }
      final roleId = responseData['name'];

      final addedRole = Role(
        id: roleId,
        roleName: newRole.roleName,
      );
      _roles.add(addedRole);
      notifyListeners();
    } catch (error) {
      print(error);

      throw (error);
    }
  }

  /*==================================== add role end ============================================*/

  /*==================================== update role start ============================================*/

  Future<void> updateRole(String id, Role newRole) async {
    final roleIndex = _roles.indexWhere((role) => role.id == id);

    if (roleIndex >= 0) {
      final url = Uri.parse(
          'https://eclms-9fed2-default-rtdb.asia-southeast1.firebasedatabase.app/roles/$id.json?auth=$authToken');

      await http.patch(url, //update data
          body: json.encode({
            'roleName': newRole.roleName,
          })); //merge data that is incoming and the data that existing in the database

      _roles[roleIndex] = newRole;
      notifyListeners();
    } else {
      print('...');
    }
  }
  /*==================================== update role end ============================================*/

  /*==================================== find role id start ============================================*/

  Role findById(String id) {
    return _roles.firstWhere((role) => role.id == id, orElse: () => null);
  }
  /*==================================== find role id end ============================================*/

}
