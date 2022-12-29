import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../screens/profile_screen.dart';
import '../screens/personalContactList_screen.dart';
import '../screens/sharedContactList_screen.dart';
import '../providers/auth_provider.dart';

class AdministratorAppDrawer extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Drawer(
      child: Column(
        children: [
          AppBar(
            title: Text('Hello Administrator'),
            automaticallyImplyLeading: false,
            backgroundColor: Theme.of(context).primaryColor,
          ),
          
          ListTile(
            leading: Icon(Icons.exit_to_app),
            title: Text('Logout'),
            onTap: () {
              Navigator.of(context).pop();
              Navigator.of(context).pushReplacementNamed('/');
              Provider.of<AuthProvider>(context, listen: false).signOut();
            },
          ),
        ],
      ),
    );
  }
}
