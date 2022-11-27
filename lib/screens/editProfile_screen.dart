import 'dart:io';

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/profile.dart';
import '../providers/profile_provider.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:image_picker/image_picker.dart';

class EditProfileScreen extends StatefulWidget {
  static const routeName = '/editProfile_page';

  @override
  State<EditProfileScreen> createState() => _EditProfileScreenState();
}

class _EditProfileScreenState extends State<EditProfileScreen> {
  final _fullNameFocusNode = FocusNode();
  final _phoneNumberFocusNode = FocusNode();
  final _imageUrlFocusNode = FocusNode();
  final _emailAddressFocusNode = FocusNode();
  final _homeAddressFocusNode = FocusNode();
  final _imageUrlController = TextEditingController();
  File _image;
  final imagePicker = ImagePicker();

  final _form = GlobalKey<FormState>();
  var _editedProfile = Profile(
    id: null,
    fullName: '',
    phoneNumber: '',
    homeAddress: '',
    emailAddress: '',
    imageUrl: '',
    companyId: '',
    roleId: '',
    departmentId: '',
  );
  var _isInit = true;
  var _isLoading = false;
  var _initValue = {
    'fullName': '',
    'phoneNumber': '',
    'emailAddress': '',
    'homeAddress': '',
    'imageUrl': '',
    'companyId': '',
    'roleId': '',
    'departmentId': '',
  };
  var userId = '';
  @override
  void initState() {
    _imageUrlFocusNode.addListener(_updateImageUrl);
    super.initState();
  }

  void _showErrorDialog(String message) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('An Error Occurred'),
        content: Text(message),
        actions: [
          FlatButton(
            onPressed: () {
              Navigator.of(context).pop();
            },
            child: Text('Okay'),
          ),
        ],
      ),
    );
  }

  @override
  void didChangeDependencies() {
    // TODO: implement didChangeDependencies
    if (_isInit) {
      final contactPersonId =
          ModalRoute.of(context).settings.arguments as String;
      userId = contactPersonId;

      if (contactPersonId != null) {
        _editedProfile = Provider.of<ProfileProvider>(context, listen: false)
            .findById(contactPersonId);
        _initValue = {
          'fullName': _editedProfile.fullName,
          'phoneNumber': _editedProfile.phoneNumber,
          'emailAddress': _editedProfile.emailAddress,
          'homeAddress': _editedProfile.homeAddress,
          'imageUrl': _editedProfile.imageUrl,
          'companyId': _editedProfile.companyId,
          'roleId': _editedProfile.roleId,
          'departmentId': _editedProfile.departmentId,
        };
        _imageUrlController.text = _editedProfile.imageUrl;
      }
    }
    _isInit = false;
    super.didChangeDependencies();
  }

  @override
  void dispose() {
    //to reduce the memory usage if already read the data
    _imageUrlFocusNode.removeListener(_updateImageUrl);
    _fullNameFocusNode.dispose();
    _phoneNumberFocusNode.dispose();
    _emailAddressFocusNode.dispose();
    _homeAddressFocusNode.dispose();
    _imageUrlController.dispose();
    _imageUrlFocusNode.dispose();

    super.dispose();
  }

//================================== Image Picker Start ==============================================//

  Future imagePickerMethod() async {
    final pick = await imagePicker.pickImage(source: ImageSource.gallery);

    setState(() {
      _image = File(pick.path);
      print('image path' + _image.toString());
    });

    //Get a reference to storage root
    Reference ref = FirebaseStorage.instance.ref();
    Reference referenceDirImages = ref.child('images');

    //create a reference for the image to be stored
    Reference referenceImageToUpload = referenceDirImages.child(userId);

    await referenceImageToUpload.putFile(_image);
    String downloadURL = await referenceImageToUpload.getDownloadURL();
    print(downloadURL);
    return downloadURL;
  }

