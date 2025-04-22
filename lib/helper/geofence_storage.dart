import 'package:hive/hive.dart';

import '../model/geofence.dart';

class GeofenceRepository {
  static const String _boxName = 'geofences_box';
  late Box<GeofenceModel> _box;

  void initialize(Box<GeofenceModel> box) {
    _box = box;
  }

  Future<void> init() async {
    if (!_box.isOpen) {
      _box = await Hive.openBox<GeofenceModel>(_boxName);
    }
  }

  Future<List<GeofenceModel>> getAllGeofences() async {
    if (!_box.isOpen) await init();
    return _box.values.toList();
  }

  Future<void> addGeofence(GeofenceModel geofence) async {
    if (!_box.isOpen) await init();
    await _box.put(geofence.id, geofence);
  }

  Future<void> updateGeofence(GeofenceModel geofence) async {
    if (!_box.isOpen) await init();
    if (_box.containsKey(geofence.id)) {
      await _box.put(geofence.id, geofence);
    }
  }

  Future<void> removeGeofence(String id) async {
    if (!_box.isOpen) await init();
    await _box.delete(id);
  }

  Future<void> clearAll() async {
    if (!_box.isOpen) await init();
    await _box.clear();
  }
}
