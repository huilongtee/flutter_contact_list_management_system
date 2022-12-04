import 'dart:convert';
import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:http/http.dart' as http;
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../providers/profile.dart';
import '../providers/profile_provider.dart';
import '../providers/role_provider.dart';
import '../providers/company_provider.dart';
import '../providers/department_provider.dart';
import '../screens/editProfile_screen.dart';
import '../widgets/profile_items.dart';
import '../widgets/app_drawer.dart';

class ProfileScreen extends StatefulWidget {
  static const routeName = '/profile';

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  var _isInit = true;
  var _isLoading = false;
  var loadedProfile = null;
  var role = null;
  var department = null;
  var company = null;
  var result = null;
  @override
  void didChangeDependencies() {
    if (_isInit) {
      setState(() {
        _isLoading = true;
      });

      Provider.of<ProfileProvider>(
        context,
        listen: false,
      ).fetchAndSetProfile().then((_) {
        final result = Provider.of<ProfileProvider>(
          context,
          listen: false,
        ).profile;
        loadedProfile = Provider.of<ProfileProvider>(
          context,
          listen: false,
        ).findById(result[0].id);
        Provider.of<RoleProvider>(context, listen: false)
            .fetchAndSetRoleList()
            .then((_) {
          role = Provider.of<RoleProvider>(context, listen: false)
              .findById(loadedProfile.roleId);

          Provider.of<DepartmentProvider>(context, listen: false)
              .fetchAndSetDepartmentList()
              .then((_) {
            setState(() {
              department =
                  Provider.of<DepartmentProvider>(context, listen: false)
                      .findById(loadedProfile.departmentId);
              Provider.of<CompanyProvider>(context, listen: false)
                  .fetchAndSetCompanyName(loadedProfile.companyId);
              _isLoading = false;
            });
          });
        });
        _isInit = false;
      });
    }

    super.didChangeDependencies();
  }

  @override
  Widget build(BuildContext context) {
    final companyNameResult =
        Provider.of<CompanyProvider>(context, listen: false).getCompanyName;

    print(companyNameResult);
    return Scaffold(
      appBar: AppBar(
        title: Text('My-List'),
        elevation: 0,
        backgroundColor: Theme.of(context).primaryColor,
        actions: [
          IconButton(
            onPressed: () {
              Navigator.pushNamed(context, EditProfileScreen.routeName,
                  arguments: loadedProfile.id);
            },
            icon: Icon(Icons.edit),
          ),
        ],
      ),
      drawer: AppDrawer(),
      body: _isLoading == true
          ? Center(
              child: CircularProgressIndicator(),
            )
          : Container(
              child: Column(
                children: [
                  Container(
                    padding: const EdgeInsets.fromLTRB(18, 10, 18, 25),
                    child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Container(
                            height: 70,
                            width: 70,
                            margin: const EdgeInsets.only(left: 20, right: 20),
                            child: loadedProfile.imageUrl.isEmpty
                                ? CircleAvatar(
                                    backgroundColor: Colors.white,
                                    child: Text(
                                      loadedProfile.fullName[0].toUpperCase(),
                                      style: TextStyle(
                                        fontWeight: FontWeight.bold,
                                        fontSize: 28,
                                      ),
                                    ),
                                  )
                                : CircleAvatar(
                                    backgroundImage:
                                        NetworkImage(loadedProfile.imageUrl),
                                  ),
                          ),
                          Padding(
                            padding: const EdgeInsets.only(right: 30),
                            child: Column(
                              children: [
                                Text(
                                  loadedProfile.fullName,
                                  style: TextStyle(
                                    fontSize: 20,
                                    color: Colors.white,
                                  ),
                                ),
                                Text(
                                  role == null ? 'Role:-' : role.roleName,
                                  style: TextStyle(
                                    fontSize: 20,
                                    color: Colors.white,
                                  ),
                                ),
                                Text(
                                  department == null
                                      ? 'Department:-'
                                      : department.departmentName,
                                  style: TextStyle(
                                    fontSize: 20,
                                    color: Colors.white,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ]),
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.only(
                        bottomLeft: Radius.circular(50),
                        bottomRight: Radius.circular(50),
                      ),
                      color: Theme.of(context).primaryColor,
                    ),
                  ),
                  Expanded(
                    child: SingleChildScrollView(
                      child: Padding(
                        padding: const EdgeInsets.only(
                          left: 18,
                          right: 18,
                          top: 18,
                        ),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Row(
                              children: [
                                ProfileWidget(
                                  size: 25,
                                  width: 50,
                                  height: 50,
                                  bgColor: Theme.of(context).primaryColor,
                                  index: 0,
                                  borderColor: Colors.grey,
                                ),
                                SizedBox(
                                  width: 10,
                                ),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        loadedProfile.phoneNumber,
                                        style: TextStyle(fontSize: 18),
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                            SizedBox(
                              height: 20,
                            ),
                            Row(
                              children: [
                                ProfileWidget(
                                  size: 25,
                                  width: 50,
                                  height: 50,
                                  bgColor: Theme.of(context).primaryColor,
                                  index: 1,
                                  borderColor: Colors.grey,
                                ),
                                SizedBox(
                                  width: 10,
                                ),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        loadedProfile.emailAddress,
                                        style: TextStyle(fontSize: 18),
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                            SizedBox(
                              height: 20,
                            ),
                            Row(
                              children: [
                                ProfileWidget(
                                  size: 25,
                                  width: 50,
                                  height: 50,
                                  bgColor: Theme.of(context).primaryColor,
                                  index: 2,
                                  borderColor: Colors.grey,
                                ),
                                SizedBox(
                                  width: 10,
                                ),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        loadedProfile.homeAddress,
                                        style: TextStyle(fontSize: 18),
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                            SizedBox(
                              height: 20,
                            ),
                            Row(
                              children: [
                                ProfileWidget(
                                  size: 25,
                                  width: 50,
                                  height: 50,
                                  bgColor: Theme.of(context).primaryColor,
                                  index: 3,
                                  borderColor: Colors.grey,
                                ),
                                SizedBox(
                                  width: 10,
                                ),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        // 'company.companyName',
                                        companyNameResult,
                                        style: TextStyle(fontSize: 18),
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                            SizedBox(
                              height: 20,
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
    );
  }
}
