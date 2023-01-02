import 'package:flutter/material.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';

class SplashScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Center(
        
        child: SpinKitDoubleBounce(
          color: Theme.of(context).primaryColor,
          size: 100,
        ),
      ),
    );
  }
}
