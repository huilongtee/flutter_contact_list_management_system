import 'package:flutter/material.dart';
import 'package:flutter_contact_list_management_system/providers/company_provider.dart';
import 'package:provider/provider.dart';
// import '../providers/administrator_provider.dart';
import '../providers/profile_provider.dart';
import '../providers/profile.dart';
import '../providers/role_provider.dart';
import '../widgets/administrator_app_drawer.dart';

class AddRoleScreen extends StatefulWidget {
  static const routeName = '/addRole_page';

  @override
  State<AddRoleScreen> createState() => _AddRoleScreenState();
}

class _AddRoleScreenState extends State<AddRoleScreen> {
  final _roleNameFocusNode = FocusNode();
  final _form = GlobalKey<FormState>();
  var _editedRole = Role(
    id: null,
    roleName: '',
  );
  var _isLoading = false;
  var _isInit = true;
  var _initValue = {
    'roleName': '',
  };

  @override
  void didChangeDependencies() {
    if (_isInit) {
      setState(() {
        _isLoading = true;
      });

      final roleId = ModalRoute.of(context).settings.arguments as String;
      // final profileList = ModalRoute.of(context).settings.arguments as List;
      // entireProfileList = profileList;
      if (roleId != null) {
        _editedRole =
            Provider.of<RoleProvider>(context, listen: false).findById(roleId);
        // selectedValue = Provider.of<ProfileProvider>(context, listen: false)
        //     .findById(_editedCompany.companyAdminId);

        _initValue = {
          'roleName': _editedRole.roleName,
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
    if (_editedRole.id != null) {
      await Provider.of<RoleProvider>(context, listen: false)
          .updateRole(_editedRole.id, _editedRole);

      Navigator.of(context).pop();
    } else {
      try {
        await Provider.of<RoleProvider>(context, listen: false)
            .addRole(_editedRole);

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
            _initValue['roleName'] == '' ? 'Add New Role' : 'Update Role Name'),
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
                          initialValue: _initValue['roleName'],
                          decoration: InputDecoration(labelText: 'Role Name'),
                          textInputAction: TextInputAction
                              .next, //prevent it from submmiting the form directly
                          onFieldSubmitted: (_) {
                            FocusScope.of(context)
                                .requestFocus(_roleNameFocusNode);
                          }, //whenever the button right cover is pressed
                          validator: (value) {
                            // return null;//it means no problem
                            if (value.isEmpty) {
                              return 'Please provide a role name';
                            }

                            return null;
                          },
                          onSaved: (value) {
                            _editedRole = Role(
                              roleName: value,
                              id: _editedRole.id,
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
                        Text(_initValue['roleName'] == '' ? 'Add' : 'Update'),
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
