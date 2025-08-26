import 'package:flutter_test/flutter_test.dart';
import 'package:sim_reader/sim_reader.dart';
import 'package:plugin_platform_interface/plugin_platform_interface.dart';
import 'package:sim_reader/src/sim_reader_method_channel.dart';

class MockSimReaderPlatform
    with MockPlatformInterfaceMixin
    implements SimReaderPlatform {
  @override
  Future<String?> getPlatformVersion() => Future.value('42');

  @override
  Future<List<SimInfo>> getAllSimInfo() {
    // TODO: implement getAllSimInfo
    throw UnimplementedError();
  }

  @override
  Future<NetworkInfo?> getNetworkInfo() {
    // TODO: implement getNetworkInfo
    throw UnimplementedError();
  }

  @override
  Future<SimInfo?> getSimInfo() {
    // TODO: implement getSimInfo
    throw UnimplementedError();
  }

  @override
  Future<bool> hasSimCard() {
    // TODO: implement hasSimCard
    throw UnimplementedError();
  }
}

void main() {
  final SimReaderPlatform initialPlatform = SimReaderPlatform.instance;

  test('$MethodChannelSimReader is the default instance', () {
    expect(initialPlatform, isInstanceOf<MethodChannelSimReader>());
  });

  test('getPlatformVersion', () async {
    MockSimReaderPlatform fakePlatform = MockSimReaderPlatform();
    SimReaderPlatform.instance = fakePlatform;

    expect(SimReader.getSimInfo().toString(), '42');
  });
}
