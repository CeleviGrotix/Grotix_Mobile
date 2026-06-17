import 'package:flutter/foundation.dart' show kIsWeb, defaultTargetPlatform, TargetPlatform;

// Cambia esto a 'true' cuando corras en celular físico, 'false' para emulador
// (Esto ahora solo afectará a tu backend principal en el puerto 5119)
const bool isPhysicalDevice = false;

// Tu backend principal (Asumo que sigue corriendo en tu PC local)
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

// Tu backend de Inteligencia Artificial (¡Ahora en Producción!)
String pythonApiBase() {
  // Asegúrate de cambiar 'grotix-ai-api' por el nombre real que
  // le pusiste a tu proyecto en la página de Render.
  return 'https://grotix-ai-api.onrender.com';
}