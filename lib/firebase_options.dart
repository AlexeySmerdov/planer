import 'package:firebase_core/firebase_core.dart' show FirebaseOptions;
import 'package:flutter/foundation.dart'
    show defaultTargetPlatform, kIsWeb, TargetPlatform;

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
        throw UnsupportedError(
          'DefaultFirebaseOptions have not been configured for windows - '
          'you can reconfigure this by running the FlutterFire CLI again.',
        );
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
    apiKey: 'AIzaSyBGuEzPxWBVVjkjLfdspyUhCUxnwvhH_38',
    appId: '1:887523662096:web:planner',
    messagingSenderId: '887523662096',
    projectId: 'planner-fe828',
    authDomain: 'planner-fe828.firebaseapp.com',
    storageBucket: 'planner-fe828.appspot.com',
  );

  static const FirebaseOptions android = FirebaseOptions(
    apiKey: 'AIzaSyBGuEzPxWBVVjkjLfdspyUhCUxnwvhH_38',
    appId: '1:887523662096:android:planner',
    messagingSenderId: '887523662096',
    projectId: 'planner-fe828',
    storageBucket: 'planner-fe828.appspot.com',
  );

  static const FirebaseOptions ios = FirebaseOptions(
    apiKey: 'AIzaSyBGuEzPxWBVVjkjLfdspyUhCUxnwvhH_38',
    appId: '1:887523662096:ios:planner',
    messagingSenderId: '887523662096',
    projectId: 'planner-fe828',
    storageBucket: 'planner-fe828.appspot.com',
    iosBundleId: 'com.example.planner',
  );

  static const FirebaseOptions macos = FirebaseOptions(
    apiKey: 'AIzaSyBGuEzPxWBVVjkjLfdspyUhCUxnwvhH_38',
    appId: '1:887523662096:macos:planner',
    messagingSenderId: '887523662096',
    projectId: 'planner-fe828',
    storageBucket: 'planner-fe828.appspot.com',
    iosBundleId: 'com.example.planner',
  );
} 