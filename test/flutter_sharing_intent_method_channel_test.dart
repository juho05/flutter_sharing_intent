import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_sharing_intent/flutter_sharing_intent_method_channel.dart';
import 'package:flutter_sharing_intent/model/sharing_file.dart';

void main() {
  MethodChannelFlutterSharingIntent platform =
      MethodChannelFlutterSharingIntent();
  const MethodChannel channel = MethodChannel('flutter_sharing_intent');

  TestWidgetsFlutterBinding.ensureInitialized();

  setUp(() {
    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
        .setMockMethodCallHandler(channel, (MethodCall methodCall) async {
          return '42';
        });
  });

  tearDown(() {
    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
        .setMockMethodCallHandler(channel, null);
  });

  test('getPlatformVersion', () async {
    expect(await platform.getPlatformVersion(), '42');
  });

  test('cleanUp sends file and thumbnail paths', () async {
    final calls = <MethodCall>[];
    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
        .setMockMethodCallHandler(channel, (MethodCall methodCall) async {
          calls.add(methodCall);
          return null;
        });
    await platform.cleanUp([
      SharedFile(value: '/inbox/a/score.pdf'),
      SharedFile(value: '/inbox/b/video.mp4', thumbnail: '/inbox/b/thumb.jpg'),
      SharedFile(value: null),
    ]);
    expect(calls.single.method, 'cleanUp');
    expect(calls.single.arguments, [
      '/inbox/a/score.pdf',
      '/inbox/b/video.mp4',
      '/inbox/b/thumb.jpg',
    ]);
  });

  test('cleanUp skips the call without paths', () async {
    final calls = <MethodCall>[];
    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
        .setMockMethodCallHandler(channel, (MethodCall methodCall) async {
          calls.add(methodCall);
          return null;
        });
    await platform.cleanUp([SharedFile(value: null)]);
    expect(calls, isEmpty);
  });
}
