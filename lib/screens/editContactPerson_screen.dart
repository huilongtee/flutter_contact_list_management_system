import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/department_provider.dart';
import '../providers/profile.dart';
import '../providers/profile_provider.dart';
import '../providers/role_provider.dart';
import '../providers/sharedContactList_provider.dart';

class EditContactPersonScreen extends StatefulWidget {
  static const routeName = '/editContactPerson_page';

  @override
  State<EditContactPersonScreen> createState() =>
      _EditContactPersonScreenState();
}

class _EditContactPersonScreenState extends State<EditContactPersonScreen> {
  var _isLoading = false;
  var _isInit = true;
  final _form = GlobalKey<FormState>();

  var _editedRole = Role(id: '', roleName: '');
  var _editedDepartment = Department(id: '', departmentName: '');

  List<Role> loadedRole = [];
  List<Department> loadedDepartment = [];
  var contactPersonID;
  var contactPerson = Profile(
    id: '',
    fullName: '',
    emailAddress: '',
    homeAddress: '',
    phoneNumber: '',
    imageUrl: '',
    companyId: '',
    roleId: '',
    departmentId: '',
  );
  @override
  void didChangeDependencies() {
    if (_isInit) {
      setState(() {
        _isLoading = true;
      });

      contactPersonID = ModalRoute.of(context).settings.arguments as String;
      contactPerson =
          Provider.of<SharedContactListProvider>(context, listen: false)
              .findById(contactPersonID);

      // role and department list getter
      loadedRole = Provider.of<RoleProvider>(context, listen: false).roleList;
      loadedDepartment = Provider.of<DepartmentProvider>(context, listen: false)
          .departmentList;

//check the current assigned role to this user
      final _role = Provider.of<RoleProvider>(context, listen: false)
          .findById(contactPerson.roleId);
      _editedRole = Role(
          id: _role == null ? null : _role.id,
          roleName: _role == null ? null : _role.roleName);

//check the current assigned department to this user
      final _department =
          Provider.of<DepartmentProvider>(context, listen: false)
              .findById(contactPerson.departmentId);
      _editedDepartment = Department(
          id: _department == null ? null : _department.id,
          departmentName:
              _department == null ? null : _department.departmentName);

      setState(() {
        _isLoading = false;
        _isInit = false;
      });
    }

    super.didChangeDependencies();
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

    await Provider.of<SharedContactListProvider>(context, listen: false)
        .editContactPerson(contactPersonID, _editedRole, _editedDepartment,contactPerson);

    Navigator.of(context).pop();

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
        title: Text('Edit Contact Person'),
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
                    key: _form,
                    child: ListView(
                      children: [
                        //Role Drop Down List
                        DropdownButtonFormField(
                          hint: Text('Select Role'),
                          isExpanded: true,
                          value: _editedRole.id==null?loadedRole[0]:_editedRole,
                          items: loadedRole.map((Role roles) {
                            return DropdownMenuItem<Role>(
                              child: Text(roles.roleName),
                              value: roles,
                            );
                          }).toList(),
                          onChanged: (value) {
                            setState(() {
                             _editedRole = value;
                            });
                          },
                        ),

                        //Department Drop Down List
                        DropdownButtonFormField(
                          hint: Text('Select Department'),
                          isExpanded: true,
                          value: _editedDepartment.id==null?loadedDepartment[0]:_editedDepartment,
                          items: loadedDepartment.map((Department departments) {
                            return DropdownMenuItem<Department>(
                              child: Text(departments.departmentName),
                              value: departments,
                            );
                          }).toList(),
                          onChanged: (value) {
                            setState(() {
                              _editedDepartment = value;
                            });
                          },
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
