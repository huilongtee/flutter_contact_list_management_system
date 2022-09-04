import 'package:flutter/material.dart';

class Role {
  final String id;
  final String roleName;

  Role({
    @required this.id,
    @required this.roleName,
  });
}

class RoleProvider with ChangeNotifier  {
  List<Role> _roles = [
    Role(
      id: '1',
      roleName: 'Role A',
    ),
    Role(
      id: '2',
      roleName: 'Role B',
    ),
    Role(
      id: '3',
      roleName: 'Role C',
    ),
    Role(
      id: '4',
      roleName: 'Role D',
    ),
  ];

  List<Role> get role {
    return [..._roles];
  }

  Role findByRoleId(String id) {
    return _roles.firstWhere((role) => role.id == id,orElse: () => null);
  }
}
