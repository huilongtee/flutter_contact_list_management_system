import 'dart:io';
import 'dart:typed_data';
import 'dart:ui' as ui;
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:image_picker/image_picker.dart';
import 'package:qr_flutter/qr_flutter.dart';
import 'package:share_plus/share_plus.dart';
import 'package:provider/provider.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';

import '../providers/nfc_provider.dart';
import '../providers/profile.dart';
import '../providers/profile_provider.dart';
import '../providers/role_provider.dart';
import '../providers/company_provider.dart';
import '../providers/department_provider.dart';

import '../screens/editProfile_screen.dart';
import '../screens/changePassword_screen.dart';

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
  var companyName = null;
  var result = null;
  File _image;
  final imagePicker = ImagePicker();
  Profile loadedProfileResult = null;
  Role loadedRoleResult = null;
  NFC loadedNFCResult = null;
  Department loadedDepartmentResult = null;
  Company loadedCompanyResult = null;
  GlobalKey _renderObjectKey = new GlobalKey();
 DateTime lastPressed;
  @override
  void didChangeDependencies() {
    if (_isInit) {
      setState(() {
        _isLoading = true;
      });

//fetch profile based on the userid
      Provider.of<ProfileProvider>(
        context,
        listen: false,
      ).fetchAndSetProfile().then((_) {
        //get list
        final result = Provider.of<ProfileProvider>(
          context,
          listen: false,
        ).profile;
        //filter list using first item in list
        final loadedProfile = Provider.of<ProfileProvider>(
          context,
          listen: false,
        ).findById(result[0].id);

        loadedProfileResult = Profile(
          id: loadedProfile.id,
          companyId: loadedProfile.companyId,
          fullName: loadedProfile.fullName,
          emailAddress: loadedProfile.emailAddress,
          homeAddress: loadedProfile.homeAddress,
          phoneNumber: loadedProfile.phoneNumber,
          roleId: loadedProfile.roleId,
          departmentId: loadedProfile.departmentId,
          imageUrl: loadedProfile.imageUrl,
          qrUrl: loadedProfile.qrUrl,
        );

        //fetch role based on the userid
        Provider.of<RoleProvider>(context, listen: false)
            .fetchAndSetRoleList()
            .then((_) {
          Provider.of<DepartmentProvider>(context, listen: false)
              .fetchAndSetDepartmentList()
              .then((_) {
            Provider.of<CompanyProvider>(context, listen: false)
                .fetchAndSetCompany()
                .then((_) {
              Provider.of<CompanyProvider>(context, listen: false)
                  .fetchAndSetCompanyName(loadedProfileResult.companyId)
                  .then((_) {
                Provider.of<NFCProvider>(context, listen: false)
                    .fetchAndSetNFC()
                    .then((_) {
                  final nfc = Provider.of<NFCProvider>(context, listen: false)
                      .findByOperatorId();
                  if (nfc == null) {
                    loadedNFCResult = null;
                  } else {
                    loadedNFCResult = NFC(
                      id: nfc.id,
                      status: nfc.status,
                      operatorID: nfc.operatorID,
                    );
                  }
                  //filter role list using first item in list
                  final role = Provider.of<RoleProvider>(context, listen: false)
                      .findById(loadedProfileResult.roleId);
                  if (role == null) {
                    loadedRoleResult = null;
                  } else {
                    loadedRoleResult =
                        Role(roleName: role.roleName, id: role.id);
                  }

                  //fetch department based on the userid

                  // //get list
                  // final result =
                  //     Provider.of<DepartmentProvider>(context, listen: false)
                  //         .departmentList;

                  //filter department list using first item in list
                  final department =
                      Provider.of<DepartmentProvider>(context, listen: false)
                          .findById(loadedProfileResult.departmentId);
                  if (department == null) {
                    loadedDepartmentResult = null;
                  } else {
                    loadedDepartmentResult = Department(
                        departmentName: department.departmentName,
                        id: department.id);
                  }

                  final companyNameResult =
                      Provider.of<CompanyProvider>(context, listen: false)
                          .getCompanyName;

                  if (companyNameResult == '') {
                    loadedCompanyResult == null;
                  } else {
                    companyName = companyNameResult;
                    loadedCompanyResult = Company(
                        id: loadedProfile.companyId,
                        companyName: companyNameResult,
                        companyAdminID: null);
                  }
                  print('user id: ' + loadedProfile.id);
                  setState(() {
                    _isLoading = false;
                  });
                });
              });
            });
          });
        });
      });
    }
    _isInit = false;
    super.didChangeDependencies();
  }

  //================================== Image Picker Start ==============================================//

  Future imagePickerMethod() async {
    final pick = await imagePicker.pickImage(
        source: ImageSource.gallery, imageQuality: 20);

    setState(() {
      _image = File(pick.path);
      print('image path' + _image.toString());
    });

    //Get a reference to storage root
    Reference ref = FirebaseStorage.instance.ref();
    Reference referenceDirImages = ref.child('images');

    //create a reference for the image to be stored
    Reference referenceImageToUpload =
        referenceDirImages.child(loadedProfileResult.id);

    setState(() {
      _isLoading = true;
    });
    await referenceImageToUpload.putFile(_image);

    String downloadURL = await referenceImageToUpload.getDownloadURL();
    await Provider.of<ProfileProvider>(context, listen: false)
        .uploadImage(downloadURL, loadedProfileResult);
    print('downloadURL' + downloadURL);
    setState(() {
      _isLoading = false;
    });
  }

