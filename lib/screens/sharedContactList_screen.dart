import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:intl_phone_field/intl_phone_field.dart';

import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../providers/department_provider.dart';
import '../providers/personalContactList_provider.dart';
import '../providers/profile_provider.dart';
import '../providers/profile.dart';
import '../providers/role_provider.dart';
import '../providers/sharedContactList_provider.dart';

// import '../screens/viewContactPerson_screen.dart';
import '../screens/department_screen.dart';
import '../screens/role_screen.dart';

import '../widgets/app_drawer.dart';
import '../widgets/searchField.dart';
import '../widgets/personal_contact_item.dart';
import '../widgets/shared_contact_item.dart';

class SharedContactListScreen extends StatefulWidget {
  static const routeName = '/sharedContactList_page';

  @override
  State<SharedContactListScreen> createState() =>
      _SharedContactListScreenState();
}

class _SharedContactListScreenState extends State<SharedContactListScreen> {
  List<Profile> _contactPerson;
  String query = '';
  DateTime lastPressed;
  var _isInit = true;
  var _isLoading = false;
  final _phoneNumberFocusNode = FocusNode();
  final _form = GlobalKey<FormState>();
  var _filledData = '';
  var _editedProfile = '';
 

  @override
  void didChangeDependencies() {
    if (_isInit) {
      setState(() {
        _isLoading = true;
      });
 
      Provider.of<SharedContactListProvider>(context, listen: false)
          .fetchAndSetSharedContactList();

      _contactPerson =
          Provider.of<SharedContactListProvider>(context, listen: false)
              .sharedContactList;

      Provider.of<RoleProvider>(context, listen: false).fetchAndSetRoleList();
      Provider.of<DepartmentProvider>(context, listen: false)
          .fetchAndSetDepartmentList();
      setState(() {
        _isLoading = false;
      });
      _isInit = false;

      super.didChangeDependencies();
    }
  }

  @override
  void dispose() {
    _phoneNumberFocusNode.dispose();
    super.dispose();
  }

  void onSelected(BuildContext context, int item) {
    switch (item) {
      case 0:
        _openDialog();
        break;
      case 1:
        Navigator.pushNamed(context, RoleScreen.routeName);
        break;
      case 2:
        Navigator.pushNamed(context, DepartmentScreen.routeName);
        break;
    }
  }

  Future _openDialog() => showDialog(
        context: context,
        builder: (context) => AlertDialog(
          title: Text('Phone Number'),
          content: Column(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Form(
                key: _form,
                child: IntlPhoneField(
                  decoration: InputDecoration(
                    labelText: 'Phone Number',
                  ),
                  autofocus: true,
                  textInputAction: TextInputAction.done,
                  onSubmitted: (_) {
                    _saveForm();
                  },
                  initialValue:
                      _filledData.isEmpty ? null : _filledData.substring(2),
                  initialCountryCode: 'MY',
                  inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                  disableLengthCheck: true,
                  validator: (value) {
                    if (value.completeNumber.substring(1).isEmpty ||
                        value.completeNumber.substring(1).length < 10 ||
                        value.completeNumber.substring(1).length > 12) {
                      return 'Phone number must greater than 10 digits and lesser than 12';
                    }
                  },
                  onSaved: (value) {
                    _filledData = value.completeNumber.substring(1);
                  },
                ),
              ),
              ElevatedButton(
                onPressed: _saveForm,
                child: Text('Add New Contact Person'),
                style: ElevatedButton.styleFrom(
                  primary: Theme.of(context).primaryColor,
                  textStyle: TextStyle(fontSize: 20),
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
    print(_filledData);
    await Provider.of<SharedContactListProvider>(context, listen: false)
        .addContactPerson(_filledData);

    Navigator.of(context).pop();
    setState(() {
      _isLoading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    print(_contactPerson);
    return Scaffold(
      appBar: AppBar(
        title: Text('My-List'),
        backgroundColor: Theme.of(context).primaryColor,
        actions: [
          PopupMenuButton<int>(
            onSelected: (item) => onSelected(context, item),
            itemBuilder: (context) => [
              PopupMenuItem<int>(
                child: Text('Add Contact Person'),
                value: 0,
              ),
              PopupMenuItem<int>(
                child: Text('Roles'),
                value: 1,
              ),
              PopupMenuItem<int>(
                child: Text('Departments'),
                value: 2,
              ),
            ],
          ),
        ],
      ),

      drawer: AppDrawer(),
      body: _isLoading == true
          ? Center(
              child: CircularProgressIndicator(),
            )
          : WillPopScope(
              onWillPop: () async {
                final now = DateTime.now();
                final maxDuration = Duration(seconds: 2);
                final isWarning = lastPressed == null ||
                    now.difference(lastPressed) > maxDuration;
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
                    child: Consumer<SharedContactListProvider>(
                      builder: (context, _contactPerson, _) => ListView.builder(
                        itemCount: _contactPerson.sharedContactList.length,
                        itemBuilder: (_, index) => Column(
                          children: [
                            SharedContactItem(
                              _contactPerson.sharedContactList[index].id,
                              _contactPerson.sharedContactList[index].fullName,
                              _contactPerson.sharedContactList[index].imageUrl,
                              _contactPerson.sharedContactList[index].roleId,
                              _contactPerson
                                  .sharedContactList[index].departmentId,
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

  Widget buildSearch() => SearchField(
        text: query,
        hintText: 'Search by Contact Person Name',
        onChanged: searchContactPerson,
      );

  void searchContactPerson(String query) {
    print(query);
    Provider.of<SharedContactListProvider>(context, listen: false)
        .findByFullName(query.toLowerCase());
  }
}
