import '../screens/place_detail.dart';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter/material.dart';
import '../models/place.dart';

class PlacesList extends StatelessWidget {
  const PlacesList({super.key, required this.places});

  final List<Place> places;

  // Helper: buat widget avatar sesuai platform
  Widget _buildAvatar(Place place) {
    // Web: pakai imageBytes
    if (kIsWeb && place.imageBytes != null) {
      return CircleAvatar(
        radius: 26,
        backgroundImage: MemoryImage(place.imageBytes!),
      );
    }

    // Mobile/Desktop: pakai File
    if (!kIsWeb && place.image != null) {
      return CircleAvatar(
        radius: 26,
        backgroundImage: FileImage(place.image!),
      );
    }

    // Fallback: tidak ada gambar
    return const CircleAvatar(
      radius: 26,
      child: Icon(Icons.image_not_supported),
    );
  }

  @override
  Widget build(BuildContext context) {
    if (places.isEmpty) {
      return Center(
        child: Text(
          'No places added yet',
          style: Theme.of(context).textTheme.bodyLarge!.copyWith(
                color: Theme.of(context).colorScheme.onSurface,
              ),
        ),
      );
    }

    return ListView.builder(
      itemCount: places.length,
      itemBuilder: (ctx, index) => ListTile(
        leading: _buildAvatar(places[index]),
        title: Text(
          places[index].title,
          style: Theme.of(context).textTheme.titleMedium!.copyWith(
                color: Theme.of(context).colorScheme.onSurface,
              ),
        ),
        subtitle: Text(
          places[index].location.address,
          style: Theme.of(context).textTheme.bodySmall!.copyWith(
                color: Theme.of(context).colorScheme.onSurface,
              ),
        ),
        onTap: () {
          Navigator.of(context).push(
            MaterialPageRoute(
              builder: (ctx) => PlaceDetailScreen(place: places[index]),
            ),
          );
        },
      ),
    );
  }
}
