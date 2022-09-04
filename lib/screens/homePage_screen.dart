import 'package:flutter/material.dart';
import '../widgets/app_drawer.dart';

class HomePage extends StatelessWidget {
  static const routeName = '/home_page';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('My-List'),
            backgroundColor: Theme.of(context).primaryColor,
      
      ),
      drawer: AppDrawer(),
      body: Center(
        child: Text('This is home page'),
      ),
    );
  }
}
