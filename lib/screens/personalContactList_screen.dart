//this do not have az listview

import 'dart:convert';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_contact_list_management_system/main.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:nfc_manager/nfc_manager.dart';
// import '../screens/viewContactPerson_screen.dart';
import 'package:intl_phone_field/intl_phone_field.dart';

import 'package:provider/provider.dart';
import '../models/http_exception.dart';

import '../providers/personalContactList_provider.dart';
import '../providers/profile_provider.dart';

import '../providers/profile.dart';
import '../widgets/personal_contact_item.dart';
import '../widgets/searchField.dart';
import '../widgets/dialog.dart';
import '../widgets/app_drawer.dart';

// class _KIndexBar extends ISuspensionBean {
//   final String tag;
//   _KIndexBar({this.tag});

//   @override
//   String getSuspensionTag() => tag;
// }

class PersonalContactListScreen extends StatefulWidget {
  static const routeName = '/personalContactList_page';

  @override
  State<PersonalContactListScreen> createState() =>
      _PersonalContactListScreenState();
}

class _PersonalContactListScreenState extends State<PersonalContactListScreen> {
  List<Profile> _contactPerson;

  String query = '';
  PersonalContactListProvider personalContactPersonProvider;
  DateTime lastPressed;

  var _isLoading = false;
  final _form = GlobalKey<FormState>();
  var _filledData = '';
  var _isInit = true;
  // List<AZItem> items = [];
  // List<AZItem> _backupList = [];
  // List<_KIndexBar> kIndexBar = [];
  Profile loadedProfileResult = null;
  bool listenerRunning = false;
  @override
  void didChangeDependencies() {
    if (_isInit) {
      setState(() {
        _isLoading = true;
      });
      Provider.of<ProfileProvider>(
        context,
        listen: false,
      ).fetchAndSetProfile().then((_) {
        Provider.of<PersonalContactListProvider>(context, listen: false)
            .fetchAndSetPersonalContactList()
            .then((_) {
          _contactPerson =
              Provider.of<PersonalContactListProvider>(context, listen: false)
                  .personalContactList;
          //get list
          final result = Provider.of<ProfileProvider>(
            context,
            listen: false,
          ).profile;
          //filter list using first item in list
          final loadedProfile = Provider.of<ProfileProvider>(
            context,
            listen: false,
          ).findById(result[0].id);
          loadedProfileResult = Profile(
            id: loadedProfile.id,
            companyId: loadedProfile.companyId,
            fullName: loadedProfile.fullName,
            emailAddress: loadedProfile.emailAddress,
            homeAddress: loadedProfile.homeAddress,
            phoneNumber: loadedProfile.phoneNumber,
            roleId: loadedProfile.roleId,
            departmentId: loadedProfile.departmentId,
            imageUrl: loadedProfile.imageUrl,
            qrUrl: loadedProfile.qrUrl,
          );
        });
        setState(() {
          _isLoading = false;
        });
        // convertToISuspensionList(_contactPerson);
        // generateKIndexBar(kIndexBarData);
      });

      _isInit = false;

      super.didChangeDependencies();
    }
  }

  void onSelected(BuildContext context, int item) {
    switch (item) {
      case 0:
        // _openDialog();
        _showBottomSheetForPhoneNo();
        break;
      case 1:
        _listenForNFCEvents();
        _showBottomSheetForNFC();

        break;
    }
  }

  // void didChangeDependencies() {
  //   if (_isInit) {
  //     setState(() {
  //       _isLoading = true;
  //     });

  //     Provider.of<PersonalContactListProvider>(context)
  //         .fetchAndSetPersonalContactList()
  //         .then((_) {
  //       _contactPerson =
  //           Provider.of<PersonalContactListProvider>(context, listen: false)
  //               .personalContactList;

  //       convertToISuspensionList(_contactPerson);
  //       // generateKIndexBar(kIndexBarData);
  //     });

  //     setState(() {
  //       _isLoading = false;
  //     });
  //     _isInit = false;

  //     super.didChangeDependencies();
  //   }
  // }

  // void convertToISuspensionList(List<Profile> items) {
  //   print('entered');
  //   this.items = items
  //       .map((item) => AZItem(
  //             title: item.fullName,
  //             tag: item.fullName[0].toUpperCase(),
  //             id: item.id,
  //             fullName: item.fullName,
  //             imageUrl: item.imageUrl,
  //             phoneNumber: item.phoneNumber,
  //             emailAddress: item.emailAddress,
  //             homeAddress: item.homeAddress,
  //           ))
  //       .toList();

  //   SuspensionUtil.sortListBySuspensionTag(this.items);
  //   SuspensionUtil.setShowSuspensionStatus(this.items);
  //   setState(() {});
  // }

