import 'dart:convert';
import 'dart:io';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:grouped_list/grouped_list.dart';
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
import '../widgets/dialog.dart';
import '../widgets/searchField.dart';
import '../widgets/personal_contact_item.dart';
import '../widgets/shared_contact_item.dart';
import 'package:grouped_list/sliver_grouped_list.dart'; //group listview

class SharedContactListScreen extends StatefulWidget {
  static const routeName = '/sharedContactList_page';

  @override
  State<SharedContactListScreen> createState() =>
      _SharedContactListScreenState();
}

class _SharedContactListScreenState extends State<SharedContactListScreen> {
  List<Profile> _contactPerson;
  List<Department> _departments;
  List<Role> _roles;
  String query = '';
  DateTime lastPressed;
  var _isInit = true;
  var _isLoading = false;
  final _phoneNumberFocusNode = FocusNode();
  final _form = GlobalKey<FormState>();
  var _filledData = '';
  bool _isAdmin = false;
  // var _editedProfile = '';
  // List _mergedList;

  @override
  void didChangeDependencies() {
    if (_isInit) {
      setState(() {
        _isLoading = true;
      });
      //get the profile and check the company id is existed
      Provider.of<ProfileProvider>(
        context,
        listen: false,
      ).fetchAndSetProfile().then((_) {
        //get list
        final result = Provider.of<ProfileProvider>(
          context,
          listen: false,
        ).profile;
        //company id not existed
        if (result.first.companyId == null) {
          final FirebaseAuth auth = FirebaseAuth.instance;
          final User user = auth.currentUser;
          //check this user whether is the company admin of any company that haven't enabled
          Provider.of<SharedContactListProvider>(context, listen: false)
              .checkIsCompanyAdmin(
                  user.phoneNumber.toString().substring(1), result.first.id)
              .then((_) {
                Provider.of<DepartmentProvider>(context, listen: false)
                  .fetchAndSetDepartmentList()
                  .then((_) {
                _departments =
                    Provider.of<DepartmentProvider>(context, listen: false)
                        .departmentList;
                Provider.of<RoleProvider>(context, listen: false)
                    .fetchAndSetRoleList()
                    .then((_) {
                  _roles = Provider.of<RoleProvider>(context, listen: false)
                      .roleList;
                  Provider.of<RoleProvider>(context, listen: false)
                      .checkAdmin()
                      .then((_) {
                    _isAdmin = Provider.of<RoleProvider>(context, listen: false)
                        .isAdmin;
                    Provider.of<RoleProvider>(context, listen: false).roleList;
                  });
                });
              });
              });
        } else {
          Provider.of<SharedContactListProvider>(context, listen: false)
              .fetchAndSetSharedContactList()
              .then((_) {
            _contactPerson =
                Provider.of<SharedContactListProvider>(context, listen: false)
                    .sharedContactList;

            if (_contactPerson != null) {
              Provider.of<DepartmentProvider>(context, listen: false)
                  .fetchAndSetDepartmentList()
                  .then((_) {
                _departments =
                    Provider.of<DepartmentProvider>(context, listen: false)
                        .departmentList;
                Provider.of<RoleProvider>(context, listen: false)
                    .fetchAndSetRoleList()
                    .then((_) {
                  _roles = Provider.of<RoleProvider>(context, listen: false)
                      .roleList;
                  Provider.of<RoleProvider>(context, listen: false)
                      .checkAdmin()
                      .then((_) {
                    _isAdmin = Provider.of<RoleProvider>(context, listen: false)
                        .isAdmin;
                    Provider.of<RoleProvider>(context, listen: false).roleList;
                  });
                });
              });
            }
          });
        }
      });

      setState(() {
        _isLoading = false;
      });

      _isInit = false;

      super.didChangeDependencies();
    }
  }

  String displayDepartmentName(String id) {
    final name =
        Provider.of<DepartmentProvider>(context, listen: false).findById(id);
    return name.departmentName.toString();
  }

  // Map<String, dynamic> getList(
  //     String id,
  //     String companyId,
  //     String departmentId,
  //     String departmentName,
  //     String emailAddress,
  //     String fullName,
  //     String homeAddress,
  //     String imageUrl,
  //     String phoneNumber,
  //     String roleId) {
  //   final Map<String, dynamic> data = new Map<String, dynamic>();
  //   data["id"] = id;
  //   data["companyId"] = companyId;
  //   data["departmentId"] = departmentId;
  //   data["departmentName"] = departmentName;
  //   data["emailAddress"] = emailAddress;
  //   data["fullName"] = fullName;
  //   data["homeAddress"] = homeAddress;
  //   data["imageUrl"] = imageUrl;
  //   data["phoneNumber"] = phoneNumber;
  //   data["roleId"] = roleId;
  //   return data;
  // }

