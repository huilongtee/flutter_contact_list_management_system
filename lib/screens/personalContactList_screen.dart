import 'package:flutter/material.dart';

import '../screens/viewContactPerson_screen.dart';

import 'package:provider/provider.dart';
import '../widgets/app_drawer.dart';
import '../providers/personalContactList_provider.dart';
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
  List<Profile> _contactPerson;
  String query = '';
  // PersonalContactListProvider personalContactPersonProvider = null;
  DateTime lastPressed;
  final _phoneNumberFocusNode = FocusNode();
  var _isLoading = false;
  final _form = GlobalKey<FormState>();
  var _filledData = '';
  var _isInit = true;
  var _editedProfile = '';
  @override
  void didChangeDependencies() {
    if (_isInit) {
      setState(() {
        _isLoading = true;
      });
      Provider.of<PersonalContactListProvider>(context)
          .fetchAndSetPersonalContactList();
      
      setState(() {
        _isLoading = false;
      });
      _isInit = false;

      // final loadedProfile = profileProvider.profile;
      // contactPerson = loadedProfile;

      super.didChangeDependencies();
    }
  }

  @override
  void dispose() {
    _phoneNumberFocusNode.dispose();
    super.dispose();
  }

  Future _openDialog() => showDialog(
        context: context,
        builder: (context) => AlertDialog(
          title: Text('Phone Number'),
          content: Column(
            children: [
              Form(
                key: _form,
                child: TextFormField(
                  autofocus: true,
                  initialValue: _filledData,
                  decoration: InputDecoration(labelText: 'Phone Number'),
                  textInputAction: TextInputAction.done,
                  onFieldSubmitted: (_) {
                    _saveForm();
                  },
                  validator: (value) {
                    // return null;//it means no problem
                    if (value.isEmpty) {
                      return 'Please provide a value';
                    }

                    return null;
                  },
                  onSaved: (value) {
                    _filledData = value;
                  },
                ),
              ),
              Container(
                child: ElevatedButton(
                  onPressed: _saveForm,
                  child: Text('Add New Contact Person'),
                  style: ElevatedButton.styleFrom(
                    primary: Theme.of(context).primaryColor,
                    textStyle: TextStyle(fontSize: 20),
                  ),
                ),
              ),
            ],
          ),
        ),
      );

  Future<void> _saveForm() async {
    final isValid = _form.currentState.validate(); //trigger all validator
    if (!isValid) {
      return; //stop function
    }
    _form.currentState.save();
    setState(() {
      _isLoading = true;
    });

    await Provider.of<PersonalContactListProvider>(context, listen: false)
        .addContactPerson(_filledData);

    Navigator.of(context).pop();
    setState(() {
      _isLoading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    _contactPerson =
          Provider.of<PersonalContactListProvider>(context).personalContactList;
      print(_contactPerson);
    return Scaffold(
      appBar: AppBar(
        title: Text('My-List'),
        backgroundColor: Theme.of(context).primaryColor,
        actions: [
          IconButton(
            onPressed: () {
              // profileProvider.addContactPerson();
              _openDialog();
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
            // buildSearch(),
            Expanded(
              child: Consumer<PersonalContactListProvider>(
                builder: (context, _contactPerson, _) => ListView.builder(
                  itemCount: _contactPerson.personalContactList.length,
                  itemBuilder: (_, index) => Column(
                    children: [
                      PersonalContactItem(
                        _contactPerson.personalContactList[index].id,
                        _contactPerson.personalContactList[index].fullName,
                        _contactPerson.personalContactList[index].imageUrl,
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
      ),
      //
    );
  }

  // Widget buildSearch() => SearchField(
  //       text: query,
  //       hintText: 'Search by Contact Person Name',
  //       onChanged: searchContactPerson,
  //     );

  // void searchContactPerson(String query) {
  //   setState(() {
  //     _contactPerson = profileProvider.findByFullName(query);
  //   });
  // }
}
