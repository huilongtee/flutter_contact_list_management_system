import 'package:flutter/material.dart';

import '../screens/editCompany_screen.dart';

class CompaniesItem extends StatelessWidget {
  final String id;
  final String companyName;

  final String companyAdminFullName;

  CompaniesItem(this.id, this.companyName, this.companyAdminFullName);
  @override
  Widget build(BuildContext context) {
    return Card(
        margin: EdgeInsets.symmetric(vertical: 5),
        elevation: 2,
        child:ListTile(
      tileColor: Theme.of(context).focusColor,
      title: Text(companyName),
      subtitle: Text('admin name: ' + companyAdminFullName),
      trailing: IconButton(
        onPressed: () {
          Navigator.pushNamed(context, EditCompanyScreen.routeName,
              arguments: id);
        },
        icon: Icon(Icons.manage_accounts),
        color: Theme.of(context).primaryColor,
      ),),
    );
  }
}
