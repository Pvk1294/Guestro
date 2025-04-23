import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:auto_size_text/auto_size_text.dart';
import 'package:gesturo/componets/navigation_bar.dart';
import 'package:gesturo/pages/navigation_pages/SOS_page.dart';
import 'package:gesturo/pages/navigation_pages/analytics_page.dart';
import 'package:gesturo/pages/setttings_page/bluetooth_page.dart';
import 'package:gesturo/pages/setttings_page/setting_page.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  int _currentIndex = 0;
  final User? _user = FirebaseAuth.instance.currentUser;

  final List<Widget> _screens = [
    _HomeContentWithGlovesCard(),
    const AnalyticsPage(),
    const Center(child: Text('Message Content')),
    const SOSPage(),
  ];

  String _getFirstName(String fullName) {
    return fullName
        .trim()
        .split(' ')
        .firstWhere((name) => name.isNotEmpty, orElse: () => 'User');
  }

  Widget _buildHealthCard(String parameter, BuildContext context) {
    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => const AnalyticsPage()),
        );
      },
      child: Container(
        height: 120,
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: Colors.grey[300]!),
          boxShadow: [
            BoxShadow(
              color: Colors.grey.withOpacity(0.1),
              blurRadius: 10,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              parameter,
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: Colors.grey[800],
              ),
            ),
            const Spacer(),
            Align(
              alignment: Alignment.centerRight,
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: Colors.grey[200],
                  borderRadius: BorderRadius.circular(4),
                ),
                child: Text(
                  'No Data',
                  style: TextStyle(fontSize: 12, color: Colors.grey[600]),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar:
          _currentIndex == 0
              ? AppBar(
                automaticallyImplyLeading: false,
                title: AutoSizeText(
                  _user?.displayName != null
                      ? 'Hey ${_getFirstName(_user!.displayName!)}!'
                      : 'Hey Guest!',
                  style: const TextStyle(fontWeight: FontWeight.bold),
                  maxFontSize: 25,
                  minFontSize: 20,
                  maxLines: 1,
                ),
                actions: [
                  Padding(
                    padding: const EdgeInsets.only(right: 12.0),
                    child: GestureDetector(
                      onTap:
                          () => Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => SettingsPage(user: _user),
                            ),
                          ),
                      child: CircleAvatar(
                        radius: 22,
                        backgroundImage:
                            _user?.photoURL != null
                                ? NetworkImage(_user!.photoURL!)
                                : null,
                        child:
                            _user?.photoURL == null
                                ? const Icon(Icons.person, size: 22)
                                : null,
                        backgroundColor: Colors.grey[200],
                      ),
                    ),
                  ),
                ],
              )
              : null, // Set AppBar to null on other pages
      body: _screens[_currentIndex],
      bottomNavigationBar: CustomNavigationBar(
        currentIndex: _currentIndex,
        onTap: (index) => setState(() => _currentIndex = index),
      ),
    );
  }
}

// _HomeContentWithGlovesCard widget definition here
class _HomeContentWithGlovesCard extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      child: Column(
        children: [
          const SizedBox(height: 20),
          // Smart Gloves Card
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Container(
              decoration: BoxDecoration(
                color: Colors.blue[50],
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: Colors.blue[100]!, width: 1),
              ),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Padding(
                    padding: const EdgeInsets.all(12.0),
                    child: Image.asset(
                      'assets/logo.png',
                      width: 80,
                      height: 80,
                      fit: BoxFit.contain,
                    ),
                  ),
                  Expanded(
                    child: Padding(
                      padding: const EdgeInsets.all(12.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text(
                            'Smart Gloves Technology',
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                              color: Colors.blue[900],
                            ),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            'Translates sign language to text and monitors health parameters',
                            style: TextStyle(
                              fontSize: 14,
                              color: Colors.blue[800],
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),

          // Bluetooth Status Card
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16.0),
            child: GestureDetector(
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => const BluetoothPage(),
                  ),
                );
              },
              child: Container(
                padding: const EdgeInsets.all(16),
                margin: const EdgeInsets.only(top: 16),
                decoration: BoxDecoration(
                  color: Colors.grey[200],
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: Colors.grey[400]!, width: 1),
                ),
                child: Row(
                  children: [
                    Icon(Icons.bluetooth, color: Colors.grey[600], size: 28),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Bluetooth Device',
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                              color: Colors.grey[800],
                            ),
                          ),
                          Text(
                            'Not connected',
                            style: TextStyle(
                              fontSize: 14,
                              color: Colors.grey[600],
                            ),
                          ),
                        ],
                      ),
                    ),
                    Icon(Icons.chevron_right, color: Colors.grey[600]),
                  ],
                ),
              ),
            ),
          ),

          // Health Parameters Cards
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              children: [
                const SizedBox(height: 20),
                // First row
                Row(
                  children: [
                    Expanded(
                      child: _HomePageState()._buildHealthCard(
                        'HEART RATE',
                        context,
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: _HomePageState()._buildHealthCard('SPO2', context),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                // Second row
                Row(
                  children: [
                    Expanded(
                      child: _HomePageState()._buildHealthCard(
                        'STEPS',
                        context,
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: Container(), // empty space under SPO2
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
