import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../widgets/app_drawer.dart';
import '../providers/role_provider.dart';
import '../widgets/role_item.dart';
import '../screens/addRole_screen.dart';

class RoleScreen extends StatefulWidget {
  static const routeName = '/roles_page';

  @override
  State<RoleScreen> createState() => _RoleScreenState();
}

class _RoleScreenState extends State<RoleScreen> {
  List<Role> _roleList;
  var _isInit = true;
  var _isLoading = false;

  @override
  void didChangeDependencies() {
    if (_isInit) {
      setState(() {
        _isLoading = true;
      });
      Provider.of<RoleProvider>(
        context,
        listen: false,
      ).fetchAndSetRoleList();
      _roleList = Provider.of<RoleProvider>(
        context,
        listen: false,
      ).roleList;
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
        title: Text('Roles'),
        backgroundColor: Theme.of(context).primaryColor,
        actions: [
          IconButton(
            icon: Icon(
              Icons.add,
            ),
            onPressed: () {
              Navigator.pushNamed(context, AddRoleScreen.routeName);
            },
          ),
        ],
      ),
      body: _isLoading == true
          ? Center(
              child: CircularProgressIndicator(),
            )
          : Padding(
              padding: const EdgeInsets.all(5.0),
              child: Column(
                children: [
                  Expanded(
                    child: Consumer<RoleProvider>(
                      builder: (context, _roleList, _) => ListView.builder(
                        itemCount: _roleList.roleList.length,
                        itemBuilder: (_, index) => Column(
                          children: [
                            RoleItem(
                              _roleList.roleList[index].id,
                              _roleList.roleList[index].roleName,
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