//================================== Image Picker End ==============================================//

  void _updateImageUrl() {
    if (!_imageUrlFocusNode.hasFocus) {
      if ((!_imageUrlController.text.startsWith('http') &&
              !_imageUrlController.text.startsWith('https')) ||
          (!_imageUrlController.text.endsWith('.png') &&
              !_imageUrlController.text.endsWith('.jpeg') &&
              !_imageUrlController.text.endsWith('.jpg'))) {
        return; //stop function
      }
      setState(() {});
    }
  }

  Future<void> _saveForm() async {
    final isValid = _form.currentState.validate(); //trigger all validator
    if (!isValid) {
      return; //stop function
    }
    _form.currentState.save();
    setState(() {
      _isLoading = true;
    });

    if (_editedProfile.id != null) {
      await Provider.of<ProfileProvider>(context, listen: false)
          .updateProfile(_editedProfile.id, _editedProfile);

      Navigator.of(context).pop();
    }
    setState(() {
      _isLoading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: Icon(Icons.arrow_back),
          onPressed: () => Navigator.of(context).pop(),
        ),
        title: Text('Edit Profile'),
        backgroundColor: Theme.of(context).primaryColor,
      ),
      body: _isLoading
          ? Center(
              child: CircularProgressIndicator(),
            )
          : Padding(
              padding: const EdgeInsets.all(15.0),
              child: Column(children: [
                Expanded(
                  child: Form(
                    //able to group them, send and validate all the TextFormField together
                    key: _form, //for establishing the connection

                    child: ListView(
                      children: [
                        TextFormField(
                          initialValue: _initValue['fullName'],
                          decoration: InputDecoration(labelText: 'Fullname'),
                          textInputAction: TextInputAction
                              .next, //prevent it from submmiting the form directly
                          onFieldSubmitted: (_) {
                            FocusScope.of(context)
                                .requestFocus(_fullNameFocusNode);
                          }, //whenever the button right cover is pressed
                          validator: (value) {
                            // return null;//it means no problem
                            if (value.isEmpty) {
                              return 'Please provide a value';
                            }

                            return null;
                          },
                          onSaved: (value) {
                            _editedProfile = Profile(
                              fullName: value,
                              homeAddress: _editedProfile.homeAddress,
                              phoneNumber: _editedProfile.phoneNumber,
                              emailAddress: _editedProfile.emailAddress,
                              imageUrl: _editedProfile.imageUrl,
                              id: _editedProfile.id,
                              companyId: _editedProfile.companyId,
                              roleId: _editedProfile.roleId,
                              departmentId: _editedProfile.departmentId,
                            );
                          },
                        ), //TextFormField will automatically connected with the widget of Form

                        TextFormField(
                          initialValue: _initValue['phoneNumber'],
                          decoration:
                              InputDecoration(labelText: 'Phone Number'),
                          textInputAction: TextInputAction
                              .next, //prevent it from submmiting the form directly
                          onFieldSubmitted: (_) {
                            FocusScope.of(context)
                                .requestFocus(_phoneNumberFocusNode);
                          }, //whenever the button right cover is pressed
                          validator: (value) {
                            // return null;//it means no problem
                            if (value.isEmpty) {
                              return 'Please provide a value';
                            }

                            return null;
                          },
                          onSaved: (value) {
                            _editedProfile = Profile(
                              fullName: _editedProfile.fullName,
                              homeAddress: _editedProfile.homeAddress,
                              phoneNumber: value,
                              emailAddress: _editedProfile.emailAddress,
                              imageUrl: _editedProfile.imageUrl,
                              id: _editedProfile.id,
                              companyId: _editedProfile.companyId,
                              roleId: _editedProfile.roleId,
                              departmentId: _editedProfile.departmentId,
                            );
                          },
                        ),

                        TextFormField(
                          initialValue: _initValue['emailAddress'],
                          decoration:
                              InputDecoration(labelText: 'Email Address'),
                          textInputAction: TextInputAction
                              .next, //prevent it from submmiting the form directly
                          onFieldSubmitted: (_) {
                            FocusScope.of(context)
                                .requestFocus(_emailAddressFocusNode);
                          }, //whenever the button right cover is pressed
                          validator: (value) {
                            // return null;//it means no problem
                            if (value.isEmpty) {
                              return 'Please provide a value';
                            }

                            return null;
                          },
                          onSaved: (value) {
                            _editedProfile = Profile(
                              fullName: _editedProfile.fullName,
                              homeAddress: _editedProfile.homeAddress,
                              phoneNumber: _editedProfile.phoneNumber,
                              emailAddress: value,
                              imageUrl: _editedProfile.imageUrl,
                              id: _editedProfile.id,
                              companyId: _editedProfile.companyId,
                              roleId: _editedProfile.roleId,
                              departmentId: _editedProfile.departmentId,
                            );
                          },
                        ),

                        TextFormField(
                          initialValue: _initValue['homeAddress'],
                          decoration:
                              InputDecoration(labelText: 'Home Address'),
                          textInputAction: TextInputAction
                              .next, //prevent it from submmiting the form directly
                          onFieldSubmitted: (_) {
                            FocusScope.of(context)
                                .requestFocus(_homeAddressFocusNode);
                          }, //whenever the button right cover is pressed
                          validator: (value) {
                            // return null;//it means no problem
                            if (value.isEmpty) {
                              return 'Please provide a value';
                            }

                            return null;
                          },
                          onSaved: (value) {
                            _editedProfile = Profile(
                              fullName: _editedProfile.fullName,
                              homeAddress: value,
                              phoneNumber: _editedProfile.phoneNumber,
                              emailAddress: _editedProfile.emailAddress,
                              imageUrl: _editedProfile.imageUrl,
                              id: _editedProfile.id,
                              companyId: _editedProfile.companyId,
                              roleId: _editedProfile.roleId,
                              departmentId: _editedProfile.departmentId,
                            );
                          },
                        ),

                        //textfield for image link upload

                        Row(
                          crossAxisAlignment: CrossAxisAlignment.end,
                          children: [
                            Container(
                              width: 100,
                              height: 100,
                              margin: EdgeInsets.only(
                                top: 8,
                                right: 10,
                              ),
                              decoration: BoxDecoration(
                                border: Border.all(
                                  width: 1,
                                  color: Colors.grey,
                                ),
                              ),
                              child: _imageUrlController.text.isEmpty
                                  ? Text('Enter a URL')
                                  : FittedBox(
                                      child: Image.network(
                                        _imageUrlController.text,
                                        fit: BoxFit.cover,
                                      ),
                                    ),
                            ),
                            // Expanded(
                            //   child: TextFormField(
                            //     decoration: InputDecoration(
                            //       labelText: 'Image URL',
                            //     ),
                            //     keyboardType: TextInputType.url,
                            //     textInputAction: TextInputAction.done,
                            //     controller:
                            //         _imageUrlController, //if you have controller then you shopuld not have initial value
                            //     onEditingComplete: () {
                            //       setState(() {});
                            //     },
                            //     focusNode: _imageUrlFocusNode,
                            //     onFieldSubmitted: (_) {
                            //       //why don't just use _saveForm instead, because _saveForm function doesn't take String input, and _saveForm is String format
                            //       _saveForm();
                            //     },
                            //     validator: (value) {
                            //       // return null;//it means no problem

                            //       if (!value.isEmpty &&
                            //           !value.startsWith('http') &&
                            //           !value.startsWith('https')) {
                            //         return 'Please provide a valid URL';
                            //       }
                            //       if (!value.isEmpty &&
                            //           !value.endsWith('.png') &&
                            //           !value.endsWith('.jpeg') &&
                            //           !value.endsWith('.jpg')) {
                            //         return 'Please provide a valid image URL';
                            //       }
                            //       return null;
                            //     },
                            //     onSaved: (value) {
                            //       _editedProfile = Profile(
                            //         fullName: _editedProfile.fullName,
                            //         homeAddress: _editedProfile.homeAddress,
                            //         phoneNumber: _editedProfile.phoneNumber,
                            //         emailAddress: _editedProfile.emailAddress,
                            //         imageUrl: value,
                            //         id: _editedProfile.id,
                            //         companyId: _editedProfile.companyId,
                            //         roleId: _editedProfile.roleId,
                            //         departmentId: _editedProfile.departmentId,
                            //       );
                            //     },
                            //   ),
                            // ),
//====================================== Image Picker start ========================================//

                            Row(
                              children: [
                                Container(
                                  height: 70,
                                  width: 70,
                                  margin: const EdgeInsets.only(
                                      left: 20, right: 20),
                                  child: _image == null
                                      ? const Center(
                                          child: Text('No Image'),
                                        )
                                      : CircleAvatar(
                                          child: Image.file(_image),
                                        ),
                                ),
                                ElevatedButton(
                                  onPressed: () async {
                                    imagePickerMethod();
                                  },
                                  child: Text('Select Image'),
                                ),
                              ],
                            ),
//====================================== Image Picker end ========================================//
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
                Container(
                  child: ElevatedButton(
                    onPressed: _saveForm,
                    child: Text('Update'),
                    style: ElevatedButton.styleFrom(
                      primary: Theme.of(context).primaryColor,
                      textStyle: TextStyle(fontSize: 20),
                    ),
                  ),
                ),
              ]),
            ),
    );
  }
}
