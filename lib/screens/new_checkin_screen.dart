import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:geolocator/geolocator.dart';
import '../main.dart';
import '../models/checkin.dart';
import '../services/storage_service.dart';

class NewCheckInScreen extends StatefulWidget {
  const NewCheckInScreen({super.key});

  @override
  State<NewCheckInScreen> createState() => _NewCheckInScreenState();
}

class _NewCheckInScreenState extends State<NewCheckInScreen> {
  final _formKey = GlobalKey<FormState>();
  final _noteController = TextEditingController();

  File? _photoFile;
  bool _isFetchingLocation = false;
  Position? _position;
  String? _locationError;
  bool _isSaving = false;

  @override
  void dispose() {
    _noteController.dispose();
    super.dispose();
  }

  // ---------------- Kamera ----------------

  Future<void> _takePhoto() async {
    try {
      final picker = ImagePicker();
      final XFile? shot = await picker.pickImage(
        source: ImageSource.camera,
        maxWidth: 1600,
        imageQuality: 85,
      );
      if (shot != null) {
        setState(() => _photoFile = File(shot.path));
      }
    } catch (e) {
      if (!mounted) return;
      _showSnack('Could not access camera: $e');
    }
  }

  // ---------------- GPS ----------------

  Future<void> _getLocation() async {
    setState(() {
      _isFetchingLocation = true;
      _locationError = null;
    });

    try {
      final serviceEnabled = await Geolocator.isLocationServiceEnabled();
      if (!serviceEnabled) {
        throw 'Location services are disabled.';
      }

      LocationPermission permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
      }
      if (permission == LocationPermission.denied ||
          permission == LocationPermission.deniedForever) {
        throw 'Location permission denied.';
      }

      final pos = await Geolocator.getCurrentPosition(
        locationSettings: const LocationSettings(
          accuracy: LocationAccuracy.high,
          distanceFilter: 0,
        ),
      ).timeout(
        const Duration(seconds: 15),
        onTimeout: () {
          throw 'Timed out getting location. Make sure GPS/location is turned on and try again.';
        },
      );

      if (!mounted) return;
      setState(() {
        _position = pos;
        _isFetchingLocation = false;
      });
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _isFetchingLocation = false;
        _locationError = e.toString();
      });
    }
  }

  // ---------------- Save ----------------

  Future<void> _save() async {
    final formOk = _formKey.currentState?.validate() ?? false;
    if (!formOk) return;

    if (_photoFile == null) {
      _showSnack('Please take a photo first.');
      return;
    }
    if (_position == null) {
      _showSnack('Please get your location first.');
      return;
    }

    setState(() => _isSaving = true);

    final newCheckIn = CheckIn(
      id: DateTime.now().microsecondsSinceEpoch.toString(),
      note: _noteController.text.trim(),
      photoPath: _photoFile!.path,
      latitude: _position!.latitude,
      longitude: _position!.longitude,
      accuracy: _position!.accuracy,
      createdAt: DateTime.now(),
    );

    final existing = await StorageService.loadCheckIns();
    existing.add(newCheckIn);
    await StorageService.saveCheckIns(existing);

    if (!mounted) return;
    Navigator.pop(context);
  }

  void _showSnack(String msg) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(msg),
        backgroundColor: Colors.black87,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('New Check-In')),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            const _SectionTitle(icon: Icons.edit_note_rounded, text: 'Note'),
            const SizedBox(height: 8),
            _NoteField(controller: _noteController),
            const SizedBox(height: 24),
            const _SectionTitle(icon: Icons.photo_camera_rounded, text: 'Photo'),
            const SizedBox(height: 8),
            _PhotoSection(photoFile: _photoFile, onTakePhoto: _takePhoto),
            const SizedBox(height: 24),
            const _SectionTitle(icon: Icons.my_location_rounded, text: 'Location'),
            const SizedBox(height: 8),
            _LocationSection(
              isFetching: _isFetchingLocation,
              position: _position,
              error: _locationError,
              onGetLocation: _getLocation,
            ),
            const SizedBox(height: 28),
            SizedBox(
              width: double.infinity,
              height: 52,
              child: ElevatedButton.icon(
                onPressed: _isSaving ? null : _save,
                icon: _isSaving
                    ? const SizedBox(
                        width: 18,
                        height: 18,
                        child: CircularProgressIndicator(
                            strokeWidth: 2, color: Colors.white),
                      )
                    : const Icon(Icons.check_circle_outline_rounded),
                label: Text(_isSaving ? 'Saving...' : 'Save Check-In'),
              ),
            ),
            const SizedBox(height: 12),
          ],
        ),
      ),
    );
  }
}

// ---------------- Sub-widget (elak satu build() gergasi) ----------------

class _SectionTitle extends StatelessWidget {
  final IconData icon;
  final String text;
  const _SectionTitle({required this.icon, required this.text});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Icon(icon, size: 18, color: AppColors.primary),
        const SizedBox(width: 6),
        Text(
          text,
          style: const TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w700,
            color: AppColors.primaryDark,
            letterSpacing: 0.2,
          ),
        ),
      ],
    );
  }
}

class _NoteField extends StatelessWidget {
  final TextEditingController controller;
  const _NoteField({required this.controller});

