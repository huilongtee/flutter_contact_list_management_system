import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_contact_list_management_system/providers/company_provider.dart';
import 'package:intl_phone_field/intl_phone_field.dart';
import 'package:provider/provider.dart';
// import '../providers/administrator_provider.dart';
import '../providers/personalContactList_provider.dart';
import '../providers/profile_provider.dart';
import '../providers/profile.dart';
import '../widgets/administrator_app_drawer.dart';
import '../widgets/dialog.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';

class EditCompanyScreen extends StatefulWidget {
  static const routeName = '/editCompany_page';

  @override
  State<EditCompanyScreen> createState() => _EditCompanyScreenState();
}

class _EditCompanyScreenState extends State<EditCompanyScreen> {
  final _companyNameFocusNode = FocusNode();
  final _form = GlobalKey<FormState>();
  var _editedCompany = Company(
    id: null,
    companyName: '',
    companyAdminID: '',
  );
  var _isLoading = false;
  var _isInit = true;
  var _initValue = {
    'companyName': '',
    'phoneNumber': '',
  };
  List<Profile> loadedNonAdmin = [];

  Profile selectedValue;

  @override
  void didChangeDependencies() {
    if (_isInit) {
      setState(() {
        _isLoading = true;
      });

      final companyId = ModalRoute.of(context).settings.arguments as String;
      //if company id not null, means the company has been created before

      _editedCompany = Provider.of<CompanyProvider>(context, listen: false)
          .findById(companyId);
      selectedValue = Provider.of<ProfileProvider>(context, listen: false)
          .findByNonAdminId(_editedCompany.companyAdminID);

      // print(selectedValue.id);
      _initValue = {
        'companyName': _editedCompany.companyName,
        'phoneNumber': _editedCompany.companyAdminID,
      };
      setState(() {
        _isLoading = false;
      });
    }
    _isInit = false;
    super.didChangeDependencies();
  }

  @override
  void dispose() {
    //to reduce the memory usage if already read the data

    super.dispose();
  }

  Future<String> _saveForm() async {
    final isValid = _form.currentState.validate(); //trigger all validator
    if (!isValid) {
      return 'cannot edit the company'; //stop function
    }
    _form.currentState.save();
    setState(() {
      _isLoading = true;
    });
    _editedCompany = Company(
      id: _editedCompany.id,
      companyName: _initValue['companyName'],
      companyAdminID: _initValue['phoneNumber'],
    );
    try {
      Profile _profile =
          await Provider.of<PersonalContactListProvider>(context, listen: false)
              .fetchAndReturnContactPersonProfile(_initValue['phoneNumber'],true);
      String errMessage = '';
      print(_profile.runtimeType);
      if (_profile != null) {
        if (_profile.companyId != null) {
          errMessage = 'The user already belong to one of the company';
        }
      } else {
        errMessage = '';

        await Provider.of<CompanyProvider>(context, listen: false)
            .updateCompany(_editedCompany.id, _editedCompany);
      }
      Navigator.of(context).pop();

      setState(() {
        _isLoading = false;
      });
      return errMessage;
    } catch (err) {
      return err.toString();
    }
  }

  @override
  Widget build(BuildContext context) {
    // selectedValue = null;
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: Icon(Icons.arrow_back),
          onPressed: () => Navigator.of(context).pop(),
        ),
        title: Text('Update Company details'),
        backgroundColor: Theme.of(context).primaryColor,
      ),
      drawer: AdministratorAppDrawer(),
      body: _isLoading
          ? Center(
              // child: CircularProgressIndicator(),
              child: SpinKitDoubleBounce(
          color: Theme.of(context).primaryColor,
          size: 100,
        ),
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
                          initialValue: _initValue['companyName'],
                          decoration:
                              InputDecoration(labelText: 'Company Name'),
                          textInputAction: TextInputAction
                              .next, //prevent it from submmiting the form directly
                          onFieldSubmitted: (_) {
                            FocusScope.of(context)
                                .requestFocus(_companyNameFocusNode);
                          }, //whenever the button right cover is pressed
                          validator: (value) {
                            // return null;//it means no problem
                            if (value.isEmpty) {
                              return 'Please provide a company name';
                            }

                            return null;
                          },
                          onSaved: (value) {
                            _initValue['companyName'] = value;
                            // _editedCompany = Company(
                            //   companyName: value,
                            //   companyAdminID: _editedCompany.companyAdminID,
                            //   id: _editedCompany.id,
                            // );
                          },
                        ),
                        // DropdownButtonFormField(
                        //   hint: Text('Select Company Admin'),
                        //   isExpanded: true,
                        //   items: loadedNonAdmin.map((Profile items) {
                        //     return DropdownMenuItem<Profile>(
                        //       child: Text(
                        //           items.fullName + " - " + items.emailAddress),
                        //       value: items,
                        //     );
                        //   }).toList(),
                        //   value: selectedValue,
                        //   onChanged: (value) {
                        //     setState(() {
                        //       selectedValue = value;
                        //     });
                        //   },
                        // ),

                        IntlPhoneField(
                          decoration: InputDecoration(
                            labelText: 'Phone Number',
                          ),
                          autofocus: true,
                          textInputAction: TextInputAction.done,
                          initialValue: _initValue.isEmpty
                              ? null
                              : _initValue['phoneNumber'].substring(2),
                          initialCountryCode: 'MY',
                          inputFormatters: [
                            FilteringTextInputFormatter.digitsOnly
                          ],
                          disableLengthCheck: true,
                          validator: (value) {
                            if (value.completeNumber.substring(1).isEmpty ||
                                value.completeNumber.substring(1).length < 10 ||
                                value.completeNumber.substring(1).length > 12) {
                              return 'Phone number must greater than 10 digits and lesser than 12';
                            }
                          },
                          onSaved: (value) {
                            _initValue['phoneNumber'] =
                                value.completeNumber.substring(1);
                          },
                        ),
                      ],
                    ),
                  ),
                ),
                Container(
                  child: ElevatedButton(
                    onPressed: () async {
                      String errMessage = await _saveForm();
                      if (errMessage.isNotEmpty) {
                        Dialogs.showMyDialog(context, errMessage);
                      }
                    },
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
