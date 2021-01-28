import 'package:flutter/material.dart';
import 'package:spo_balaesang/screen/application_screen.dart';
import 'package:spo_balaesang/screen/home_screen.dart';

class BottomNavScreen extends StatefulWidget {
  @override
  _BottomNavScreenState createState() => _BottomNavScreenState();
}

class _BottomNavScreenState extends State<BottomNavScreen> {
  final List<Widget> _screens = [HomeScreen(), ApplicationScreen()];
  int _currentIndex = 0;

  final Map<String, dynamic> _bottomNavItems = {
    'Beranda': Icons.home_filled,
    'Aplikasi': Icons.apps_rounded,
  };

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        body: IndexedStack(
          index: _currentIndex,
          children: _screens,
        ),
        bottomNavigationBar: BottomNavigationBar(
          currentIndex: _currentIndex,
          onTap: (index) => setState(() => _currentIndex = index),
          type: BottomNavigationBarType.fixed,
          backgroundColor: Colors.white,
          showUnselectedLabels: true,
          selectedItemColor: Colors.blueAccent,
          selectedLabelStyle: const TextStyle(
              color: Colors.blueAccent, fontWeight: FontWeight.bold),
          unselectedLabelStyle: const TextStyle(
            color: Colors.grey,
            fontWeight: FontWeight.normal,
          ),
          unselectedItemColor: Colors.grey,
          items: _bottomNavItems
              .map((key, value) => MapEntry(
                    key,
                    BottomNavigationBarItem(
                      label: key,
                      icon: Icon(value as IconData),
                    ),
                  ))
              .values
              .toList(),
        ));
  }
}
