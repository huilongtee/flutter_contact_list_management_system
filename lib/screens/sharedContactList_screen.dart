// import 'dart:convert';
// import '../providers/personalContactList_provider.dart';
// import 'package:grouped_list/grouped_list.dart';
// import 'package:shared_preferences/shared_preferences.dart';
// import '../screens/viewContactPerson_screen.dart';
// import '../widgets/personal_contact_item.dart';
// import 'package:grouped_list/sliver_grouped_list.dart'; //group listview

import 'dart:convert';
import 'dart:io';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:intl_phone_field/intl_phone_field.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:nfc_manager/nfc_manager.dart';
import 'package:provider/provider.dart';

import '../providers/department_provider.dart';
import '../providers/profile_provider.dart';
import '../providers/profile.dart';
import '../providers/role_provider.dart';
import '../providers/sharedContactList_provider.dart';

import '../screens/department_screen.dart';
import '../screens/role_screen.dart';

import '../widgets/app_drawer.dart';
import '../widgets/dialog.dart';
import '../widgets/searchField.dart';
import '../widgets/shared_contact_item.dart';

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
  bool isNfcAvalible = false;
  bool listenerRunning = false;

  @override
  void didChangeDependencies() {
    if (_isInit) {
      setState(() {
        _isLoading = true;
        print('_isLoading');
        print(_isLoading);
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

        Profile loadedProfile = Provider.of<ProfileProvider>(
          context,
          listen: false,
        ).findById(result.first.id);
        if (loadedProfile.companyId == null) {
          print('null');
        }
        //company id not existed
        print('the company id is' + loadedProfile.companyId);
        if (loadedProfile.companyId.isEmpty) {
          print('enter company id = null');
          final FirebaseAuth auth = FirebaseAuth.instance;
          final User user = auth.currentUser;
          //check this user whether is the company admin of any company that haven't enabled
          Provider.of<SharedContactListProvider>(context, listen: false)
              .checkIsCompanyAdmin(
                  user.phoneNumber.toString().substring(1), loadedProfile.id)
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
                _roles =
                    Provider.of<RoleProvider>(context, listen: false).roleList;
                Provider.of<RoleProvider>(context, listen: false)
                    .checkAdmin()
                    .then((_) {
                  _isAdmin =
                      Provider.of<RoleProvider>(context, listen: false).isAdmin;
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

            Provider.of<DepartmentProvider>(context, listen: false)
                .fetchAndSetDepartmentList()
                .then((_) {
              _departments =
                  Provider.of<DepartmentProvider>(context, listen: false)
                      .departmentList;
              Provider.of<RoleProvider>(context, listen: false)
                  .fetchAndSetRoleList()
                  .then((_) {
                _roles =
                    Provider.of<RoleProvider>(context, listen: false).roleList;
                Provider.of<RoleProvider>(context, listen: false)
                    .checkAdmin()
                    .then((_) {
                  _isAdmin =
                      Provider.of<RoleProvider>(context, listen: false).isAdmin;
                  print('_isAdmin');
                  print(_isAdmin);
                });
              });
            });
          });
        }
      });
      checkISNFCAvailable();
      setState(() {
        _isLoading = false;
        print('_isLoading');
        print(_isLoading);
      });
      _isInit = false;
    }

    super.didChangeDependencies();
  }

  void checkISNFCAvailable() async {
    isNfcAvalible = await NfcManager.instance.isAvailable();
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

  void onSelected(BuildContext context, int item) async {
    switch (item) {
      case 0:
        // _openDialog();
        _showBottomSheetForPhoneNo();
        break;
      case 1:
        _showBottomSheetForNFC();
        String errMessage = await _listenForNFCEvents();

        if (errMessage != null) {
          Dialogs.showMyDialog(context, errMessage);
        }
        break;
      case 2:
        Navigator.pushNamed(context, RoleScreen.routeName);
        break;
      case 3:
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
  void _showBottomSheetForPhoneNo() {
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

//add by nfc
  void _showBottomSheetForNFC() {
    showModalBottomSheet(
        context: context,
        builder: (BuildContext content) {
          return Card(
            elevation: 5,
            child: Container(
                padding: EdgeInsets.all(10),
                child: Center(
                  child: _getNfcWidgets(),
                )),
          );
        });
  }

  Widget _getNfcWidgets() {
    if (isNfcAvalible) {
      return Text('Please tag the NFC card too add new contact person');
    } else {
      if (Platform.isIOS) {
        //Ios doesnt allow the user to turn of NFC at all,  if its not avalible it means its not build in
        return const Text("Your device doesn't support NFC");
      } else {
        //Android phones can turn of NFC in the settings
        return const Text(
            "Your device doesn't support NFC or it's turned off in the system settings");
      }
    }
  }

  //Helper method to show a quick message
  void _alert(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          message,
        ),
        duration: const Duration(
          seconds: 2,
        ),
      ),
    );
  }

  Future<String> _listenForNFCEvents() async {
    //Always run this for ios but only once for android
    if (Platform.isAndroid && listenerRunning == false || Platform.isIOS) {
      //Android supports reading nfc in the background, starting it one time is all we need
      if (Platform.isAndroid) {
        _alert(
          'NFC listener running in background now, approach tag(s)',
        );
        //Update button states
        setState(() {
          listenerRunning = true;
        });
      }

      NfcManager.instance.startSession(
        onDiscovered: (NfcTag tag) async {
          bool succses = false;
          //Try to convert the raw tag data to NDEF
          final ndefTag = Ndef.from(tag);
          //If the data could be converted we will get an object
          if (ndefTag != null) {
            // If we want to write the current counter vlaue we will replace the current content on the tag

            //The NDEF Message was already parsed, if any
            if (ndefTag.cachedMessage != null) {
              var ndefMessage = ndefTag.cachedMessage;
              //Each NDEF message can have multiple records, we will use the first one in our example
              if (ndefMessage.records.isNotEmpty &&
                  ndefMessage.records.first.typeNameFormat ==
                      NdefTypeNameFormat.nfcWellknown) {
                //If the first record exists as 1:Well-Known we consider this tag as having a value for us
                final wellKnownRecord = ndefMessage.records.first;

                ///Payload for a 1:Well Known text has the following format:
                ///[Encoding flag 0x02 is UTF8][ISO language code like en][content]

                if (wellKnownRecord.payload.first == 0x02) {
                  //Now we know the encoding is UTF8 and we can skip the first byte
                  final languageCodeAndContentBytes =
                      wellKnownRecord.payload.skip(1).toList();
                  //Note that the language code can be encoded in ASCI, if you need it be carfully with the endoding
                  final languageCodeAndContentText =
                      utf8.decode(languageCodeAndContentBytes);
                  //Cutting of the language code
                  final payload = languageCodeAndContentText.substring(2);
                  //Parsing the content to string
                  // final storedCounters = int.tryParse(payload);
                  final storedContactPersonID = payload.toString();
                  if (storedContactPersonID != null) {
                    succses = true;

                    try {
                      setState(() {
                        _isLoading = true;
                      });
                      final errMessage =
                          await Provider.of<SharedContactListProvider>(context,
                                  listen: false)
                              .addContactPersonByContactPersonID(
                                  storedContactPersonID);
                      setState(() {
                        _isLoading = false;
                      });

                      Navigator.of(context).pop();

                      return errMessage;
                    } on HttpException catch (error) {
                      return error.toString();
                    } catch (error) {
                      return error.toString();
                    }
                  }
                }
              }
            }
          }

          //Due to the way ios handles nfc we need to stop after each tag
          if (Platform.isIOS) {
            NfcManager.instance.stopSession();
          }
          if (succses == false) {
            _alert(
              'Tag was not valid',
            );
          }
        },
        // Required for iOS to define what type of tags should be noticed
        pollingOptions: {
          NfcPollingOption.iso14443,
          NfcPollingOption.iso15693,
        },
      );
    }
    return null;
  }

  @override
  Widget build(BuildContext context) {
    if (_isAdmin == true) {
      print('it is th admin');
    } else {
      print('it is not admin');
    }
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
                        child: Text('Add Contact Person By Phone Number'),
                        value: 0,
                      ),
                      PopupMenuItem<int>(
                        child: Text('Add Contact Person By NFC Card'),
                        value: 1,
                      ),
                      PopupMenuItem<int>(
                        child: Text('Roles'),
                        value: 2,
                      ),
                      PopupMenuItem<int>(
                        child: Text('Departments'),
                        value: 3,
                      ),
                    ],
                  ),
                ]
              : null),

      drawer: AppDrawer(),
      body: _isLoading == true
          ? Center(
              // child: CircularProgressIndicator(),
              child: SpinKitDoubleBounce(
                color: Theme.of(context).primaryColor,
                size: 100,
              ),
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
                          itemBuilder: (_, index) {
                            final sortedItem = _contactPerson.sharedContactList
                              ..sort((item1, item2) =>
                                  item1.fullName.compareTo(item2.fullName));
                            final item = sortedItem[index];
                            return Column(
                              children: [
                                SharedContactItem(
                                  // _contactPerson
                                  //     .sharedContactList[index].id,
                                  // _contactPerson
                                  //     .sharedContactList[index].fullName,
                                  // _contactPerson
                                  //     .sharedContactList[index].imageUrl,
                                  // _contactPerson
                                  //     .sharedContactList[index].roleId,
                                  // _contactPerson.sharedContactList[index]
                                  //     .departmentId,
                                  // _isAdmin,
                                  item.id,
                                  item.fullName,
                                  item.imageUrl,
                                  item.roleId,
                                  item.departmentId,
                                  _isAdmin,
                                ),
                              ],
                            );
                          },
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
