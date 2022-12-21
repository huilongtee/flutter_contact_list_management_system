import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../providers/profile_provider.dart';
import '../screens/profile_screen.dart';
import '../screens/personalContactList_screen.dart';
import '../screens/sharedContactList_screen.dart';
import '../providers/auth_provider.dart';

class AppDrawer extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Drawer(
      child: Column(
        children: [
          AppBar(
            title: Text(
              'My-List',
              style: TextStyle(color: Colors.white),
            ),
            automaticallyImplyLeading: false,
            backgroundColor: Theme.of(context).primaryColor,
          ),
          // Divider(),
          // ListTile(
          //   leading: Icon(Icons.home),
          //   title: Text('Home'),
          //   onTap: () {
          //     Navigator.of(context).pushReplacementNamed('/');
          //   },
          // ),
          Padding(
            padding: const EdgeInsets.all(10),
            child: Column(
              children: [
                ListTile(
                  leading: Icon(
                    Icons.person_outline_rounded,
                    color: Theme.of(context).secondaryHeaderColor,
                    size: 26,
                  ),
                  title: Text('Personal Contact List'),
                  onTap: () {
                    Navigator.of(context).pushReplacementNamed(
                        PersonalContactListScreen.routeName);
                  },
                ),
                Divider(
                  thickness: 2,
                ),
                ListTile(
                  leading: Icon(
                    Icons.groups_outlined,
                    color: Theme.of(context).secondaryHeaderColor,
                    size: 26,
                  ),
                  title: Text('Company Contact List'),
                  onTap: () {
                    Navigator.of(context).pushReplacementNamed(
                        SharedContactListScreen.routeName);
                  },
                ),
                Divider(
                  thickness: 2,
                ),
                ListTile(
                  leading: Icon(
                    Icons.contact_mail_outlined,
                    color: Theme.of(context).secondaryHeaderColor,
                    size: 26,
                  ),
                  title: Text('Profile'),
                  onTap: () {
                    Navigator.of(context)
                        .pushReplacementNamed(ProfileScreen.routeName);
                  },
                ),
                Divider(
                  thickness: 2,
                ),
                ListTile(
                  leading: Icon(
                    Icons.exit_to_app,
                    color: Colors.red,
                    size: 26,
                  ),
                  title: Text('Logout'),
                  onTap: () {
                    Navigator.of(context).pop();
                    Navigator.of(context).pushReplacementNamed('/');
                    Provider.of<AuthProvider>(context, listen: false).logout();
                  },
                ),
              ],
            ),
          )
        ],
      ),
    );
  }
}
