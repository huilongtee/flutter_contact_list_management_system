import 'package:flutter/material.dart';


class PersonalContactListProvider with ChangeNotifier{
  final String listId;
  final String contactPersonId;

  PersonalContactListProvider({
    @required this.listId,
    @required this.contactPersonId,
  });

  // Future<void> deleteContactPerson(String id) {
  //   final existingContactPersonIndex =
  //       _profile.indexWhere((contactPerson) => contactPerson.id == id);
  //   var existingContactPerson = _profile[existingContactPersonIndex];

  //   if (existingContactPerson != null) {
  //     _profile.removeAt(existingContactPersonIndex);

  //     existingContactPerson = null;
  //     notifyListeners();
  //   }
  // }
}
