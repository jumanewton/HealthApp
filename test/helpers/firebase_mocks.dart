// test/helpers/firebase_mocks.dart

import 'package:flutter_test/flutter_test.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_core_platform_interface/firebase_core_platform_interface.dart';
import 'package:flutter/services.dart';
import 'package:meta/meta.dart';
import 'package:mockito/mockito.dart';

class MockFirebaseAppPlatform extends Mock implements FirebaseAppPlatform {
  @override
  String get name => '[DEFAULT]';
}

class MockFirebaseApp implements FirebaseApp {
  @override
  String get name => '[DEFAULT]';

  @override
  Map<String, dynamic> get pluginConstants => {}; // Keep only this one

  @override
  FirebaseOptions get options => const FirebaseOptions(
    apiKey: 'test-api-key',
    appId: 'test-app-id',
    messagingSenderId: 'test-sender-id',
    projectId: 'test-project-id',
    storageBucket: 'test-bucket',
  );
  
  @override
  Future<void> delete() async {}
  
  @override
  bool operator ==(Object other) =>
      other is FirebaseApp && other.name == name;
      
  @override
  int get hashCode => name.hashCode;
  
  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}

class MockFirebasePlatform extends Mock implements FirebasePlatform {
  MockFirebaseApp? _app;
  
   @override
  FirebaseAppPlatform app([String name = defaultFirebaseAppName]) {
    _app ??= MockFirebaseApp();
    return _app! as FirebaseAppPlatform;
  }
  
  @override
  @visibleForTesting
  Future<FirebaseAppPlatform> initializeApp({
    String? name,
    FirebaseOptions? options,
  }) async {
    _app ??= MockFirebaseApp(); // Ensure _app is initialized
    final appPlatform = MockFirebaseAppPlatform(); // Create a MockFirebaseAppPlatform instance
    return appPlatform; // Return the MockFirebaseAppPlatform instance
  }
  
  @override
  List<FirebaseAppPlatform> get apps => _app != null ? <FirebaseAppPlatform>[_app! as FirebaseAppPlatform] : <FirebaseAppPlatform>[];
}

Future<void> setupFirebaseCoreMocks() async {
  TestWidgetsFlutterBinding.ensureInitialized();

  // Register the mock platform
  final platform = MockFirebasePlatform();
  FirebasePlatform.instance = platform;

  // Mock method channel
  const MethodChannel channel = MethodChannel(
    'plugins.flutter.io/firebase_core',
  );
  
  TestWidgetsFlutterBinding.ensureInitialized().defaultBinaryMessenger
      .setMockMethodCallHandler(channel, (call) async {
    try {
      if (call.method == 'Firebase#initializeCore') {
        return [
          {
            'name': '[DEFAULT]',
            'options': {
              'apiKey': 'test-api-key',
              'appId': 'test-app-id',
              'messagingSenderId': 'test-sender-id',
              'projectId': 'test-project-id',
              'storageBucket': 'test-bucket',
            },
            'pluginConstants': {},
          }
        ];
      }
      if (call.method == 'Firebase#initializeApp') {
        return {
          'name': call.arguments['appName'] ?? '[DEFAULT]',
          'options': call.arguments['options'] ?? {
            'apiKey': 'test-api-key',
            'appId': 'test-app-id',
            'messagingSenderId': 'test-sender-id',
            'projectId': 'test-project-id',
            'storageBucket': 'test-bucket',
          },
          'pluginConstants': {},
        };
      }
      return null;
    } catch (e) {
      throw PlatformException(
        code: 'UNKNOWN',
        message: 'An unknown error occurred: $e',
      );
    }
  });
}