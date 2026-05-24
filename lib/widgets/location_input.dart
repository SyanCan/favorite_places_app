import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'dart:async';
import '../models/place.dart';
import '../screens/map.dart';
import 'package:latlong2/latlong.dart';

// Web-only import
import 'location_input_web.dart'
    if (dart.library.io) 'location_input_mobile.dart'
    as location_helper;

class LocationInput extends StatefulWidget {
  const LocationInput({super.key, required this.onSelectLocation});

  final void Function(PlaceLocation location) onSelectLocation;

  @override
  State<LocationInput> createState() => _LocationInputState();
}

class _LocationInputState extends State<LocationInput> {
  PlaceLocation? _pickedLocation;
  bool _isGettingLocation = false;
  String? _errorMessage;

  // Reverse geocoding dengan Nominatim (OpenStreetMap) - gratis
  Future<String> _getAddressFromCoords(double lat, double lng) async {
    final url = Uri.parse(
      'https://nominatim.openstreetmap.org/reverse'
      '?format=json&lat=$lat&lon=$lng&zoom=18&addressdetails=1',
    );
    try {
      final response = await http.get(
        url,
        headers: {'User-Agent': 'FavoritePlacesApp/1.0'},
      );
      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        return data['display_name'] as String? ??
            'Lat: ${lat.toStringAsFixed(5)}, Lng: ${lng.toStringAsFixed(5)}';
      }
    } catch (_) {}
    return 'Lat: ${lat.toStringAsFixed(5)}, Lng: ${lng.toStringAsFixed(5)}';
  }

  Future<void> _savePickedLocation(double lat, double lng) async {
    setState(() {
      _isGettingLocation = true;
      _errorMessage = null;
    });

    final address = await _getAddressFromCoords(lat, lng);
    final location = PlaceLocation(
      latitude: lat,
      longitude: lng,
      address: address,
    );

    if (!mounted) return;
    setState(() {
      _pickedLocation = location;
      _isGettingLocation = false;
    });

    widget.onSelectLocation(location);
  }

  Future<void> _getCurrentLocation() async {
    setState(() {
      _isGettingLocation = true;
      _errorMessage = null;
    });

    try {
      final coords = await location_helper.getCurrentCoordinates();
      if (coords == null) {
        setState(() {
          _isGettingLocation = false;
          _errorMessage = 'Izin lokasi ditolak. Gunakan "Pick on Map".';
        });
        return;
      }
      await _savePickedLocation(coords[0], coords[1]);
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _isGettingLocation = false;
        _errorMessage = 'Gagal mendapat lokasi. Coba "Pick on Map".';
      });
    }
  }

  Future<void> _selectOnMap() async {
    final picked = await Navigator.of(context).push<LatLng>(
      MaterialPageRoute(
        builder: (ctx) => MapScreen(
          location:
              _pickedLocation ??
              const PlaceLocation(
                latitude: -8.6705,
                longitude: 115.2126,
                address: '',
              ),
          isSelecting: true,
        ),
      ),
    );

    if (picked == null) return;
    await _savePickedLocation(picked.latitude, picked.longitude);
  }

  @override
  Widget build(BuildContext context) {
    Widget previewContent = Text(
      'No location chosen',
      textAlign: TextAlign.center,
      style: Theme.of(context).textTheme.bodyLarge!.copyWith(
        color: Theme.of(context).colorScheme.onSurface,
      ),
    );

    if (_isGettingLocation) {
      previewContent = const Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          CircularProgressIndicator(),
          SizedBox(height: 8),
          Text('Getting location...'),
        ],
      );
    } else if (_errorMessage != null) {
      previewContent = Padding(
        padding: const EdgeInsets.all(8.0),
        child: Text(
          _errorMessage!,
          textAlign: TextAlign.center,
          style: TextStyle(color: Theme.of(context).colorScheme.error),
        ),
      );
    } else if (_pickedLocation != null) {
      previewContent = Padding(
        padding: const EdgeInsets.all(8.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.location_on, size: 32, color: Colors.redAccent),
            const SizedBox(height: 6),
            Text(
              _pickedLocation!.address,
              textAlign: TextAlign.center,
              maxLines: 3,
              overflow: TextOverflow.ellipsis,
              style: Theme.of(context).textTheme.bodySmall!.copyWith(
                color: Theme.of(context).colorScheme.onSurface,
              ),
            ),
          ],
        ),
      );
    }

    return Column(
      children: [
        Container(
          height: 170,
          width: double.infinity,
          alignment: Alignment.center,
          decoration: BoxDecoration(
            border: Border.all(
              width: 1,
              color: Theme.of(context).colorScheme.primary.withOpacity(0.2),
            ),
          ),
          child: previewContent,
        ),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            TextButton.icon(
              icon: const Icon(Icons.my_location),
              label: const Text('Get Current'),
              onPressed: _isGettingLocation ? null : _getCurrentLocation,
            ),
            TextButton.icon(
              icon: const Icon(Icons.map_outlined),
              label: const Text('Pick on Map'),
              onPressed: _isGettingLocation ? null : _selectOnMap,
            ),
          ],
        ),
        if (kIsWeb)
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 12),
            child: Text(
              'silahkan klik "Get Current" lalu izinkan akses lokasi,\natau gunakan "Pick on Map".',
              textAlign: TextAlign.center,
              style: Theme.of(context).textTheme.bodySmall!.copyWith(
                color: Theme.of(context).colorScheme.onSurface.withOpacity(0.6),
              ),
            ),
          ),
      ],
    );
  }
}
