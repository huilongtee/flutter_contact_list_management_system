import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_contact_list_management_system/providers/profile_provider.dart';
import '../providers/nfc_provider.dart';
import 'package:nfc_manager/nfc_manager.dart';
import 'package:provider/provider.dart';

import '../main.dart';

class NFCItem extends StatefulWidget {
  final String id;
  final String status;
  final String operatorID;

  NFCItem(this.id, this.status, this.operatorID);

  @override
  State<NFCItem> createState() => _NFCItemState();
}

class _NFCItemState extends State<NFCItem> {
  bool listenerRunning = false;

  bool writeOperatorIDOnNextContact = false;



  //add by nfc
  void _showBottomSheetForNFC() {
    showModalBottomSheet(
        context: context,
        builder: (BuildContext content) {
          return Card(
            elevation: 5,
            child: Container(
                padding: EdgeInsets.all(10),
                child: Center(
                  child: _getNfcWidgets(),
                )),
          );
        });
  }

  Widget _getNfcWidgets() {
    if (isNfcAvalible) {
      //For ios always false, for android true if running
      writeOperatorIDOnNextContact ? null : _writeNfcTag();
      return 
      Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(writeOperatorIDOnNextContact
            ? 'Waiting for tag to write'
            : 'Write to tag'),
        ],
      );
    } else {
      if (Platform.isIOS) {
        //Ios doesnt allow the user to turn of NFC at all,  if its not avalible it means its not build in
        return const Text("Your device doesn't support NFC");
      } else {
        //Android phones can turn of NFC in the settings
        return const Text(
            "Your device doesn't support NFC or it's turned off in the system settings");
      }
    }
  }

  //Helper method to show a quick message
  void _alert(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          message,
        ),
        duration: const Duration(
          seconds: 2,
        ),
      ),
    );
  }

  Future<void> _listenForNFCEvents() async {
    //Always run this for ios but only once for android
    if (Platform.isAndroid && listenerRunning == false || Platform.isIOS) {
      //Android supports reading nfc in the background, starting it one time is all we need
      if (Platform.isAndroid) {
        _alert(
          'NFC listener running in background now, approach tag(s)',
        );
        //Update button states
        setState(() {
          listenerRunning = true;
        });
      }

      NfcManager.instance.startSession(
        onDiscovered: (NfcTag tag) async {
          bool succses = false;
          //Try to convert the raw tag data to NDEF
          final ndefTag = Ndef.from(tag);
          //If the data could be converted we will get an object
          if (ndefTag != null) {
            // If we want to write the current counter vlaue we will replace the current content on the tag
            if (writeOperatorIDOnNextContact) {
              //Ensure the write flag is off again
              setState(() {
                writeOperatorIDOnNextContact = false;
              });
              //Create a 1Well known tag with en as language code and 0x02 encoding for UTF8
              final ndefRecord =
                  NdefRecord.createText(widget.operatorID.toString());
              //Create a new ndef message with a single record
              final ndefMessage = NdefMessage([ndefRecord]);
              //Write it to the tag, tag must still be "connected" to the device
              try {
                //Any existing content will be overrwirten
                await ndefTag.write(ndefMessage);
                _alert('Operator ID written to tag');
                succses = true;
                Provider.of<NFCProvider>(
                  context,
                  listen: false,
                ).updateNFCStatus(
                  widget.id,
                  NFC(
                    id: widget.id,
                    status: widget.status,
                    operatorID: widget.operatorID,
                  ),
                );
                Navigator.of(context).pop();
              } catch (e) {
                _alert("Writting failed, press 'Write to tag' again");
              }
            }
            // //The NDEF Message was already parsed, if any
            // else if (ndefTag.cachedMessage != null) {
            //   var ndefMessage = ndefTag.cachedMessage;
            //   //Each NDEF message can have multiple records, we will use the first one in our example
            //   if (ndefMessage.records.isNotEmpty &&
            //       ndefMessage.records.first.typeNameFormat ==
            //           NdefTypeNameFormat.nfcWellknown) {
            //     //If the first record exists as 1:Well-Known we consider this tag as having a value for us
            //     final wellKnownRecord = ndefMessage.records.first;

            //     ///Payload for a 1:Well Known text has the following format:
            //     ///[Encoding flag 0x02 is UTF8][ISO language code like en][content]

            //     if (wellKnownRecord.payload.first == 0x02) {
            //       //Now we know the encoding is UTF8 and we can skip the first byte
            //       final languageCodeAndContentBytes =
            //           wellKnownRecord.payload.skip(1).toList();
            //       //Note that the language code can be encoded in ASCI, if you need it be carfully with the endoding
            //       final languageCodeAndContentText =
            //           utf8.decode(languageCodeAndContentBytes);
            //       //Cutting of the language code
            //       final payload = languageCodeAndContentText.substring(2);
            //       //Parsing the content to int
            //       final storedCounters = int.tryParse(payload);
            //       if (storedCounters != null) {
            //         succses = true;
            //         _alert('Counter restored from tag');
            //         setState(() {
            //           _counter = storedCounters;
            //         });
            //       }
            //     }
            //   }
            // }
          }
          //Due to the way ios handles nfc we need to stop after each tag
          if (Platform.isIOS) {
            NfcManager.instance.stopSession();
          }
          if (succses == false) {
            _alert(
              'Tag was not valid',
            );
          }
        },
        // Required for iOS to define what type of tags should be noticed
        pollingOptions: {
          NfcPollingOption.iso14443,
          NfcPollingOption.iso15693,
        },
      );
    }
  }

  @override
  void dispose() {
    try {
      NfcManager.instance.stopSession();
    } catch (_) {
      //We dont care
    }
    super.dispose();
  }

  void _writeNfcTag() {
    setState(() {
      writeOperatorIDOnNextContact = true;
    });

    if (Platform.isAndroid) {
      _alert('Approach phone with tag');
    }
    //Writing a requires to read the tag first, on android this call might do nothing as the listner is already running
    _listenForNFCEvents();
  }

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: EdgeInsets.symmetric(vertical: 5),
      elevation: 2,
      child: ListTile(
        contentPadding: EdgeInsets.symmetric(vertical: 10, horizontal: 15),
        onTap: () {
          _listenForNFCEvents();
          _showBottomSheetForNFC();
        },
        title: Text(widget.operatorID),
        subtitle: Text(widget.status),
      ),
    );
  }
}
