import 'package:flutter/material.dart';
import 'package:flutter_contact_list_management_system/providers/company_provider.dart';
import 'package:provider/provider.dart';
import '../providers/administrator_provider.dart';
import '../providers/department_provider.dart';
import '../providers/profile_provider.dart';
import '../providers/profile.dart';
import '../providers/role_provider.dart';
import '../widgets/administrator_app_drawer.dart';

class AddDepartmentScreen extends StatefulWidget {
  static const routeName = '/addDepartment_page';

  @override
  State<AddDepartmentScreen> createState() => _AddDepartmentScreenState();
}

class _AddDepartmentScreenState extends State<AddDepartmentScreen> {
  final _departmentNameFocusNode = FocusNode();
  final _form = GlobalKey<FormState>();
  var _editedDepartment = Department(
    id: null,
    departmentName: '',
  );
  var _isLoading = false;
  var _isInit = true;
  var _initValue = {
    'departmentName': '',
  };

  @override
  void didChangeDependencies() {
    if (_isInit) {
      setState(() {
        _isLoading = true;
      });

      final departmentId = ModalRoute.of(context).settings.arguments as String;
      // final profileList = ModalRoute.of(context).settings.arguments as List;
      // entireProfileList = profileList;
      if (departmentId != null) {
        _editedDepartment =
            Provider.of<DepartmentProvider>(context, listen: false).findById(departmentId);
        // selectedValue = Provider.of<ProfileProvider>(context, listen: false)
        //     .findById(_editedCompany.companyAdminId);

        _initValue = {
          'departmentName': _editedDepartment.departmentName,
        };
        setState(() {
          _isLoading = false;
        });
      } else {
        setState(() {
          _isLoading = false;
        });
      }
    }
    _isInit = false;
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
    if (_editedDepartment.id != null) {
      await Provider.of<DepartmentProvider>(context, listen: false)
          .updateDepartment(_editedDepartment.id, _editedDepartment);

      Navigator.of(context).pop();
    } else {
      try {
        await Provider.of<DepartmentProvider>(context, listen: false)
            .addDepartment(_editedDepartment);

        Navigator.of(context).pop();
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
        title: Text(
            _initValue['departmentName'] == '' ? 'Add New Department' : 'Update Department Name'),
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
                          initialValue: _initValue['departmentName'],
                          decoration: InputDecoration(labelText: 'Department Name'),
                          textInputAction: TextInputAction
                              .next, //prevent it from submmiting the form directly
                          onFieldSubmitted: (_) {
                            FocusScope.of(context)
                                .requestFocus(_departmentNameFocusNode);
                          }, //whenever the button right cover is pressed
                          validator: (value) {
                            // return null;//it means no problem
                            if (value.isEmpty) {
                              return 'Please provide a department name';
                            }

                            return null;
                          },
                          onSaved: (value) {
                            _editedDepartment = Department(
                              departmentName: value,
                              id: _editedDepartment.id,
                            );
                          },
                        ),
                      ],
                    ),
                  ),
                ),
                Container(
                  child: ElevatedButton(
                    onPressed: _saveForm,
                    child:
                        Text(_initValue['departmentName'] == '' ? 'Add' : 'Update'),
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
