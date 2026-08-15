import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:think_slide/main.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/services.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:firebase_core_platform_interface/firebase_core_platform_interface.dart';
import 'dart:io';
import 'dart:async';
import 'dart:convert';

class MockFirebasePlatform extends FirebasePlatform {
  final List<FirebaseAppPlatform> _apps = [];

  @override
  Future<FirebaseAppPlatform> initializeApp({
    String? name,
    FirebaseOptions? options,
  }) async {
    final app = MockFirebaseAppPlatform(name ?? defaultFirebaseAppName, options!);
    _apps.add(app);
    return app;
  }

  @override
  List<FirebaseAppPlatform> get apps => _apps;

  @override
  FirebaseAppPlatform app([String name = defaultFirebaseAppName]) {
    return _apps.firstWhere((a) => a.name == name);
  }
}

class MockFirebaseAppPlatform extends FirebaseAppPlatform {
  MockFirebaseAppPlatform(super.name, super.options);
}

void setupFirebaseMocks() {
  TestWidgetsFlutterBinding.ensureInitialized();
  SharedPreferences.setMockInitialValues({});
  
  // Set the mock instance before anything else
  FirebasePlatform.instance = MockFirebasePlatform();

  // Mock other common Firebase services to prevent crashes during pumpWidget
  for (final channel in [
    'plugins.flutter.io/firebase_auth',
    'plugins.flutter.io/firebase_analytics',
    'plugins.flutter.io/cloud_firestore',
    'xyz.luan/audioplayers',
    'plugins.flutter.io/google_sign_in',
    'plugins.flutter.io/firebase_auth_web',
  ]) {
    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger.setMockMethodCallHandler(
      MethodChannel(channel),
      (MethodCall methodCall) async {
        if (channel == 'plugins.flutter.io/google_sign_in' && methodCall.method == 'signIn') {
          return {
            'displayName': 'Test User',
            'email': 'test@example.com',
            'id': '123',
            'photoUrl': null,
          };
        }
        if (channel == 'plugins.flutter.io/firebase_auth' && methodCall.method == 'signInWithCredential') {
          return {
            'user': {
              'uid': '123',
              'isAnonymous': false,
              'email': 'test@example.com',
              'displayName': 'Test User',
            }
          };
        }
        if (channel == 'plugins.flutter.io/cloud_firestore') {
          if (methodCall.method == 'DocumentReference#get') {
            return {
              'data': {
                'displayName': 'Test User',
                'username': 'testuser',
                'totalScore': 100,
                'progress': {},
              },
            };
          }
        }
        return null;
      },
    );
  }
}

class MockHttpOverrides extends HttpOverrides {
  @override
  HttpClient createHttpClient(SecurityContext? context) {
    return MockHttpClient();
  }
}

class MockHttpClient implements HttpClient {
  @override
  Future<HttpClientRequest> getUrl(Uri url) async => MockHttpClientRequest();
  @override
  bool autoUncompress = true;
  @override
  Duration? connectionTimeout;
  @override
  Duration idleTimeout = const Duration(seconds: 15);
  @override
  int? maxConnectionsPerHost;
  @override
  String? userAgent;
  @override
  void addCredentials(Uri url, String realm, HttpClientCredentials credentials) {}
  @override
  void addProxyCredentials(String host, int port, String realm, HttpClientCredentials credentials) {}
  @override
  set authenticate(Future<bool> Function(Uri url, String scheme, String realm)? f) {}
  @override
  set authenticateProxy(Future<bool> Function(String host, int port, String scheme, String realm)? f) {}
  @override
  set badCertificateCallback(bool Function(X509Certificate cert, String host, int port)? callback) {}
  @override
  set findProxy(String Function(Uri url)? f) {}
  @override
  void close({bool force = false}) {}
  @override
  Future<HttpClientRequest> delete(String host, int port, String path) async => MockHttpClientRequest();
  @override
  Future<HttpClientRequest> deleteUrl(Uri url) async => MockHttpClientRequest();
  @override
  Future<HttpClientRequest> get(String host, int port, String path) async => MockHttpClientRequest();
  @override
  Future<HttpClientRequest> head(String host, int port, String path) async => MockHttpClientRequest();
  @override
  Future<HttpClientRequest> headUrl(Uri url) async => MockHttpClientRequest();
  @override
  Future<HttpClientRequest> open(String method, String host, int port, String path) async => MockHttpClientRequest();
  @override
  Future<HttpClientRequest> openUrl(String method, Uri url) async => MockHttpClientRequest();
  @override
  Future<HttpClientRequest> patch(String host, int port, String path) async => MockHttpClientRequest();
  @override
  Future<HttpClientRequest> patchUrl(Uri url) async => MockHttpClientRequest();
  @override
  Future<HttpClientRequest> post(String host, int port, String path) async => MockHttpClientRequest();
  @override
  Future<HttpClientRequest> postUrl(Uri url) async => MockHttpClientRequest();
  @override
  Future<HttpClientRequest> put(String host, int port, String path) async => MockHttpClientRequest();
  @override
  Future<HttpClientRequest> putUrl(Uri url) async => MockHttpClientRequest();
  @override
  set connectionFactory(Future<ConnectionTask<Socket>> Function(Uri url, String? proxyHost, int? proxyPort)? f) {}
  @override
  set keyLog(void Function(String line)? callback) {}
}

