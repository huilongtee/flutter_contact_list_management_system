import 'package:flutter/material.dart';

class Department {
  final String id;
  final String departmentName;

  Department({
    @required this.id,
    @required this.departmentName,
  });
}

class DepartmentProvider with ChangeNotifier {
  List<Department> _departments = [
    Department(
      id: '1',
      departmentName: 'Department A',
    ),
    Department(
      id: '2',
      departmentName: 'Department B',
    ),
    Department(
      id: '3',
      departmentName: 'Department C',
    ),
    Department(
      id: '4',
      departmentName: 'Department D',
    ),
  ];

  List<Department> get department {
    return [..._departments];
  }

  Department findByDepartmentId(String id) {
    return _departments.firstWhere((department) => department.id == id,orElse: () => null);
  }
}
