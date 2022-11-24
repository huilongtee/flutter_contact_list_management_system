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
  var _editedContactPersonDetail = Profile(
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

  List<Role> loadedRole = [];
  List<Department> loadedDepartment = [];
  Role _role = null;
  Department _department = null;

  @override
  void didChangeDependencies() {
    if (_isInit) {
      setState(() {
        _isLoading = true;
      });

      final contactPersonID =
          ModalRoute.of(context).settings.arguments as String;
      final contactPerson =
          Provider.of<SharedContactListProvider>(context, listen: false)
              .findById(contactPersonID);

      _role = Provider.of<RoleProvider>(context, listen: false)
          .findById(contactPerson.roleId);

      _department = Provider.of<DepartmentProvider>(context, listen: false)
          .findById(contactPerson.departmentId);

      loadedRole = Provider.of<RoleProvider>(context, listen: false).roleList;
      loadedDepartment = Provider.of<DepartmentProvider>(context, listen: false)
          .departmentList;
      _editedContactPersonDetail = Profile(
        id: contactPersonID,
        fullName: contactPerson.fullName,
        phoneNumber: contactPerson.phoneNumber,
        emailAddress: contactPerson.emailAddress,
        homeAddress: contactPerson.homeAddress,
        imageUrl: contactPerson.imageUrl,
        companyId: contactPerson.companyId,
        roleId: contactPerson.roleId,
        departmentId: contactPerson.departmentId,
      );

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
    if (_editedContactPersonDetail.id != null) {
      await Provider.of<SharedContactListProvider>(context, listen: false)
          .editContactPerson(
              _editedContactPersonDetail.id, _editedContactPersonDetail);

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
                          value: _editedContactPersonDetail.roleId,
                          items: loadedRole.map((Role roles) {
                            return DropdownMenuItem<String>(
                              child: Text(roles.roleName),
                              value: roles.id,
                            );
                          }).toList(),
                          onChanged: (value) {
                            setState(() {
                              _editedContactPersonDetail = Profile(
                                id: _editedContactPersonDetail.id,
                                fullName: _editedContactPersonDetail.fullName,
                                phoneNumber:
                                    _editedContactPersonDetail.phoneNumber,
                                emailAddress:
                                    _editedContactPersonDetail.emailAddress,
                                homeAddress:
                                    _editedContactPersonDetail.homeAddress,
                                imageUrl: _editedContactPersonDetail.imageUrl,
                                companyId: _editedContactPersonDetail.companyId,
                                roleId: value,
                                departmentId:
                                    _editedContactPersonDetail.departmentId,
                              );
                            });
                          },
                        ),

                        //Department Drop Down List
                        DropdownButtonFormField(
                          hint: Text('Select Department'),
                          isExpanded: true,
                          value: _editedContactPersonDetail,
                          items: loadedDepartment.map((Department departments) {
                            return DropdownMenuItem<String>(
                              child: Text(departments.departmentName),
                              value: departments.id,
                            );
                          }).toList(),
                          onChanged: (value) {
                            setState(() {
                              _editedContactPersonDetail = Profile(
                                id: _editedContactPersonDetail.id,
                                fullName: _editedContactPersonDetail.fullName,
                                phoneNumber:
                                    _editedContactPersonDetail.phoneNumber,
                                emailAddress:
                                    _editedContactPersonDetail.emailAddress,
                                homeAddress:
                                    _editedContactPersonDetail.homeAddress,
                                imageUrl: _editedContactPersonDetail.imageUrl,
                                companyId: _editedContactPersonDetail.companyId,
                                roleId: _editedContactPersonDetail.roleId,
                                departmentId: value,
                              );
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
