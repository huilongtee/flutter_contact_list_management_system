// import '../widgets/app_drawer.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/department_provider.dart';
import '../widgets/department_item.dart';
import '../screens/addDepartment_screen.dart';

import 'package:flutter_spinkit/flutter_spinkit.dart';

class DepartmentScreen extends StatefulWidget {
  static const routeName = '/departments_page';

  @override
  State<DepartmentScreen> createState() => _DepartmentScreenState();
}

class _DepartmentScreenState extends State<DepartmentScreen> {
  List<Department> _departmentList;
  var _isInit = true;
  var _isLoading = false;

  @override
  void didChangeDependencies() {
    if (_isInit) {
      setState(() {
        _isLoading = true;
      });
      Provider.of<DepartmentProvider>(
        context,
        listen: false,
      ).fetchAndSetDepartmentList();
      _departmentList = Provider.of<DepartmentProvider>(
        context,
        listen: false,
      ).departmentList;
      setState(() {
        _isLoading = false;
      });
      _isInit = false;

      super.didChangeDependencies();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Departments'),
        backgroundColor: Theme.of(context).primaryColor,
        actions: [
          IconButton(
            icon: Icon(
              Icons.add,
            ),
            onPressed: () {
              Navigator.pushNamed(context, AddDepartmentScreen.routeName);
            },
          ),
        ],
      ),
      body: _isLoading == true
          ? Center(
              // child: CircularProgressIndicator(),
              child: SpinKitDoubleBounce(
          color: Theme.of(context).primaryColor,
          size: 100,
        ),
            )
          : Padding(
              padding: const EdgeInsets.all(5.0),
              child: Column(
                children: [
                  Expanded(
                    child: Consumer<DepartmentProvider>(
                      builder: (context, _departmentList, _) =>
                          ListView.builder(
                        itemCount: _departmentList.departmentList.length,
                        itemBuilder: (_, index) => Column(
                          children: [
                            DepartmentItem(
                              _departmentList.departmentList[index].id,
                              _departmentList
                                  .departmentList[index].departmentName,
                            ),
                            Divider(
                              thickness: 1,
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
    );
  }
}
