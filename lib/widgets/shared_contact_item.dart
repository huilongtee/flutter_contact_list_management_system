import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_svg_provider/flutter_svg_provider.dart';
import 'package:flutter_svg/svg.dart';
import 'package:provider/provider.dart';
import '../providers/personalContactList_provider.dart';
import '../providers/profile_provider.dart';
import '../screens/editContactPerson_screen.dart';


class SharedContactItem extends StatefulWidget {
  final String id;
  final String userName;
  final String imageUrl;
 

  SharedContactItem(this.id, this.userName, this.imageUrl);

  @override
  State<SharedContactItem> createState() => _SharedContactItemState();
}

class _SharedContactItemState extends State<SharedContactItem> {
  
 
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
        Provider.of<PersonalContactListProvider>(context, listen: false)
            .deleteContactPerson(widget
                .id); //listen:false to set it as dont want it set permenant listener
      },
      child: ListTile(
        title: Text(widget.userName),
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
              ),
        
         
       
    );
  }
}