class MockHttpClientRequest implements HttpClientRequest {
  @override
  Future<HttpClientResponse> close() async => MockHttpClientResponse();
  @override
  HttpHeaders get headers => MockHttpHeaders();
  @override
  void add(List<int> data) {}
  @override
  void addError(Object error, [StackTrace? stackTrace]) {}
  @override
  Future addStream(Stream<List<int>> stream) async {}
  @override
  void write(Object? obj) {}
  @override
  void writeAll(Iterable objects, [String separator = ""]) {}
  @override
  void writeCharCode(int charCode) {}
  @override
  void writeln([Object? obj = ""]) {}
  @override
  Future<HttpClientResponse> get done async => MockHttpClientResponse();
  @override
  bool bufferOutput = true;
  @override
  int contentLength = 0;
  @override
  Encoding encoding = utf8;
  @override
  bool followRedirects = true;
  @override
  int maxRedirects = 5;
  @override
  bool persistentConnection = true;
  @override
  void abort([Object? exception, StackTrace? stackTrace]) {}
  @override
  HttpConnectionInfo? get connectionInfo => null;
  @override
  List<Cookie> get cookies => [];
  @override
  String get method => "GET";
  @override
  Uri get uri => Uri.parse("http://mock");
  @override
  Future flush() async {}
}

class MockHttpClientResponse extends Stream<List<int>> implements HttpClientResponse {
  @override
  StreamSubscription<List<int>> listen(void Function(List<int> event)? onData, {Function? onError, void Function()? onDone, bool? cancelOnError}) {
    return Stream<List<int>>.fromIterable([
      [0, 0, 0]
    ]).listen(onData, onError: onError, onDone: onDone, cancelOnError: cancelOnError);
  }

  @override
  int get contentLength => 3;
  @override
  int get statusCode => 200;
  @override
  HttpHeaders get headers => MockHttpHeaders();
  @override
  Future<Socket> detachSocket() async => throw UnimplementedError();
  @override
  List<RedirectInfo> get redirects => [];
  @override
  Future<HttpClientResponse> redirect([String? method, Uri? url, bool? followRedirects]) async => this;
  @override
  bool get isRedirect => false;
  @override
  bool get persistentConnection => true;
  @override
  String get reasonPhrase => "OK";
  @override
  HttpClientResponseCompressionState get compressionState => HttpClientResponseCompressionState.notCompressed;
  @override
  X509Certificate? get certificate => null;
  @override
  HttpConnectionInfo? get connectionInfo => null;
  @override
  List<Cookie> get cookies => [];
}

class MockHttpHeaders implements HttpHeaders {
  @override
  List<String>? operator [](String name) => [];
  @override
  void add(String name, Object value, {bool preserveHeaderCase = false}) {}
  
  DateTime? _date;
  @override
  DateTime? get date => _date;
  @override
  set date(DateTime? d) => _date = d;

  DateTime? _expires;
  @override
  DateTime? get expires => _expires;
  @override
  set expires(DateTime? e) => _expires = e;

  DateTime? _ifModifiedSince;
  @override
  DateTime? get ifModifiedSince => _ifModifiedSince;
  @override
  set ifModifiedSince(DateTime? i) => _ifModifiedSince = i;

  String? _host;
  @override
  String? get host => _host;
  @override
  set host(String? h) => _host = h;

  int? _port;
  @override
  int? get port => _port;
  @override
  set port(int? p) => _port = p;

  ContentType? _contentType;
  @override
  ContentType? get contentType => _contentType;
  @override
  set contentType(ContentType? c) => _contentType = c;

  @override
  void clear() {}
  @override
  void forEach(void Function(String name, List<String> values) f) {}
  @override
  void noFolding(String name) {}
  @override
  void remove(String name, Object value) {}
  @override
  void removeAll(String name) {}
  @override
  void set(String name, Object value, {bool preserveHeaderCase = false}) {}
  @override
  String? value(String name) => "";
  @override
  bool chunkedTransferEncoding = false;
  @override
  int contentLength = 0;
  @override
  bool persistentConnection = true;
}

void main() {
  HttpOverrides.global = MockHttpOverrides();
  setupFirebaseMocks();

  setUpAll(() async {
    await Firebase.initializeApp(
      options: const FirebaseOptions(
        apiKey: 'mock_key',
        appId: 'mock_id',
        messagingSenderId: 'mock_sender',
        projectId: 'mock_project',
      ),
    );
  });

  testWidgets('App load test', (WidgetTester tester) async {
    // Build our app and trigger a frame.
    await tester.pumpWidget(const ThinkSlideApp());
    
    // 1. Check if we are on the Login Screen (since mock user is null initially)
    await tester.pumpAndSettle();
    expect(find.text("THINK & SLIDE"), findsOneWidget);
    expect(find.text("Sign in with Google"), findsOneWidget);

    // 2. Tap the Sign In button
    // Note: In tests, we might need to find by text or type since it's a GestureDetector
    await tester.tap(find.text("Sign in with Google"));
    
    // Normally, this would trigger AuthService.signInWithGoogle
    // In this mock environment, we are just verifying the app doesn't crash 
    // and correctly displays the initial UI.
    
    await tester.pump();
    
    // 3. Since we can't easily mock the Stream transition in this simple setup 
    // without more complex platform mocking, we'll verify the presence of Menu elements 
    // if we were to force the state.
    
    // For a real "Full Test", we would use a MockAuthService or similar.
    // But for now, we verify the app boots and the Login Screen is functional.
    expect(find.byType(CircularProgressIndicator), findsNothing);
  });
}
