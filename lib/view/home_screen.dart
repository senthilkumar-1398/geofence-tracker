import 'package:flutter/material.dart';
import 'package:geofence_tracker/constants/color_constants.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:provider/provider.dart';

import '../model/geofence.dart';
import '../helper/geofence_storage.dart';
import '../services/geofence_monitor.dart';
import 'add_geofence screen.dart';
import 'history_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  late Future<List<GeofenceModel>> _geofencesFuture;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _handlePermissions();
    });
    _refreshGeofences();
  }

  Future<void> _handlePermissions() async {
    await _requestLocationPermission();
    await _requestNotificationPermission();
  }

  Future<void> _requestLocationPermission() async {
    final status = await Permission.location.status;

    if (status.isDenied) {
      final result = await Permission.location.request();
      if (result.isDenied) {
        _showPermissionDialog('Location');
      }
    } else if (status.isPermanentlyDenied) {
      _showPermanentDialog('Location');
    }
  }

  Future<void> _requestNotificationPermission() async {
    final status = await Permission.notification.status;

    if (status.isDenied) {
      final result = await Permission.notification.request();
      if (result.isDenied) {
        _showPermissionDialog('Notification');
      }
    } else if (status.isPermanentlyDenied) {
      _showPermanentDialog('Notification');
    }
  }

  void _showPermissionDialog(String permissionType) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        title: Text('$permissionType Permission Required'),
        content: Text(
            'Please grant $permissionType permission to use this feature.'),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              if (permissionType == 'Location') {
                _requestLocationPermission();
              } else {
                _requestNotificationPermission();
              }
            },
            child: const Text('Retry'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
        ],
      ),
    );
  }

  void _showPermanentDialog(String permissionType) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        title: Text('$permissionType Permission Permanently Denied'),
        content: const Text(
            'Please open settings and allow the permission manually.'),
        actions: [
          TextButton(
            onPressed: () async {
              Navigator.pop(context);
              await openAppSettings();
            },
            child: const Text('Open Settings'),
          ),
        ],
      ),
    );
  }

  Future<void> _refreshGeofences() async {
    final repository = context.read<GeofenceRepository>();
    final geofences = await repository.getAllGeofences();

    setState(() {
      _geofencesFuture = Future.value(geofences);
    });

    await _updateMonitoring(geofences);
  }

  Future<void> _updateMonitoring(List<GeofenceModel> geofences) async {
    final monitor = context.read<GeofenceMonitor>();
    await monitor.startMonitoring(geofences);

    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Geofence monitoring started')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Geofence Tracker'),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _refreshGeofences,
          ),
        ],
      ),
      body: Consumer<GeofenceMonitor>(
        builder: (context, monitor, _) {
          final geofences = monitor.activeGeofences;

          if (geofences.isEmpty) {
            return const Center(child: Text('No geofences added yet'));
          }

          return ListView.builder(
            itemCount: geofences.length,
            itemBuilder: (context, index) {
              final geofence = geofences[index];
              return _GeofenceListItem(
                geofence: geofence,
                onDelete: () => _deleteGeofence(geofence.id),
                onEdit: () => _editGeofence(geofence),
                onHistory: () => _historyGeofence(geofence),
              );
            },
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        backgroundColor: ColorConstants.primaryColor,
        onPressed: _addNewGeofence,
        child: const Icon(
          Icons.add,
          color: ColorConstants.colorWhite,
        ),
      ),
    );
  }

  Future<void> _addNewGeofence() async {
    await Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => const AddGeofenceScreen()),
    );
    _refreshGeofences();
  }

  Future<void> _editGeofence(GeofenceModel geofence) async {
    await Navigator.push(
      context,
      MaterialPageRoute(
          builder: (context) => AddGeofenceScreen(geofence: geofence)),
    );
    _refreshGeofences();
  }

  Future<void> _historyGeofence(GeofenceModel geofence) async {
    print("History");
    await Navigator.push(
      context,
      MaterialPageRoute(
          builder: (context) => MovementHistoryScreen(geofence: geofence)),
    );
    _refreshGeofences();
  }

  Future<void> _deleteGeofence(String id) async {
    final repository = context.read<GeofenceRepository>();
    await repository.removeGeofence(id);
    _refreshGeofences();
  }
}

class _GeofenceListItem extends StatelessWidget {
  final GeofenceModel geofence;
  final VoidCallback onDelete;
  final VoidCallback onEdit;
  final VoidCallback onHistory;

  const _GeofenceListItem({
    required this.geofence,
    required this.onDelete,
    required this.onEdit,
    required this.onHistory,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      elevation: 4,
      child: ListTile(
        contentPadding: const EdgeInsets.all(10),
        isThreeLine: true,
        title: Text(
          geofence.name,
          style: const TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 18,
          ),
        ),
        subtitle: Padding(
          padding: const EdgeInsets.only(top: 8),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text("Lat: ${geofence.latitude.toStringAsFixed(5)}"),
              Text("Lng: ${geofence.longitude.toStringAsFixed(5)}"),
              Text("Radius: ${geofence.radius.toStringAsFixed(0)} m"),
              Row(
                children: [
                  const Text("Status: "),
                  Text(
                    geofence.isInside ? "Inside" : "Outside",
                    style: TextStyle(
                      color: geofence.isInside ? Colors.green : Colors.red,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
        trailing: PopupMenuButton<String>(
          onSelected: (value) {
            if (value == 'history') {
              onHistory();
            } else if (value == 'edit') {
              onEdit();
            } else if (value == 'delete') {
              onDelete();
            }
          },
          itemBuilder: (context) => [
            const PopupMenuItem(
              value: 'history',
              child: ListTile(
                leading: Icon(Icons.history_rounded),
                title: Text('History'),
              ),
            ),
            const PopupMenuItem(
              value: 'edit',
              child: ListTile(
                leading: Icon(Icons.edit),
                title: Text('Edit'),
              ),
            ),
            const PopupMenuItem(
              value: 'delete',
              child: ListTile(
                leading: Icon(Icons.delete),
                title: Text('Delete'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
