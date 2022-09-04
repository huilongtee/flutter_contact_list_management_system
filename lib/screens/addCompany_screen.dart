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
  var loadedAdmin;
  List<dynamic> list = [{'id':'1','name':'tee hui long'},{'id':'2','name':'tee hui'}];
  String selectedValue = null;
  @override
  void didChangeDependencies() {
    if (_isInit) {
      final companyId = ModalRoute.of(context).settings.arguments as String;
      if (companyId != null) {
        _editedCompany = Provider.of<CompanyProvider>(context, listen: false)
            .findById(companyId);
        //  loadedAdmin =
        //     Provider.of<ProfileProvider>(context, listen: false)
        //         .findById(_editedCompany.companyAdminId);
        _initValue = {
          'companyName': _editedCompany.companyName,
          'companyAdminId': _editedCompany.companyAdminId,
        };
      } else {
        Provider.of<ProfileProvider>(context, listen: false)
            .fetchAndSetNonAdmin()
            .then((_) {
          setState(() {
            _isLoading = false;
          });
        });
        loadedAdmin =
            Provider.of<ProfileProvider>(context, listen: false).nonAdmin;
      }
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
      // Provider.of<CompanyProvider>(context, listen: false)
      //     .updateCompany(_editedCompany.id, _editedCompany);

      Navigator.of(context).pop();
    } else {
      try {
        // await Provider.of<CompanyProvider>(context, listen: false)
        //     .addCompany(_editedCompany);
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
        title: Text(_initValue== null
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
                        DropdownButtonFormField(
                            hint: Text('Select Company Admin'),
                            isExpanded: true,
                            value: selectedValue,
                            items: list.map((items) {
                              return DropdownMenuItem(
                                child: Text(items['name']),
                                value: items['id'],
                              );
                            }).toList(),
                            onChanged: (value) {
                              selectedValue = value;
                              setState(() {});
                            })
                      ],
                    ),
                  ),
                ),
                Container(
                  child: ElevatedButton(
                    onPressed: _saveForm,
                    child: Text('Add'),
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
