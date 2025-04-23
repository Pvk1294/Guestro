import 'package:flutter/material.dart';

class AnalyticsPage extends StatelessWidget {
  const AnalyticsPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Health Analytics')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: SingleChildScrollView(
          child: Column(
            children: [
              _buildExpandedCard(
                title: 'Heart Rate',
                value: 'No Data',
                icon: Icons.favorite,),

              const SizedBox(height: 16),
              _buildExpandedCard(
                title: 'SPO2',
                value: 'No Data',
                icon: Icons.spa,),
              const SizedBox(height: 16),
              _buildExpandedCard(
                title: 'Steps',
                value: 'No Data',
                icon: Icons.directions_walk,),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildExpandedCard({
    required String title,
    required String value,
    required IconData icon,
    String? detailText,
  }) {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      margin: const EdgeInsets.symmetric(vertical: 10),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(icon, size: 40),
                const SizedBox(width: 16),
                Text(
                  title,
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 10),
            Text(
              'Value: $value',
              style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
            ),
            const SizedBox(height: 10),
            if (detailText != null) ...[
              Text(
                detailText,
                style: const TextStyle(fontSize: 14, color: Colors.grey),
              ),
            ],
            // Placeholder for the graph in the future.
            const SizedBox(height: 20),
            Container(
              height: 150,
              color: Colors.grey[200],
              child: const Center(child: Text('Graph Placeholder')),
            ),
          ],
        ),
      ),
    );
  }
}
