import 'package:plugin_platform_interface/plugin_platform_interface.dart';

import 'sim_reader_method_channel.dart';
import '../sim_reader.dart';

abstract class SimReaderPlatform extends PlatformInterface {
  /// Constructs a SimReaderPlatform.
  SimReaderPlatform() : super(token: _token);

  static final Object _token = Object();

  static SimReaderPlatform _instance = MethodChannelSimReader();

  /// The default instance of [SimReaderPlatform] to use.
  ///
  /// Defaults to [MethodChannelSimReader].
  static SimReaderPlatform get instance => _instance;

  /// Platform-specific implementations should set this with their own
  /// platform-specific class that extends [SimReaderPlatform] when
  /// they register themselves.
  static set instance(SimReaderPlatform instance) {
    PlatformInterface.verifyToken(instance, _token);
    _instance = instance;
  }

  Future<SimInfo?> getSimInfo() {
    throw UnimplementedError('getSimInfo() has not been implemented.');
  }

  Future<List<SimInfo>> getAllSimInfo() {
    throw UnimplementedError('getAllSimInfo() has not been implemented.');
  }

  Future<bool> hasSimCard() {
    throw UnimplementedError('hasSimCard() has not been implemented.');
  }

  Future<NetworkInfo?> getNetworkInfo() {
    throw UnimplementedError('getNetworkInfo() has not been implemented.');
  }
}
