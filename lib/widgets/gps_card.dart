import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';

import '../services/location_service.dart';

class GpsCard extends StatefulWidget {
  final Function(Position position) onLocationSelected;

  const GpsCard({
    super.key,
    required this.onLocationSelected,
  });

  @override
  State<GpsCard> createState() => _GpsCardState();
}

class _GpsCardState extends State<GpsCard> {
  Position? _position;
  bool _isLoading = false;

  Future<void> _getLocation() async {
    setState(() {
      _isLoading = true;
    });

    Position? position = await LocationService.getCurrentLocation();

    if (!mounted) return;
    setState(() {
      _position = position;
      _isLoading = false;
    });

    if (position != null) {
      widget.onLocationSelected(position);
    } else {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text("Unable to get current location."),
          ),
        );
      }
    }
  }

  Widget _buildInfoRow(String title, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 5),
      child: Row(
        children: [
          SizedBox(
            width: 90,
            child: Text(
              title,
              style: const TextStyle(
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          Expanded(
            child: Text(value),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 2,
      margin: const EdgeInsets.symmetric(vertical: 10),
      child: Padding(
        padding: const EdgeInsets.all(15),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const Text(
              "GPS Location",
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 15),
            ElevatedButton.icon(
              onPressed: _isLoading ? null : _getLocation,
              icon: const Icon(Icons.location_on),
              label: Text(
                _isLoading ? "Getting Location..." : "Get Location",
              ),
            ),
            const SizedBox(height: 20),
            if (_isLoading)
              const Center(
                child: CircularProgressIndicator(),
              ),
            if (_position != null) ...[
              _buildInfoRow(
                "Latitude",
                _position!.latitude.toStringAsFixed(6),
              ),
              _buildInfoRow(
                "Longitude",
                _position!.longitude.toStringAsFixed(6),
              ),
              _buildInfoRow(
                "Accuracy",
                "${_position!.accuracy.toStringAsFixed(2)} m",
              ),
            ],
          ],
        ),
      ),
    );
  }
}
