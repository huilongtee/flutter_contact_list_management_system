// //this consists of az listview

// import 'dart:convert';

// import 'package:flutter/material.dart';
// import 'package:flutter/services.dart';

// import 'package:azlistview/azlistview.dart';
// // import '../screens/viewContactPerson_screen.dart';
// import 'package:intl_phone_field/intl_phone_field.dart';

// import 'package:provider/provider.dart';
// import '../models/http_exception.dart';
// import '../providers/azitem.dart';
// import '../providers/personalContactList_provider.dart';
// import '../providers/profile_provider.dart';

// import '../providers/profile.dart';
// import '../widgets/personal_contact_item.dart';
// import '../widgets/searchField.dart';
// import '../widgets/dialog.dart';
// import '../widgets/app_drawer.dart';

// // class _KIndexBar extends ISuspensionBean {
// //   final String tag;
// //   _KIndexBar({this.tag});

// //   @override
// //   String getSuspensionTag() => tag;
// // }

// class PersonalContactListScreen extends StatefulWidget {
//   static const routeName = '/personalContactList_page';

//   @override
//   State<PersonalContactListScreen> createState() =>
//       _PersonalContactListScreenState();
// }

// class _PersonalContactListScreenState extends State<PersonalContactListScreen> {
//   List<Profile> _contactPerson;

//   String query = '';
//   PersonalContactListProvider personalContactPersonProvider;
//   DateTime lastPressed;

//   var _isLoading = false;
//   final _form = GlobalKey<FormState>();
//   var _filledData = '';
//   var _isInit = true;
//   List<AZItem> items = [];
//   List<AZItem> _backupList = [];
//   // List<_KIndexBar> kIndexBar = [];
//   @override
//   // void didChangeDependencies() {
//   //   if (_isInit) {
//   //     setState(() {
//   //       _isLoading = true;
//   //     });

//   //     Provider.of<PersonalContactListProvider>(context)
//   //         .fetchAndSetPersonalContactList()
//   //         .then((_) {
//   //       _contactPerson =
//   //           Provider.of<PersonalContactListProvider>(context, listen: false)
//   //               .personalContactList;

//   //       convertToISuspensionList(_contactPerson);
//   //       // generateKIndexBar(kIndexBarData);
//   //     });

//   //     setState(() {
//   //       _isLoading = false;
//   //     });
//   //     _isInit = false;

//   //     super.didChangeDependencies();
//   //   }
//   // }

//   void didChangeDependencies() {
//     if (_isInit) {
//       setState(() {
//         _isLoading = true;
//       });

//       Provider.of<PersonalContactListProvider>(context)
//           .fetchAndSetPersonalContactList()
//           .then((_) {
//         _contactPerson =
//             Provider.of<PersonalContactListProvider>(context, listen: false)
//                 .personalContactList;

//         convertToISuspensionList(_contactPerson);
//         // generateKIndexBar(kIndexBarData);
//       });

//       setState(() {
//         _isLoading = false;
//       });
//       _isInit = false;

//       super.didChangeDependencies();
//     }
//   }

//   void convertToISuspensionList(List<Profile> items) {
//     print('entered');
//     this.items = items
//         .map((item) => AZItem(
//               title: item.fullName,
//               tag: item.fullName[0].toUpperCase(),
//               id: item.id,
//               fullName: item.fullName,
//               imageUrl: item.imageUrl,
//               phoneNumber: item.phoneNumber,
//               emailAddress: item.emailAddress,
//               homeAddress: item.homeAddress,
//             ))
//         .toList();

//     SuspensionUtil.sortListBySuspensionTag(this.items);
//     SuspensionUtil.setShowSuspensionStatus(this.items);
//     setState(() {});
//   }

//   // void generateKIndexBar(List<String> kIndexBarItems) {
//   //   this.kIndexBar = kIndexBarItems
//   //       .map((item) => _KIndexBar(
//   //             tag: item,
//   //           ))
//   //       .toList();
//   //   SuspensionUtil.sortListBySuspensionTag(this.kIndexBar);
//   //   SuspensionUtil.setShowSuspensionStatus(this.kIndexBar);
//   //   setState(() {});
//   // }

