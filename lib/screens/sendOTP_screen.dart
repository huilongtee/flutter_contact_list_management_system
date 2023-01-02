import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:intl_phone_field/intl_phone_field.dart';

import 'package:provider/provider.dart';
import 'package:sms_autofill/sms_autofill.dart';
import '../providers/personalContactList_provider.dart';
import '../providers/profile.dart';

import '../widgets/dialog.dart';

import '../screens/verifyOTP_screen.dart';

class SendOTPScreen extends StatefulWidget {
  static const routeName = '/sendOTP_page';
  static String verify = '';
  @override
  State<SendOTPScreen> createState() => _SendOTPScreenState();
}

class _SendOTPScreenState extends State<SendOTPScreen> {
  String phoneNumber = '';
  // final phoneNumberController = TextEditingController();
  void getAppSignatureID() async {
    await SmsAutoFill().getAppSignature;
  }

  FirebaseAuth auth = FirebaseAuth.instance;
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Phone Verification'),
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
            Image.asset(
              'assets/images/authenticate.png',
            ),
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
            IntlPhoneField(
              decoration: InputDecoration(
                labelText: 'Phone Number',
              ),
              initialCountryCode: 'MY',
              inputFormatters: [FilteringTextInputFormatter.digitsOnly],
              disableLengthCheck: true,
              validator: (value) {
                if (value.completeNumber.substring(1).isEmpty ||
                    value.completeNumber.substring(1).length < 10 ||
                    value.completeNumber.substring(1).length > 12) {
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
            SizedBox(
              height: 40,
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () async {
                  getAppSignatureID();

                  await FirebaseAuth.instance.verifyPhoneNumber(
                    phoneNumber: phoneNumber,
                    verificationCompleted: (PhoneAuthCredential credential) {},
                    verificationFailed: (FirebaseAuthException e) {
                      Dialogs.showMyDialog(context, e.code);
                    },
                    codeSent: (String verificationId, int resendToken) {
                      SendOTPScreen.verify = verificationId;
                      Navigator.pop(context);
                      Navigator.pushNamed(context, VerifyOTPScreen.routeName,
                          arguments: phoneNumber);
                    },
                    codeAutoRetrievalTimeout: (String verificationId) {},
                  );
                },
                child: Text('Send the code'),
              ),
            ),
          ],
        )),
      ),
    );
  }
}
