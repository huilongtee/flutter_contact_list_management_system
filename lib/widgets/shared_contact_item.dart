import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_contact_list_management_system/providers/role_provider.dart';
import 'package:flutter_svg_provider/flutter_svg_provider.dart';
import 'package:flutter_svg/svg.dart';
import 'package:provider/provider.dart';
import '../providers/department_provider.dart';
import '../providers/personalContactList_provider.dart';
import '../providers/profile_provider.dart';
import '../providers/sharedContactList_provider.dart';
import '../screens/contactPersonDetail.dart';
import '../screens/editContactPerson_screen.dart';

class SharedContactItem extends StatefulWidget {
  final String id;
  final String userName;
  final String imageUrl;
  final String roleID;
  final String departmentID;

  SharedContactItem(
      this.id, this.userName, this.imageUrl, this.roleID, this.departmentID);

  @override
  State<SharedContactItem> createState() => _SharedContactItemState();
}

class _SharedContactItemState extends State<SharedContactItem> {
  @override
  Widget build(BuildContext context) {
    final role = Provider.of<RoleProvider>(context, listen: false)
        .findById(widget.roleID);
    final department = Provider.of<DepartmentProvider>(context, listen: false)
        .findById(widget.departmentID);
    return Dismissible(
      key: ValueKey(widget.id),
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
                'Do you want to remove this contact person from the contact list'),
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
        Provider.of<SharedContactListProvider>(context, listen: false)
            .deleteContactPerson(widget
                .id); //listen:false to set it as dont want it set permenant listener
      },
      child: ListTile(
       onTap: () => Navigator.pushNamed(context, ContactPersonDetailScreen.routeName,
                  arguments: widget.id),
        title: Text(widget.userName),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              role == null ? 'Role:-' : 'Role:' + role.roleName,
            ),
            Text(
              department == null
                  ? 'Department:-'
                  : 'Department:'+ department.departmentName,
            ),
          ],
        ),
        leading: widget.imageUrl.isEmpty
            ? CircleAvatar(
                backgroundColor: Theme.of(context).primaryColor,
                child: Text(
                  widget.userName[0].toUpperCase(),
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 28,
                  ),
                ),
              )
            : CircleAvatar(
                backgroundImage: NetworkImage(
                  widget.imageUrl,
                ),
              ),
        trailing: GestureDetector(
          onTap: () =>
              Navigator.pushNamed(context, EditContactPersonScreen.routeName,
              arguments: widget.id ),
          child: Icon(
            Icons.settings,
            color: Theme.of(context).primaryColor,
          ),
        ),
      ),
    );
  }
}
