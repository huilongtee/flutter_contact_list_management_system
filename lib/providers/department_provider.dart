import 'dart:async';

import 'package:flutter/material.dart';
import 'package:collection/collection.dart';
import 'dart:convert'; //convert data into json
import 'package:http/http.dart' as http;
import '../models/http_exception.dart';
import 'package:flutter/material.dart';

class Department {
  final String id;
  final String departmentName;

  Department({
    @required this.id,
    @required this.departmentName,
  });
}

class DepartmentProvider with ChangeNotifier {
  List<Department> _departments;
  final String authToken;
  final String userId;
  var companyID = '';

  DepartmentProvider(this.authToken, this.userId, this._departments);

  List<Department> get departmentList {
    return [..._departments];
  }

  /*==================================== fetch all departments that created by this company start ============================================*/
  Future<void> fetchAndSetDepartmentList() async {
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

      // if (checkCompanyIDExtractedData == null) {
      //   return;
      // }

      //get current user companyID
      checkCompanyIDExtractedData.forEach((id, contactPersonData) {
        companyID = contactPersonData['companyID'];
      });
      //fetch all colleague userId
      final searchTerm = 'orderBy="companyID"&equalTo="$companyID"';

      var url = Uri.parse(
          'https://eclms-9fed2-default-rtdb.asia-southeast1.firebasedatabase.app/departments.json?auth=$authToken&$searchTerm');
      try {
        final response = await http.get(url);

        final extractedData = json.decode(response.body) as Map<String,
            dynamic>; //String key with dynamic value since flutter do not know the nested data
        if (extractedData == null) {
          return;
        }

        final List<Department> loadedDepartment = [];
        if (extractedData == null) {
          return;
        }

        extractedData.forEach((departmentId, departmentData) {
          loadedDepartment.add(
            Department(
              id: departmentId,
              departmentName: departmentData['departmentName'],
            ),
          );
          _departments = loadedDepartment;
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
  /*==================================== fetch all departments that created by this company end ============================================*/

  /*==================================== add department start ============================================*/

  Future<void> addDepartment(Department newDepartment) async {
    var url = Uri.parse(
        'https://eclms-9fed2-default-rtdb.asia-southeast1.firebasedatabase.app/departments.json?auth=$authToken');
    try {
      final response = await http.post(url, //add data
          body: json.encode({
            'departmentName': newDepartment.departmentName,
            'companyID': companyID,
          }));

      final responseData = json.decode(response.body) as Map<String, dynamic>;
      if (responseData['error'] != null) {
        throw HttpException(responseData['error']['message']);
      }
      final departmentId = responseData['name'];

      final addedDepartment = Department(
        id: departmentId,
        departmentName: newDepartment.departmentName,
      );
      _departments.add(addedDepartment);
      notifyListeners();
    } catch (error) {
      print(error);

      throw (error);
    }
  }

  /*==================================== add departments end ============================================*/

  /*==================================== update department start ============================================*/

  Future<void> updateDepartment(String id, Department newDepartment) async {
    final departmentIndex =
        _departments.indexWhere((department) => department.id == id);

    if (departmentIndex >= 0) {
      final url = Uri.parse(
          'https://eclms-9fed2-default-rtdb.asia-southeast1.firebasedatabase.app/departments/$id.json?auth=$authToken');

      await http.patch(url, //update data
          body: json.encode({
            'departmentName': newDepartment.departmentName,
          })); //merge data that is incoming and the data that existing in the database

      _departments[departmentIndex] = newDepartment;
      notifyListeners();
    } else {
      print('...');
    }
  }
  /*==================================== update department end ============================================*/

  /*==================================== find department id start ============================================*/

  Department findById(String id) {
    return _departments.firstWhere((department) => department.id == id,
        orElse: () => null);
  }
  /*==================================== find department id end ============================================*/

}
