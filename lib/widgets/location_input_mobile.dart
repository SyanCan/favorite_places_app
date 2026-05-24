// location_input_mobile.dart
// Digunakan saat dart.library.io tersedia (Android, iOS, Desktop)
import 'package:location/location.dart';

/// Mengambil koordinat [lat, lng] via GPS device.
/// Mengembalikan null jika izin ditolak atau terjadi error.
Future<List<double>?> getCurrentCoordinates() async {
  final location = Location();

  bool serviceEnabled = await location.serviceEnabled();
  if (!serviceEnabled) {
    serviceEnabled = await location.requestService();
    if (!serviceEnabled) return null;
  }

  PermissionStatus permission = await location.hasPermission();
  if (permission == PermissionStatus.denied) {
    permission = await location.requestPermission();
    if (permission != PermissionStatus.granted) return null;
  }

  final locationData = await location.getLocation();
  final lat = locationData.latitude;
  final lng = locationData.longitude;

  if (lat == null || lng == null) return null;
  return [lat, lng];
}
