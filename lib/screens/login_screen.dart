import 'dart:math';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../screens/verifyOTP_screen.dart';
import 'package:intl_phone_field/intl_phone_field.dart';
import 'package:provider/provider.dart';
import 'package:sms_autofill/sms_autofill.dart';
import '../providers/auth_provider.dart';
import '../models/http_exception.dart';
import '../screens/register_screen.dart';
import '../screens/sendOTP_screen.dart';
import '../widgets/dialog.dart';

enum AuthMode { Signup, Login }

class LoginScreen extends StatefulWidget {
  static const routeName = '/login';
  
  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  String phoneNumber = '';

  void getAppSignatureID() async {
    await SmsAutoFill().getAppSignature;
  }

  @override
  Widget build(BuildContext context) {
    final deviceSize = MediaQuery.of(context).size;

    return Scaffold(
      body: Stack(
        children: [
          Container(
            decoration: BoxDecoration(color: Color.fromRGBO(204, 204, 255, 1)),
          ),
          SingleChildScrollView(
            child: Container(
              height: deviceSize.height,
              width: deviceSize.width,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: <Widget>[
                  Flexible(
                    child: Container(
                      margin: EdgeInsets.only(bottom: 20.0),
                      child: Text(
                        'My-List',
                        style: TextStyle(
                          color:
                              // Theme.of(context).accentTextTheme.headline1.color,
                              // Theme.of(context).primaryTextTheme.headline1.color,
                              Colors.white,
                          fontSize: 50,
                          fontFamily: 'Anton',
                          fontWeight: FontWeight.normal,
                        ),
                      ),
                    ),
                  ),
                  Flexible(
                    flex: deviceSize.width > 600 ? 2 : 1,
                    child: Card(
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10.0),
                      ),
                      elevation: 8.0,
                      child: Container(
                        height: 290,
                        constraints: BoxConstraints(minHeight: 290),
                        width: deviceSize.width * 0.75,
                        padding: EdgeInsets.all(16.0),
                        child: SingleChildScrollView(
                        
                          child: Column(
                           
                            children: [
                         SizedBox(height: 20,),
                              IntlPhoneField(
                                decoration: InputDecoration(
                                  labelText: 'Phone Number',
                                ),
                                initialCountryCode: 'MY',
                                inputFormatters: [
                                  FilteringTextInputFormatter.digitsOnly
                                ],
                                disableLengthCheck: true,
                                validator: (value) {
                                  if (value.completeNumber
                                          .substring(1)
                                          .isEmpty ||
                                      value.completeNumber.substring(1).length <
                                          10 ||
                                      value.completeNumber.substring(1).length >
                                          12) {
                                    return 'Phone number must greater than 10 digits and lesser than 12';
                                  }
                                },
                                onChanged: (value) {
                                  phoneNumber = value.completeNumber;
                                },
                              ),
                              SizedBox(
                                height: 20,
                              ),
                              ElevatedButton(
                                child: Text(
                                  'Login',
                                  style: TextStyle(
                                    // color: Colors.white,
                                    // color:Theme.of(context).accentTextTheme.headline1.color,
                                    color: Theme.of(context)
                                        .primaryTextTheme
                                        .headline1
                                        .color,
                                  ),
                                ),
                                onPressed: () async {
                                  getAppSignatureID();

                                  await FirebaseAuth.instance.verifyPhoneNumber(
                                    phoneNumber: phoneNumber,
                                    verificationCompleted:
                                        (PhoneAuthCredential credential) {},
                                    verificationFailed:
                                        (FirebaseAuthException e) {
                                      Dialogs.showMyDialog(context, e.code);
                                    },
                                    codeSent: (String verificationId,
                                        int resendToken) {
                                      SendOTPScreen.verify = verificationId;
                                      Navigator.pushNamed(
                                          context, VerifyOTPScreen.routeName,
                                          arguments: phoneNumber);
                                    },
                                    codeAutoRetrievalTimeout:
                                        (String verificationId) {},
                                  );
                                },
                                style: ElevatedButton.styleFrom(
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(30),
                                  ),
                                  padding: EdgeInsets.symmetric(
                                      horizontal: 30.0, vertical: 8.0),
                                  backgroundColor:
                                      Theme.of(context).primaryColor,
                                ),
                              ),
                              SizedBox(
                                height: 40,
                              ),
                              TextButton(
                                child: Text('Register for an account'),
                                onPressed: () {
                                  // Navigator.pushNamed(context, RegisterScreen.routeName);
                                  Navigator.pushNamed(
                                      context, SendOTPScreen.routeName);
                                },
                                style: TextButton.styleFrom(
                                  tapTargetSize:
                                      MaterialTapTargetSize.shrinkWrap,
                                  padding: EdgeInsets.symmetric(
                                      horizontal: 30.0, vertical: 4),
                                  foregroundColor: Theme.of(context)
                                      .primaryTextTheme
                                      .headline1
                                      .color,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
