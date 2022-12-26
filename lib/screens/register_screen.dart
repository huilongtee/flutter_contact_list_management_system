import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:intl_phone_field/intl_phone_field.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../helper/location_helper.dart';
import 'package:provider/provider.dart';
import '../providers/auth_provider.dart';
import '../models/http_exception.dart';
import 'package:flutter/services.dart';
import 'package:firebase_database/firebase_database.dart';

class RegisterScreen extends StatefulWidget {
  static const routeName = '/register';

  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  int currentStep = 0;
  bool isCompleted = false;
  final GlobalKey<FormState> _formKey = GlobalKey();
  Map<String, dynamic> _authData = {
    'fullName': '',
    'homeAddress': '',
    'email': '',
   
  };
  var _isLoading = false;
  var _isLocationLoading = false;
  String phoneNumber;
  final homeAddressController = TextEditingController();
  final passwordController = TextEditingController();
  @override
  void didChangeDependencies() {
    final phoneNumber = ModalRoute.of(context).settings.arguments;

    this.phoneNumber = phoneNumber;
    print(this.phoneNumber);
    super.didChangeDependencies();
  }

  Future<void> _getCurrentUserLocation() async {
    setState(() {
      _isLocationLoading = true;
    });

    try {
      LocationPermission locpermission;
      Position _position;

      await Geolocator.requestPermission();

      locpermission = await Geolocator.checkPermission();
      if (locpermission == LocationPermission.denied) {
        locpermission = await Geolocator.requestPermission();
        if (locpermission == LocationPermission.denied) {
          return;
        }
      }

      if (locpermission == LocationPermission.deniedForever) {
        return;
      }

      if (locpermission == LocationPermission.always ||
          locpermission == LocationPermission.whileInUse) {
        _position = await Geolocator.getCurrentPosition();
        var latitude = _position.latitude;
        var longitude = _position.longitude;

        final address =
            await LocationHelper.getPlaceAddress(latitude, longitude);

        setState(() {
          homeAddressController.text = address;
          _authData['homeAddress'] = address;

          _isLocationLoading = false;
        });
      }
    } catch (error) {
      return;
    }
  }

