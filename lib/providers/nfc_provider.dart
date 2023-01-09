import 'dart:async';

import 'package:flutter/material.dart';
import 'package:collection/collection.dart';

import 'dart:convert'; //convert data into json
import 'package:http/http.dart' as http;
import '../models/http_exception.dart';
import 'package:flutter/material.dart';

class NFC {
  final String id;
  final String status;
  final String operatorID;

  NFC({
    @required this.id,
    @required this.status,
    @required this.operatorID,
  });
}

class NFCProvider with ChangeNotifier {
  List<NFC> _nfcs;
  final String authToken;
  final String userId;
  NFCProvider(this.authToken, this.userId, this._nfcs);

  List<NFC> get nfcList {
    return [..._nfcs];
  }

  //======================================= Request NFC Tag Start =========================================//
  Future<void> requestNFCTag() async {
    final url = Uri.parse(
        'https://eclms-4113b-default-rtdb.asia-southeast1.firebasedatabase.app/nfc.json?auth=$authToken');
    try {
      final nfcResponse = await http.post(url, //add data
          body: json.encode({
            'status': 'Requesting',
            'operatorID': userId,
          })); //merge data that is incoming and the data that existing in the database

      final responseData =
          json.decode(nfcResponse.body) as Map<String, dynamic>;
      if (responseData['error'] != null) {
        throw HttpException(responseData['error']['message']);
      }

      final addedNFC = NFC(
        id: responseData['name'],
        status: 'Requesting',
        operatorID: userId,
      );
      _nfcs.add(addedNFC);
      notifyListeners();
    } catch (error) {
      throw HttpException(error);
    }
  }
  //======================================= Request NFC Tag End =========================================//

  //======================================= Fetch and Set NFC Tag Status Start =========================================//
  Future<void> fetchAndSetNFC() async {
    final searchTerm = 'orderBy="operatorID"&equalTo="$userId"';
    var url = Uri.parse(
        'https://eclms-4113b-default-rtdb.asia-southeast1.firebasedatabase.app/nfc.json?auth=$authToken&$searchTerm');
    try {
      final response = await http.get(url);

      final extractedData = json.decode(response.body) as Map<String,
          dynamic>; //String key with dynamic value since flutter do not know the nested data

      if (extractedData == null) {
        print("error");
        return;
      }
      // var status = '';
      // extractedData.forEach((profileId, profileData) {
      //   status = profileData['status'];
      // });

      final List<NFC> loadedNFCs = [];
      if (extractedData == null) {
        return;
      }

      extractedData.forEach((nfcId, nfcData) {
        loadedNFCs.add(NFC(
          id: nfcId,
          status: nfcData['status'],
          operatorID: nfcData['operatorID'],
        ));
        _nfcs = loadedNFCs;
      });

      notifyListeners();
    } catch (error) {
      print(error);

      throw (error);
    }
  }

  //======================================= Fetch and Set NFC Tag Status End =========================================//

    //======================================= Fetch and Set NFC Tag that is Requesting Status Start =========================================//
  Future<void> fetchAndSetRequestingNFC() async {
    final searchTerm = 'orderBy="status"&equalTo="Requesting"';
    var url = Uri.parse(
        'https://eclms-4113b-default-rtdb.asia-southeast1.firebasedatabase.app/nfc.json?auth=$authToken&$searchTerm');
    try {
      final response = await http.get(url);

      final extractedData = json.decode(response.body) as Map<String,
          dynamic>; //String key with dynamic value since flutter do not know the nested data

      if (extractedData == null) {
        print("error");
        return;
      }

      final List<NFC> loadedNFCs = [];
      if (extractedData == null) {
        return;
      }

      extractedData.forEach((nfcId, nfcData) {
        loadedNFCs.add(NFC(
          id: nfcId,
          status: nfcData['status'],
          operatorID: nfcData['operatorID'],
        ));
        _nfcs = loadedNFCs;
      });

      notifyListeners();
    } catch (error) {
      print(error);

      throw (error);
    }
  }

  //======================================= Fetch and Set NFC Tag that is Requesting Status End =========================================//
  //======================================= Update NFC Tag Status Start =========================================//
  Future<void> updateNFCStatus(String id, NFC newNFC) async {
    final nfcIndex = _nfcs.indexWhere((nfc) => nfc.id == id);

    if (nfcIndex >= 0) {
      final url = Uri.parse(
          'https://eclms-4113b-default-rtdb.asia-southeast1.firebasedatabase.app/nfc/$id.json?auth=$authToken');

      await http.patch(url, //update data
          body: json.encode({
            'status': 'Delivering',
          })); //merge data that is incoming and the data that existing in the database

      // _nfcs[nfcIndex] = NFC(
      //   id: id,
      //   status: 'Delivering',
      //   operatorID: newNFC.operatorID,
      // );
      _nfcs.removeAt(nfcIndex);
      notifyListeners();
    } else {
      print('...');
    }
  }
  //======================================= Update NFC Tag Status End =========================================//

  /*==================================== find role id start ============================================*/

  NFC findByOperatorId() {
    return _nfcs.firstWhere((nfc) => nfc.operatorID == userId,
        orElse: () => null);
  }
  /*==================================== find role id end ============================================*/

}