  // void generateKIndexBar(List<String> kIndexBarItems) {
  //   this.kIndexBar = kIndexBarItems
  //       .map((item) => _KIndexBar(
  //             tag: item,
  //           ))
  //       .toList();
  //   SuspensionUtil.sortListBySuspensionTag(this.kIndexBar);
  //   SuspensionUtil.setShowSuspensionStatus(this.kIndexBar);
  //   setState(() {});
  // }

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
          await Provider.of<PersonalContactListProvider>(context, listen: false)
              .addContactPerson(_filledData, loadedProfileResult);

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
                      onSubmitted: (_) async {
                        String response = await _saveForm();

                        if (response.isNotEmpty) {
                          Dialogs.showMyDialog(context, response);
                        }
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
                        print(value);
                        _filledData = value.completeNumber.substring(1);
                      },
                    ),
                  ),
                  ElevatedButton(
                    onPressed: () async {
                      String response = await _saveForm();
                      if (response.isNotEmpty) {
                        Dialogs.showMyDialog(context, response);
                      }
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

  // Widget buildHeader(String tag) => Container(
  //       height: 40,
  //       margin: EdgeInsets.only(
  //         right: 16,
  //       ),
  //       padding: EdgeInsets.only(
  //         left: 16,
  //       ),
  //       color: Colors.grey.shade300,
  //       alignment: Alignment.centerLeft,
  //       child: Text(
  //         '$tag',
  //         softWrap: false,
  //         style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
  //       ),
  //     );

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

  Future<void> _listenForNFCEvents() async {
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
      final errMessage =
          await Provider.of<PersonalContactListProvider>(context, listen: false)
              .addContactPersonByContactPersonID(storedContactPersonID,loadedProfileResult);

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
  }

  @override
  void dispose() {
    try {
      NfcManager.instance.stopSession();
    } catch (err) {
      print(err);
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Personal Contact List',
          style: TextStyle(
            // color: Theme.of(context).textTheme.bodyText1.color,
            color: Colors.white,
          ),
        ),
        backgroundColor: Theme.of(context).primaryColor,
        actions: [
          PopupMenuButton<int>(
            onSelected: (item) => onSelected(context, item),
            itemBuilder: (context) => [
              PopupMenuItem<int>(
                child: Text('Add By Phone Number'),
                value: 0,
              ),
              PopupMenuItem<int>(
                child: Text('Add By Tapping NFC Card'),
                value: 1,
              ),
            ],
          ),
          // IconButton(
          //   onPressed: () {
          //     // profileProvider.addContactPerson();
          //     // _openDialog();
          //     _showBottomSheet();
          //     // _showErrorDialog('error');
          //   },
          //   icon: Icon(Icons.add),
          //   // color: Theme.of(context).textTheme.bodyText1.color,
          //   // color: Theme.of(context).secondaryHeaderColor,
          //   color: Colors.white,
          // ),
        ],
      ),
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
                      child: Consumer<PersonalContactListProvider>(
                        builder: (context, _contactPerson, _) =>
                            ListView.builder(
                          itemCount: _contactPerson.personalContactList.length,
                          itemBuilder: (_, index) => Column(
                            children: [
                              PersonalContactItem(
                                _contactPerson.personalContactList[index].id,
                                _contactPerson
                                    .personalContactList[index].fullName,
                                _contactPerson
                                    .personalContactList[index].imageUrl,
                                _contactPerson
                                    .personalContactList[index].phoneNumber,
                                _contactPerson
                                    .personalContactList[index].emailAddress,
                                _contactPerson
                                    .personalContactList[index].homeAddress,
                              ),
                              // Divider(
                              //   thickness: 1,
                              // ),
                            ],
                          ),
                        ),
                      ),
                    ),

                    // child: LayoutBuilder(
                    //   builder:
                    //       (BuildContext context, BoxConstraints constraints) {
                    //     return AzListView(
                    //       data: items,
                    //       itemCount: items.length,
                    //       itemBuilder: (context, index) {
                    //         final item = items[index];
                    //         final tag = item.getSuspensionTag();
                    //         final offstage = !item.isShowSuspension;

                    //         return Column(
                    //           children: [
                    //             Offstage(
                    //               offstage: offstage,
                    //               child: buildHeader(tag),
                    //             ),

                    //             Container(
                    //               margin: EdgeInsets.only(
                    //                 right: 15,
                    //               ),
                    //               child: PersonalContactItem(
                    //                 item.id,
                    //                 item.fullName,
                    //                 item.imageUrl,
                    //                 item.phoneNumber,
                    //                 item.emailAddress,
                    //                 item.homeAddress,
                    //               ),
                    //             ),
                    //             // Divider(
                    //             //   thickness: 1,
                    //             // ),
                    //           ],
                    //         );
                    //       },
                    //       indexBarData:
                    //           constraints.maxHeight > 400 ? kIndexBarData : [],
                    //       indexHintBuilder: (context, hint) => Container(
                    //         alignment: Alignment.center,
                    //         child: Text(
                    //           hint,
                    //           style: TextStyle(
                    //             color: Colors.white,
                    //             fontSize: 30,
                    //           ),
                    //         ),
                    //         width: 60,
                    //         height: 60,
                    //         decoration: BoxDecoration(
                    //           color: Colors.blue,
                    //           shape: BoxShape.circle,
                    //         ),
                    //       ),
                    //       // indexBarMargin: EdgeInsets.only(
                    //       //   right: 5,
                    //       // ),
                    //       indexBarOptions: IndexBarOptions(
                    //         needRebuild: true,
                    //         indexHintAlignment: Alignment.centerRight,
                    //         indexHintOffset: Offset(-20, 0),
                    //         selectTextStyle: TextStyle(
                    //           color: Colors.white,
                    //           fontWeight: FontWeight.bold,
                    //         ),
                    //         selectItemDecoration: BoxDecoration(
                    //           shape: BoxShape.circle,
                    //           color: Colors.blue,
                    //         ),
                    //       ),
                    //     );
                    //   },
                    // ),
                  ),
                ]),
              ),
            ),
    );
  }

  Widget buildSearch() => SearchField(
        text: query,
        hintText: 'Search by Contact Person Name',
        onChanged: searchContactPerson,
      );

  void searchContactPerson(String query) {
    print(query);
    Provider.of<PersonalContactListProvider>(context, listen: false)
        .findByFullName(query.toLowerCase());
  }
}
