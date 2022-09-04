// import 'package:flutter/material.dart';
// import 'package:provider/provider.dart';
// import '../providers/profile.dart';
// import '../providers/profile_provider.dart';

// class EditContactPersonScreen extends StatefulWidget {
//   static const routeName = '/editContactPerson_page';

//   @override
//   State<EditContactPersonScreen> createState() =>
//       _EditContactPersonScreenState();
// }

// class _EditContactPersonScreenState extends State<EditContactPersonScreen> {
//   final _roleIdFocusNode = FocusNode();
//   final _departmentIdFocusNode = FocusNode();

//   final _form = GlobalKey<FormState>();
//   var _editedProfile = Profile(
//       id: null,
//       fullName: '',
//       phoneNumber: '',
//       homeAddress: '',
//       emailAddress: '',
//       imageUrl: '');
//   var _isInit = true;
//   var _initValue = {
//     'fullName': '',
//     'phoneNumber': '',
//     'emailAddress': '',
//     'homeAddress': '',
//     'imageUrl': '',
//     'companyId': '',
//     'roleId': '',
//     'departmentId': '',
//   };

//   @override
//   void didChangeDependencies() {
//     // TODO: implement didChangeDependencies
//     if (_isInit) {
//       final contactPersonId =
//           ModalRoute.of(context).settings.arguments as String;
//       if (contactPersonId != null) {
//         // _editedProfile = Provider.of<ProfileProvider>(context, listen: false)
//         //     .findById(contactPersonId);

//         _initValue = {
//           'fullName': _editedProfile.fullName,
//           'phoneNumber': _editedProfile.phoneNumber,
//           'emailAddress': _editedProfile.emailAddress,
//           'homeAddress': _editedProfile.homeAddress,
//           'imageUrl': _editedProfile.imageUrl,
//           'roleId': _editedProfile.roleId,
//           'departmentId': _editedProfile.departmentId,
//           'companyId': _editedProfile.companyId,
//         };
//       }
//     }
//     _isInit = false;
//     super.didChangeDependencies();
//   }

//   @override
//   void dispose() {
//     //to reduce the memory usage if already read the data
    

//     super.dispose();
//   }


//   void _saveForm() {
//     final isValid = _form.currentState.validate(); //trigger all validator
//     if (!isValid) {
//       return; //stop function
//     }
//     _form.currentState.save();

//     if (_editedProfile.id != null) {
//       Provider.of<ProfileProvider>(context, listen: false)
//           .updateProfile(_editedProfile.id, _editedProfile);

//       Navigator.of(context).pop();
//     }
//   }

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(
//         leading: IconButton(
//           icon: Icon(Icons.arrow_back),
//           onPressed: () => Navigator.of(context).pop(),
//         ),
//         title: Text('Edit Product'),
//         backgroundColor: Theme.of(context).primaryColor,
//       ),
//       body: Padding(
//         padding: const EdgeInsets.all(15.0),
//         child: Column(children: [
//           Expanded(
//             child: Form(
//               //able to group them, send and validate all the TextFormField together
//               key: _form, //for establishing the connection

//               child: ListView(
//                 children: [
                  
                    
//                     ],
                  
                  
                  
                
//               ),
//             ),
//           ),
//           Container(
//             child: ElevatedButton(
//               onPressed: _saveForm,
//               child: Text('Update'),
//               style: ElevatedButton.styleFrom(
//                 primary: Theme.of(context).primaryColor,
//                 textStyle: TextStyle(fontSize: 20),
//               ),
//             ),
//           ),
//         ]),
//       ),
//     );
//   }
// }
