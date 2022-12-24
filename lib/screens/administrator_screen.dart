import 'package:flutter/material.dart';
import '../providers/profile.dart';
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
  Future _loadedData;

  Future _fetchAllData() async {
    await Provider.of<CompanyProvider>(
      context,
      listen: false,
    ).fetchAndSetCompany();

    await Provider.of<ProfileProvider>(
      context,
      listen: false,
    ).fetchAndSetNonAdmin(true);
  }

  // List<Profile> contactPerson;
  @override
  void didChangeDependencies() {
    if (_isInit) {
      setState(() {
        _isLoading = true;
      });

      _loadedData = _fetchAllData().then((_) {
        print('entered did changed');
        setState(() {
          _isLoading = false;
          _isInit = false;
        });
      });
    }

    super.didChangeDependencies();
  }

  Future<void> _refreshCompanyList(BuildContext context) async {
    _fetchAllData();
  }

  @override
  Widget build(BuildContext context) {
    print(_loadedData);
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
      body: FutureBuilder(
        future: _fetchAllData(),
        builder: (context, snapshot) =>
            snapshot.connectionState == ConnectionState.waiting
                ? Center(
                    child: CircularProgressIndicator(),
                  )
                : RefreshIndicator(
                    onRefresh: () => _refreshCompanyList(context),
                    child: _loadedData == null
                        ? Center(
                            child: Text(
                              'There is no company has been created yet',
                              style: TextStyle(color: Colors.black),
                            ),
                          )
                        : Padding(
                            padding: const EdgeInsets.all(5.0),
                            child: Column(
                              children: [
                                Expanded(
                                  child: Consumer<CompanyProvider>(
                                    builder: (context, _loadedData, _) =>
                                        ListView.builder(
                                      itemCount: _loadedData.companies.length,
                                      itemBuilder: (_, index) {
                                        var profileResult =
                                            Provider.of<ProfileProvider>(
                                          context,
                                          listen: false,
                                        ).findByNonAdminId(_loadedData
                                                .companies[index]
                                                .companyAdminID);

                                        return Column(
                                          children: [
                                            CompaniesItem(
                                              _loadedData.companies[index].id,
                                              _loadedData
                                                  .companies[index].companyName,
                                              profileResult.fullName,
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
                  ),
      ),
    );
  }
}
