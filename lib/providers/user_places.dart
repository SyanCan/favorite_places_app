import 'dart:io';
import 'dart:typed_data';
import 'package:flutter/foundation.dart' show kIsWeb;
import '../models/place.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:path_provider/path_provider.dart' as syspaths;
import 'package:path/path.dart' as path;

import 'package:sqflite/sqflite.dart' as sql;
import 'package:sqflite/sqlite_api.dart';

Future<Database>? _db;

Future<Database> _getDatabase() async {
  if (_db != null) return _db!;
  final dbPath = await sql.getDatabasesPath();
  final db = await sql.openDatabase(
    path.join(dbPath, 'places.db'),
    onCreate: (db, version) {
      return db.execute(
        'CREATE TABLE user_places('
        'id TEXT PRIMARY KEY, '
        'title TEXT, '
        'image TEXT, '
        'lat REAL, '
        'lng REAL, '
        'address TEXT)',
      );
    },
    version: 1,
  );
  return db;
}

// PERBAIKAN: Ganti StateNotifier -> Notifier (Riverpod v3)
class UserPlacesNotifier extends Notifier<List<Place>> {
  @override
  List<Place> build() {
    // State awal: list kosong
    return [];
  }

  Future<void> loadPlaces() async {
    if (kIsWeb) return;

    final db = await _getDatabase();
    final data = await db.query('user_places');

    final List<Place> places = data.map((row) {
      final imgPath = row['image'] as String;
      return Place(
        id: row['id'] as String,
        title: row['title'] as String,
        image: File(imgPath),
        imagePath: imgPath,
        location: PlaceLocation(
          latitude: row['lat'] as double,
          longitude: row['lng'] as double,
          address: row['address'] as String,
        ),
      );
    }).toList();

    state = places;
  }

  Future<void> addPlace(
    String title,
    PlaceLocation location, {
    File? image,
    Uint8List? imageBytes,
  }) async {
    String? savedImagePath;
    File? savedFile;

    if (!kIsWeb && image != null) {
      final appDir = await syspaths.getApplicationDocumentsDirectory();
      final filename = path.basename(image.path);
      savedFile = await image.copy('${appDir.path}/$filename');
      savedImagePath = savedFile.path;
    }

    final newPlace = Place(
      title: title,
      location: location,
      image: savedFile,
      imageBytes: imageBytes,
      imagePath: savedImagePath,
    );

    if (!kIsWeb && savedImagePath != null) {
      final db = await _getDatabase();
      await db.insert('user_places', {
        'id': newPlace.id,
        'title': newPlace.title,
        'image': savedImagePath,
        'lat': newPlace.location.latitude,
        'lng': newPlace.location.longitude,
        'address': newPlace.location.address,
      });
    }

    state = [newPlace, ...state];
  }
}

// PERBAIKAN: Ganti StateNotifierProvider -> NotifierProvider (Riverpod v3)
final userPlacesProvider = NotifierProvider<UserPlacesNotifier, List<Place>>(
  UserPlacesNotifier.new,
);
