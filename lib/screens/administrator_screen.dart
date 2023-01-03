// import '../screens/addCompany_screen.dart';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:intl_phone_field/intl_phone_field.dart';
import '../providers/personalContactList_provider.dart';
import '../providers/profile.dart';
import '../providers/profile_provider.dart';

import 'package:provider/provider.dart';
import '../providers/company_provider.dart';
import '../widgets/administrator_app_drawer.dart';
import '../widgets/companies_items.dart';
import '../widgets/dialog.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';

class AdministratorScreen extends StatefulWidget {
  static const routeName = '/administrator_page';

  @override
  State<AdministratorScreen> createState() => _AdministratorScreenState();
}

class _AdministratorScreenState extends State<AdministratorScreen> {
  var _isInit = true;
  var _isLoading = false;
  Future _loadedData;
  final GlobalKey<FormState> _formKey = GlobalKey();
  Map<String, dynamic> _authData = {
    'phoneNo': '',
    'companyName': '',
  };
  Future<void> _fetchAllData() async {
    await Provider.of<CompanyProvider>(
      context,
      listen: false,
    ).fetchAndSetCompany();

    await Provider.of<ProfileProvider>(
      context,
      listen: false,
    ).fetchAndSetNonAdmin(true);
  }

  // List<Profile> contactPerson;
  @override
  void didChangeDependencies() {
    if (_isInit) {
      setState(() {
        _isLoading = true;
      });

      _loadedData = _fetchAllData().then((_) {
        print('entered did changed');
        setState(() {
          _isLoading = false;
          _isInit = false;
        });
      });
    }

    super.didChangeDependencies();
  }

  Future<void> _refreshCompanyList(BuildContext context) async {
    _fetchAllData();
  }

  Future<String> _submit() async {
    if (!_formKey.currentState.validate()) {
      // Invalid!
      Navigator.of(context).pop();
      setState(() {
        _isLoading = false;
      });
      return 'Could not add this company';
    }
    _formKey.currentState.save();
    setState(() {
      _isLoading = true;
    });

    if (_authData['phoneNo'].toString().substring(2).isEmpty) {
      return 'The phone number should not be empty';
    }

    try {
      String errMessage = '';
      Profile profile =
          await Provider.of<PersonalContactListProvider>(context, listen: false)
              .fetchAndReturnContactPersonProfile(_authData['phoneNo'],true);
      if (profile == null) {
        // Log user in

        await Provider.of<CompanyProvider>(context, listen: false).addCompany(
          _authData['phoneNo'],
          _authData['companyName'],
        );
      } else {
        errMessage = 'This user cannot be chosen.';
      }
      Navigator.of(context).pop();
      setState(() {
        _isLoading = false;
      });
      return errMessage;
    } on HttpException catch (error) {
      return error.toString();
    } catch (error) {
      const errorMessage = 'Could not create the company. Please try again.';
      return errorMessage.toString();
    }
  }

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
                  Expanded(
                    child: Form(
                      //able to group them, send and validate all the TextFormField together
                      key: _formKey, //for establishing the connection

                      child: ListView(
                        children: [
                          TextFormField(
                            decoration:
                                InputDecoration(labelText: 'Company Name'),
                            keyboardType: TextInputType.text,
                            validator: (value) {
                              if (value.isEmpty) {
                                return 'Please fill in company name';
                              }
                            },
                            onSaved: (value) {
                              _authData['companyName'] = value;
                            },
                          ),
                          IntlPhoneField(
                            decoration: InputDecoration(
                              labelText: 'Phone Number',
                            ),
                            initialCountryCode: 'MY',
                            inputFormatters: [
                              FilteringTextInputFormatter.digitsOnly
                            ],
                            disableLengthCheck: true,
                            validator: (value) {
                              if (value.completeNumber.substring(1).isEmpty ||
                                  value.completeNumber.substring(1).length <
                                      10 ||
                                  value.completeNumber.substring(1).length >
                                      12) {
                                return 'Phone number must greater than 10 digits and lesser than 12 digits';
                              }
                            },
                            onSaved: (value) {
                              _authData['phoneNo'] =
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
                        String response = await _submit();
                        if (response.isNotEmpty) {
                          Dialogs.showMyDialog(context, response);
                        }
                      },
                      child: Text('Add'),
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
        });
  }

  @override
  Widget build(BuildContext context) {
    print(_loadedData);
    return Scaffold(
      appBar: AppBar(
        title: Text('My-List'),
        backgroundColor: Theme.of(context).primaryColor,
        actions: [
          IconButton(
            onPressed: () {
              // Navigator.pushNamed(context, AddCompanyScreen.routeName);
              _showBottomSheet();
            },
            icon: Icon(Icons.add),
          ),
        ],
      ),
      drawer: AdministratorAppDrawer(),
      body: FutureBuilder(
        future: _fetchAllData(),
        builder: (context, snapshot) =>
            snapshot.connectionState == ConnectionState.waiting
                ? Center(
                    child: CircularProgressIndicator(),
                  )
                : RefreshIndicator(
                    onRefresh: () => _refreshCompanyList(context),
                    child: _loadedData == null
                        ? Center(
              // child: CircularProgressIndicator(),
              child: SpinKitDoubleBounce(
          color: Theme.of(context).primaryColor,
          size: 100,
        ),
            )
                        : Container(
                            decoration: BoxDecoration(
                              color: Colors.indigo[50],
                            ),
                            child: Column(
                              children: [
                                Expanded(
                                  child: Container(
                                    padding: EdgeInsets.symmetric(
                                        horizontal: 10, vertical: 5),
                                    child: Consumer<CompanyProvider>(
                                      builder: (context, _loadedData, _) =>
                                          ListView.builder(
                                        itemCount: _loadedData.companies.length,
                                        itemBuilder: (_, index) {
                                          Profile profileResult =
                                              Provider.of<ProfileProvider>(
                                            context,
                                            listen: false,
                                          ).findByNonAdminId(_loadedData
                                                  .companies[index]
                                                  .companyAdminID);

                                          return Column(
                                            children: [
                                              CompaniesItem(
                                                _loadedData.companies[index].id,
                                                _loadedData.companies[index]
                                                    .companyName,
                                                profileResult == null
                                                    ? ''
                                                    : profileResult.fullName,
                                              ),
                                            ],
                                          );
                                        },
                                      ),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                  ),
      ),
    );
  }
}
