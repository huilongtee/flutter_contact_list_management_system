import 'package:flutter/material.dart';
import 'package:flutter_contact_list_management_system/screens/administrator_screen.dart';
import 'package:provider/provider.dart';

import '../providers/auth_provider.dart';
import '../providers/profile_provider.dart';
import '../providers/sharedContactList_provider.dart';
import '../providers/personalContactList_provider.dart';
import '../providers/department_provider.dart';
import '../providers/company_provider.dart';
import '../providers/role_provider.dart';
import '../providers/administrator_provider.dart';

import '../screens/login_screen.dart';
import '../screens/register_screen.dart';
import '../screens/splash_screen.dart';
import '../screens/sharedContactList_screen.dart';
import '../screens/personalContactList_screen.dart';
import '../screens/profile_screen.dart';
import '../screens/editProfile_screen.dart';
import '../screens/addCompany_screen.dart';
import '../screens/editContactPerson_screen.dart';
import '../screens/role_screen.dart';
import '../screens/department_screen.dart';
import '../screens/addRole_screen.dart';
import '../screens/addDepartment_screen.dart';

void main() => runApp(MyApp());

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(
          create: (context) => AuthProvider(),
        ),
        // ChangeNotifierProvider(
        //   create: (context) => ProfileProvider(),
        // ),
        ChangeNotifierProxyProvider<AuthProvider, ProfileProvider>(
          update: (context, auth, previousProfile) => ProfileProvider(
              auth.token,
              auth.userId,
              previousProfile == null
                  ? []
                  : previousProfile
                      .profile), //update=provider version>=4.0.0, else=builder/create
        ),
        // ChangeNotifierProvider(
        //   create: (context) => PersonalContactListProvider(),
        // ),

        ChangeNotifierProxyProvider<AuthProvider, PersonalContactListProvider>(
          update: (context, auth, personalContactList) =>
              PersonalContactListProvider(
                  auth.token,
                  auth.userId,
                  personalContactList == null
                      ? []
                      : personalContactList
                          .personalContactList), //update=provider version>=4.0.0, else=builder/create
        ),

        ChangeNotifierProxyProvider<AuthProvider, SharedContactListProvider>(
          update: (context, auth, sharedContactList) => SharedContactListProvider(
              auth.token,
              auth.userId,
              sharedContactList == null
                  ? []
                  : sharedContactList
                      .sharedContactList), //update=provider version>=4.0.0, else=builder/create
        ),

        ChangeNotifierProxyProvider<AuthProvider, RoleProvider>(
          update: (context, auth, roleList) => RoleProvider(
              auth.token,
              auth.userId,
              roleList == null
                  ? []
                  : roleList
                      .roleList), //update=provider version>=4.0.0, else=builder/create
        ),

        ChangeNotifierProxyProvider<AuthProvider, DepartmentProvider>(
          update: (context, auth, departmentList) => DepartmentProvider(
              auth.token,
              auth.userId,
              departmentList == null
                  ? []
                  : departmentList
                      .departmentList), //update=provider version>=4.0.0, else=builder/create
        ),

        ChangeNotifierProxyProvider<AuthProvider, CompanyProvider>(
          update: (context, auth, previousCompany) => CompanyProvider(
              auth.token,
              previousCompany == null
                  ? []
                  : previousCompany
                      .companies), //update=provider version>=4.0.0, else=builder/create
        ),
        // ChangeNotifierProvider(
        //   create: (context) => AdministratorProvider(),
        // ),
      ],
      child: Consumer<AuthProvider>(
        builder: (context, auth, _) => MaterialApp(
          debugShowCheckedModeBanner: false,
          //consumer only will rebuilt the MaterialApp
          title: 'My-List',
          theme: ThemeData(
            primaryColor: Color.fromARGB(255, 255, 196, 0),
            fontFamily: 'Lato',
            textTheme: ThemeData.light().textTheme.copyWith(
                  bodyText1: TextStyle(
                    color: Color.fromRGBO(20, 51, 51, 1),
                    fontSize: 16,
                  ),
                ),
          ),
          home: !auth.isAuth
              ? FutureBuilder(
                  future: auth.tryAutoLogin(),
                  builder: (context, authResultSnpshot) =>
                      (authResultSnpshot.connectionState ==
                              ConnectionState.waiting)
                          ? SplashScreen()
                          : LoginScreen())
              : auth.isAdministrator
                  ? AdministratorScreen()
                  : PersonalContactListScreen(),
          routes: {
            SharedContactListScreen.routeName: (context) =>
                SharedContactListScreen(),
            PersonalContactListScreen.routeName: (context) =>
                PersonalContactListScreen(),
            ProfileScreen.routeName: (context) => ProfileScreen(),
            EditProfileScreen.routeName: (context) => EditProfileScreen(),
            RegisterScreen.routeName: (context) => RegisterScreen(),
            AddCompanyScreen.routeName: (context) => AddCompanyScreen(),
            AddRoleScreen.routeName: (context) => AddRoleScreen(),
            RoleScreen.routeName: (context) => RoleScreen(),
            DepartmentScreen.routeName: (context) => DepartmentScreen(),
            AddDepartmentScreen.routeName: (context) => AddDepartmentScreen(),
            EditContactPersonScreen.routeName: (context) =>
                EditContactPersonScreen(),
          },
        ),
      ),
    );
  }
}
