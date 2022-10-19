import 'package:flutter/material.dart';
import '../providers/profile_provider.dart';
import '../screens/addCompany_screen.dart';
import 'package:provider/provider.dart';
import '../providers/company_provider.dart';
import '../widgets/administrator_app_drawer.dart';
import '../widgets/companies_items.dart';

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
      var result;

      result = Provider.of<CompanyProvider>(
        context,
        listen: false,
      ).fetchAndSetCompany().then((_) {
        Provider.of<ProfileProvider>(
      context,
      listen: false,
    ).fetchAndSetNonAdmin().then((_)  {
      setState(() {
          _isLoading = false;
        });
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
      body: _isLoading
          ? Center(
              child: CircularProgressIndicator(),
            )
          : Padding(
              padding: const EdgeInsets.all(5.0),
              child: Column(
                children: [
                  Expanded(
                    child: Consumer<CompanyProvider>(
                      builder: (context, _loadedData, _) => ListView.builder(
                        itemCount: _loadedData.companies.length,
                        itemBuilder: (_, index) {
                          print("test " +
                              _loadedData.companies[index].companyAdminId);
                          var result = Provider.of<ProfileProvider>(
                            context,
                            listen: false,
                          ).findByAdminId(
                              _loadedData.companies[index].companyAdminId);
                          print(result);
                          var adminFullName = result.fullName;

                          return Column(
                            children: [
                              CompaniesItem(
                                _loadedData.companies[index].id,
                                _loadedData.companies[index].companyName,
                                 adminFullName,
                              ),
                              Divider(
                                thickness: 1,
                              ),
                            ],
                          );
                        },
                      ),
                    ),
                  ),
                ],
              ),
            ),
    );
  }
}
