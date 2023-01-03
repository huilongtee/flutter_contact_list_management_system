// import '../widgets/app_drawer.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/nfc_provider.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';

import '../providers/profile_provider.dart';
import '../widgets/administrator_app_drawer.dart';
import '../widgets/nfc_item.dart';

class NFCScreen extends StatefulWidget {
  static const routeName = '/nfcs_page';

  @override
  State<NFCScreen> createState() => _NFCScreenState();
}

class _NFCScreenState extends State<NFCScreen> {
  List<NFC> _nfcList;
  var _isInit = true;
  var _isLoading = false;

  @override
  void didChangeDependencies() {
    if (_isInit) {
      setState(() {
        _isLoading = true;
      });
      Provider.of<NFCProvider>(
        context,
        listen: false,
      ).fetchAndSetRequestingNFC().then((_) {});
      Provider.of<ProfileProvider>(context, listen: false)
          .fetchAndSetAllProfile()
          .then((_) {
        _nfcList = Provider.of<NFCProvider>(
          context,
          listen: false,
        ).nfcList;
      });

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
        title: Text('NFC Requests'),
        backgroundColor: Theme.of(context).primaryColor,
      ),
      drawer: AdministratorAppDrawer(),
      body: _isLoading == true
          ? Center(
              // child: CircularProgressIndicator(),
              child: SpinKitDoubleBounce(
                color: Theme.of(context).primaryColor,
                size: 100,
              ),
            )
          : Container(
                            decoration: BoxDecoration(
                              color: Colors.indigo[50],
                            ),
                            child: Column(
                              children: [
                                Expanded(
                                  child: Container(
                                    padding: EdgeInsets.symmetric(
                                        horizontal: 10, vertical: 5),
                                    child:  Consumer<NFCProvider>(
                      builder: (context, _nfcList, _) => ListView.builder(
                        itemCount: _nfcList.nfcList.length,
                        itemBuilder: (_, index) => Column(
                          children: [
                            NFCItem(
                              _nfcList.nfcList[index].id,
                              _nfcList.nfcList[index].status,
                              _nfcList.nfcList[index].operatorID,
                            ),
                            
                          ],
                        ),
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
