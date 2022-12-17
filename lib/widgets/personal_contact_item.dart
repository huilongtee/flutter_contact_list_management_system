import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_svg_provider/flutter_svg_provider.dart';
import 'package:flutter_svg/svg.dart';
import 'package:provider/provider.dart';
import '../providers/personalContactList_provider.dart';
import '../providers/profile_provider.dart';
import '../screens/contactPersonDetail.dart';
import '../screens/editContactPerson_screen.dart';
//launch phone call indirectly
import 'package:url_launcher/url_launcher.dart';
//launch phone call directly
import 'package:flutter_phone_direct_caller/flutter_phone_direct_caller.dart';
//launch map app
import 'package:maps_launcher/maps_launcher.dart';

class PersonalContactItem extends StatefulWidget {
  final String id;
  final String userName;
  final String imageUrl;
  final String phoneNumber;
  final String emailAddress;
  final String homeAddress;

  PersonalContactItem(this.id, this.userName, this.imageUrl, this.phoneNumber,
      this.emailAddress, this.homeAddress);

  @override
  State<PersonalContactItem> createState() => _PersonalContactItemState();
}

class _PersonalContactItemState extends State<PersonalContactItem> {
  void onLongerPress() {
    FlutterPhoneDirectCaller.callNumber(widget.phoneNumber);
  }

  void onShorterPress() {
    launchUrl(Uri(scheme: 'tel', path: widget.phoneNumber));
  }

  void openEmailApp() {
    launchUrl(Uri(scheme: 'mailTo', path: widget.emailAddress));
  }

  void openMapApp() {
    MapsLauncher.launchQuery(widget.homeAddress);
  }

  @override
  Widget build(BuildContext context) {
    return Dismissible(
      // key: ValueKey(widget.id),
      key: UniqueKey(),

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
              TextButton(
                child: Text('No'),
                onPressed: () {
                  Navigator.of(context).pop(false);
                },
              ),
              TextButton(
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
        onTap: () => Navigator.pushNamed(
            context, ContactPersonDetailScreen.routeName,
            arguments: widget.id),
        title: Text(widget.userName),
        leading: widget.imageUrl.isEmpty
            ? CircleAvatar(
                backgroundColor: Theme.of(context).primaryColor,
                child: Text(
                  widget.userName[0].toUpperCase(),
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 28,
                    color: Colors.white,
                  ),
                ),
              )
            : CircleAvatar(
                backgroundImage: NetworkImage(
                  widget.imageUrl,
                ),
              ),
        trailing: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            GestureDetector(
              onTap: () => onShorterPress(),
              onLongPress: () => onLongerPress(),
              child: Icon(
                Icons.phone,
                color: Theme.of(context).primaryColor,
              ),
            ),
            SizedBox(
              width: 20,
            ),
            GestureDetector(
              onTap: () => openEmailApp(),
              child: Icon(
                Icons.email,
                color: Theme.of(context).primaryColor,
              ),
            ),
            SizedBox(
              width: 20,
            ),
            GestureDetector(
              onTap: () => openMapApp(),
              child: Icon(
                Icons.maps_home_work,
                color: Theme.of(context).primaryColor,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
