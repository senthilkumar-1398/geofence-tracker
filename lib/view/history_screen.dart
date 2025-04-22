import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';

import '../helper/movement_history_storage.dart';
import '../model/geofence.dart';
import '../model/movement_history.dart';

class MovementHistoryScreen extends StatelessWidget {
  final GeofenceModel? geofence;

  const MovementHistoryScreen({this.geofence, super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          geofence == null
              ? 'All Movement History'
              : 'History for ${geofence!.name}',
          style: const TextStyle(fontFamily: 'Poppins'),
        ),
      ),
      body: FutureBuilder<List<MovementHistory>>(
        future: geofence == null
            ? Provider.of<MovementHistoryRepository>(context).getAllHistory()
            : Provider.of<MovementHistoryRepository>(context)
                .getHistoryByGeofence(geofence!.id),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          if (snapshot.hasError ||
              !snapshot.hasData ||
              snapshot.data!.isEmpty) {
            return const Center(
              child: Text(
                'No movement history found',
                style: TextStyle(fontFamily: 'Poppins'),
              ),
            );
          }

          final history = snapshot.data!;
          return ListView.builder(
            itemCount: history.length,
            itemBuilder: (context, index) {
              final entry = history[index];
              return ListTile(
                title: Text(
                  entry.isEntering ? 'Entered' : 'Exited',
                  style: TextStyle(
                    fontFamily: 'Poppins',
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: entry.isEntering ? Colors.green : Colors.red,
                  ),
                ),
                subtitle: Padding(
                  padding: const EdgeInsets.only(top: 4.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        DateFormat('yyyy-MM-dd HH:mm:ss')
                            .format(entry.timestamp),
                        style: const TextStyle(
                          fontFamily: 'Poppins',
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                          color: Colors.deepPurple,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        'Lat: ${entry.latitude.toStringAsFixed(6)}, Lon: ${entry.longitude.toStringAsFixed(6)}',
                        style: const TextStyle(
                          fontFamily: 'Poppins',
                          fontSize: 13,
                          color: Colors.black87,
                        ),
                      ),
                    ],
                  ),
                ),
                trailing: Icon(
                  entry.isEntering ? Icons.login : Icons.logout,
                  color: entry.isEntering ? Colors.green : Colors.red,
                ),
              );
            },
          );
        },
      ),
    );
  }
}
