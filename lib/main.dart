import 'package:flutter/material.dart';
import 'package:geofence_tracker/view/home_screen.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:provider/provider.dart';
import 'helper/movement_history_storage.dart';
import 'model/geofence.dart';
import 'model/movement_history.dart';
import 'helper/geofence_storage.dart';
import 'services/geofence_monitor.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await Hive.initFlutter();
  Hive.registerAdapter(GeofenceModelAdapter());
  Hive.registerAdapter(MovementHistoryAdapter()); // Register the new adapter

  final geofenceBox = await Hive.openBox<GeofenceModel>('geofences');
  final historyBox = await Hive.openBox<MovementHistory>('movement_history_box');

  final geofenceRepo = GeofenceRepository()..initialize(geofenceBox);
  final historyRepo = MovementHistoryRepository()..initialize(historyBox);

  final notifications = FlutterLocalNotificationsPlugin();
  await notifications.initialize(
    const InitializationSettings(
      android: AndroidInitializationSettings('@mipmap/ic_launcher'),
    ),
  );

  runApp(
    MultiProvider(
      providers: [
        Provider(create: (_) => geofenceRepo),
        Provider(create: (_) => historyRepo),
        ChangeNotifierProvider(create: (_) => GeofenceMonitor(notifications, historyRepo)), // <-- inject here
      ],
      child: const MyApp(),
    ),
  );
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Geofence Manager',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        primarySwatch: Colors.blue,
        visualDensity: VisualDensity.adaptivePlatformDensity,
      ),
      home: const HomeScreen(),
    );
  }
}