  List<Step> getSteps() => [
        Step(
          state: currentStep > 0 ? StepState.complete : StepState.indexed,
          isActive: currentStep >= 0,
          title: Text('Account Details'),
          content: Container(
            child: Column(children: [
              TextFormField(
                decoration: InputDecoration(labelText: 'Full Name'),
                keyboardType: TextInputType.text,
                validator: (value) {
                  if (value.isEmpty) {
                    return 'Please fill in your name';
                  }
                },
                onSaved: (value) {
                  _authData['fullName'] = value;
                },
              ),
              TextFormField(
                decoration: InputDecoration(labelText: 'E-Mail'),
                keyboardType: TextInputType.emailAddress,
                validator: (value) {
                  if (value.isEmpty || !value.contains('@')) {
                    return 'Invalid email!';
                  }
                },
                onSaved: (value) {
                  _authData['email'] = value;
                },
              ),

              // IntlPhoneField(
              //   decoration: InputDecoration(
              //     labelText: 'Phone Number',
              //   ),
              //   initialCountryCode: 'MY',
              //   inputFormatters: [FilteringTextInputFormatter.digitsOnly],
              //   disableLengthCheck: true,
              //   validator: (value) {
              //     if (value.completeNumber.substring(1).isEmpty ||
              //         value.completeNumber.substring(1).length < 10 ||
              //         value.completeNumber.substring(1).length > 12) {
              //       return 'Phone number must greater than 10 digits and lesser than 12';
              //     }
              //   },
              //   onSaved: (value) {
              //     _authData['phoneNo'] = value.completeNumber.substring(1);
              //   },
              // ),

              //     TextFormField(

              //   decoration: InputDecoration(labelText: 'Phone Number'),
              //   keyboardType: TextInputType.phone,

              //   inputFormatters: [FilteringTextInputFormatter.deny(RegExp(r'[ \s-]'))],
              //   validator: (value) {
              //     if (value.isEmpty || value.length < 10 || value.length > 11) {
              //       return 'Phone number must greater than 10 digits and lesser than 12';
              //     }
              //   },
              //   onSaved: (value) {
              //     _authData['phoneNo'] = value;
              //   },
              // ),
            ]),
          ),
        ),
        // Step(
        //   state: currentStep > 1 ? StepState.complete : StepState.indexed,
        //   isActive: currentStep >= 1,
        //   title: Text('Password'),
        //   content: Container(
        //     child: Column(
        //       children: [
        //         TextFormField(
        //           decoration: InputDecoration(labelText: 'Password'),
        //           obscureText: true,
        //           controller: passwordController,
        //           validator: (value) {
        //             if (value.isEmpty || value.length < 5) {
        //               return 'Password is too short!';
        //             }
        //           },
        //           onSaved: (value) {
        //             _authData['password'] = value;
        //           },
        //         ),
        //         TextFormField(
        //           decoration: InputDecoration(labelText: 'Confirm Password'),
        //           obscureText: true,
        //           validator: (value) {
        //             if (value != passwordController.text) {
        //               return 'Passwords do not match!';
        //             }
        //           },
        //         ),
        //       ],
        //     ),
        //   ),
        // ),
        Step(
          isActive: currentStep >= 1,
          title: Text('Address'),
          content: Container(
            child: Row(
              children: [
                Expanded(
                  child: TextFormField(
                    decoration: InputDecoration(labelText: 'Home Address'),
                    controller: homeAddressController,
                    validator: (value) {
                      if (value.isEmpty) {
                        return 'Please enter your home address.';
                      }
                    },
                    onSaved: (value) {
                      _authData['homeAddress'] = value;
                    },
                  ),
                ),
                if (_isLocationLoading)
                  CircularProgressIndicator()
                else
                  IconButton(
                    icon: Icon(Icons.location_on),
                    onPressed: _getCurrentUserLocation,
                  ),
              ],
            ),
          ),
        ),
      ];
  void _showErrorDialog(String message) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('An Error Occurred'),
        content: Text(message),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.of(context).pop();
            },
            child: Text('Okay'),
          ),
        ],
      ),
    );
  }

  Future<void> _submit() async {
    if (!_formKey.currentState.validate()) {
      // Invalid!
      return;
    }
    _formKey.currentState.save();
    setState(() {
      _isLoading = true;
    });

    try {
      // Log user in
      await Provider.of<AuthProvider>(context, listen: false).signup(
        _authData['email'],
       
        _authData['fullName'],
        phoneNumber,
        _authData['homeAddress'],
      );
      SharedPreferences _sharedPreferences =
          await SharedPreferences.getInstance();
      if (!_sharedPreferences.getString('userData').isEmpty) {
        Navigator.pop(context);
      }
    } on HttpException catch (error) {
      //only handle special case which error from Httpexception only
      var errorMessage = 'Authentication failed';
      if (error.toString().contains('EMAIL_EXISTS')) {
        errorMessage = 'This email address is already in use.';
      } else if (error.toString().contains('INVALID_EMAIL')) {
        errorMessage = 'This is not a valid email address';
      } else if (error.toString().contains('WEAK_PASSWORD')) {
        errorMessage = 'This password is too weak.';
      } else if (error.toString().contains('EMAIL_NOT_FOUND')) {
        errorMessage = 'Could not find a user with that email.';
      } else if (error.toString().contains('INVALID_PASSWORD')) {
        errorMessage = 'Invalid password.';
      } else if (error.toString().contains('phoneNumberExisted')) {
        errorMessage = 'The phone number has been taken';
      }
      _showErrorDialog(errorMessage);
    } catch (error) {
      const errorMessage = 'Could not authenticate you. Please try again.';
      _showErrorDialog(errorMessage);
    }

    setState(() {
      _isLoading = false;
    });
  }

  @override
  void dispose() {
    homeAddressController.dispose();
    passwordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Register An Account'),
        backgroundColor: Theme.of(context).primaryColor,
      ),
      body: Theme(
        data: Theme.of(context).copyWith(
          colorScheme:
              ColorScheme.light(primary: Theme.of(context).primaryColor),
        ),
        child: Form(
          key: _formKey,
          child: Stepper(
            type: StepperType.vertical,
            steps: getSteps(),
            currentStep: currentStep,
            onStepContinue: () {
              final isLastStep = currentStep == getSteps().length - 1;
              if (isLastStep) {
                _submit();
              } else {
                setState(() => currentStep += 1);
              }
            },
            onStepCancel: () {
              currentStep == 0 ? null : setState(() => currentStep -= 1);
            },
            onStepTapped: (step) => setState(() => currentStep = step),
            controlsBuilder: (BuildContext context, ControlsDetails controls) {
              final isLastStep = currentStep == getSteps().length - 1;

              return Container(
                margin: EdgeInsets.only(top: 20),
                child: Row(children: [
                  if (currentStep != 0)
                    Expanded(
                      child: ElevatedButton(
                        child: Text('BACK'),
                        onPressed: controls.onStepCancel,
                      ),
                    ),
                  SizedBox(
                    width: 15,
                  ),
                  if (_isLoading)
                    CircularProgressIndicator()
                  else
                    Expanded(
                      child: ElevatedButton(
                        child: Text(isLastStep ? 'REGISTER' : 'NEXT'),
                        onPressed: controls.onStepContinue,
                      ),
                    ),
                ]),
              );
            },
          ),
        ),
      ),
    );
  }
}