  @override
  Widget build(BuildContext context) {
    return TextFormField(
      controller: controller,
      maxLines: 2,
      decoration: const InputDecoration(
        hintText: 'Write a note about this check-in...',
      ),
      validator: (value) {
        if (value == null || value.trim().isEmpty) {
          return 'Note is required';
        }
        return null;
      },
    );
  }
}

class _PhotoSection extends StatelessWidget {
  final File? photoFile;
  final VoidCallback onTakePhoto;
  const _PhotoSection({required this.photoFile, required this.onTakePhoto});

  @override
  Widget build(BuildContext context) {
    final hasPhoto = photoFile != null;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          width: double.infinity,
          height: 190,
          decoration: BoxDecoration(
            color: hasPhoto
                ? Colors.black
                : AppColors.primary.withValues(alpha: 0.05),
            border: Border.all(
              color: hasPhoto
                  ? Colors.transparent
                  : AppColors.primary.withValues(alpha: 0.25),
              width: 1.4,
            ),
            borderRadius: BorderRadius.circular(14),
          ),
          child: hasPhoto
              ? ClipRRect(
                  borderRadius: BorderRadius.circular(13),
                  child: Image.file(photoFile!, fit: BoxFit.cover),
                )
              : Center(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(Icons.image_outlined,
                          size: 36, color: AppColors.primary.withValues(alpha: 0.5)),
                      const SizedBox(height: 8),
                      Text(
                        'No photo yet',
                        style: TextStyle(
                            color: AppColors.primary.withValues(alpha: 0.6)),
                      ),
                    ],
                  ),
                ),
        ),
        const SizedBox(height: 10),
        SizedBox(
          width: double.infinity,
          child: OutlinedButton.icon(
            onPressed: onTakePhoto,
            icon: Icon(hasPhoto
                ? Icons.refresh_rounded
                : Icons.camera_alt_outlined),
            label: Text(hasPhoto ? 'Retake Photo' : 'Take Photo'),
          ),
        ),
      ],
    );
  }
}

class _LocationSection extends StatelessWidget {
  final bool isFetching;
  final Position? position;
  final String? error;
  final VoidCallback onGetLocation;

  const _LocationSection({
    required this.isFetching,
    required this.position,
    required this.error,
    required this.onGetLocation,
  });

  @override
  Widget build(BuildContext context) {
    // Pick colors/icon based on state: loading / error / success / empty
    Color bg;
    Color border;
    Widget content;

    if (isFetching) {
      bg = AppColors.primary.withValues(alpha: 0.05);
      border = AppColors.primary.withValues(alpha: 0.25);
      content = const Row(
        children: [
          SizedBox(
            width: 18,
            height: 18,
            child: CircularProgressIndicator(
                strokeWidth: 2, color: AppColors.primary),
          ),
          SizedBox(width: 10),
          Text('Fetching location…',
              style: TextStyle(color: AppColors.primaryDark)),
        ],
      );
    } else if (error != null) {
      bg = AppColors.error.withValues(alpha: 0.06);
      border = AppColors.error.withValues(alpha: 0.3);
      content = Row(
        children: [
          const Icon(Icons.error_outline_rounded,
              color: AppColors.error, size: 20),
          const SizedBox(width: 8),
          Expanded(
            child: Text(error!,
                style: const TextStyle(color: AppColors.error)),
          ),
        ],
      );
    } else if (position != null) {
      bg = AppColors.success.withValues(alpha: 0.06);
      border = AppColors.success.withValues(alpha: 0.3);
      content = Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: const [
              Icon(Icons.check_circle_rounded,
                  color: AppColors.success, size: 18),
              SizedBox(width: 6),
              Text('Location captured',
                  style: TextStyle(
                      color: AppColors.success,
                      fontWeight: FontWeight.w700,
                      fontSize: 13)),
            ],
          ),
          const SizedBox(height: 8),
          _InfoRow('Latitude', position!.latitude.toStringAsFixed(6)),
          _InfoRow('Longitude', position!.longitude.toStringAsFixed(6)),
          _InfoRow('Accuracy', '±${position!.accuracy.toStringAsFixed(1)} m'),
        ],
      );
    } else {
      bg = Colors.grey.shade50;
      border = Colors.grey.shade300;
      content = Text('No location yet', style: TextStyle(color: Colors.grey.shade500));
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          width: double.infinity,
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(
            color: bg,
            border: Border.all(color: border, width: 1.2),
            borderRadius: BorderRadius.circular(14),
          ),
          child: content,
        ),
        const SizedBox(height: 10),
        SizedBox(
          width: double.infinity,
          child: OutlinedButton.icon(
            onPressed: isFetching ? null : onGetLocation,
            icon: Icon(position != null
                ? Icons.refresh_rounded
                : Icons.my_location_outlined),
            label: Text(position != null ? 'Update Location' : 'Get Location'),
          ),
        ),
      ],
    );
  }
}

class _InfoRow extends StatelessWidget {
  final String label;
  final String value;
  const _InfoRow(this.label, this.value);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 2),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label,
              style: TextStyle(color: Colors.grey.shade700, fontSize: 13)),
          Text(value,
              style: const TextStyle(
                  fontWeight: FontWeight.w600, fontSize: 13)),
        ],
      ),
    );
  }
}
