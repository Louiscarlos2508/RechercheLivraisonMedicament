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
    apiKey: 'AIzaSyDSitt3KKoQi1lmgfKkahWSSc_PtK03ZNM',
    appId: '1:436269061105:web:4bdf3b5f7335c93d242a50',
    messagingSenderId: '436269061105',
    projectId: 'recherchelivraisonmedica-f311e',
    authDomain: 'recherchelivraisonmedica-f311e.firebaseapp.com',
    storageBucket: 'recherchelivraisonmedica-f311e.firebasestorage.app',
  );

  static const FirebaseOptions android = FirebaseOptions(
    apiKey: 'AIzaSyAgIXIP_H-K44TSh6b3X7wpEuGNigDsZkk',
    appId: '1:436269061105:android:9b0ce90489a795f7242a50',
    messagingSenderId: '436269061105',
    projectId: 'recherchelivraisonmedica-f311e',
    storageBucket: 'recherchelivraisonmedica-f311e.firebasestorage.app',
  );

  static const FirebaseOptions ios = FirebaseOptions(
    apiKey: 'AIzaSyDc1QzRHTUJh9m6Yw7570vSJGjDKbwl8S4',
    appId: '1:436269061105:ios:8a478286eefa4a81242a50',
    messagingSenderId: '436269061105',
    projectId: 'recherchelivraisonmedica-f311e',
    storageBucket: 'recherchelivraisonmedica-f311e.firebasestorage.app',
    iosBundleId: 'com.siso.recherchelivraisonmedicament',
  );

  static const FirebaseOptions macos = FirebaseOptions(
    apiKey: 'AIzaSyDc1QzRHTUJh9m6Yw7570vSJGjDKbwl8S4',
    appId: '1:436269061105:ios:8a478286eefa4a81242a50',
    messagingSenderId: '436269061105',
    projectId: 'recherchelivraisonmedica-f311e',
    storageBucket: 'recherchelivraisonmedica-f311e.firebasestorage.app',
    iosBundleId: 'com.siso.recherchelivraisonmedicament',
  );

  static const FirebaseOptions windows = FirebaseOptions(
    apiKey: 'AIzaSyDSitt3KKoQi1lmgfKkahWSSc_PtK03ZNM',
    appId: '1:436269061105:web:6f818da4caeb30b3242a50',
    messagingSenderId: '436269061105',
    projectId: 'recherchelivraisonmedica-f311e',
    authDomain: 'recherchelivraisonmedica-f311e.firebaseapp.com',
    storageBucket: 'recherchelivraisonmedica-f311e.firebasestorage.app',
  );
}
