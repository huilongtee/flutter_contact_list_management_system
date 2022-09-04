import 'package:flutter/material.dart';
import 'dart:convert'; //convert data into json
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import '../models/http_exception.dart';

class Company {
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

  CompanyProvider(this.authToken, this._companies);

  List<Company> get companies {
    return [..._companies];
  }

  Future<void> fetchAndSetCompany() async {
    final url = Uri.parse(
        'https://eclms-9fed2-default-rtdb.asia-southeast1.firebasedatabase.app/companies.json?auth=$authToken');
    try {
      final response = await http.get(url);
      print(json.decode(response.body));
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

  Company findById(String id) {
    return _companies.firstWhere((company) => company.id == id,
        orElse: () => null);
  }


}
