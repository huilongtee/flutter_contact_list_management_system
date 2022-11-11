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

  RoleProvider(this.authToken, this.userId, this._roles);

  List<Role> get roleList {
    return [..._roles];
  }

  /*==================================== fetch all roles that created by this company start ============================================*/
  Future<void> fetchAndSetRoleList() async {
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
          'https://eclms-9fed2-default-rtdb.asia-southeast1.firebasedatabase.app/roles.json?auth=$authToken&$searchTerm');
      try {
        final response = await http.get(url);

        final extractedData = json.decode(response.body) as Map<String,
            dynamic>; //String key with dynamic value since flutter do not know the nested data
        if (extractedData == null) {
          return;
        }

        final List<Role> loadedRole = [];
        if (extractedData == null) {
          return;
        }

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
