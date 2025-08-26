import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import '../sim_reader.dart';

/// An implementation of [] that uses method channels.
class MethodChannelSimReader extends SimReaderPlatform {
  /// The method channel used to interact with the native platform.
  @visibleForTesting
  final methodChannel = const MethodChannel('sim_reader');

  @override
  Future<SimInfo?> getSimInfo() async {
    try {
      final result = await methodChannel.invokeMethod<Map<Object?, Object?>>(
        'getSimInfo',
      );
      if (result == null) return null;
      return SimInfo.fromMap(Map<String, dynamic>.from(result));
    } on PlatformException catch (e) {
      throw SimReaderException('Failed to get SIM info: ${e.message}');
    }
  }

  @override
  Future<List<SimInfo>> getAllSimInfo() async {
    try {
      final result = await methodChannel.invokeMethod<List<Object?>>(
        'getAllSimInfo',
      );
      if (result == null) return [];

      return result
          .cast<Map<Object?, Object?>>()
          .map((sim) => SimInfo.fromMap(Map<String, dynamic>.from(sim)))
          .toList();
    } on PlatformException catch (e) {
      throw SimReaderException('Failed to get all SIM info: ${e.message}');
    }
  }

  @override
  Future<bool> hasSimCard() async {
    try {
      final result = await methodChannel.invokeMethod<bool>('hasSimCard');
      return result ?? false;
    } on PlatformException catch (e) {
      throw SimReaderException('Failed to check SIM card: ${e.message}');
    }
  }

  @override
  Future<NetworkInfo?> getNetworkInfo() async {
    try {
      final result = await methodChannel.invokeMethod<Map<Object?, Object?>>(
        'getNetworkInfo',
      );
      if (result == null) return null;
      return NetworkInfo.fromMap(Map<String, dynamic>.from(result));
    } on PlatformException catch (e) {
      throw SimReaderException('Failed to get network info: ${e.message}');
    }
  }
}
