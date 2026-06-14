import 'package:flutter/foundation.dart' show kIsWeb, defaultTargetPlatform, TargetPlatform;

// Cambia esto a 'true' cuando corras en celular físico, 'false' para emulador
const bool isPhysicalDevice = true;

String apiBase() {
  if (kIsWeb) return 'http://localhost:5119';
  switch (defaultTargetPlatform) {
    case TargetPlatform.android:
      return isPhysicalDevice
          ? 'http://192.168.18.221:5119'  // Celular físico
          : 'http://10.0.2.2:5119';       // Emulador
    case TargetPlatform.iOS: return 'http://localhost:5119';
    default:                 return 'http://localhost:5119';
  }
}

String pythonApiBase() {
  if (kIsWeb) return 'http://localhost:8000';
  switch (defaultTargetPlatform) {
    case TargetPlatform.android:
      return isPhysicalDevice
          ? 'http://192.168.18.221:8000'  // Celular físico
          : 'http://10.0.2.2:8000';       // Emulador
    case TargetPlatform.iOS: return 'http://localhost:8000';
    default:                 return 'http://192.168.18.221:8000';
  }
}