import 'dart:io';
import 'dart:typed_data';
import 'package:uuid/uuid.dart';

const uuid = Uuid();

class PlaceLocation {
  const PlaceLocation({
    required this.latitude,
    required this.longitude,
    required this.address,
  });

  final double latitude;
  final double longitude;
  final String address;
}

class Place {
  Place({
    required this.title,
    required this.location,
    String? id,
    File? image,
    Uint8List? imageBytes,
    String? imagePath,
  })  : id = id ?? uuid.v4(),
        image = image,
        imageBytes = imageBytes,
        imagePath = imagePath;

  final String id;
  final String title;
  final File? image;           // Mobile/Desktop
  final Uint8List? imageBytes; // Web
  final String? imagePath;     // Path untuk DB (mobile)
  final PlaceLocation location;
}
