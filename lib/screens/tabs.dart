// import 'package:flutter/material.dart';

// import '../widgets/app_drawer.dart';
// // import '../screens/profile_screen.dart';
// // import '../screens/personalContactList_screen.dart';
// // import '../screens/sharedContactList_screen.dart';

// class TabsScreen extends StatefulWidget {
//   final String userID;

//   TabsScreen(this.userID);

//   @override
//   State<TabsScreen> createState() => _TabsScreenState();
// }

// class _TabsScreenState extends State<TabsScreen> {
//   List<Map<String, Object>> _pages;

//   int _selectedPageIndex = 0;

//   void _selectPage(int index) {
//     setState(() {
//       _selectedPageIndex = index;
//     });
//   }

//   @override
//   void initState() {
//     _pages = [
//       // {
//       //   'page': HomePage(),
//       // },
//       {
//         'page': PersonalContactList(),
//       },
//       {
//         'page': SharedContactList(widget.userID),
//       },
//       {
//         'page': ProfileScreen(),
//       },
//     ];
//     super.initState();
//   }

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       drawer: AppDrawer(),
//       body: _pages[_selectedPageIndex]['page'],
//       bottomNavigationBar: BottomNavigationBar(
//         onTap: _selectPage,
//         // backgroundColor: Theme.of(context).primaryColor,
//         unselectedItemColor: Colors.grey,
//         selectedItemColor: Theme.of(context).primaryColor,
//         currentIndex: _selectedPageIndex,
//         // type: BottomNavigationBarType.shifting,
//         items: [
//           // BottomNavigationBarItem(
//           //   icon: Icon(Icons.home),
//           //   label: 'Home',

//           // ),
//           BottomNavigationBarItem(
//             icon: Icon(Icons.person_outline),
//             label: 'Personal',
//           ),
//           BottomNavigationBarItem(
//             icon: Icon(Icons.group_outlined),
//             label: 'Company',
//           ),
//           BottomNavigationBarItem(
//             icon: Icon(Icons.account_circle_outlined),
//             label: 'Profile',
//           ),
//         ],
//       ),
//     );
//   }
// }
