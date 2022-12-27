import 'dart:convert';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:sms_autofill/sms_autofill.dart';
import 'package:pinput/pinput.dart';
import '../widgets/dialog.dart';

import '../providers/auth_provider.dart';
import '../providers/personalContactList_provider.dart';
import '../providers/profile.dart';

import '../screens/register_screen.dart';
import '../screens/sendOTP_screen.dart';
import '../screens/personalContactList_screen.dart';
import 'administrator_screen.dart';

class VerifyOTPScreen extends StatefulWidget {
  static const routeName = '/verifyOTP_page';

  @override
  State<VerifyOTPScreen> createState() => _VerifyOTPScreenState();
}

class _VerifyOTPScreenState extends State<VerifyOTPScreen> with CodeAutoFill {
  FirebaseAuth auth = FirebaseAuth.instance;
  var codeValue = '';

  Future<bool> checkIsAdmin() async {
    final prefs = await SharedPreferences.getInstance();
    if (!prefs.containsKey('userData')) {
      //if there is no data is being stored in the userData key

      return false;
    }
    final extractedUserData = json.decode(prefs.getString('userData')) as Map<
        String, Object>; //string key and object value(dataTime, token,userId)

    print(extractedUserData['isAdministrator']);
    return extractedUserData['isAdministrator'];
  }

  @override
  void codeUpdated() {
    setState(() {
      print('codeUpdated');
    });
  }

  void listenOtp() async {
    await SmsAutoFill().unregisterListener();
    listenForCode();
    await SmsAutoFill().listenForCode;
  }

  @override
  void dispose() {
    SmsAutoFill().unregisterListener();
    super.dispose();
  }

  @override
  void initState() {
    listenOtp();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    final phoneNumber = ModalRoute.of(context).settings.arguments;

    final defaultPinTheme = PinTheme(
      width: 56,
      height: 56,
      textStyle: TextStyle(
          fontSize: 20,
          color: Color.fromRGBO(30, 60, 87, 1),
          fontWeight: FontWeight.w600),
      decoration: BoxDecoration(
        border: Border.all(color: Color.fromRGBO(234, 239, 243, 1)),
        borderRadius: BorderRadius.circular(20),
      ),
    );

    final focusedPinTheme = defaultPinTheme.copyDecorationWith(
      border: Border.all(color: Color.fromRGBO(114, 178, 238, 1)),
      borderRadius: BorderRadius.circular(8),
    );

    final submittedPinTheme = defaultPinTheme.copyWith(
      decoration: defaultPinTheme.decoration.copyWith(
        color: Color.fromRGBO(234, 239, 243, 1),
      ),
    );
    var code = '';
    return Scaffold(
      appBar: AppBar(
        title: Text('Verify OTP'),
        backgroundColor: Theme.of(context).primaryColor,
        leading: IconButton(
          onPressed: () {
            Navigator.pop(context);
          },
          icon: Icon(
            Icons.arrow_back,
          ),
        ),
      ),
      body: Container(
        padding: const EdgeInsets.symmetric(
          horizontal: 25,
        ),
        alignment: Alignment.center,
        child: SingleChildScrollView(
            child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Image.asset('assets/images/authenticate.png'),
            SizedBox(
              height: 20,
            ),
            Text(
              'Phone Verification',
              style: TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.bold,
              ),
            ),
            SizedBox(
              height: 10,
            ),
            Text(
              'We need to register your phone before getting started.',
              style: TextStyle(fontSize: 16),
              textAlign: TextAlign.center,
            ),
            SizedBox(
              height: 10,
            ),

            //enter code area
            // Pinput(
            //   length: 6,
            //   showCursor: true,
            //   onChanged: (value) {
            //     code = value;
            //   },
            // ),
            PinFieldAutoFill(
              currentCode: codeValue,
              codeLength: 6,
              onCodeChanged: (code) {
                setState(() {
                  codeValue = code.toString();
                });
              },
            ),
            SizedBox(
              height: 20,
            ),
            SizedBox(
              height: 40,
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () async {
                  try {
                    // Create a PhoneAuthCredential with the code
                    PhoneAuthCredential credential =
                        PhoneAuthProvider.credential(
                            verificationId: SendOTPScreen.verify,
                            smsCode: codeValue);
                    // Sign the user in (or link) with the credential
                    //it will check whether the phone has been register before by Firebase authentication itself
                    //it will auto register for the user
                    //if already existed, sign in the user
                    await auth.signInWithCredential(credential).then((_) async {
                      //after the phone number has been authentiated, check whether the user is register or sign in
                      Profile userProfile =
                          await Provider.of<PersonalContactListProvider>(
                                  context,
                                  listen: false)
                              .fetchAndReturnContactPersonProfile(
                        phoneNumber.toString().substring(1),
                      );

                      final FirebaseAuth auth = FirebaseAuth.instance;
                      final User result = auth.currentUser;

                      String _userId = result.uid;
                      print(_userId);
                      print(userProfile);

                      //register
                      if (userProfile == null) {
                        Navigator.pop(context);
                        Navigator.pushNamed(
                          context,
                          RegisterScreen.routeName,
                          arguments: phoneNumber.toString().substring(1),
                        );
                      } else {
                        //sign in
                        //check whether the user is system admin
                        await Provider.of<AuthProvider>(context, listen: false)
                            .checkIdentity();

                        Future<bool> isAdmin = checkIsAdmin();
                        if (isAdmin == true) {
                          print('isAdmin');
                          Navigator.pop(context);
                          Navigator.pushNamed(
                              context, AdministratorScreen.routeName);
                        } else {
                          print('notAdmin');

                          Navigator.pop(context);
                          Navigator.pushNamed(
                              context, PersonalContactListScreen.routeName);
                        }
                      }
                    });
                  } catch (err) {
                    Dialogs.showMyDialog(context, err);
                  }
                },
                child: Text('Verify Phone Number'),
              ),
            ),
            TextButton(
              onPressed: () {
                Navigator.pop(context);
              },
              child: Text('Edit Phone Number?'),
            ),
          ],
        )),
      ),
    );
  }
}
