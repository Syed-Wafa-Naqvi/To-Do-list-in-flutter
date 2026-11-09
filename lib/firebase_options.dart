import 'package:firebase_core/firebase_core.dart' show FirebaseOptions;
import 'package:flutter/foundation.dart'
    show defaultTargetPlatform, kIsWeb, TargetPlatform;

/// Default [FirebaseOptions] for use with your Firebase apps.
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
        return linux;
      default:
        throw UnsupportedError(
          'DefaultFirebaseOptions are not supported for this platform.',
        );
    }
  }

  static const FirebaseOptions web = FirebaseOptions(
    apiKey: 'AIzaSyDemoPlaceholderApiKeyWeb000000',
    appId: '1:100000000000:web:0000000000000000000000',
    messagingSenderId: '100000000000',
    projectId: 'product-listing-prototype',
    authDomain: 'product-listing-prototype.firebaseapp.com',
    storageBucket: 'product-listing-prototype.appspot.com',
  );

  static const FirebaseOptions android = FirebaseOptions(
    apiKey: 'AIzaSyDemoPlaceholderApiKeyAndroid000',
    appId: '1:100000000000:android:0000000000000000000000',
    messagingSenderId: '100000000000',
    projectId: 'product-listing-prototype',
    storageBucket: 'product-listing-prototype.appspot.com',
  );

  static const FirebaseOptions ios = FirebaseOptions(
    apiKey: 'AIzaSyDemoPlaceholderApiKeyIOS0000000',
    appId: '1:100000000000:ios:0000000000000000000000',
    messagingSenderId: '100000000000',
    projectId: 'product-listing-prototype',
    storageBucket: 'product-listing-prototype.appspot.com',
    iosBundleId: 'com.example.productListingPrototype',
  );

  static const FirebaseOptions macos = FirebaseOptions(
    apiKey: 'AIzaSyDemoPlaceholderApiKeyMacOS00000',
    appId: '1:100000000000:ios:0000000000000000000000',
    messagingSenderId: '100000000000',
    projectId: 'product-listing-prototype',
    storageBucket: 'product-listing-prototype.appspot.com',
    iosBundleId: 'com.example.productListingPrototype',
  );

  static const FirebaseOptions windows = FirebaseOptions(
    apiKey: 'AIzaSyDemoPlaceholderApiKeyWin0000000',
    appId: '1:100000000000:web:0000000000000000000000',
    messagingSenderId: '100000000000',
    projectId: 'product-listing-prototype',
    authDomain: 'product-listing-prototype.firebaseapp.com',
    storageBucket: 'product-listing-prototype.appspot.com',
  );

  static const FirebaseOptions linux = FirebaseOptions(
    apiKey: 'AIzaSyDemoPlaceholderApiKeyLinux00000',
    appId: '1:100000000000:web:0000000000000000000000',
    messagingSenderId: '100000000000',
    projectId: 'product-listing-prototype',
    authDomain: 'product-listing-prototype.firebaseapp.com',
    storageBucket: 'product-listing-prototype.appspot.com',
  );
}
