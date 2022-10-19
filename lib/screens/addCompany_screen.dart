import 'package:flutter/material.dart';
import 'package:flutter_contact_list_management_system/providers/company_provider.dart';
import 'package:provider/provider.dart';
import '../providers/administrator_provider.dart';
import '../providers/profile_provider.dart';
import '../providers/profile.dart';
import '../widgets/administrator_app_drawer.dart';

class AddCompanyScreen extends StatefulWidget {
  static const routeName = '/addCompany_page';

  @override
  State<AddCompanyScreen> createState() => _AddCompanyScreenState();
}

class _AddCompanyScreenState extends State<AddCompanyScreen> {
  final _companyNameFocusNode = FocusNode();
  final _companyAdminIdFocusNode = FocusNode();
  final _form = GlobalKey<FormState>();
  var _editedCompany = Company(
    id: null,
    companyName: '',
    companyAdminId: '',
  );
  var _isLoading = false;
  var _isInit = true;
  var _initValue = {
    'companyName': '',
    'companyAdminId': '',
  };
  List loadedAdmin = [];

  String selectedValue = 'XHM5YXMzFVOM25vvPeTBHT4xCiZ2';
  @override
  void didChangeDependencies() {
    if (_isInit) {
      final companyId = ModalRoute.of(context).settings.arguments as String;
      if (companyId != null) {
        _editedCompany = Provider.of<CompanyProvider>(context, listen: false)
            .findById(companyId);
       
        _initValue = {
          'companyName': _editedCompany.companyName,
          'companyAdminId': _editedCompany.companyAdminId,
        };
      }
      //else {
      //   Provider.of<ProfileProvider>(context, listen: false)
      //       .fetchAndSetNonAdmin()
      //       .then((_) {
      //     setState(() {
      //       _isLoading = false;
      //     });
      //   });
      //   loadedAdmin =
      //       Provider.of<ProfileProvider>(context, listen: false).nonAdmin;
      // }
    }
    super.didChangeDependencies();
  }

  @override
  void dispose() {
    //to reduce the memory usage if already read the data

    super.dispose();
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
    if (_editedCompany.id != null) {
      await Provider.of<CompanyProvider>(context, listen: false)
          .updateCompany(_editedCompany.id, _editedCompany);

      Navigator.of(context).pop();
    } else {
      if(_editedCompany.companyAdminId!=null){
      try {
       
       
        await Provider.of<ProfileProvider>(context, listen: false)
            .fetchAndSetProfile()
            .then((_) {
          setState(() {
            Profile loadedProfile = Provider.of<ProfileProvider>(context, listen: false)
                .findById(_editedCompany.companyAdminId);
            Provider.of<CompanyProvider>(context, listen: false)
            .addCompany(_editedCompany, loadedProfile);
          });
        });

        
      } catch (error) {
        await showDialog<Null>(
            context: context,
            builder: (ctx) => AlertDialog(
                  title: Text('An error occurred'),
                  content: Text('Something went wrong'),
                  actions: [
                    FlatButton(
                        onPressed: () {
                          Navigator.of(ctx)
                              .pop(); //once this show dialog pop, then will only execute the then function
                        },
                        child: Text('Okey'))
                  ],
                ));
      }
      }
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
        title: Text(_initValue['companyAdminId']==''
            ? 'Add New Company Account'
            : 'Update Company details'),
        backgroundColor: Theme.of(context).primaryColor,
      ),
      drawer: AdministratorAppDrawer(),
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
                            _editedCompany = Company(
                              companyName: value,
                              companyAdminId: _editedCompany.companyAdminId,
                              id: _editedCompany.id,
                            );
                          },
                        ),

                        TextFormField(
                          initialValue: _initValue['companyAdminId'],
                          decoration:
                              InputDecoration(labelText: 'Company Admin Id'),
                          textInputAction: TextInputAction
                              .next, //prevent it from submmiting the form directly
                          onFieldSubmitted: (_) {
                            FocusScope.of(context)
                                .requestFocus(_companyAdminIdFocusNode);
                          }, //whenever the button right cover is pressed
                          validator: (value) {
                            // return null;//it means no problem
                            if (value.isEmpty) {
                              return 'Please provide a company admin id';
                            }

                            return null;
                          },
                          onSaved: (value) {
                            _editedCompany = Company(
                              companyName: _editedCompany.companyName,
                              companyAdminId: value,
                              id: _editedCompany.id,
                            );
                          },
                        ),

                        // DropdownButtonFormField<Profile>(
                        //   hint: Text('Select Company Admin'),
                        //   isExpanded: true,
                        //   value: selectedValue,
                        //   items: loadedAdmin.map((Profile items) {
                        //     return DropdownMenuItem<String>(
                        //       child: Text(items.fullName),
                        //       value: items.departmentId,
                        //     );
                        //   }).toList(),
                        //   onChanged: (value) {
                        //     selectedValue = value;
                        //     setState(() {});
                        //   },
                        // ),

                        // DropdownButton<String>(
                        //   hint: Text('Select Company Admin'),
                        //   isExpanded: true,
                        //   value: selectedValue,
                        //   iconSize: 24,
                        //   icon: Icon(Icons.arrow_drop_down,color: Colors.black,),
                        //   items: loadedAdmin
                        //       .map<DropdownMenuItem<String>>((item) {
                        //     return DropdownMenuItem<String>(
                        //       child: Text(item),
                        //       value: item,
                        //     );
                        //   }).toList(),
                        //   onChanged: (value) {
                        //     setState(() {
                        //       selectedValue = value;
                        //     });
                        //   },
                        // validator: (value) {
                        //   // return null;//it means no problem
                        //   if (value.toString().isEmpty) {
                        //     return 'Please select a company admin';
                        //   }

                        //   return null;
                        // },
                        // onSaved: (value) {
                        //   _editedCompany = Company(
                        //     companyName: _editedCompany.companyName,
                        //     companyAdminId: value.toString(),
                        //     id: _editedCompany.id,
                        //   );
                        // },
                      ],
                    ),
                  ),
                ),
                Container(
                  child: ElevatedButton(
                    onPressed: _saveForm,
                    child: Text(_initValue['companyAdminId']==''
            ? 'Add'
            : 'Update'),
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