//   Future<String> _saveForm() async {
//     setState(() {
//       _isLoading = true;
//     });
//     final isValid = _form.currentState.validate(); //trigger all validator
//     if (!isValid) {
//       Navigator.of(context).pop();
//       setState(() {
//         _isLoading = false;
//       });
//       return 'Could not add the person'; //stop function
//     }
//     _form.currentState.save();

//     try {
//       final errMessage =
//           await Provider.of<PersonalContactListProvider>(context, listen: false)
//               .addContactPerson(_filledData);

//       Navigator.of(context).pop();

//       setState(() {
//         _isLoading = false;
//       });
//       return errMessage;
//     } on HttpException catch (error) {
//       return error.toString();
//     } catch (error) {
//       return error.toString();
//     }
//   }

//   void _showBottomSheet() {
//     showModalBottomSheet(
//         context: context,
//         builder: (BuildContext content) {
//           return Card(
//             elevation: 5,
//             child: Container(
//               padding: EdgeInsets.all(10),
//               child: Column(
//                 mainAxisAlignment: MainAxisAlignment.spaceBetween,
//                 children: [
//                   Form(
//                     key: _form,
//                     child: IntlPhoneField(
//                       decoration: InputDecoration(
//                         labelText: 'Phone Number',
//                       ),
//                       autofocus: true,
//                       textInputAction: TextInputAction.done,
//                       onSubmitted: (_) async {
//                         String response = await _saveForm();

//                         if (response.isNotEmpty) {
//                           Dialogs.showMyDialog(context, response);
//                         }
//                       },
//                       initialValue:
//                           _filledData.isEmpty ? null : _filledData.substring(2),
//                       initialCountryCode: 'MY',
//                       inputFormatters: [FilteringTextInputFormatter.digitsOnly],
//                       disableLengthCheck: true,
//                       validator: (value) {
//                         if (value.completeNumber.substring(1).isEmpty ||
//                             value.completeNumber.substring(1).length < 10 ||
//                             value.completeNumber.substring(1).length > 12) {
//                           return 'Phone number must greater than 10 digits and lesser than 12';
//                         }
//                       },
//                       onSaved: (value) {
//                         _filledData = value.completeNumber.substring(1);
//                       },
//                     ),
//                   ),
//                   ElevatedButton(
//                     onPressed: () async {
//                       String response = await _saveForm();
//                       if (response.isNotEmpty) {
//                         Dialogs.showMyDialog(context, response);
//                       }
//                     },
//                     child: Text('Add New Contact Person'),
//                     style: ElevatedButton.styleFrom(
//                       backgroundColor: Theme.of(context).primaryColor,
//                       textStyle: TextStyle(fontSize: 20),
//                     ),
//                   ),
//                 ],
//               ),
//             ),
//           );
//         });
//   }