//================================== Image Picker End ==============================================//

//================================== Save QR code image Start ==============================================//

  Future<void> _getWidgetImage() async {
    try {
      RenderRepaintBoundary boundary =
          _renderObjectKey.currentContext.findRenderObject();
      ui.Image image = await boundary.toImage(pixelRatio: 3.0);
      ByteData byteData =
          await image.toByteData(format: ui.ImageByteFormat.png);
      var pngBytes = byteData.buffer.asUint8List();

//Get a reference to storage root
      Reference ref = FirebaseStorage.instance.ref();
      Reference referenceDirImages = ref.child('qrCodeImage');

      //create a reference for the image to be stored
      Reference referenceImageToUpload =
          referenceDirImages.child(loadedProfileResult.id);

      setState(() {
        _isLoading = true;
      });

      // await referenceImageToUpload.putFile(pngBytes);
      await referenceImageToUpload.putData(pngBytes);

      String downloadURL = await referenceImageToUpload.getDownloadURL();
      await Provider.of<ProfileProvider>(context, listen: false)
          .uploadQRImage(downloadURL, loadedProfileResult);
      await Share.share('This is the QR code of ' +
          loadedProfileResult.fullName +
          '\n\n' +
          downloadURL);
      print('downloadURL' + downloadURL);
      setState(() {
        _isLoading = false;
      });
    } catch (exception) {}
  }

//================================== Save QR code image End ==============================================//

//================================== Shared QR code image Start ==============================================//
  Future<void> sharedQRCode() async {
    // await Share.share('This is the QR code of' +
    //         loadedProfileResult.fullName +
    //         '\n\n' +
    //         loadedProfileResult.qrUrl);
    await Share.share(loadedProfileResult.qrUrl);
    Navigator.of(context).pop();
  }

//================================== Shared QR code image End ==============================================//
//================================== choose index action Start ==============================================//

  void onSelected(BuildContext context, int item) {
    switch (item) {
      case 0:
        // _openDialog();

        Navigator.pushNamed(context, EditProfileScreen.routeName,
            arguments: loadedProfileResult.id);

        break;
      case 1:
        Navigator.pushNamed(context, ChangePasswordScreen.routeName);
        break;
    }
  }
