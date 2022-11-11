import 'package:flutter/material.dart';

import '../screens/addDepartment_screen.dart';

class DepartmentItem extends StatelessWidget {
  final String id;
  final String departmentName;

  DepartmentItem(this.id, this.departmentName);

  @override
  Widget build(BuildContext context) {
    return ListTile(
      title: Text(departmentName),
      trailing: IconButton(
        icon: Icon(Icons.edit),
        color: Theme.of(context).primaryColor,
        onPressed: () {
          Navigator.pushNamed(context, AddDepartmentScreen.routeName,
              arguments: id);
        },
      ),
    );
  }
}
