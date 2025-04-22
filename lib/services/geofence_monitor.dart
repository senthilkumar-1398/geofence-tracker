import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:geolocator/geolocator.dart';
import '../helper/movement_history_storage.dart';
import '../model/geofence.dart';
import '../model/movement_history.dart';

class GeofenceMonitor extends ChangeNotifier {
  final FlutterLocalNotificationsPlugin notifications;
  final List<GeofenceModel> _activeGeofences = [];
  StreamSubscription<Position>? _positionSubscription;
  final Set<String> _triggeredGeofences = {};

  List<GeofenceModel> get activeGeofences => _activeGeofences;

  final MovementHistoryRepository historyRepository;

  GeofenceMonitor(this.notifications, this.historyRepository);

  Future<void> startMonitoring(List<GeofenceModel> geofences) async {
    await stopMonitoring();
    _activeGeofences.addAll(geofences);
    _triggeredGeofences.clear();

    const settings = LocationSettings(
      accuracy: LocationAccuracy.high,
      distanceFilter: 10,
    );

    _positionSubscription = Geolocator.getPositionStream(
      locationSettings: settings,
    ).listen(_checkPositionAgainstGeofences);
  }

  Future<void> stopMonitoring() async {
    await _positionSubscription?.cancel();
    _positionSubscription = null;
    _activeGeofences.clear();
    _triggeredGeofences.clear();
  }

  void _checkPositionAgainstGeofences(Position position) {
    for (final geofence in _activeGeofences) {
      final distance = Geolocator.distanceBetween(
        position.latitude,
        position.longitude,
        geofence.latitude,
        geofence.longitude,
      );

      final isInside = distance <= geofence.radius;

      if (isInside && !_triggeredGeofences.contains(geofence.id)) {
        _triggeredGeofences.add(geofence.id);
        geofence.isInside = true;
        _showNotification('Entered Geofence', 'You entered ${geofence.name}');
        _recordMovement(geofence, position, true);
        notifyListeners();
      } else if (!isInside && _triggeredGeofences.contains(geofence.id)) {
        _triggeredGeofences.remove(geofence.id);
        geofence.isInside = false;
        _showNotification('Exited Geofence', 'You left ${geofence.name}');
        _recordMovement(geofence, position, false);
        notifyListeners();
      }
    }
  }

  Future<void> _recordMovement(
      GeofenceModel geofence, Position position, bool isEntering) async {
    final history = MovementHistory(
      geofenceId: geofence.id,
      geofenceName: geofence.name,
      timestamp: DateTime.now(),
      latitude: position.latitude,
      longitude: position.longitude,
      isEntering: isEntering,
    );
    await historyRepository.addHistory(history);
  }

  Future<void> _showNotification(String title, String body) async {
    const androidDetails = AndroidNotificationDetails(
      'geofence_channel',
      'Geofence Alerts',
      importance: Importance.high,
      priority: Priority.high,
    );

    const platformDetails = NotificationDetails(android: androidDetails);

    final notificationId =
        DateTime.now().millisecondsSinceEpoch.remainder(100000);

    await notifications.show(notificationId, title, body, platformDetails);
  }
}
