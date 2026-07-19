import 'dart:io';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../main.dart';
import '../models/checkin.dart';

class DetailScreen extends StatelessWidget {
  final CheckIn checkIn;

  const DetailScreen({super.key, required this.checkIn});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Check-In Detail'),
      ),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            _PhotoPreview(photoPath: checkIn.photoPath),
            Padding(
              padding: const EdgeInsets.all(18.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(14),
                      border: Border.all(color: Colors.grey.shade200),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const _SectionLabel(
                            icon: Icons.edit_note_rounded, text: 'NOTE'),
                        const SizedBox(height: 6),
                        Text(
                          checkIn.note,
                          style: Theme.of(context).textTheme.bodyLarge,
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 14),
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: AppColors.primary.withValues(alpha: 0.05),
                      borderRadius: BorderRadius.circular(14),
                      border: Border.all(
                          color: AppColors.primary.withValues(alpha: 0.15)),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const _SectionLabel(
                            icon: Icons.my_location_rounded,
                            text: 'LOCATION'),
                        const SizedBox(height: 10),
                        _DetailRow(
                          label: 'Latitude',
                          value: checkIn.latitude.toStringAsFixed(6),
                        ),
                        _DetailRow(
                          label: 'Longitude',
                          value: checkIn.longitude.toStringAsFixed(6),
                        ),
                        _DetailRow(
                          label: 'Accuracy',
                          value: '${checkIn.accuracy.toStringAsFixed(1)} m',
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 14),
                  Row(
                    children: [
                      Icon(Icons.event_rounded,
                          size: 16, color: Colors.grey.shade500),
                      const SizedBox(width: 6),
                      Text(
                        DateFormat('dd MMM yyyy, hh:mm a')
                            .format(checkIn.createdAt),
                        style: TextStyle(
                          fontSize: 13,
                          color: Colors.grey.shade600,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _PhotoPreview extends StatelessWidget {
  final String? photoPath;

  const _PhotoPreview({required this.photoPath});

  @override
  Widget build(BuildContext context) {
    final file = photoPath != null ? File(photoPath!) : null;
    final hasPhoto = file != null && file.existsSync();

    return Container(
      height: 260,
      width: double.infinity,
      color: Colors.black,
      child: hasPhoto
          ? Image.file(file, fit: BoxFit.cover)
          : Center(
              child: Icon(
                Icons.image_not_supported_outlined,
                size: 48,
                color: Colors.grey.shade600,
              ),
            ),
    );
  }
}

class _SectionLabel extends StatelessWidget {
  final IconData icon;
  final String text;
  const _SectionLabel({required this.icon, required this.text});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Icon(icon, size: 15, color: AppColors.primary),
        const SizedBox(width: 6),
        Text(
          text,
          style: const TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.w700,
            color: AppColors.primary,
            letterSpacing: 0.6,
          ),
        ),
      ],
    );
  }
}

class _DetailRow extends StatelessWidget {
  final String label;
  final String value;

  const _DetailRow({required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 5.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: TextStyle(fontSize: 14, color: Colors.grey.shade700),
          ),
          Text(
            value,
            style: const TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w700,
              color: AppColors.primaryDark,
            ),
          ),
        ],
      ),
    );
  }
}
