// File generated by FlutterFire CLI.
// ignore_for_file: type=lint
import 'package:firebase_core/firebase_core.dart' show FirebaseOptions;
import 'package:flutter/foundation.dart'
    show defaultTargetPlatform, kIsWeb, TargetPlatform;

/// Default [FirebaseOptions] for use with your Firebase apps.
///
/// Example:
/// ```dart
/// import 'firebase_options.dart';
/// // ...
/// await Firebase.initializeApp(
///   options: DefaultFirebaseOptions.currentPlatform,
/// );
/// ```
class DefaultFirebaseOptions {
  static FirebaseOptions get currentPlatform {
    if (kIsWeb) {
      return web;
    }
    switch (defaultTargetPlatform) {
      case TargetPlatform.android:
        return android;
      case TargetPlatform.iOS:
        return ios;
      case TargetPlatform.macOS:
        return macos;
      case TargetPlatform.windows:
        return windows;
      case TargetPlatform.linux:
        throw UnsupportedError(
          'DefaultFirebaseOptions have not been configured for linux - '
          'you can reconfigure this by running the FlutterFire CLI again.',
        );
      default:
        throw UnsupportedError(
          'DefaultFirebaseOptions are not supported for this platform.',
        );
    }
  }

  static const FirebaseOptions web = FirebaseOptions(
    apiKey: 'AIzaSyD0IFHPW1TXrzs-6W8N0Wnowq6G7FqB2rs',
    appId: '1:158625250753:web:d74d47b0b38de1946dc340',
    messagingSenderId: '158625250753',
    projectId: 'ymmify',
    authDomain: 'ymmify.firebaseapp.com',
    storageBucket: 'ymmify.firebasestorage.app',
    measurementId: 'G-N0KE7D9BJS',
  );

  static const FirebaseOptions android = FirebaseOptions(
    apiKey: 'AIzaSyCSrH6r6eypGtcchUcWFmxrzapCDVJ13LY',
    appId: '1:158625250753:android:e0ef6fc95b73650d6dc340',
    messagingSenderId: '158625250753',
    projectId: 'ymmify',
    storageBucket: 'ymmify.firebasestorage.app',
  );

  static const FirebaseOptions ios = FirebaseOptions(
    apiKey: 'AIzaSyDkFtQIAPHnxTIEdgFqz4bffaLLV4IREEY',
    appId: '1:158625250753:ios:7b54049fcf0e61636dc340',
    messagingSenderId: '158625250753',
    projectId: 'ymmify',
    storageBucket: 'ymmify.firebasestorage.app',
    iosBundleId: 'com.example.frontend',
  );

  static const FirebaseOptions macos = FirebaseOptions(
    apiKey: 'AIzaSyDkFtQIAPHnxTIEdgFqz4bffaLLV4IREEY',
    appId: '1:158625250753:ios:7b54049fcf0e61636dc340',
    messagingSenderId: '158625250753',
    projectId: 'ymmify',
    storageBucket: 'ymmify.firebasestorage.app',
    iosBundleId: 'com.example.frontend',
  );

  static const FirebaseOptions windows = FirebaseOptions(
    apiKey: 'AIzaSyD0IFHPW1TXrzs-6W8N0Wnowq6G7FqB2rs',
    appId: '1:158625250753:web:13ffe46b8e0a42356dc340',
    messagingSenderId: '158625250753',
    projectId: 'ymmify',
    authDomain: 'ymmify.firebaseapp.com',
    storageBucket: 'ymmify.firebasestorage.app',
    measurementId: 'G-JR5WZ0D7Y7',
  );
}
