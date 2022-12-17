import 'package:flutter/material.dart';
import 'package:flutter_contact_list_management_system/providers/sharedContactList_provider.dart';
import 'package:provider/provider.dart';
import '../providers/department_provider.dart';
import '../providers/personalContactList_provider.dart';
import '../providers/profile.dart';
import '../providers/company_provider.dart';
import '../providers/role_provider.dart';
import '../widgets/profile_items.dart';

class ContactPersonDetailScreen extends StatefulWidget {
  static const routeName = '/contactPersonDetailScreen';

  final String id;
  final String listType;

  ContactPersonDetailScreen({this.id, this.listType});

  @override
  State<ContactPersonDetailScreen> createState() =>
      _ContactPersonDetailScreenState();
}

class _ContactPersonDetailScreenState extends State<ContactPersonDetailScreen> {
  var _isInit = true;
  var _isLoading = false;

  var _contactPerson;
  var companyNameResult;
  Profile loadedProfileResult = null;
  Role loadedRoleResult = null;
  Department loadedDepartmentResult = null;
  Company loadedCompanyResult = null;

  @override
  void didChangeDependencies() {
    if (_isInit) {
      setState(() {
        _isLoading = true;
      });
      // final contactPersonId =
      //     ModalRoute.of(context).settings.arguments as String;

      // _contactPerson = Provider.of<PersonalContactListProvider>(context)
      //     .findById(contactPersonId);

      final args = ModalRoute.of(context).settings.arguments
          as ContactPersonDetailScreen;

      if (args.listType == 'shared') {
        loadedProfileResult =
            Provider.of<SharedContactListProvider>(context, listen: false)
                .findById(args.id);

        Provider.of<CompanyProvider>(context, listen: false)
            .fetchAndSetCompanyName(loadedProfileResult.companyId);
      } else if (args.listType == 'personal') {
        loadedProfileResult =
            Provider.of<PersonalContactListProvider>(context, listen: false)
                .findById(args.id);
        if (loadedProfileResult.companyId.isNotEmpty) {
          Provider.of<CompanyProvider>(context, listen: false)
              .fetchAndSetCompanyName(loadedProfileResult.companyId);
        } else {
          setState(() {
            _isLoading = false;
            _isInit = false;
          });
        }
      }
      setState(() {
        _isLoading = false;
        _isInit = false;
      });
      super.didChangeDependencies();
    }
  }

  @override
  Widget build(BuildContext context) {
    final companyNameResult =
        Provider.of<CompanyProvider>(context, listen: false).getCompanyName;

    return Scaffold(
      appBar: AppBar(
        title: Text('My-List'),
        elevation: 0,
        backgroundColor: Theme.of(context).primaryColor,
      ),
      body: _isLoading == true
          ? Center(
              child: CircularProgressIndicator(),
            )
          : Container(
              child: Column(
                children: [
                  Container(
                    padding: const EdgeInsets.fromLTRB(18, 10, 18, 25),
                    child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Container(
                            height: 70,
                            width: 70,
                            margin: const EdgeInsets.only(left: 20, right: 20),
                            child: loadedProfileResult.imageUrl.isEmpty
                                ? CircleAvatar(
                                    backgroundColor: Colors.white,
                                    child: Text(
                                      loadedProfileResult.fullName[0]
                                          .toUpperCase(),
                                      style: TextStyle(
                                        fontWeight: FontWeight.bold,
                                        fontSize: 28,
                                      ),
                                    ),
                                  )
                                : CircleAvatar(
                                    backgroundImage: NetworkImage(
                                        loadedProfileResult.imageUrl),
                                  ),
                          ),
                          Padding(
                            padding: const EdgeInsets.only(right: 30),
                            child: Text(
                              loadedProfileResult.fullName,
                              style: TextStyle(
                                fontSize: 20,
                              ),
                            ),
                          ),
                        ]),
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.only(
                        bottomLeft: Radius.circular(50),
                        bottomRight: Radius.circular(50),
                      ),
                      color: Theme.of(context).primaryColor,
                    ),
                  ),
                  Expanded(
                    child: SingleChildScrollView(
                      child: Padding(
                        padding: const EdgeInsets.only(
                          left: 18,
                          right: 18,
                          top: 18,
                        ),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Row(
                              children: [
                                ProfileWidget(
                                  size: 25,
                                  width: 50,
                                  height: 50,
                                  bgColor: Theme.of(context).primaryColor,
                                  index: 0,
                                  borderColor: Colors.grey,
                                ),
                                SizedBox(
                                  width: 10,
                                ),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        loadedProfileResult.phoneNumber,
                                        style: TextStyle(fontSize: 18),
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                            SizedBox(
                              height: 20,
                            ),
                            Row(
                              children: [
                                ProfileWidget(
                                  size: 25,
                                  width: 50,
                                  height: 50,
                                  bgColor: Theme.of(context).primaryColor,
                                  index: 1,
                                  borderColor: Colors.grey,
                                ),
                                SizedBox(
                                  width: 10,
                                ),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        loadedProfileResult.emailAddress,
                                        style: TextStyle(fontSize: 18),
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                            SizedBox(
                              height: 20,
                            ),
                            Row(
                              children: [
                                ProfileWidget(
                                  size: 25,
                                  width: 50,
                                  height: 50,
                                  bgColor: Theme.of(context).primaryColor,
                                  index: 2,
                                  borderColor: Colors.grey,
                                ),
                                SizedBox(
                                  width: 10,
                                ),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        loadedProfileResult.homeAddress,
                                        style: TextStyle(fontSize: 18),
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                            SizedBox(
                              height: 20,
                            ),
                            Row(
                              children: [
                                ProfileWidget(
                                  size: 25,
                                  width: 50,
                                  height: 50,
                                  bgColor: Theme.of(context).primaryColor,
                                  index: 3,
                                  borderColor: Colors.grey,
                                ),
                                SizedBox(
                                  width: 10,
                                ),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        companyNameResult.isEmpty
                                            ? ''
                                            : companyNameResult,
                                        style: TextStyle(fontSize: 18),
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                            SizedBox(
                              height: 20,
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
