import 'package:flutter/material.dart';

class Dialogs {
  static Future<void> showMyDialog(parentContext, message) {
    print('entered show my dialog function');
    print(message);
    return showDialog(
      context: parentContext,
      builder: (context) => AlertDialog(
        title: Text('An Error Occurred'),
        content: Text(message),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.of(context).pop();
            },
            child: Text('Okay'),
          ),
        ],
      ),
    );
  }
}
