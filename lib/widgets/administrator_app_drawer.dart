import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../screens/administrator_screen.dart';
import '../screens/nfc_screen.dart';
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
          Padding(
            padding: const EdgeInsets.all(10),
            child: Column(
              children: [
               ListTile(
                  leading: Icon(
                    Icons.home_outlined,
                    color: Theme.of(context).secondaryHeaderColor,
                    size: 26,
                  ),
                  title: Text('Home'),
                  onTap: () {
                    Navigator.of(context)
                        .pushReplacementNamed(AdministratorScreen.routeName);
                  },
                ),
                Divider(
                  thickness: 2,
                ),
                ListTile(
                  leading: Icon(
                    Icons.credit_card,
                    color: Theme.of(context).secondaryHeaderColor,
                    size: 26,
                  ),
                  title: Text('NFCs Requests'),
                  onTap: () {
                    Navigator.of(context)
                        .pushReplacementNamed(NFCScreen.routeName);
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
                    // Provider.of<AuthProvider>(context, listen: false).logout();
                    Provider.of<AuthProvider>(context, listen: false).signOut();
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