  @override
  void dispose() {
    _phoneNumberFocusNode.dispose();
    super.dispose();
  }

  void onSelected(BuildContext context, int item) {
    switch (item) {
      case 0:
        // _openDialog();
        _showBottomSheet();
        break;
      case 1:
        Navigator.pushNamed(context, RoleScreen.routeName);
        break;
      case 2:
        Navigator.pushNamed(context, DepartmentScreen.routeName);
        break;
    }
  }

  Future<String> _saveForm() async {
    setState(() {
      _isLoading = true;
    });
    final isValid = _form.currentState.validate(); //trigger all validator
    if (!isValid) {
      Navigator.of(context).pop();
      setState(() {
        _isLoading = false;
      });
      return 'Could not add the person'; //stop function
    }
    _form.currentState.save();

    try {
      final errMessage =
          await Provider.of<SharedContactListProvider>(context, listen: false)
              .addContactPerson(_filledData);

      Navigator.of(context).pop();

      setState(() {
        _isLoading = false;
      });
      return errMessage;
    } on HttpException catch (error) {
      return error.toString();
    } catch (error) {
      return error.toString();
    }
  }

//show bottom sheet start
  void _showBottomSheet() {
    showModalBottomSheet(
        context: context,
        builder: (BuildContext content) {
          return Card(
            elevation: 5,
            child: Container(
              padding: EdgeInsets.all(10),
              child: Column(
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
                    onPressed: () async {
                      String response = await _saveForm();

                      Dialogs.showMyDialog(context, response);
                    },
                    child: Text('Add New Contact Person'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Theme.of(context).primaryColor,
                      textStyle: TextStyle(fontSize: 20),
                    ),
                  ),
                ],
              ),
            ),
          );
        });
  }
//show bottom sheet end

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
          title: Text('Shared Contact List'),
          backgroundColor: Theme.of(context).primaryColor,
          actions: _isAdmin == true
              ? [
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
                ]
              : null),

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
              child: Container(
                decoration: BoxDecoration(
                  color: Colors.indigo[50],
                ),
                child: Column(children: [
                  buildSearch(),
                  Expanded(
                    child: Container(
                      padding:
                          EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                      child: Consumer<SharedContactListProvider>(
                        builder: (context, _contactPerson, _) =>
                            ListView.builder(
                          itemCount: _contactPerson.sharedContactList.length,
                          itemBuilder: (_, index) => Column(
                            children: [
                              SharedContactItem(
                                _contactPerson.sharedContactList[index].id,
                                _contactPerson
                                    .sharedContactList[index].fullName,
                                _contactPerson
                                    .sharedContactList[index].imageUrl,
                                _contactPerson.sharedContactList[index].roleId,
                                _contactPerson
                                    .sharedContactList[index].departmentId,
                                _isAdmin,
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ),

                  //grouped list, current bug is failed to assign department and role

                  //there is still having a bug, only refresh again then can generate grouped list
                  // Expanded(
                  //   child: GroupedListView<dynamic, String>(
                  //     groupComparator: (element1, element2) => element1.compareTo(element2),
                  //     useStickyGroupSeparators: true,
                  //     // elements: _contactPerson,
                  //     elements: _mergedList,

                  //     // groupBy: (Profile element) => element.departmentId == null
                  //     //     ? 'Other'
                  //     //     : displayDepartmentName(element.departmentId).toString(),
                  //      groupBy: ( item)=>item['departmentName'],
                  //     groupSeparatorBuilder: (value) => Container(
                  //       width: double.infinity,
                  //       padding: const EdgeInsets.all(15),
                  //       color: Colors.black,
                  //       child: Text(
                  //         value.toString(),
                  //         style: TextStyle(
                  //           color: Colors.white,
                  //         ),
                  //       ),
                  //     ),
                  //     itemBuilder: (context, element) => Column(
                  //       children: [
                  //         SharedContactItem(
                  //           element['id'],
                  //           element['fullName'],
                  //           element['imageUrl'],
                  //           element['roleID'],
                  //           element['departmentID'],

                  //           // element.id,
                  //           // element.fullName,
                  //           // element.imageUrl,
                  //           // element.roleId,
                  //           // element.departmentId,

                  //           // _contactPerson[element].id,
                  //           // _contactPerson[element].fullName,
                  //           // _contactPerson[element].imageUrl,
                  //           // _contactPerson[element].roleId,
                  //           // _contactPerson[element].departmentId,
                  //         ),
                  //         Divider(
                  //           thickness: 1,
                  //         ),
                  //       ],
                  //     ),
                  //   ),
                  // ),
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
