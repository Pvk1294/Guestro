import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_blue_plus/flutter_blue_plus.dart' as fb;
import 'package:Gesturo/services/machine/bluetooth_services.dart';

class BluetoothDeviceListScreen extends StatefulWidget {
  @override
  _BluetoothDeviceListScreenState createState() => _BluetoothDeviceListScreenState();
}

class _BluetoothDeviceListScreenState extends State<BluetoothDeviceListScreen> {
  final BluetoothService _bluetoothService = BluetoothService();
  List<fb.ScanResult> _devices = [];
  fb.BluetoothDevice? _selectedDevice;
  bool _isScanning = false;
  bool _isBluetoothOn = false;
  bool _isConnecting = false;
  StreamSubscription? _scanSubscription;

  @override
  void initState() {
    super.initState();
    _initBluetooth();
  }

  @override
  void dispose() {
    _scanSubscription?.cancel();
    _bluetoothService.stopScan();
    super.dispose();
  }

  Future<void> _initBluetooth() async {
    try {
      _isBluetoothOn = await _bluetoothService.isBluetoothOn();
      if (!_isBluetoothOn) {
        await _bluetoothService.turnOnBluetooth();
        _isBluetoothOn = true;
      }
      _startScan();
    } catch (e) {
      _showError('Bluetooth Error', e.toString());
    }
  }

  void _startScan() async {
    try {
      setState(() {
        _isScanning = true;
        _devices = [];
      });

      _scanSubscription = _bluetoothService.scanDevices().listen((results) {
        setState(() {
          _devices = results.where((r) => r.device.localName.isNotEmpty).toList();
        });
      });
    } catch (e) {
      _showError('Scan Error', e.toString());
      setState(() => _isScanning = false);
    }
  }

  Future<void> _connectToDevice() async {
    if (_selectedDevice == null) return;

    setState(() => _isConnecting = true);
    
    try {
      await _bluetoothService.connectToDevice(_selectedDevice!);
      Navigator.pop(context, _selectedDevice); // Return connected device
    } catch (e) {
      _showError('Connection Failed', e.toString());
    } finally {
      setState(() => _isConnecting = false);
    }
  }

  void _showError(String title, String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('$title: $message'),
        backgroundColor: Colors.red,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Connect Device'),
        automaticallyImplyLeading: false,
        centerTitle: true,
        elevation: 0,
        actions: [
          IconButton(
            icon: Icon(Icons.refresh),
            onPressed: () {
              _bluetoothService.stopScan();
              _startScan();
            },
          ),
        ],
      ),
      body: Column(
        children: [
          // Status indicator
          Container(
            padding: EdgeInsets.symmetric(vertical: 8),
            color: Colors.grey[100],
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  Icons.bluetooth,
                  color: _isBluetoothOn ? Colors.blue : Colors.grey,
                  size: 20,
                ),
                SizedBox(width: 8),
                Text(
                  _isBluetoothOn ? 'Bluetooth is ON' : 'Bluetooth is OFF',
                  style: TextStyle(
                    color: _isBluetoothOn ? Colors.blue : Colors.grey,
                  ),
                ),
              ],
            ),
          ),
          
          // Available devices header
          Padding(
            padding: EdgeInsets.fromLTRB(16, 24, 16, 8),
            child: Text(
              'Available Bluetooth Devices',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Colors.grey[700],
              ),
            ),
          ),
          
          // Device list
          Expanded(
            child: _isScanning && _devices.isEmpty
                ? Center(
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        CircularProgressIndicator(),
                        SizedBox(height: 16),
                        Text('Searching for devices...'),
                      ],
                    ),
                  )
                : ListView.builder(
                    padding: EdgeInsets.symmetric(horizontal: 16),
                    itemCount: _devices.length,
                    itemBuilder: (context, index) {
                      final device = _devices[index].device;
                      final isSelected = _selectedDevice?.remoteId == device.remoteId;
                      return _buildDeviceTile(device, isSelected);
                    },
                  ),
          ),
          
          // Connect button
          Padding(
            padding: EdgeInsets.all(16),
            child: SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  padding: EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  backgroundColor: _selectedDevice != null ? Colors.blue : Colors.grey[300],
                ),
                onPressed: _selectedDevice != null && !_isConnecting ? _connectToDevice : null,
                child: _isConnecting
                    ? SizedBox(
                        height: 20,
                        width: 20,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          color: Colors.white,
                        ),
                      )
                    : Text(
                        'CONNECT SELECTED DEVICE',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDeviceTile(fb.BluetoothDevice device, bool isSelected) {
    return Card(
      margin: EdgeInsets.only(bottom: 8),
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: BorderSide(
          color: isSelected ? Colors.blue : Colors.grey[200]!,
          width: 1,
        ),
      ),
      child: InkWell(
        borderRadius: BorderRadius.circular(12),
        onTap: () {
          setState(() {
            _selectedDevice = device;
          });
        },
        child: Padding(
          padding: EdgeInsets.all(16),
          child: Row(
            children: [
              Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  color: isSelected ? Colors.blue[50] : Colors.grey[100],
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  Icons.devices,
                  color: isSelected ? Colors.blue : Colors.grey[600],
                ),
              ),
              SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      device.localName,
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    SizedBox(height: 4),
                    Text(
                      'Tap to connect',
                      style: TextStyle(
                        fontSize: 14,
                        color: Colors.grey[600],
                      ),
                    ),
                    SizedBox(height: 4),
                  ],
                ),
              ),
              if (isSelected)
                Icon(
                  Icons.check_circle,
                  color: Colors.blue,
                ),
            ],
          ),
        ),
      ),
    );
  }
}