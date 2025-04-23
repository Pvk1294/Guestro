import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter_contacts/flutter_contacts.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:shared_preferences/shared_preferences.dart';

class EmergencyContactsScreen extends StatefulWidget {
  @override
  _EmergencyContactsScreenState createState() => _EmergencyContactsScreenState();
}

class _EmergencyContactsScreenState extends State<EmergencyContactsScreen> {
  List<Contact> _contacts = [];
  final List<Contact> _selectedContacts = [];
  bool _isLoading = false;
  String _errorMessage = '';
  

  TextEditingController _searchController = TextEditingController();
  String _searchQuery = '';

  @override
  void initState() {
    super.initState();
    _initializeContacts();
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _initializeContacts() async {
    try {
      await _fetchContacts();
      await _loadSavedContacts();
    } catch (e) {
      setState(() {
        _errorMessage = 'Failed to initialize contacts: ${e.toString()}';
      });
    }
  }

  Future<bool> _checkContactPermission() async {
    if (!await FlutterContacts.requestPermission(readonly: true)) {
      setState(() {
        _errorMessage = 'Contact permission is required to use this feature';
      });
      if (await Permission.contacts.isPermanentlyDenied) {
        if (mounted) {
          showDialog(
            context: context,
            builder: (context) => AlertDialog(
              title: Text('Contact Permission Required'),
              content: Text('Please enable contact permission in app settings to use this feature.'),
              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(context),
                  child: Text('Cancel'),
                ),
                TextButton(
                  onPressed: () => openAppSettings(),
                  child: Text('Open Settings'),
                ),
              ],
            ),
          );
        }
      }
      return false;
    }
    return true;
  }

  Future<void> _fetchContacts() async {
    setState(() {
      _isLoading = true;
      _errorMessage = '';
    });

    try {
      bool hasPermission = await _checkContactPermission();
      if (!hasPermission) {
        setState(() => _isLoading = false);
        return;
      }

      final contacts = await FlutterContacts.getContacts(
        withProperties: true,
        withPhoto: false,
      );

      setState(() {
        _contacts = contacts.where((contact) =>
          contact.phones.isNotEmpty
        ).toList();
        _contacts.sort((a, b) =>
          (a.displayName).compareTo(b.displayName)
        );
      });
    } catch (e) {
      setState(() {
        _errorMessage = 'Error fetching contacts: ${e.toString()}';
      });
    } finally {
      setState(() => _isLoading = false);
    }
  }

  Future<void> _saveSelectedContacts() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final contactsJson = _selectedContacts.map((contact) {
        return {
          'name': contact.displayName,
          'phone': contact.phones.first.number,
        };
      }).toList();

      await prefs.setString('emergency_contacts', jsonEncode(contactsJson));

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Emergency contacts saved successfully'),
            backgroundColor: Colors.green,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to save contacts: ${e.toString()}'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  Future<void> _loadSavedContacts() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final contactsJson = prefs.getString('emergency_contacts');

      if (contactsJson != null) {
        final savedContacts = jsonDecode(contactsJson) as List;

        for (var saved in savedContacts) {
          final match = _contacts.firstWhere(
            (c) => c.phones.first.number == saved['phone'],
            orElse: () => Contact(id: '', displayName: '', phones: []),
          );

          if (match.id.isNotEmpty && !_selectedContacts.contains(match)) {
            setState(() {
              _selectedContacts.add(match);
            });
          }
        }
      }
    } catch (e) {
      setState(() {
        _errorMessage = 'Error loading saved contacts: ${e.toString()}';
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final filteredContacts = _contacts.where((contact) {
      final name = contact.displayName.toLowerCase();
      final phone = contact.phones.first.number.toLowerCase();
      return name.contains(_searchQuery.toLowerCase()) ||
          phone.contains(_searchQuery.toLowerCase());
    }).toList();

    return Scaffold(
      appBar: AppBar(
        title: Text('Emergency Contacts'),
        actions: [
          IconButton(
            icon: Icon(Icons.refresh),
            onPressed: _fetchContacts,
          ),
        ],
      ),
      body: _isLoading
          ? Center(child: CircularProgressIndicator())
          : Column(
              children: [
                if (_errorMessage.isNotEmpty)
                  Container(
                    padding: EdgeInsets.all(8),
                    color: Colors.red[100],
                    child: Row(
                      children: [
                        Icon(Icons.error, color: Colors.red),
                        SizedBox(width: 8),
                        Expanded(
                          child: Text(
                            _errorMessage,
                            style: TextStyle(color: Colors.red[900]),
                          ),
                        ),
                        IconButton(
                          icon: Icon(Icons.close),
                          onPressed: () => setState(() => _errorMessage = ''),
                        ),
                      ],
                    ),
                  ),
                Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: TextField(
                    controller: _searchController,
                    decoration: InputDecoration(
                      hintText: 'Search contacts...',
                      prefixIcon: Icon(Icons.search),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    onChanged: (value) {
                      setState(() {
                        _searchQuery = value;
                      });
                    },
                  ),
                ),
                Expanded(
                  child: filteredContacts.isEmpty
                      ? Center(
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(Icons.contact_phone, size: 48, color: Colors.grey),
                              SizedBox(height: 16),
                              Text(
                                'No contacts found',
                                style: Theme.of(context).textTheme.titleLarge,
                              ),
                              SizedBox(height: 8),
                              ElevatedButton(
                                onPressed: _fetchContacts,
                                child: Text('Refresh Contacts'),
                              ),
                            ],
                          ),
                        )
                      : ListView.builder(
                          itemCount: filteredContacts.length,
                          itemBuilder: (context, index) {
                            final contact = filteredContacts[index];
                            final phone = contact.phones.first.number;

                            return CheckboxListTile(
                              title: Text(contact.displayName),
                              subtitle: Text(phone),
                              value: _selectedContacts.contains(contact),
                              onChanged: (selected) {
                                setState(() {
                                  if (selected == true) {
                                    if (_selectedContacts.length < 4) {
                                      _selectedContacts.add(contact);
                                    } else {
                                      ScaffoldMessenger.of(context).showSnackBar(
                                        SnackBar(
                                          content: Text('You can only select up to 4 emergency contacts'),
                                          backgroundColor: Colors.orange,
                                        ),
                                      );
                                    }
                                  } else {
                                    _selectedContacts.remove(contact);
                                  }
                                });
                              },
                            );
                          },
                        ),
                ),
                if (_contacts.isNotEmpty)
                  Padding(
                    padding: EdgeInsets.all(16),
                    child: Column(
                      children: [
                        Text(
                          'Selected: ${_selectedContacts.length}/4 contacts',
                          style: Theme.of(context).textTheme.titleMedium,
                        ),
                        SizedBox(height: 16),
                        ElevatedButton(
                          onPressed: _selectedContacts.isEmpty ? null : _saveSelectedContacts,
                          child: Text('Save Emergency Contacts'),
                          style: ElevatedButton.styleFrom(
                            minimumSize: Size(double.infinity, 48),
                          ),
                        ),
                      ],
                    ),
                  ),
              ],
            ),
    );
  }
}
