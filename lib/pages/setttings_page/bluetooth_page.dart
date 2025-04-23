import 'package:flutter/material.dart';

class BluetoothPage extends StatelessWidget {
  const BluetoothPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Connect Device'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            // Header
            Text(
              'Available Bluetooth Devices',
              style: Theme.of(context).textTheme.headlineSmall,
            ),
            const SizedBox(height: 20),
            
            // Device List (Placeholder)
            Expanded(
              child: ListView(
                children: [
                  _buildDeviceTile('Smart Gloves v2.0', context),
                  _buildDeviceTile('Health Monitor', context),
                  _buildDeviceTile('Sign Language Pod', context),
                ],
              ),
            ),
            
            // Connection Button
            ElevatedButton(
              onPressed: () {
                // Would connect device in real implementation
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Connecting to device...')),
                );
              },
              child: const Text('Connect Selected Device'),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDeviceTile(String deviceName, BuildContext context) {
    return Card(
      child: ListTile(
        leading: const Icon(Icons.bluetooth),
        title: Text(deviceName),
        subtitle: const Text('Tap to connect'),
        trailing: const Icon(Icons.chevron_right),
        onTap: () {
          // Selection logic would go here
        },
      ),
    );
  }
}