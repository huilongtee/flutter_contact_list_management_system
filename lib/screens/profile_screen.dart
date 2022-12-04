import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:provider/provider.dart';
import '../providers/profile.dart';
import '../providers/profile_provider.dart';
import '../providers/role_provider.dart';
import '../providers/company_provider.dart';
import '../providers/department_provider.dart';
import '../screens/editProfile_screen.dart';
import '../widgets/profile_items.dart';
import '../widgets/app_drawer.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:image_picker/image_picker.dart';
import 'package:qr_flutter/qr_flutter.dart';
import 'package:share_plus/share_plus.dart';
import 'dart:ui' as ui;
import 'dart:typed_data';
import 'dart:io';

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
  File _image;
  final imagePicker = ImagePicker();
  Profile loadedProfileResult = null;
  GlobalKey _renderObjectKey = new GlobalKey();
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
        Provider.of<RoleProvider>(context, listen: false)
            .fetchAndSetRoleList()
            .then((_) {
          role = Provider.of<RoleProvider>(context, listen: false)
              .findById(loadedProfileResult.roleId);

          Provider.of<DepartmentProvider>(context, listen: false)
              .fetchAndSetDepartmentList()
              .then((_) {
            setState(() {
              department =
                  Provider.of<DepartmentProvider>(context, listen: false)
                      .findById(loadedProfileResult.departmentId);
              Provider.of<CompanyProvider>(context, listen: false)
                  .fetchAndSetCompanyName(loadedProfileResult.companyId);
              _isLoading = false;
            });
          });
        });
        _isInit = false;
      });
    }

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
      await Share.share('This is the QR code of' +
          loadedProfileResult.fullName +
          '\n\n' +
          downloadURL);
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

  @override
  Widget build(BuildContext context) {
    final companyNameResult =
        Provider.of<CompanyProvider>(context, listen: false).getCompanyName;

    return Scaffold(
      appBar: AppBar(
        elevation: 0,
        backgroundColor: Theme.of(context).primaryColor,
        actions: [
          IconButton(
            onPressed: () {
              Navigator.pushNamed(context, EditProfileScreen.routeName,
                  arguments: loadedProfileResult.id);
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
          : Stack(
              alignment: Alignment.center,
              children: [
                CustomPaint(
                  child: Container(
                    width: MediaQuery.of(context).size.width,
                    height: MediaQuery.of(context).size.height,
                  ),
                  painter: HeaderCurvedContainer(context),
                ),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Padding(
                      padding: EdgeInsets.all(20),
                      child: Text(
                        'Profile',
                        style: TextStyle(
                          fontSize: 35,
                          letterSpacing: 1.5,
                          color: Colors.white,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                    Container(
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
                    )
                  ],
                ),
                Padding(
                  padding: EdgeInsets.only(
                    bottom: 280,
                    left: 160,
                  ),
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
                SingleChildScrollView(
                  child: Padding(
                    padding: const EdgeInsets.only(
                      left: 18,
                      right: 18,
                      top: 18,
                    ),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        loadedProfileResult.qrUrl == null
                            ? RepaintBoundary(
                                key: _renderObjectKey,
                                child: QrImage(
                                  data: loadedProfileResult.id,
                                  version: QrVersions.auto,
                                  size: 165.0,
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
                                child: Image.network(loadedProfileResult.qrUrl),
                              ),
                        loadedProfileResult.qrUrl == null
                            ? FloatingActionButton(
                                onPressed: _getWidgetImage,
                              )
                            : FloatingActionButton(
                                //
                                onPressed: () => showDialog<Null>(
                                  context: context,
                                  builder: (ctx) => AlertDialog(
                                    title: Text(
                                        "Confirmation for sharing QR code"),
                                    content: Column(
                                      children: [
                                        Text(
                                            'The QR code link may keeps sharing by the receiver of this QR code link'),
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
                ),
              ],
            ),
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
