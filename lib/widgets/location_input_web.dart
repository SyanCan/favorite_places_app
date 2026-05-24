// location_input_web.dart
// Digunakan saat dart.library.html tersedia (Flutter Web)
// ignore: avoid_web_libraries_in_flutter
import 'dart:html' as html;
import 'dart:async';

/// Mengambil koordinat [lat, lng] via browser Geolocation API.
/// Mengembalikan null jika izin ditolak atau terjadi error.
Future<List<double>?> getCurrentCoordinates() async {
  final completer = Completer<List<double>?>();

  html.window.navigator.geolocation.getCurrentPosition(
    enableHighAccuracy: true,
    timeout: const Duration(seconds: 15),
  ).then((position) {
    final lat = position.coords!.latitude!.toDouble();
    final lng = position.coords!.longitude!.toDouble();
    completer.complete([lat, lng]);
  }).catchError((error) {
    completer.complete(null);
  });

  return completer.future;
}
