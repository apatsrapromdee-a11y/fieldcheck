import 'package:flutter/material.dart';
import '../main.dart';
import '../models/checkin.dart';
import '../services/storage_service.dart';
import '../widgets/checkin_card.dart';
import 'new_checkin_screen.dart';
import 'detail_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  List<CheckIn> _checkIns = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadCheckIns();
  }

  Future<void> _loadCheckIns() async {
    final data = await StorageService.loadCheckIns();

    if (!mounted) return;
    setState(() {
      _checkIns = data.reversed.toList();
      _isLoading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Row(
          mainAxisSize: MainAxisSize.min,
          children: const [
            Icon(Icons.location_on_rounded, size: 22),
            SizedBox(width: 6),
            Text("FieldCheck"),
          ],
        ),
      ),
      body: _isLoading
          ? const Center(
              child: CircularProgressIndicator(color: AppColors.primary),
            )
          : _checkIns.isEmpty
              ? _buildEmptyState()
              : _buildCheckInList(),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () async {
          await Navigator.push(
            context,
            MaterialPageRoute(
              builder: (_) => const NewCheckInScreen(),
            ),
          );
          _loadCheckIns();
        },
        icon: const Icon(Icons.add),
        label: const Text('New Check-In'),
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: 110,
              height: 110,
              decoration: BoxDecoration(
                color: AppColors.primary.withValues(alpha: 0.08),
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.assignment_outlined,
                size: 52,
                color: AppColors.primary,
              ),
            ),
            const SizedBox(height: 24),
            const Text(
              "No check-ins yet",
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: Colors.black87,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              "Tap the button below to create\nyour first field check-in.",
              style: TextStyle(color: Colors.grey.shade600, height: 1.4),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCheckInList() {
    return RefreshIndicator(
      color: AppColors.primary,
      onRefresh: _loadCheckIns,
      child: ListView.builder(
        padding: const EdgeInsets.fromLTRB(12, 12, 12, 90),
        itemCount: _checkIns.length,
        itemBuilder: (context, index) {
          final checkIn = _checkIns[index];

          return CheckInCard(
            checkIn: checkIn,
            onTap: () async {
              await Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => DetailScreen(checkIn: checkIn),
                ),
              );
            },
          );
        },
      ),
    );
  }
}
