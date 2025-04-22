import 'package:hive/hive.dart';
import 'package:uuid/uuid.dart';

part 'movement_history.g.dart';

@HiveType(typeId: 1)
class MovementHistory {
  @HiveField(0)
  final String id;

  @HiveField(1)
  final String geofenceId;

  @HiveField(2)
  final String geofenceName;

  @HiveField(3)
  final DateTime timestamp;

  @HiveField(4)
  final double latitude;

  @HiveField(5)
  final double longitude;

  @HiveField(6)
  final bool isEntering;

  MovementHistory({
    String? id,
    required this.geofenceId,
    required this.geofenceName,
    required this.timestamp,
    required this.latitude,
    required this.longitude,
    required this.isEntering,
  }) : id = id ?? const Uuid().v4();
}
