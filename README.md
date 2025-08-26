![Logo](https://github.com/sanjaysharmajw/sim_reader/blob/main/screenshots/banner.png?raw=true)


# SIM Reader 📱

| Publisher Name | Pub Score | Pub Version |
|:------------------:|:---------------:|:--------------:|
| ![Permission](https://img.shields.io/pub/publisher/sim_reader) | ![SIM Info](https://img.shields.io/pub/points/sim_reader) | ![Network](https://img.shields.io/pub/v/sim_reader) |

A powerful Flutter plugin for reading SIM card information including carrier name, country code, phone number, network details, and more. Supports both single and dual SIM devices across Android and iOS platforms
## ✨ Features

- 📋 **Comprehensive SIM Information**: Carrier name, country code, MCC/MNC, phone number
- 📱 **Dual SIM Support**: Read information from multiple SIM cards
- 🌐 **Network Details**: Network operator, type (2G/3G/4G/5G), availability status
- 🔒 **Permission Management**: Built-in permission handling and requests
- 🚀 **Cross Platform**: Works on both Android and iOS
- ⚡ **Easy Integration**: Simple API with comprehensive error handling
- 🛡️ **Privacy Focused**: Respects platform limitations and user privacy





## 🚀 Quick Start

### Installation

Add this to your package's `pubspec.yaml` file:

```yaml
dependencies:
  sim_reader: ^1.0.0
  permission_handler: ^10.4.3  # For runtime permissions
```

Then run:

```bash
flutter pub get
```

### Basic Usage

```dart
import 'package:sim_reader/sim_reader.dart';
import 'package:permission_handler/permission_handler.dart';

// Request permission first
await Permission.phone.request();

// Check if device has SIM card
bool hasSimCard = await SimReader.hasSimCard();

// Get primary SIM card information
SimInfo? simInfo = await SimReader.getSimInfo();

// Get all SIM cards (for dual SIM devices)
List<SimInfo> allSimCards = await SimReader.getAllSimInfo();

// Get network information
NetworkInfo? networkInfo = await SimReader.getNetworkInfo();
```

### Complete Example

```dart
import 'package:flutter/material.dart';
import 'package:sim_reader/sim_reader.dart';
import 'package:permission_handler/permission_handler.dart';

class SimReaderDemo extends StatefulWidget {
  @override
  _SimReaderDemoState createState() => _SimReaderDemoState();
}

class _SimReaderDemoState extends State<SimReaderDemo> {
  List<SimInfo> simCards = [];
  NetworkInfo? networkInfo;
  bool isLoading = true;
  String? error;

  @override
  void initState() {
    super.initState();
    loadSimInfo();
  }

  Future<void> loadSimInfo() async {
    try {
      // Request permission
      PermissionStatus status = await Permission.phone.request();
      
      if (!status.isGranted) {
        setState(() {
          error = 'Phone permission is required';
          isLoading = false;
        });
        return;
      }

      // Get SIM information
      final allSimInfo = await SimReader.getAllSimInfo();
      final netInfo = await SimReader.getNetworkInfo();

      setState(() {
        simCards = allSimInfo;
        networkInfo = netInfo;
        isLoading = false;
      });
    } on SimReaderException catch (e) {
      setState(() {
        error = e.message;
        isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('SIM Reader Demo')),
      body: isLoading
          ? Center(child: CircularProgressIndicator())
          : error != null
              ? Center(child: Text('Error: $error'))
              : ListView.builder(
                  itemCount: simCards.length,
                  itemBuilder: (context, index) {
                    final sim = simCards[index];
                    return Card(
                      child: ListTile(
                        leading: Icon(Icons.sim_card),
                        title: Text(sim.carrierName ?? 'Unknown'),
                        subtitle: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text('Country: ${sim.countryCode?.toUpperCase()}'),
                            if (sim.phoneNumber != null)
                              Text('Phone: ${sim.phoneNumber}'),
                            Text('MCC/MNC: ${sim.mobileCountryCode}/${sim.mobileNetworkCode}'),
                          ],
                        ),
                      ),
                    );
                  },
                ),
      floatingActionButton: FloatingActionButton(
        onPressed: loadSimInfo,
        child: Icon(Icons.refresh),
      ),
    );
  }
}
```

## 🛠️ Platform Setup

### Android Configuration

Add the following permissions to your `android/app/src/main/AndroidManifest.xml`:

```xml
<manifest xmlns:android="http://schemas.android.com/apk/res/android">
    
    <!-- Required permissions -->
    <uses-permission android:name="android.permission.READ_PHONE_STATE" />
    <uses-permission android:name="android.permission.ACCESS_NETWORK_STATE" />
    
    <!-- Optional: For phone number access on Android 10+ -->
    <uses-permission android:name="android.permission.READ_PHONE_NUMBERS" />
    
    <application>
        <!-- Your app configuration -->
    </application>
</manifest>
```

### iOS Configuration

No additional configuration required. The plugin uses the CoreTelephony framework which is automatically available.



## 📱 iOS Permission Requirements

### Good News: No Explicit Permissions Required!

Unlike Android, iOS doesn't require explicit permissions in `Info.plist` for accessing SIM card information through the CoreTelephony framework. The SIM Reader plugin uses only public APIs that are automatically available.

## 🛠️ iOS Setup Steps (If needed, please use it. And if the SIM is not being detected, you can try using it.)

### 1. Info.plist Configuration (Optional but Recommended)

While not required, you can add usage descriptions for better App Store review process:

**File:** `ios/Runner/Info.plist`

```xml
<?xml version="1.0" encoding="UTF-8"?>
<!DOCTYPE plist PUBLIC "-//Apple//DTD PLIST 1.0//EN" "http://www.apple.com/DTDs/PropertyList-1.0.dtd">
<plist version="1.0">
<dict>
    <!-- Your existing configuration -->
    
    <!-- Optional: Add these for App Store transparency -->
    <key>NSPhoneNumberUsageDescription</key>
    <string>This app needs to access SIM card information to display carrier details and network information.</string>
    
    <key>NSContactsUsageDescription</key>
    <string>This app may access SIM card information for carrier and network details.</string>
    
    <!-- Minimum iOS version -->
    <key>MinimumOSVersion</key>
    <string>9.0</string>
    
    <!-- Your other app configurations -->
</dict>
</plist>
```

### 2. No Runtime Permission Requests Needed

Unlike Android, you don't need to request runtime permissions for SIM access:

```dart
// ❌ NOT NEEDED on iOS
// await Permission.phone.request();

// ✅ Direct access works on iOS
List<SimInfo> simCards = await SimReader.getAllSimInfo();
```

### 3. iOS-Specific Implementation

Here's how to handle iOS in your app:

```dart
import 'dart:io';
import 'package:sim_reader/sim_reader.dart';

class SimReaderHelper {
  static Future<List<SimInfo>> getSimInfo() async {
    try {
      if (Platform.isIOS) {
        // iOS - Direct access, no permissions needed
        return await SimReader.getAllSimInfo();
      } else {
        // Android - Request permissions first
        await Permission.phone.request();
        return await SimReader.getAllSimInfo();
      }
    } catch (e) {
      print('Error getting SIM info: $e');
      return [];
    }
  }
}
```

## 🔒 iOS Privacy and Limitations

### **What Works on iOS:**
- ✅ Carrier name
- ✅ Country code (ISO)
- ✅ Mobile Country Code (MCC)
- ✅ Mobile Network Code (MNC)
- ✅ Network operator name
- ✅ Network type detection
- ✅ Multiple SIM detection (iOS 12+)

### **What Doesn't Work on iOS:**
- ❌ Phone number (Apple privacy restriction)
- ❌ SIM serial number (not available via public APIs)
- ❌ Subscriber ID/IMSI (not available via public APIs)
- ❌ Detailed signal strength

### **iOS Versions Support:**
- **iOS 9.0+**: Basic SIM information
- **iOS 12.0+**: Enhanced dual SIM support
- **iOS 14.1+**: 5G network type detection

## 📋 Complete iOS Setup Example

### 1. Update Info.plist

```xml
<!-- ios/Runner/Info.plist -->
<key>CFBundleName</key>
<string>SIM Reader Example</string>

<key>CFBundleDisplayName</key>
<string>SIM Reader</string>

<!-- Optional: Usage descriptions -->
<key>NSPhoneNumberUsageDescription</key>
<string>Access SIM card information to display carrier and network details</string>

<!-- Minimum iOS version -->
<key>MinimumOSVersion</key>
<string>9.0</string>
```


## 📚 API Reference

### SimReader Class

#### Static Methods

| Method | Return Type | Description |
|--------|-------------|-------------|
| `getSimInfo()` | `Future<SimInfo?>` | Get primary SIM card information |
| `getAllSimInfo()` | `Future<List<SimInfo>>` | Get all available SIM cards |
| `hasSimCard()` | `Future<bool>` | Check if device has SIM card |
| `getNetworkInfo()` | `Future<NetworkInfo?>` | Get network operator information |

### SimInfo Class

Represents SIM card information:

```dart
class SimInfo {
  final String? carrierName;           // Carrier/operator name
  final String? countryCode;           // ISO country code (e.g., "US", "IN")
  final String? mobileCountryCode;     // Mobile Country Code (MCC)
  final String? mobileNetworkCode;     // Mobile Network Code (MNC)
  final String? phoneNumber;           // Phone number (limited availability)
  final String? simSerialNumber;       // SIM serial number/ICCID
  final String? subscriberId;          // Subscriber ID/IMSI (Android only)
  final int? simSlotIndex;            // SIM slot index (0, 1, etc.)
  final bool isNetworkRoaming;        // Whether device is roaming
}
```

#### Example Usage

```dart
SimInfo? simInfo = await SimReader.getSimInfo();

if (simInfo != null) {
  print('Carrier: ${simInfo.carrierName}');
  print('Country: ${simInfo.countryCode}');
  print('Phone: ${simInfo.phoneNumber}');
  print('MCC: ${simInfo.mobileCountryCode}');
  print('MNC: ${simInfo.mobileNetworkCode}');
  print('Roaming: ${simInfo.isNetworkRoaming}');
}
```

### NetworkInfo Class

Represents network information:

```dart
class NetworkInfo {
  final String? networkOperatorName;   // Network operator name
  final String? networkOperator;       // Network operator code
  final String? networkType;           // Network type (2G, 3G, 4G, 5G, LTE, etc.)
  final bool isNetworkAvailable;       // Network availability status
  final int? signalStrength;           // Signal strength (limited support)
}
```

#### Example Usage

```dart
NetworkInfo? networkInfo = await SimReader.getNetworkInfo();

if (networkInfo != null) {
  print('Operator: ${networkInfo.networkOperatorName}');
  print('Type: ${networkInfo.networkType}');
  print('Available: ${networkInfo.isNetworkAvailable}');
}
```

### SimReaderException

Custom exception for SIM Reader specific errors:

```dart
try {
  final simInfo = await SimReader.getSimInfo();
} on SimReaderException catch (e) {
  print('SIM Reader Error: ${e.message}');
} catch (e) {
  print('General Error: $e');
}
```

## 🔐 Permission Handling

### Automatic Permission Requests

```dart
import 'package:permission_handler/permission_handler.dart';

Future<bool> requestSimPermissions() async {
  PermissionStatus status = await Permission.phone.status;
  
  if (status.isDenied) {
    status = await Permission.phone.request();
  }
  
  if (status.isPermanentlyDenied) {
    // Open app settings
    await openAppSettings();
    return false;
  }
  
  return status.isGranted;
}

// Usage
if (await requestSimPermissions()) {
  final simInfo = await SimReader.getAllSimInfo();
  // Handle SIM information
} else {
  // Handle permission denied
}
```

### Permission Status Checking

```dart
Future<void> checkPermissionStatus() async {
  PermissionStatus status = await Permission.phone.status;
  
  switch (status) {
    case PermissionStatus.granted:
      print('Permission granted');
      break;
    case PermissionStatus.denied:
      print('Permission denied');
      break;
    case PermissionStatus.permanentlyDenied:
      print('Permission permanently denied');
      break;
    case PermissionStatus.restricted:
      print('Permission restricted');
      break;
    default:
      print('Permission status: $status');
  }
}
```

## 🌍 Platform Differences

### Android Capabilities
- ✅ Full SIM information access
- ✅ Phone number (when available and permitted)
- ✅ SIM serial number and subscriber ID
- ✅ Complete dual SIM support
- ✅ Detailed network type information
- ✅ Roaming status

### iOS Capabilities
- ✅ Carrier information (name, MCC, MNC)
- ✅ Country code
- ✅ Basic network information
- ✅ Multiple SIM detection (iOS 12+)
- ❌ Phone number (Apple privacy restriction)
- ❌ SIM serial number (not available via public APIs)
- ❌ Subscriber ID (not available via public APIs)
- ⚠️ Limited roaming information

## 🔧 Advanced Usage

### Dual SIM Handling

```dart
Future<void> handleDualSim() async {
  List<SimInfo> allSims = await SimReader.getAllSimInfo();
  
  if (allSims.length > 1) {
    print('Device has dual SIM');
    
    for (int i = 0; i < allSims.length; i++) {
      SimInfo sim = allSims[i];
      print('SIM ${i + 1}:');
      print('  Slot: ${sim.simSlotIndex}');
      print('  Carrier: ${sim.carrierName}');
      print('  Country: ${sim.countryCode}');
    }
  } else if (allSims.length == 1) {
    print('Device has single SIM');
  } else {
    print('No SIM cards found');
  }
}
```

### Network Type Detection

```dart
Future<void> checkNetworkType() async {
  NetworkInfo? networkInfo = await SimReader.getNetworkInfo();
  
  if (networkInfo != null) {
    String networkType = networkInfo.networkType ?? 'Unknown';
    
    switch (networkType.toUpperCase()) {
      case 'LTE':
      case '4G':
        print('4G/LTE network detected');
        break;
      case '5G':
      case 'NR':
        print('5G network detected');
        break;
      case '3G':
      case 'UMTS':
      case 'HSDPA':
      case 'HSUPA':
      case 'HSPA':
        print('3G network detected');
        break;
      case '2G':
      case 'GSM':
      case 'GPRS':
      case 'EDGE':
        print('2G network detected');
        break;
      default:
        print('Network type: $networkType');
    }
  }
}
```

### Error Handling Best Practices

```dart
class SimReaderHelper {
  static Future<List<SimInfo>> getSafeSimInfo() async {
    try {
      // Check permission first
      if (!await Permission.phone.isGranted) {
        throw SimReaderException('Permission not granted');
      }
      
      // Check if SIM card exists
      if (!await SimReader.hasSimCard()) {
        throw SimReaderException('No SIM card found');
      }
      
      // Get SIM information
      List<SimInfo> simCards = await SimReader.getAllSimInfo();
      
      if (simCards.isEmpty) {
        throw SimReaderException('SIM information not available');
      }
      
      return simCards;
      
    } on SimReaderException catch (e) {
      print('SIM Reader specific error: ${e.message}');
      rethrow;
    } catch (e) {
      print('Unexpected error: $e');
      throw SimReaderException('Failed to get SIM information: $e');
    }
  }
}
```

## 🐛 Troubleshooting

### Common Issues

#### 1. Permission Denied
- **Cause**: Required permissions not granted
- **Solution**: Request `READ_PHONE_STATE` permission at runtime

#### 2. No SIM Information
- **Cause**: SIM card not present or information restricted
- **Solution**: Check `hasSimCard()` first, test on real device

#### 3. Build Errors
- **Android**: Update compileSdkVersion to 33+
- **iOS**: Run `pod install` in ios directory

#### 4. Emulator Issues
- **Solution**: Test on real device with active SIM card

### Debug Helper

```dart
Future<void> debugSimReader() async {
  print('=== SIM Reader Debug ===');
  
  try {
    // Permission check
    bool hasPermission = await Permission.phone.isGranted;
    print('Permission granted: $hasPermission');
    
    if (!hasPermission) {
      print('Requesting permission...');
      PermissionStatus status = await Permission.phone.request();
      print('Permission status: $status');
    }
    
    // SIM card check
    bool hasSim = await SimReader.hasSimCard();
    print('Has SIM card: $hasSim');
    
    if (hasSim) {
      // Get all SIM info
      List<SimInfo> sims = await SimReader.getAllSimInfo();
      print('SIM count: ${sims.length}');
      
      for (int i = 0; i < sims.length; i++) {
        SimInfo sim = sims[i];
        print('SIM $i: ${sim.carrierName} (${sim.countryCode})');
      }
      
      // Network info
      NetworkInfo? network = await SimReader.getNetworkInfo();
      if (network != null) {
        print('Network: ${network.networkOperatorName} (${network.networkType})');
      }
    }
    
  } catch (e) {
    print('Debug error: $e');
  }
  
  print('=== Debug Complete ===');
}
```

## 📋 Requirements

- **Flutter**: 3.0.0 or higher
- **Dart**: 3.0.0 or higher
- **Android**: API level 16+ (Android 4.1+)
- **iOS**: iOS 9.0 or higher

## 🤝 Contributing

Contributions are welcome! Please feel free to submit a Pull Request. For major changes, please open an issue first to discuss what you would like to change.

### Development Setup

1. Fork the repository
2. Create your feature branch (`git checkout -b feature/amazing-feature`)
3. Commit your changes (`git commit -m 'Add some amazing feature'`)
4. Push to the branch (`git push origin feature/amazing-feature`)
5. Open a Pull Request

## 📄 License

This project is licensed under the BSD-3-Clause License - see the [LICENSE](LICENSE) file for details.

## 🙏 Acknowledgments

- Flutter team for the excellent plugin architecture
- Contributors and users who provided feedback and suggestions
- Mobile platform teams for providing SIM card access APIs

## 📞 Support

- **Issues**: [GitHub Issues](https://github.com/sanjaysharmajw/sim_reader/issues)
- **Documentation**: [API Documentation](https://pub.dev/documentation/sim_reader/latest/)
- **Examples**: Check the `/example` directory for complete working examples

## 🔗 Related Packages

- [`permission_handler`](https://pub.dev/packages/permission_handler) - For handling runtime permissions
- [`device_info_plus`](https://pub.dev/packages/device_info_plus) - For additional device information
- [`connectivity_plus`](https://pub.dev/packages/connectivity_plus) - For network connectivity status

---

Made with ❤️ by the SIM Reader team