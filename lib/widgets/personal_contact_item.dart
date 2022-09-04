import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/profile_provider.dart';
import '../screens/editContactPerson_screen.dart';

class PersonalContactItem extends StatelessWidget {
  final String id;
  final String userName;
  final String imageUrl;

  PersonalContactItem(this.id, this.userName, this.imageUrl);
  @override
  Widget build(BuildContext context) {
    final scaffold = Scaffold.of(context);
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
        Provider.of<ProfileProvider>(context, listen: false).deleteContactPerson(
            id); //listen:false to set it as dont want it set permenant listener
      },
      child: ListTile(
        title: Text(userName),
        leading: CircleAvatar(
          backgroundImage: NetworkImage(
            imageUrl,
          ),
        ),
        trailing: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            IconButton(
              onPressed: null,
              icon: Icon(Icons.phone),
              color: Theme.of(context).primaryColor,
            ),
            IconButton(
              onPressed: null,
              icon: Icon(Icons.email),
              color: Colors.black,
            ),
            IconButton(
              onPressed: null,
              icon: Icon(Icons.maps_home_work),
              color: Theme.of(context).primaryColor,
            ),
          ],
        ),
      ),
    );
  }
}
