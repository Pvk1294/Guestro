import 'package:flutter/material.dart';
import 'package:Gesturo/pages/setttings_page/Profile_page.dart';
import 'package:Gesturo/pages/setttings_page/bluetooth_page.dart';
import 'package:Gesturo/services/auth/auth_services.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:Gesturo/pages/account_page/login_page.dart';
import 'package:shared_preferences/shared_preferences.dart';

class SettingsPage extends StatefulWidget {
  final User? user;
  final void Function()? onTap;

  const SettingsPage({super.key, this.onTap, required this.user});

  @override
  State<SettingsPage> createState() => _SettingsPageState();
}

class _SettingsPageState extends State<SettingsPage> {
  final AuthServices authService = AuthServices();
  String _currentLanguage = 'ISL'; // Default language

  @override
  void initState() {
    super.initState();
    _loadLanguage();
  }

  Future<void> _loadLanguage() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    setState(() {
      _currentLanguage = prefs.getString('selectedLanguage') ?? 'ISL';
    });
  }

  Future<void> _logout(BuildContext context) async {
    try {
      await authService.signOut();
      Navigator.pushAndRemoveUntil(
        context,
        MaterialPageRoute(builder: (context) => LoginPage(onTap: null)),
        (route) => false,
      );
    } catch (e) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Logout failed: ${e.toString()}')));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Settings'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            // Profile Section
            Card(
              elevation: 2,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  children: [
                    CircleAvatar(
                      radius: 40,
                      backgroundImage:
                          widget.user?.photoURL != null
                              ? NetworkImage(widget.user!.photoURL!)
                              : null,
                      child:
                          widget.user?.photoURL == null
                              ? const Icon(Icons.person, size: 40)
                              : null,
                    ),
                    const SizedBox(height: 16),
                    Text(
                      widget.user?.displayName ?? 'Guest User',
                      style: Theme.of(context).textTheme.titleLarge,
                    ),
                    const SizedBox(height: 4),
                    Text(
                      widget.user?.email ?? 'No email provided',
                      style: Theme.of(
                        context,
                      ).textTheme.bodyMedium?.copyWith(color: Colors.grey[600]),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 24),

            // Settings Options
            _buildSettingsOption(
              context,
              icon: Icons.edit,
              title: 'Edit Profile',
              onTap:
                  () => Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder:
                          (context) => EditProfilePage(
                            user: widget.user,
                          ), // Passing user here
                    ),
                  ),
            ),

            _buildLanguageDropdown(context),

            _buildSettingsOption(
              context,
              icon: Icons.bluetooth,
              title: 'Device Settings',
              onTap:
                  () => Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => BluetoothDeviceListScreen(),
                    ),
                  ),
            ),

            const SizedBox(height: 100),

            // Logout Button
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () => _logout(context),
                style: ElevatedButton.styleFrom(
                  foregroundColor: Colors.white,
                  backgroundColor: Colors.red,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                ),
                child: const Text('LOGOUT'),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSettingsOption(
    BuildContext context, {
    required IconData icon,
    required String title,
    required VoidCallback onTap,
  }) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: ListTile(
        leading: Icon(icon),
        title: Text(title),
        trailing: const Icon(Icons.chevron_right),
        onTap: onTap,
      ),
    );
  }

  Widget _buildLanguageDropdown(BuildContext context) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: ListTile(
        leading: const Icon(Icons.language),
        title: const Text('Language'),
        trailing: DropdownButton<String>(
          value: _currentLanguage,
          underline: const SizedBox(),
          items:
              ['ISL', 'BSL', 'ASL']
                  .map(
                    (language) => DropdownMenuItem(
                      value: language,
                      child: Text(language),
                    ),
                  )
                  .toList(),
          onChanged: (String? newValue) async {
            if (newValue != null) {
              SharedPreferences prefs = await SharedPreferences.getInstance();
              await prefs.setString('selectedLanguage', newValue);
              setState(() {
                _currentLanguage = newValue;
              });
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text('Language set to $newValue')),
              );
            }
          },
        ),
      ),
    );
  }
}
