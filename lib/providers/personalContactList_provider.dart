import 'package:flutter/material.dart';


class PersonalContactListProvider with ChangeNotifier{
  final String listId;
  final String contactPersonId;

  PersonalContactListProvider({
    @required this.listId,
    @required this.contactPersonId,
  });
}
