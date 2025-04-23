import 'package:flutter_blue_plus/flutter_blue_plus.dart' as fb;

class BluetoothService {
  // Check if Bluetooth is supported on the device
  Future<bool> isBluetoothAvailable() async {
    try {
      return await fb.FlutterBluePlus.isSupported;
    } catch (e) {
      throw Exception('Failed to check Bluetooth support: $e');
    }
  }

  // Check if Bluetooth is currently turned on
  Future<bool> isBluetoothOn() async {
    try {
      return await fb.FlutterBluePlus.isOn;
    } catch (e) {
      throw Exception('Failed to check Bluetooth state: $e');
    }
  }

  // Turn on Bluetooth (Android only)
  Future<void> turnOnBluetooth() async {
    try {
      if (!await isBluetoothOn()) {
        await fb.FlutterBluePlus.turnOn();
      }
    } catch (e) {
      throw Exception('Failed to turn on Bluetooth: $e');
    }
  }

  // Scan for BLE devices with timeout
  Stream<List<fb.ScanResult>> scanDevices({Duration timeout = const Duration(seconds: 15)}) {
    try {
      fb.FlutterBluePlus.startScan(
        timeout: timeout,
        removeIfGone: const Duration(seconds: 5),
      );
      return fb.FlutterBluePlus.scanResults;
    } catch (e) {
      throw Exception('Failed to start scanning: $e');
    }
  }

  // Connect to a BLE device with timeout
  Future<void> connectToDevice(fb.BluetoothDevice device, {Duration timeout = const Duration(seconds: 15)}) async {
    try {
      await device.connect(
        autoConnect: false,
        timeout: timeout,
      );
    } catch (e) {
      throw Exception('Failed to connect to device ${device.remoteId}: $e');
    }
  }

  // Disconnect from device
  Future<void> disconnectDevice(fb.BluetoothDevice device) async {
    try {
      if (device.isConnected) {
        await device.disconnect();
      }
    } catch (e) {
      throw Exception('Failed to disconnect from device ${device.remoteId}: $e');
    }
  }

  // Discover services of a connected device
  Future<List<fb.BluetoothService>> discoverServices(fb.BluetoothDevice device) async {
    try {
      if (!device.isConnected) {
        throw Exception('Device is not connected');
      }
      return await device.discoverServices();
    } catch (e) {
      throw Exception('Failed to discover services: $e');
    }
  }

  // Stop ongoing scan
  Future<void> stopScan() async {
    try {
      await fb.FlutterBluePlus.stopScan();
    } catch (e) {
      throw Exception('Failed to stop scanning: $e');
    }
  }

  // Get connected devices
  Future<List<fb.BluetoothDevice>> getConnectedDevices() async {
  return await fb.FlutterBluePlus.connectedDevices;
  }


  // Listen to device connection state changes
  Stream<fb.BluetoothConnectionState> deviceConnectionState(fb.BluetoothDevice device) {
    return device.connectionState;
  }
}