import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:provider/provider.dart';

import '../providers/auth_provider.dart';

class ChangePasswordScreen extends StatefulWidget {
  static const routeName = '/changePassword';

  @override
  State<ChangePasswordScreen> createState() => _ChangePasswordScreenState();
}

class _ChangePasswordScreenState extends State<ChangePasswordScreen> {
  final _form = GlobalKey<FormState>();
  String newPassword = '';
  final newPasswordController = TextEditingController();
  User currentUser = null;
  final FirebaseAuth auth = FirebaseAuth.instance;

  @override
  void initState() {
    getUserData();
    super.initState();
  }

  void getUserData() {
    final User result = auth.currentUser;

    setState(() {
      currentUser = result;
    });
  }

  @override
  void dispose() {
    newPasswordController.dispose();
    super.dispose();
  }

  changePassword() async {
    try {
      await currentUser.updatePassword(newPassword);
      FirebaseAuth.instance.signOut();
      Navigator.of(context).pop();
      Navigator.of(context).pushReplacementNamed('/');
      Provider.of<AuthProvider>(context, listen: false).logout();

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          backgroundColor: Colors.black,
          content: Text('Your password has been changed. Please login again'),
        ),
      );
    } catch (err) {
      print(err);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Change Password'),
        backgroundColor: Theme.of(context).primaryColor,
      ),
      backgroundColor: Colors.indigo[50],
      body: Form(
        key: _form,
        child: Padding(
          padding: const EdgeInsets.symmetric(
            vertical: 20,
            horizontal: 25,
          ),
          child: ListView(
            children: [
              // SizedBox(
              //   height: 100,
              // ),
              Padding(
                padding: const EdgeInsets.all(10),
                // child: SvgPicture.asset('assets/images/change password.svg'),
                // child: SvgPicture.asset('assets/images/user-tie-solid.svg'),
                child: Image.asset('assets/images/change password.png'),
          
              ),
              Container(
                margin: EdgeInsets.symmetric(vertical: 10),
                child: TextFormField(
                  autofocus: false,
                  obscureText: true,
                  decoration: InputDecoration(
                    labelText: "New Password",
                    hintText: "Enter New Password",
                    labelStyle: TextStyle(fontSize: 20),
                    border: OutlineInputBorder(),
                    errorStyle: TextStyle(
                      color: Colors.black26,
                      fontSize: 15,
                    ),
                  ),
                  controller: newPasswordController,
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please Enter Password';
                    }
                    return null;
                  },
                ),
              ),
              ElevatedButton(
                onPressed: () {
                  if (_form.currentState.validate()) {
                    setState(() {
                      newPassword = newPasswordController.text;
                    });
                    changePassword();
                  }
                },
                child: Text(
                  'Change Password',
                  style: TextStyle(
                    fontSize: 18,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
