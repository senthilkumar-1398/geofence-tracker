import 'package:hive/hive.dart';
import 'package:uuid/uuid.dart';

part 'geofence.g.dart';

@HiveType(typeId: 0)
class GeofenceModel {
  @HiveField(0)
  final String id;

  @HiveField(1)
  final String name;

  @HiveField(2)
  final double latitude;

  @HiveField(3)
  final double longitude;

  @HiveField(4)
  final double radius;

  @HiveField(5)
  bool isInside;

  GeofenceModel({
    String? id,
    required this.name,
    required this.latitude,
    required this.longitude,
    required this.radius,
    this.isInside = false,
  }) : id = id ?? const Uuid().v4();

  GeofenceModel copyWith({
    String? name,
    double? latitude,
    double? longitude,
    double? radius,
    bool? isInside,
  }) {
    return GeofenceModel(
      id: id,
      name: name ?? this.name,
      latitude: latitude ?? this.latitude,
      longitude: longitude ?? this.longitude,
      radius: radius ?? this.radius,
      isInside: isInside ?? this.isInside,
    );
  }
}
