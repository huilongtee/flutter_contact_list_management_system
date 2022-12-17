// import 'dart:convert';

// import 'package:flutter/material.dart';
// import 'package:flutter/services.dart';
// import 'package:shared_preferences/shared_preferences.dart';

// // import '../screens/viewContactPerson_screen.dart';
// import 'package:intl_phone_field/intl_phone_field.dart';

// import 'package:provider/provider.dart';
// import '../models/http_exception.dart';
// import '../widgets/app_drawer.dart';
// import '../providers/personalContactList_provider.dart';
// import '../providers/profile_provider.dart';
// import '../providers/profile.dart';
// import '../widgets/personal_contact_item.dart';
// import '../widgets/searchField.dart';

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
//   final _phoneNumberFocusNode = FocusNode();
//   var _isLoading = false;
//   final _form = GlobalKey<FormState>();
//   var _filledData = '';
//   var _isInit = true;

//   @override
//   void didChangeDependencies() {
//     if (_isInit) {
//       setState(() {
//         _isLoading = true;
//       });

//       Provider.of<PersonalContactListProvider>(context)
//           .fetchAndSetPersonalContactList();
//       _contactPerson =
//           Provider.of<PersonalContactListProvider>(context).personalContactList;
//       setState(() {
//         _isLoading = false;
//       });
//       _isInit = false;

//       super.didChangeDependencies();
//     }
//   }

//   @override
//   void dispose() {
//     _phoneNumberFocusNode.dispose();
//     super.dispose();
//   }

//   void _showErrorDialog(String message) {
//     showDialog(
//       context: context,
//       builder: (context) => AlertDialog(
//         title: Text('An Error Occurred'),
//         content: Text(message),
//         actions: [
//           TextButton(
//             onPressed: () {
//               Navigator.of(context).pop();
//             },
//             child: Text('Okay'),
//           ),
//         ],
//       ),
//     );
//   }

//   Future<void> _saveForm() async {
//     final isValid = _form.currentState.validate(); //trigger all validator
//     if (!isValid) {
//       return; //stop function
//     }
//     _form.currentState.save();
//     setState(() {
//       _isLoading = true;
//     });
//     try {
//       await Provider.of<PersonalContactListProvider>(context, listen: false)
//           .addContactPerson(_filledData);
//     } on HttpException catch (error) {
//       String errMessage = '';
//       if (error.toString().contains('not found')) {
//         errMessage = 'This phone number is not found in the system';
//       } else if (error.toString().contains('existed')) {
//         errMessage = 'This phone number is already existed in the system';
//       }
//       _showErrorDialog(errMessage);
//     } catch (error) {
//       const errMessage = 'Could not add this phone number';
//       _showErrorDialog(errMessage);
//     }
//     Navigator.of(context).pop();
//     setState(() {
//       _isLoading = false;
//     });
//   }

// //show bottom sheet start
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
//                       onSubmitted: (_) {
//                         _saveForm();
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
//                     onPressed: _saveForm,
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
// //show bottom sheet end

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
//                     child: Consumer<PersonalContactListProvider>(
//                       builder: (context, _contactPerson, _) => ListView.builder(
//                         itemCount: _contactPerson.personalContactList.length,
//                         itemBuilder: (_, index) => Column(
//                           children: [
//                             PersonalContactItem(
//                               _contactPerson.personalContactList[index].id,
//                               _contactPerson
//                                   .personalContactList[index].fullName,
//                               _contactPerson
//                                   .personalContactList[index].imageUrl,
//                               _contactPerson
//                                   .personalContactList[index].phoneNumber,
//                               _contactPerson
//                                   .personalContactList[index].emailAddress,
//                               _contactPerson
//                                   .personalContactList[index].homeAddress,
//                             ),
//                             Divider(
//                               thickness: 1,
//                             ),
//                           ],
//                         ),
//                       ),
//                     ),
//                   ),
//                 ]),
//               ),
//             ),
//       //
//     );
//   }

//   Widget buildSearch() => SearchField(
//         text: query,
//         hintText: 'Search by Contact Person Name',
//         onChanged: searchContactPerson,
//       );

//   void searchContactPerson(String query) {
//     print(query);
//     Provider.of<PersonalContactListProvider>(context, listen: false)
//         .findByFullName(query.toLowerCase());
//   }
// }
