import 'package:flutter/material.dart';

import 'admin_account_management_page.dart';

class AdminSpace extends StatefulWidget {
  const AdminSpace({super.key});

  @override
  State<AdminSpace> createState() => _AdminSpaceState();
}

class _AdminSpaceState extends State<AdminSpace> {
  int _currentPageIndex = 0;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: <Widget>[
        const AccountManagementPage(title: 'Account Management'),
        Container(
          color: Colors.green,
          alignment: Alignment.center,
          child: const Text('Page 2'),
        ),
        Container(
          color: Colors.blue,
          alignment: Alignment.center,
          child: const Text('Page 3'),
        ),
      ][_currentPageIndex],
      bottomNavigationBar: NavigationBar(
        onDestinationSelected: (int index) {
          setState(() {
            _currentPageIndex = index;
          });
        },
        selectedIndex: _currentPageIndex,
        destinations: const <Widget>[
          NavigationDestination(
            icon: Icon(Icons.account_circle),
            label: 'Accounts',
          ),
          NavigationDestination(
            icon: Icon(Icons.library_books),
            label: 'QALib',
          ),
          NavigationDestination(
            icon: Icon(Icons.settings),
            label: 'Settings',
          ),
        ],
      ),
    );
  }
}
