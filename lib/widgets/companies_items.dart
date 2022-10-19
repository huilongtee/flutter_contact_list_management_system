import 'package:flutter/material.dart';

import '../screens/addCompany_screen.dart';

class CompaniesItem extends StatelessWidget {
  final String id;
  final String companyName;

  final String companyAdminFullName;
 

  CompaniesItem(this.id, this.companyName, this.companyAdminFullName);
  @override
  Widget build(BuildContext context) {

    return Dismissible(
      key: ValueKey(id),
      background: Container(
        color: Theme.of(context).errorColor,
        child: Icon(
          Icons.delete,
          color: Colors.white,
          size: 40,
        ),
        alignment: Alignment.centerRight,
        padding: EdgeInsets.only(
          right: 20,
        ),
        margin: EdgeInsets.symmetric(horizontal: 15, vertical: 4),
      ),
      direction: DismissDirection.endToStart,
      confirmDismiss: (direction) {
        return showDialog(
          context: context,
          builder: (ctx) => AlertDialog(
            title: Text('Are your sure?'),
            content: Text(
                'Do you want to remove this company from the company list'),
            actions: [
              FlatButton(
                child: Text('No'),
                onPressed: () {
                  Navigator.of(context).pop(false);
                },
              ),
              FlatButton(
                child: Text('Yes'),
                onPressed: () {
                  Navigator.of(context).pop(true);
                },
              ),
            ],
          ),
        );
      },
      onDismissed: (direction) {
        // Provider.of<ProfileProvider>(context, listen: false).deleteContactPerson(
        //     id); //listen:false to set it as dont want it set permenant listener
      },
      child: ListTile(
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
      ),
    );
  }
}
