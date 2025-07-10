import 'package:flutter/material.dart';

class TripsListScreen extends StatelessWidget {
  const TripsListScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Mes Voyages'),
        backgroundColor: Theme.of(context).primaryColor,
        foregroundColor: Colors.white,
      ),
      body: ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: 3, // Mock data count
        itemBuilder: (context, index) {
          return _buildTripCard(index);
        },
      ),
    );
  }

  Widget _buildTripCard(int index) {
    // Mock trip data
    final mockTrips = [
      {
        'name': 'TRIP/0001/25',
        'departure': 'Casablanca',
        'destination': 'Paris',
        'state': 'in_progress',
        'revenue': 850.0,
        'date': '02/07/2025',
      },
      {
        'name': 'TRIP/0002/25',
        'departure': 'Madrid',
        'destination': 'Rome',
        'state': 'done',
        'revenue': 1200.0,
        'date': '28/06/2025',
      },
      {
        'name': 'TRIP/0003/25',
        'departure': 'Lyon',
        'destination': 'Berlin',
        'state': 'draft',
        'revenue': 0.0,
        'date': '10/07/2025',
      },
    ];

    final trip = mockTrips[index];

    return Card(
      margin: const EdgeInsets.only(bottom: 16),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Expanded(
                  child: Text(
                    trip['name'] as String,
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                _buildStatusChip(trip['state'] as String),
              ],
            ),
            const SizedBox(height: 8),
            Row(
              children: [
                const Icon(
                  Icons.departure_board,
                  size: 16,
                  color: Colors.green,
                ),
                const SizedBox(width: 4),
                Expanded(
                  child: Text(
                    trip['departure'] as String,
                    style: const TextStyle(fontSize: 14),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 4),
            Row(
              children: [
                const Icon(Icons.location_on, size: 16, color: Colors.red),
                const SizedBox(width: 4),
                Expanded(
                  child: Text(
                    trip['destination'] as String,
                    style: const TextStyle(fontSize: 14),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Row(
              children: [
                const Icon(Icons.schedule, size: 16, color: Colors.blue),
                const SizedBox(width: 4),
                Text(
                  'Date: ${trip['date']}',
                  style: const TextStyle(fontSize: 14),
                ),
              ],
            ),
            if ((trip['revenue'] as double) > 0) ...[
              const SizedBox(height: 8),
              Row(
                children: [
                  const Icon(Icons.attach_money, size: 16, color: Colors.green),
                  const SizedBox(width: 4),
                  Text(
                    'Revenus: ${(trip['revenue'] as double).toStringAsFixed(2)} €',
                    style: const TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildStatusChip(String status) {
    Color color;
    String label;

    switch (status) {
      case 'done':
        color = Colors.green;
        label = 'Terminé';
        break;
      case 'in_progress':
        color = Colors.orange;
        label = 'En cours';
        break;
      case 'draft':
        color = Colors.grey;
        label = 'Brouillon';
        break;
      default:
        color = Colors.grey;
        label = 'Inconnu';
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color.withOpacity(0.3)),
      ),
      child: Text(
        label,
        style: TextStyle(
          color: color,
          fontSize: 12,
          fontWeight: FontWeight.w500,
        ),
      ),
    );
  }
}
