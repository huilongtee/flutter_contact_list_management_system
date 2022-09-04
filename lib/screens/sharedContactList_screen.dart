import 'dart:convert';
import 'package:flutter/material.dart';
import '../screens/viewContactPerson_screen.dart';
import 'editProfile_screen.dart';
import '../widgets/app_drawer.dart';

import 'package:provider/provider.dart';
import '../providers/sharedContactList_provider.dart';
import '../providers/profile_provider.dart';

import '../providers/profile.dart';
import '../widgets/shared_contact_item.dart';
import '../widgets/searchField.dart';

class SharedContactListScreen extends StatefulWidget {
  static const routeName = '/sharedContactList_page';
final String userID;

  SharedContactListScreen(this.userID);
  @override
  State<SharedContactListScreen> createState() => _SharedContactListScreenState();
}

class _SharedContactListScreenState extends State<SharedContactListScreen> {
  List<Profile> contactPerson;
  String query = '';
  ProfileProvider profileProvider = null;

  @override
  void didChangeDependencies() {
    final sList = Provider.of<SharedContactListProvider>(
      context,
      listen: false,
    );
    profileProvider = Provider.of<ProfileProvider>(
      context,
      listen: false,
    );

    

    super.didChangeDependencies();
  }

  @override
  Widget build(BuildContext context) {
    // final userId = ModalRoute.of(context).settings.arguments as String;

    return Scaffold(
      appBar: AppBar(
        title: Text('My-List'),
        backgroundColor: Theme.of(context).primaryColor,
        actions: [
          IconButton(
            onPressed: () {
              // profileProvider.addContactPerson();
            },
            icon: Icon(Icons.add),
          ),
        ],
      ),

      drawer: AppDrawer(),
      body: Padding(
        padding: const EdgeInsets.all(5.0),
        child: Column(children: [
          buildSearch(),
          Expanded(
            child: Consumer<SharedContactListProvider>(
              builder: (ctx, contactPersonData, _) => ListView.builder(
                itemCount: contactPersonData.companies.length,
                itemBuilder: (context, index) => Column(
                  children: [
                    SharedContactItem(
                      contactPersonData.companies[index].id,
                      contactPersonData.companies[index].companyId,
                      contactPersonData.companies[index].contactPersonId,
               
                    ),
                    Divider(
                      thickness: 1,
                    ),
                  ],
                ),
              ),
            ),
          ),
        ]),
      ),
      //
    );
  }

  Widget buildSearch() => SearchField(
        text: query,
        hintText: 'Search by Contact Person Name',
        onChanged: searchContactPerson,
      );

  void searchContactPerson(String query) {
    setState(() {
      contactPerson = profileProvider.findByFullName(query);
    });
  }
}
