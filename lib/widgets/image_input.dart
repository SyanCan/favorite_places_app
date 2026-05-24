import 'dart:io';
import 'dart:typed_data';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';

class ImageInput extends StatefulWidget {
  const ImageInput({super.key, required this.onPickImage});

  // Untuk web: File akan null, gunakan webImageBytes
  // Untuk mobile: File akan terisi
  final void Function(File? image, Uint8List? webImageBytes) onPickImage;

  @override
  State<ImageInput> createState() => _ImageInputState();
}

class _ImageInputState extends State<ImageInput> {
  XFile? _selectedXFile;
  Uint8List? _webImageBytes;
  File? _mobileFile;

  Future<void> _pickImage() async {
    final imagePicker = ImagePicker();
    final pickedImage = await imagePicker.pickImage(
      source: kIsWeb ? ImageSource.gallery : ImageSource.camera,
      maxWidth: 600,
    );

    if (pickedImage == null) return;

    if (kIsWeb) {
      // Web: baca sebagai bytes
      final bytes = await pickedImage.readAsBytes();
      setState(() {
        _selectedXFile = pickedImage;
        _webImageBytes = bytes;
      });
      widget.onPickImage(null, bytes);
    } else {
      // Mobile/Desktop: gunakan File
      final file = File(pickedImage.path);
      setState(() {
        _selectedXFile = pickedImage;
        _mobileFile = file;
      });
      widget.onPickImage(file, null);
    }
  }

  @override
  Widget build(BuildContext context) {
    Widget content = TextButton.icon(
      icon: Icon(kIsWeb ? Icons.photo_library : Icons.camera),
      label: Text(kIsWeb ? 'Pick Image' : 'Take Picture'),
      onPressed: _pickImage,
    );

    bool hasImage = kIsWeb ? _webImageBytes != null : _mobileFile != null;

    if (hasImage) {
      content = GestureDetector(
        onTap: _pickImage,
        child: kIsWeb
            ? Image.memory(
                _webImageBytes!,
                fit: BoxFit.cover,
                width: double.infinity,
                height: double.infinity,
              )
            : Image.file(
                _mobileFile!,
                fit: BoxFit.cover,
                width: double.infinity,
                height: double.infinity,
              ),
      );
    }

    return Container(
      decoration: BoxDecoration(
        border: Border.all(
          width: 1,
          color: Theme.of(context).colorScheme.primary.withOpacity(0.2),
        ),
      ),
      height: 250,
      width: double.infinity,
      alignment: Alignment.center,
      child: content,
    );
  }
}
