import 'package:hive/hive.dart';
import '../model/movement_history.dart';

class MovementHistoryRepository {
  static const String _boxName = 'movement_history_box';
  late Box<MovementHistory> _box;

  void initialize(Box<MovementHistory> box) {
    _box = box;
  }

  Future<void> init() async {
    if (!_box.isOpen) {
      _box = await Hive.openBox<MovementHistory>(_boxName);
    }
  }

  Future<List<MovementHistory>> getAllHistory() async {
    await init();
    return _box.values.toList();
  }

  Future<List<MovementHistory>> getHistoryByGeofence(String geofenceId) async {
    await init();
    return _box.values
        .where((history) => history.geofenceId == geofenceId)
        .toList()
        .reversed
        .toList();
  }

  Future<void> addHistory(MovementHistory history) async {
    await init();
    await _box.put(history.id, history);
  }

  Future<void> clearAll() async {
    await init();
    await _box.clear();
  }
}