//   Widget buildHeader(String tag) => Container(
//         height: 40,
//         margin: EdgeInsets.only(
//           right: 16,
//         ),
//         padding: EdgeInsets.only(
//           left: 16,
//         ),
//         color: Colors.grey.shade300,
//         alignment: Alignment.centerLeft,
//         child: Text(
//           '$tag',
//           softWrap: false,
//           style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
//         ),
//       );

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(
//         title: Text('My-List'),
//         backgroundColor: Theme.of(context).primaryColor,
//         actions: [
//           IconButton(
//             onPressed: () {
//               // profileProvider.addContactPerson();
//               // _openDialog();
//               _showBottomSheet();
//               // _showErrorDialog('error');
//             },
//             icon: Icon(Icons.add),
//           ),
//         ],
//       ),
//       drawer: AppDrawer(),
//       body: _isLoading == true
//           ? Center(
//               child: CircularProgressIndicator(),
//             )
//           : WillPopScope(
//               onWillPop: () async {
//                 final now = DateTime.now();
//                 final maxDuration = Duration(seconds: 2);
//                 final isWarning = lastPressed == null ||
//                     now.difference(lastPressed) > maxDuration;
//                 if (isWarning) {
//                   lastPressed = DateTime.now();
//                   final snackBar = SnackBar(
//                     content: Text('Tap again to close app'),
//                     duration: maxDuration,
//                   );

//                   ScaffoldMessenger.of(context)
//                     ..removeCurrentSnackBar()
//                     ..showSnackBar(snackBar);
//                   return false;
//                 } else {
//                   return true;
//                 }
//               },
//               child: Padding(
//                 padding: const EdgeInsets.all(5.0),
//                 child: Column(children: [
//                   buildSearch(),
//                   Expanded(
//                     // child: Consumer<PersonalContactListProvider>(
//                     //   builder: (context, _contactPerson, _) => ListView.builder(
//                     //     itemCount: _contactPerson.personalContactList.length,
//                     //     itemBuilder: (_, index) => Column(
//                     //       children: [
//                     //         PersonalContactItem(
//                     //           _contactPerson.personalContactList[index].id,
//                     //           _contactPerson
//                     //               .personalContactList[index].fullName,
//                     //           _contactPerson
//                     //               .personalContactList[index].imageUrl,
//                     //           _contactPerson
//                     //               .personalContactList[index].phoneNumber,
//                     //           _contactPerson
//                     //               .personalContactList[index].emailAddress,
//                     //           _contactPerson
//                     //               .personalContactList[index].homeAddress,
//                     //         ),
//                     //         Divider(
//                     //           thickness: 1,
//                     //         ),
//                     //       ],
//                     //     ),
//                     //   ),
//                     // ),

//                     child: LayoutBuilder(
//                       builder:
//                           (BuildContext context, BoxConstraints constraints) {
//                         return AzListView(
//                           data: items,
//                           itemCount: items.length,
//                           itemBuilder: (context, index) {
//                             final item = items[index];
//                             final tag = item.getSuspensionTag();
//                             final offstage = !item.isShowSuspension;

//                             return Column(
//                               children: [
//                                 Offstage(
//                                   offstage: offstage,
//                                   child: buildHeader(tag),
//                                 ),

//                                 Container(
//                                   margin: EdgeInsets.only(
//                                     right: 15,
//                                   ),
//                                   child: PersonalContactItem(
//                                     item.id,
//                                     item.fullName,
//                                     item.imageUrl,
//                                     item.phoneNumber,
//                                     item.emailAddress,
//                                     item.homeAddress,
//                                   ),
//                                 ),
//                                 // Divider(
//                                 //   thickness: 1,
//                                 // ),
//                               ],
//                             );
//                           },
//                           indexBarData:
//                               constraints.maxHeight > 400 ? kIndexBarData : [],
//                           indexHintBuilder: (context, hint) => Container(
//                             alignment: Alignment.center,
//                             child: Text(
//                               hint,
//                               style: TextStyle(
//                                 color: Colors.white,
//                                 fontSize: 30,
//                               ),
//                             ),
//                             width: 60,
//                             height: 60,
//                             decoration: BoxDecoration(
//                               color: Colors.blue,
//                               shape: BoxShape.circle,
//                             ),
//                           ),
//                           // indexBarMargin: EdgeInsets.only(
//                           //   right: 5,
//                           // ),
//                           indexBarOptions: IndexBarOptions(
//                             needRebuild: true,
//                             indexHintAlignment: Alignment.centerRight,
//                             indexHintOffset: Offset(-20, 0),
//                             selectTextStyle: TextStyle(
//                               color: Colors.white,
//                               fontWeight: FontWeight.bold,
//                             ),
//                             selectItemDecoration: BoxDecoration(
//                               shape: BoxShape.circle,
//                               color: Colors.blue,
//                             ),
//                           ),
//                         );
//                       },
//                     ),
//                   ),
//                 ]),
//               ),
//             ),
//     );
//   }

//   Widget buildSearch() => SearchField(
//         text: query,
//         hintText: 'Search by Contact Person Name',
//         onChanged: searchContactPerson,
//       );

//   // void searchContactPerson(String query) {
//   //   print(query);
//   //   Provider.of<PersonalContactListProvider>(context, listen: false)
//   //       .findByFullName(query.toLowerCase());
//   // }

//   void searchContactPerson(String name) {
//     print(name);
//     if (name.isEmpty) {
//       items = _backupList;
//     } else {
//       items = items
//           .where((data) =>
//               data.fullName.toLowerCase().contains(name.toLowerCase()))
//           .toList();
//     }
//     // notifyListeners();
//   }
// }
