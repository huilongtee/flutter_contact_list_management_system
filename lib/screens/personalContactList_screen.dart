import 'package:flutter/material.dart';
import '../screens/viewContactPerson_screen.dart';
import 'editProfile_screen.dart';

import '../widgets/app_drawer.dart';
import 'package:provider/provider.dart';
import '../providers/profile_provider.dart';
import '../providers/profile.dart';
import '../widgets/personal_contact_item.dart';
import '../widgets/searchField.dart';

class PersonalContactListScreen extends StatefulWidget {
  static const routeName = '/personalContactList_page';

  @override
  State<PersonalContactListScreen> createState() =>
      _PersonalContactListScreenState();
}

class _PersonalContactListScreenState extends State<PersonalContactListScreen> {
  List<Profile> contactPerson;
  String query = '';
  ProfileProvider profileProvider = null;
  DateTime lastPressed;
  @override
  void didChangeDependencies() {
    profileProvider = Provider.of<ProfileProvider>(context);
    final loadedProfile = profileProvider.profile;
    contactPerson = loadedProfile;

    super.didChangeDependencies();
  }

  @override
  Widget build(BuildContext context) {
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
      body: WillPopScope(
        onWillPop: () async {
          final now = DateTime.now();
          final maxDuration = Duration(seconds: 2);
          final isWarning =
              lastPressed == null || now.difference(lastPressed) > maxDuration;
          if (isWarning) {
            lastPressed = DateTime.now();
            final snackBar = SnackBar(
              content: Text('Tap again to close app'),
              duration: maxDuration,
            );

            ScaffoldMessenger.of(context)
              ..removeCurrentSnackBar()
              ..showSnackBar(snackBar);
            return false;
          } else {
            return true;
          }
        },
        child: Padding(
          padding: const EdgeInsets.all(5.0),
          child: Column(children: [
            buildSearch(),
            Expanded(
              child: Consumer<ProfileProvider>(
                builder: (context, contactPersonData, _) => ListView.builder(
                  itemCount: contactPersonData.profile.length,
                  itemBuilder: (_, index) => Column(
                    children: [
                      // PersonalContactItem(
                      //   contactPersonData.profile[index].id,
                      //   contactPersonData.profile[index].fullName,
                      //   contactPersonData.profile[index].imageUrl,
                      // ),
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