//================================== choose index action End ==============================================//

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        elevation: 0,
        backgroundColor: Theme.of(context).primaryColor,
        actions: [
          // PopupMenuButton<int>(
          //   onSelected: (item) => onSelected(context, item),
          //   itemBuilder: (context) => [
          //     PopupMenuItem<int>(
          //       child: Text('Edit Profile'),
          //       value: 0,
          //     ),
          //     PopupMenuItem<int>(
          //       child: Text('Change Password'),
          //       value: 1,
          //     ),
          //   ],
          // ),

          IconButton(
            onPressed: () {
              Navigator.pushNamed(context, EditProfileScreen.routeName,
                  arguments: loadedProfileResult.id);
            },
            icon: Icon(Icons.edit),
            // color: Theme.of(context).textTheme.bodyText1.color,
            color: Colors.white,
          ),
        ],
      ),
      drawer: AppDrawer(),
      body: _isLoading == true
          ? Center(
              // child: CircularProgressIndicator(),
              child: SpinKitDoubleBounce(
                color: Theme.of(context).primaryColor,
                size: 100,
              ),
            )
          : WillPopScope(
              onWillPop: () async {
                final now = DateTime.now();
                final maxDuration = Duration(seconds: 2);
                final isWarning = lastPressed == null ||
                    now.difference(lastPressed) > maxDuration;
                if (isWarning) {
                  lastPressed = DateTime.now();
                  final snackBar = SnackBar(
                    content: Text('Tap again to close app'),
                    duration: maxDuration,
                  );

                  ScaffoldMessenger.of(context)
                    ..removeCurrentSnackBar()
                    ..showSnackBar(snackBar);
                  return false;
                } else {
                  return true;
                }
              },
              child:ListView(
              padding: EdgeInsets.zero,
              children: [
                // Container(
                //   margin: EdgeInsets.only(bottom: 20),
                //   child: buildTop(),
                // ),
                Container(
                  margin: EdgeInsets.only(
                    bottom: 20,
                  ),
                  child: buildTop(),
                ),

                buildContent(),
              ],
            ),
            ),
    );
  }

  Widget buildContent() {
    return SingleChildScrollView(
      child: Padding(
        padding: const EdgeInsets.all(18),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            //request nfc button

            loadedNFCResult == null
                ?  TextButton(
                          child: Text('Request for NFC Tag'),
                          onPressed: () async {
                            setState(() {
                              _isLoading = true;
                            });

                            await Provider.of<NFCProvider>(context,
                                    listen: false)
                                .requestNFCTag();

                            setState(() {
                              _isLoading = false;
                            });
                          },
                        )
                :  TextButton(
                          child: Text(loadedNFCResult.status == 'Requesting'
                              ? 'Requesting NFC'
                              : loadedNFCResult.status == 'Delivering'
                                  ? 'NFC Tag is delivering'
                                  : 'Request for NFC Tag'),
                          onPressed: loadedNFCResult.status.isNotEmpty
                              ? null
                              : () async {
                                  setState(() {
                                    _isLoading = true;
                                  });

                                  await Provider.of<NFCProvider>(context,
                                          listen: false)
                                      .requestNFCTag();

                                  setState(() {
                                    _isLoading = false;
                                  });
                                },
                        
                  ),

            //fullname
            Container(
              margin: const EdgeInsets.symmetric(vertical: 10),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.all(
                  Radius.circular(
                    20,
                  ),
                ),
                color: Theme.of(context).primaryColor,
              ),
              alignment: Alignment.center,
              width: double.infinity,
              child: Padding(
                padding: EdgeInsets.all(10),
                child: Text(
                  loadedProfileResult.fullName,
                  style: TextStyle(
                    fontSize: 22,
                  ),
                ),
              ),
            ),

            //email
            Container(
              margin: const EdgeInsets.symmetric(vertical: 10),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.all(
                  Radius.circular(
                    20,
                  ),
                ),
                color: Theme.of(context).primaryColor,
              ),
              alignment: Alignment.center,
              width: double.infinity,
              child: Padding(
                padding: EdgeInsets.all(10),
                child: Text(
                  loadedProfileResult.emailAddress,
                  style: TextStyle(
                    fontSize: 22,
                  ),
                ),
              ),
            ),

            //company name
            loadedCompanyResult == null
                ? Container()
                : Container(
                    margin: const EdgeInsets.symmetric(vertical: 10),
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.all(
                        Radius.circular(
                          20,
                        ),
                      ),
                      color: Theme.of(context).primaryColor,
                    ),
                    alignment: Alignment.center,
                    width: double.infinity,
                    child: Padding(
                      padding: EdgeInsets.all(10),
                      child: Text(
                        companyName,
                        style: TextStyle(
                          fontSize: 22,
                        ),
                      ),
                    ),
                  ),

            //department
            loadedDepartmentResult == null
                ? Container()
                : Container(
                    margin: const EdgeInsets.symmetric(vertical: 10),
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.all(
                        Radius.circular(
                          20,
                        ),
                      ),
                      color: Theme.of(context).primaryColor,
                    ),
                    alignment: Alignment.center,
                    width: double.infinity,
                    child: Padding(
                      padding: EdgeInsets.all(10),
                      child: Text(
                        loadedDepartmentResult.departmentName,
                        style: TextStyle(
                          fontSize: 22,
                        ),
                      ),
                    ),
                  ),
            //role
            loadedRoleResult == null
                ? Container()
                : Container(
                    margin: const EdgeInsets.symmetric(vertical: 10),
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.all(
                        Radius.circular(
                          20,
                        ),
                      ),
                      color: Theme.of(context).primaryColor,
                    ),
                    alignment: Alignment.center,
                    width: double.infinity,
                    child: Padding(
                      padding: EdgeInsets.all(10),
                      child: Text(
                        loadedRoleResult.roleName,
                        style: TextStyle(
                          fontSize: 22,
                        ),
                      ),
                    ),
                  ),
            // Container(
            //   child: Padding(
            //     padding: EdgeInsets.all(10),
            //     child: Text(loadedProfileResult.fullName),
            //   ),
            // ),
            // Container(
            //   child: Padding(
            //     padding: EdgeInsets.all(10),
            //     child: Text(loadedProfileResult.emailAddress),
            //   ),
            // ),
            // loadedDepartmentResult == null
            //     ? Container()
            //     : Container(
            //         child: Padding(
            //           padding: EdgeInsets.all(10),
            //           child: Text(loadedDepartmentResult.departmentName),
            //         ),
            //       ),
            // loadedRoleResult == null
            //     ? Container()
            //     : Container(
            //         child: Padding(
            //           padding: EdgeInsets.all(10),
            //           child: Text(loadedRoleResult.roleName),
            //         ),
            //       ),
            loadedProfileResult.qrUrl == null
                ? RepaintBoundary(
                    key: _renderObjectKey,
                    child: QrImage(
                      data: loadedProfileResult.id,
                      version: QrVersions.auto,
                      size: 260.0,
                      backgroundColor: Colors.white,
                      errorStateBuilder: (cxt, err) {
                        return Container(
                          child: Center(
                            child: Text(
                              "Something gone wrong ...",
                              textAlign: TextAlign.center,
                            ),
                          ),
                        );
                      },
                    ),
                  )
                : Padding(
                    padding: EdgeInsets.all(5),
                    child: Image.network(
                      loadedProfileResult.qrUrl,
                      width: 260,
                      height: 260,
                    ),
                  ),
            loadedProfileResult.qrUrl == null
                ? FloatingActionButton(
                    child: Icon(Icons.share),
                    // onPressed: _getWidgetImage,
                    onPressed: () => showDialog<Null>(
                      context: context,
                      builder: (ctx) => AlertDialog(
                        title: Text("Confirmation for sharing QR code"),
                        content: Column(
                          children: [
                            Text(
                                'The QR code link may keeps sharing by the receiver of this QR code link'),
                            SizedBox(
                              height: 10,
                            ),
                            Text(
                                '* By sharing this QR code, you will share your information to the third party. We aware the PDPA protection, the purpose of this info only limited for the official business purpose'),
                            SizedBox(
                              height: 10,
                            ),
                            Text('Would you like to continue?'),
                          ],
                        ),
                        actions: [
                          TextButton(
                            child: Text("Cancel"),
                            onPressed: () {
                              Navigator.of(context).pop();
                            },
                          ),
                          TextButton(
                            child: Text("Continue"),
                            onPressed: () {
                              _getWidgetImage();
                            },
                          ),
                        ],
                      ),
                    ),
                  )
                : FloatingActionButton(
                    child: Icon(Icons.share),
                    onPressed: () => showDialog<Null>(
                      context: context,
                      builder: (ctx) => AlertDialog(
                        title: Text("Confirmation for sharing QR code"),
                        content: Column(
                          children: [
                            Text(
                                'The QR code link may keeps sharing by the receiver of this QR code link.'),
                            SizedBox(
                              height: 10,
                            ),
                            Text(
                                '* By sharing this QR code, you will share your information to the third party. We aware the PDPA protection, the purpose of this info only limited for the official business purpose.'),
                            SizedBox(
                              height: 10,
                            ),
                            Text('Would you link to continue?'),
                          ],
                        ),
                        actions: [
                          TextButton(
                            child: Text("Cancel"),
                            onPressed: () {
                              Navigator.of(context).pop();
                            },
                          ),
                          TextButton(
                            child: Text("Continue"),
                            onPressed: () {
                              sharedQRCode();
                            },
                          ),
                        ],
                      ),
                    ),
                  ),
          ],
        ),
      ),
    );
  }

  Widget buildTop() {
    return Stack(
      clipBehavior: Clip.none,
      alignment: Alignment.center,
      children: [
        CustomPaint(
          child: Container(
            width: MediaQuery.of(context).size.width,
            height: MediaQuery.of(context).size.height / 3,
          ),
          painter: HeaderCurvedContainer(context),
        ),
        Positioned(
          top: 10,
          child: Padding(
            padding: EdgeInsets.all(20),
            child: Text(
              'Profile',
              style: TextStyle(
                fontSize: 35,
                letterSpacing: 1.5,
                // color: Theme.of(context).textTheme.bodyText1.color,
                color: Colors.white,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ),
        loadedProfileResult.imageUrl.isEmpty
            ? Positioned(
                top: MediaQuery.of(context).size.width / 4,
                child: Container(
                  padding: EdgeInsets.all(10),
                  width: MediaQuery.of(context).size.width / 2,
                  height: MediaQuery.of(context).size.width / 2,
                  decoration: BoxDecoration(
                    border: Border.all(
                      color: Colors.white,
                      width: 5,
                    ),
                    shape: BoxShape.circle,
                    color: Colors.white,
                  ),
                  child: CircleAvatar(
                    backgroundColor: Colors.white,
                    child: Text(
                      loadedProfileResult.fullName[0].toUpperCase(),
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: MediaQuery.of(context).size.width / 4,
                        color: Colors.blue,
                      ),
                    ),
                  ),
                ),
              )
            : Positioned(
                top: MediaQuery.of(context).size.width / 4,
                child: Container(
                  padding: EdgeInsets.all(10),
                  width: MediaQuery.of(context).size.width / 2,
                  height: MediaQuery.of(context).size.width / 2,
                  decoration: BoxDecoration(
                    border: Border.all(
                      color: Colors.white,
                      width: 5,
                    ),
                    shape: BoxShape.circle,
                    color: Colors.white,
                    image: DecorationImage(
                      fit: BoxFit.cover,
                      image: NetworkImage(loadedProfileResult.imageUrl),
                    ),
                  ),
                ),
              ),
        Positioned(
          top: 200,
          left: MediaQuery.of(context).size.width / 2 + 50,
          child: CircleAvatar(
            backgroundColor: Colors.black54,
            child: IconButton(
              icon: Icon(
                Icons.camera_alt_outlined,
                color: Colors.white,
              ),
              onPressed: () {
                imagePickerMethod();
              },
            ),
          ),
        ),
      ],
    );
  }
}

class HeaderCurvedContainer extends CustomPainter {
  final BuildContext context;

  HeaderCurvedContainer(this.context);

  @override
  void paint(Canvas canvas, Size size) {
    Paint paint = Paint()..color = Theme.of(context).primaryColor;
    Path path = Path()
      ..relativeLineTo(0, 150)
      ..quadraticBezierTo(size.width / 2, 225, size.width, 150)
      ..relativeLineTo(0, -150)
      ..close();
    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(CustomPainter oldDelegate) => false;
}
