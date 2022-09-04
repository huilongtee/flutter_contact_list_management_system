import 'package:flutter/material.dart';
import '../screens/addCompany_screen.dart';
import 'package:provider/provider.dart';
import '../providers/company_provider.dart';
import '../widgets/administrator_app_drawer.dart';

class AdministratorScreen extends StatefulWidget {
  @override
  State<AdministratorScreen> createState() => _AdministratorScreenState();
}

class _AdministratorScreenState extends State<AdministratorScreen> {
  var _isInit = true;
  var _isLoading = false;
  var _loadedData = null;
  @override
  void didChangeDependencies() {
    if (_isInit) {
      setState(() {
        _isLoading = true;
      });

      final result  = Provider.of<CompanyProvider>(
        context,
        listen: false,
      ).fetchAndSetCompany().then((_) {
        setState(() {
          _isLoading = false;
        });
      });

      _loadedData = result;
    }
    _isInit = false;
    super.didChangeDependencies();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('My-List'),
        backgroundColor: Theme.of(context).primaryColor,
        actions: [
          IconButton(
            onPressed: () {
              Navigator.pushNamed(context, AddCompanyScreen.routeName);
            },
            icon: Icon(Icons.add),
          ),
        ],
      ),
      drawer: AdministratorAppDrawer(),

      body: Padding(
        padding: const EdgeInsets.all(5.0),
        child: Container(
          child: ListTile(
            title: Text('company name'),
            subtitle: Text('admin name: Tee Hui Long'),
            trailing: IconButton(
              onPressed: () {
                // Navigator.pushNamed(context, EditContactPersonScreen.routeName,
                //     arguments: widget.contactPersonId);
              },
              icon: Icon(Icons.manage_accounts),
              color: Theme.of(context).primaryColor,
            ),
          ),
        ),
      ),
    );
  }
}
