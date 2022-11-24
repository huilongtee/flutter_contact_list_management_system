import 'package:flutter/material.dart';

import '../screens/addCompany_screen.dart';

class CompaniesItem extends StatelessWidget {
  final String id;
  final String companyName;

  final String companyAdminFullName;

  CompaniesItem(this.id, this.companyName, this.companyAdminFullName);
  @override
  Widget build(BuildContext context) {
    return ListTile(
      title: Text(companyName),
      subtitle: Text('admin name: ' + companyAdminFullName),
      trailing: IconButton(
        onPressed: () {
          Navigator.pushNamed(context, AddCompanyScreen.routeName,
              arguments: id);
        },
        icon: Icon(Icons.manage_accounts),
        color: Theme.of(context).primaryColor,
      ),
    );
  }
}
