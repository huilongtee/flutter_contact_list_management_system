import 'package:flutter/material.dart';

class ContactList {
  final String id;
  final String contactPersonId;
  final String companyId;

  ContactList({
    @required this.id,
    @required this.contactPersonId,
    @required this.companyId,
  });

  
}

class SharedContactListProvider with ChangeNotifier {
  final List<ContactList> _companies = [
    ContactList(
      id: '1',
      contactPersonId: '1',
      companyId: '1',
    ),
    ContactList(
      id: '2',
      contactPersonId: '2',
      companyId: '1',
    ),
    ContactList(
      id: '3',
      contactPersonId: '3',
      companyId: '1',
    ),
    ContactList(
      id: '4',
      contactPersonId: '4',
      companyId: '2',
    ),
  ];

  List<ContactList> get companies {
    List<ContactList> _loadedCompanyList = [];

    for (int i = 0; i < _companies.length; i++) {
      if (_companies[i].companyId.contains('1')) {
        _loadedCompanyList.add(_companies[i]);
      }
    }
    return _loadedCompanyList;
  }
}
