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
            companyAdminId: companyData['companyAdminId'],
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

      extractedData.forEach((companyId, companyData) {
        if (companyId == 'companyName') {
          print('entered');
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

            await http.patch(userUrl, //update data
                body: json.encode({
                  'companyID': companyId.toString(),
                })); //merge data that is incoming and the data that existing in the database
            entireProfileList[profileIndex] = oldProfile;
            notifyListeners();
          } catch (error) {
            print(error);
            throw error;
          }
        }
      } catch (error) {
        print(error);
        throw error;
      }
    } else {
      print('nothing fetched');
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
            'companyAdminId': newCompany.companyAdminId,
          })); //merge data that is incoming and the data that existing in the database

      _companies[companyIndex] = newCompany;
      notifyListeners();
    } else {
      print('...');
    }
  }
}
