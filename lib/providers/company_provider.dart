import 'package:flutter/material.dart';
import 'dart:convert'; //convert data into json

import 'package:http/http.dart' as http;
import '../models/http_exception.dart';
import '../providers/profile.dart';

class Company with ChangeNotifier {
  final String id;
  final String companyName;
  final String companyAdminId;

  Company({
    @required this.id,
    @required this.companyName,
    @required this.companyAdminId,
  });
}

class CompanyProvider with ChangeNotifier {
  final String authToken;

  List<Company> _companies = [];
  List<Profile> _profile = [];
  String _companyNameResult = '';

  CompanyProvider(this.authToken, this._companies);

  List<Company> get companies {
    return [..._companies];
  }

  List<Profile> get profile {
    return [..._profile];
  }

  // String get getCompanyName {
  //   return companyName;
  // }

  String get getCompanyName {
    return _companyNameResult;
  }

  Future<void> fetchAndSetCompany() async {
    final url = Uri.parse(
        'https://eclms-9fed2-default-rtdb.asia-southeast1.firebasedatabase.app/companies.json?auth=$authToken');
    try {
      final response = await http.get(url);
      final extractedData = json.decode(response.body) as Map<String,
          dynamic>; //String key with dynamic value since flutter do not know the nested data

      final List<Company> loadedCompanies = [];
      if (extractedData == null) {
        return;
      }

      extractedData.forEach((companyId, companyData) {
        loadedCompanies.add(
          Company(
            id: companyId,
            companyName: companyData['companyName'],
            companyAdminId: companyData['companyAdminID'],
          ),
        );
        _companies = loadedCompanies;

        notifyListeners();
      });
    } catch (error) {
      print(error);

      throw (error);
    }
  }

  //fetch company name by searching company id
  Future<void> fetchAndSetCompanyName(String companyID) async {
    final url = Uri.parse(
        'https://eclms-9fed2-default-rtdb.asia-southeast1.firebasedatabase.app/companies/$companyID.json?auth=$authToken');

    try {
      final response = await http.get(url);
      final extractedData = json.decode(response.body) as Map<String,
          dynamic>; //String key with dynamic value since flutter do not know the nested data
      if (extractedData == null) {
        return null;
      }
    _companyNameResult = '';

      extractedData.forEach((companyId, companyData) {
        if (companyId == 'companyName') {
          _companyNameResult = companyData;
        }
      });
      notifyListeners();
    } catch (error) {
      print(error);

      throw (error);
    }
  }

  Future<void> addCompany(Company newCompany, Profile oldProfile,
      List<Profile> entireProfileList) async {
    final id = oldProfile.id;

    final profileIndex = entireProfileList.indexWhere((prof) => prof.id == id);
    var responseData;
    var extractedData;
    final userUrl = Uri.parse(
        'https://eclms-9fed2-default-rtdb.asia-southeast1.firebasedatabase.app/users/$id.json?auth=$authToken');
    if (profileIndex >= 0) {
      try {
        final response = await http.get(userUrl);

        extractedData = json.decode(response.body) as Map<String,
            dynamic>; //String key with dynamic value since flutter do not know the nested data

        //return null means this userId doesn't exists
        if (extractedData == null) {
          return;
        } else {
          final url = Uri.parse(
              'https://eclms-9fed2-default-rtdb.asia-southeast1.firebasedatabase.app/companies.json?auth=$authToken');
          try {
            final companyResponse = await http.post(url, //add data
                body: json.encode({
                  'companyName': newCompany.companyName,
                  'companyAdminId': id,
                })); //merge data that is incoming and the data that existing in the database

            responseData =
                json.decode(companyResponse.body) as Map<String, dynamic>;
            if (responseData['error'] != null) {
              throw HttpException(responseData['error']['message']);
            }
            final companyId = responseData['name'];

            final addedCompany = Company(
              id: companyId,
              companyName: newCompany.companyName,
              companyAdminId: id,
            );
            _companies.add(addedCompany);

            //create role called company admin for this company
            final createRoleUrl = Uri.parse(
                'https://eclms-9fed2-default-rtdb.asia-southeast1.firebasedatabase.app/roles.json?auth=$authToken');
            try {
              final createRoleResponse = await http.post(
                  createRoleUrl, //add data
                  body: json.encode({
                    'companyID': companyId,
                    'roleName': 'Admin',
                  })); //merge data that is incoming and the data that existing in the database

              final createRoleResponseData =
                  json.decode(createRoleResponse.body) as Map<String, dynamic>;
              if (responseData['error'] != null) {
                throw HttpException(createRoleResponseData['error']['message']);
              }
              var roleId = '';
              createRoleResponseData.forEach((id, createRoleResponseData) {
                roleId = createRoleResponseData;
              });

              //assign this role for this admin, wo indicate this user role is admin
              await http.patch(userUrl, //update data
                  body: json.encode({
                    'companyID': companyId.toString(),
                    'roleID': roleId,
                  }));
              entireProfileList[profileIndex] = oldProfile;

              //add into shared contact list
              final addIntoSharedContactListUrl = Uri.parse(
                  'https://eclms-9fed2-default-rtdb.asia-southeast1.firebasedatabase.app/sharedContactList.json?auth=$authToken');
              try {
                final addIntoSharedContactListResponse = await http.post(
                    addIntoSharedContactListUrl, //add data
                    body: json.encode({
                      'companyID': companyId,
                      'operatorID': id,
                    })); //merge data that is incoming and the data that existing in the database

                final addIntoSharedContactListResponseData =
                    json.decode(addIntoSharedContactListResponse.body)
                        as Map<String, dynamic>;
                if (responseData['error'] != null) {
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
          } catch (error) {
            throw HttpException(error);
          }
        }
      } catch (error) {
        throw HttpException(error);
      }
    } else {
      throw HttpException('Something wrong');
    }
  }

  Company findById(String id) {
    return _companies.firstWhere((company) => company.id == id,
        orElse: () => null);
  }

  Future<void> updateCompany(String id, Company newCompany) async {
    final companyIndex = _companies.indexWhere((company) => company.id == id);

    if (companyIndex >= 0) {
      final url = Uri.parse(
          'https://eclms-9fed2-default-rtdb.asia-southeast1.firebasedatabase.app/companies/$id.json?auth=$authToken');

      await http.patch(url, //update data
          body: json.encode({
            'companyName': newCompany.companyName,
            'companyAdminID': newCompany.companyAdminId,
          })); //merge data that is incoming and the data that existing in the database

      _companies[companyIndex] = newCompany;
      notifyListeners();
    } else {
      print('...');
    }
  }
}
