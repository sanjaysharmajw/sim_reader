library sim_reader;

import 'src/sim_reader_platform_interface.dart';

export 'src/sim_reader_platform_interface.dart';

/// Main class for accessing SIM card information
class SimReader {
  /// Get basic SIM card information
  static Future<SimInfo?> getSimInfo() {
    return SimReaderPlatform.instance.getSimInfo();
  }

  /// Get all available SIM cards (for dual SIM devices)
  static Future<List<SimInfo>> getAllSimInfo() {
    return SimReaderPlatform.instance.getAllSimInfo();
  }

  /// Check if device has SIM card
  static Future<bool> hasSimCard() {
    return SimReaderPlatform.instance.hasSimCard();
  }

  /// Get network operator information
  static Future<NetworkInfo?> getNetworkInfo() {
    return SimReaderPlatform.instance.getNetworkInfo();
  }
}

/// SIM card information model
class SimInfo {
  final String? carrierName;
  final String? countryCode;
  final String? mobileCountryCode;
  final String? mobileNetworkCode;
  final String? phoneNumber;
  final String? simSerialNumber;
  final String? subscriberId;
  final int? simSlotIndex;
  final bool isNetworkRoaming;

  SimInfo({
    this.carrierName,
    this.countryCode,
    this.mobileCountryCode,
    this.mobileNetworkCode,
    this.phoneNumber,
    this.simSerialNumber,
    this.subscriberId,
    this.simSlotIndex,
    this.isNetworkRoaming = false,
  });

  factory SimInfo.fromMap(Map<String, dynamic> map) {
    return SimInfo(
      carrierName: map['carrierName'],
      countryCode: map['countryCode'],
      mobileCountryCode: map['mobileCountryCode'],
      mobileNetworkCode: map['mobileNetworkCode'],
      phoneNumber: map['phoneNumber'],
      simSerialNumber: map['simSerialNumber'],
      subscriberId: map['subscriberId'],
      simSlotIndex: map['simSlotIndex'],
      isNetworkRoaming: map['isNetworkRoaming'] ?? false,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'carrierName': carrierName,
      'countryCode': countryCode,
      'mobileCountryCode': mobileCountryCode,
      'mobileNetworkCode': mobileNetworkCode,
      'phoneNumber': phoneNumber,
      'simSerialNumber': simSerialNumber,
      'subscriberId': subscriberId,
      'simSlotIndex': simSlotIndex,
      'isNetworkRoaming': isNetworkRoaming,
    };
  }

  @override
  String toString() {
    return 'SimInfo(carrierName: $carrierName, countryCode: $countryCode, '
        'phoneNumber: $phoneNumber, simSlotIndex: $simSlotIndex)';
  }
}

/// Network information model
class NetworkInfo {
  final String? networkOperatorName;
  final String? networkOperator;
  final String? networkType;
  final bool isNetworkAvailable;
  final int? signalStrength;

  NetworkInfo({
    this.networkOperatorName,
    this.networkOperator,
    this.networkType,
    this.isNetworkAvailable = false,
    this.signalStrength,
  });

  factory NetworkInfo.fromMap(Map<String, dynamic> map) {
    return NetworkInfo(
      networkOperatorName: map['networkOperatorName'],
      networkOperator: map['networkOperator'],
      networkType: map['networkType'],
      isNetworkAvailable: map['isNetworkAvailable'] ?? false,
      signalStrength: map['signalStrength'],
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'networkOperatorName': networkOperatorName,
      'networkOperator': networkOperator,
      'networkType': networkType,
      'isNetworkAvailable': isNetworkAvailable,
      'signalStrength': signalStrength,
    };
  }

  @override
  String toString() {
    return 'NetworkInfo(networkOperatorName: $networkOperatorName, '
        'networkType: $networkType, isNetworkAvailable: $isNetworkAvailable)';
  }
}

/// Custom exception for SIM Reader errors
class SimReaderException implements Exception {
  final String message;

  SimReaderException(this.message);

  @override
  String toString() => 'SimReaderException: $message';
}