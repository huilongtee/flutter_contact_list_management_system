import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/profile_provider.dart';
import '../providers/sharedContactList_provider.dart';
import '../providers/company_provider.dart';
import '../providers/role_provider.dart';
import '../providers/department_provider.dart';
import '../screens/editContactPerson_screen.dart';

class SharedContactItem extends StatefulWidget {
  final String id;
  final String companyId;
  final String contactPersonId;

  SharedContactItem(this.id, this.companyId, this.contactPersonId);

  @override
  State<SharedContactItem> createState() => _SharedContactItemState();
}

class _SharedContactItemState extends State<SharedContactItem> {
  String imageUrl = '';
  String contactPersonName = '';
  String roleName = '';
  String departmentName = '';

  @override
  void didChangeDependencies() {
   final loadedProfile = Provider.of<ProfileProvider>(
      context,
    ).findById('1');
    imageUrl = loadedProfile.imageUrl;
    contactPersonName = loadedProfile.fullName;
    final role = Provider.of<RoleProvider>(
      context,
      listen: false,
    ).findByRoleId(loadedProfile.roleId);
    roleName = role.roleName;
    final department = Provider.of<DepartmentProvider>(
      context,
      listen: false,
    ).findByDepartmentId(loadedProfile.departmentId);
    departmentName = department.departmentName;
    super.didChangeDependencies();
  }

  @override
  Widget build(BuildContext context) {
    final scaffold = Scaffold.of(context);
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
        // Provider.of<ProfileProvider>(context, listen: false)
        //     .deleteContactPerson(widget
        //         .contactPersonId); //listen:false to set it as dont want it set permenant listener
      },
      child: ListTile(
        leading: CircleAvatar(
          backgroundImage: NetworkImage(
            imageUrl,
          ),
        ),
        title: Text(contactPersonName),
        subtitle: Text(roleName + ' in ' + departmentName),
        trailing: IconButton(
          onPressed: () {
            // Navigator.pushNamed(context, EditContactPersonScreen.routeName,
            //     arguments: widget.contactPersonId);
          },
          icon: Icon(Icons.edit),
          color: Theme.of(context).primaryColor,
        ),
      ),
    );
  }
}
