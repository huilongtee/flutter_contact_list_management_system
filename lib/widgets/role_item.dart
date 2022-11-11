import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_svg_provider/flutter_svg_provider.dart';
import 'package:flutter_svg/svg.dart';
import 'package:provider/provider.dart';
import '../providers/personalContactList_provider.dart';
import '../providers/profile_provider.dart';
import '../screens/addRole_screen.dart';
import '../screens/editContactPerson_screen.dart';

class RoleItem extends StatelessWidget {
  final String id;
  final String roleName;

  RoleItem(this.id, this.roleName);

  @override
  Widget build(BuildContext context) {
    return ListTile(
      title: Text(roleName),
      trailing: IconButton(
        icon: Icon(Icons.edit),
        color: Theme.of(context).primaryColor,
        onPressed: () {
          Navigator.pushNamed(context, AddRoleScreen.routeName, arguments: id);
        },
      ),
    );
  }
}
