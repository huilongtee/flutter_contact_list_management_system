import 'package:flutter/foundation.dart';

class Profile with ChangeNotifier{
  final String id;
  final String fullName;
  final String emailAddress;
  final String homeAddress;
  final String phoneNumber;
  final String imageUrl;
  final String companyId;
  final String roleId;
  final String departmentId;

  Profile({
    @required this.id,
    @required this.fullName,
    @required this.emailAddress,
    @required this.homeAddress,
    @required this.phoneNumber,
    @required this.imageUrl,
    @required this.companyId,
    @required this.roleId,
    @required this.departmentId,
  });

  indexWhere(bool Function(dynamic prof) param0) {}
}
