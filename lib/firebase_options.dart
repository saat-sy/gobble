// File generated by FlutterFire CLI.
// ignore_for_file: lines_longer_than_80_chars
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
    // ignore: missing_enum_constant_in_switch
    switch (defaultTargetPlatform) {
      case TargetPlatform.android:
        return android;
      case TargetPlatform.iOS:
        return ios;
      case TargetPlatform.macOS:
        throw UnsupportedError(
          'DefaultFirebaseOptions have not been configured for macos - '
          'you can reconfigure this by running the FlutterFire CLI again.',
        );
    }

    throw UnsupportedError(
      'DefaultFirebaseOptions are not supported for this platform.',
    );
  }

  static const FirebaseOptions web = FirebaseOptions(
    apiKey: 'AIzaSyCoPEtXXQ8KDo6S5eEUoVwFe0NGIL0mcGo',
    appId: '1:368649451633:web:9a9a75efceb445beff03d0',
    messagingSenderId: '368649451633',
    projectId: 'gobble-game',
    authDomain: 'gobble-game.firebaseapp.com',
    storageBucket: 'gobble-game.appspot.com',
  );

  static const FirebaseOptions android = FirebaseOptions(
    apiKey: 'AIzaSyBKSAQAdIzGUEESnaGAM-C8B3rpSTG8HBc',
    appId: '1:368649451633:android:dfb6691257e2d8c7ff03d0',
    messagingSenderId: '368649451633',
    projectId: 'gobble-game',
    storageBucket: 'gobble-game.appspot.com',
  );

  static const FirebaseOptions ios = FirebaseOptions(
    apiKey: 'AIzaSyDIrA4u81xOCKKBk_ivyzvFCCfrmKl5Z4Y',
    appId: '1:368649451633:ios:973ee4dbd4f5866dff03d0',
    messagingSenderId: '368649451633',
    projectId: 'gobble-game',
    storageBucket: 'gobble-game.appspot.com',
    iosClientId: '368649451633-akhj9sab63i32gcqfvgf1jplo52e99dm.apps.googleusercontent.com',
    iosBundleId: 'com.example.gobble',
  );
}