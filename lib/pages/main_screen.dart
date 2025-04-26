import 'package:Gesturo/pages/navigation_pages/message_page.dart';
import 'package:flutter/material.dart';
import 'package:Gesturo/componets/navigation_bar.dart';
import 'package:Gesturo/pages/navigation_pages/SOS_page.dart';

class MainScreen extends StatefulWidget {
  const MainScreen({super.key});

  @override
  State<MainScreen> createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> {
  int _currentIndex = 0;

  final List<Widget> _screens = [
    const Center(child: Text('Home Content')),
    const Center(child: Text('Analytics Content')),
    MessagePage(),
    const SOSPage(),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: _screens[_currentIndex],
      bottomNavigationBar: CustomNavigationBar(
        currentIndex: _currentIndex,
        onTap: (index) => setState(() => _currentIndex = index),
      ),
    );
  }
}
