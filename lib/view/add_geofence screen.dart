import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:provider/provider.dart';

import '../constants/color_constants.dart';
import '../helper/geofence_storage.dart';
import '../model/geofence.dart';

class AddGeofenceScreen extends StatefulWidget {
  final GeofenceModel? geofence;

  const AddGeofenceScreen({this.geofence, super.key});

  @override
  State<AddGeofenceScreen> createState() => _AddGeofenceScreenState();
}

class _AddGeofenceScreenState extends State<AddGeofenceScreen> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _nameController;
  late TextEditingController _radiusController;
  late LatLng _selectedPosition;

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController(
      text: widget.geofence?.name ?? '',
    );
    _radiusController = TextEditingController(
      text: widget.geofence?.radius.toString() ?? '100',
    );
    _selectedPosition = widget.geofence != null
        ? LatLng(widget.geofence!.latitude, widget.geofence!.longitude)
        : const LatLng(0, 0);

    WidgetsBinding.instance.addPostFrameCallback((_) async {
      final repository = context.read<GeofenceRepository>();
      await repository.init();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.geofence == null ? 'Add Geofence' : 'Edit Geofence'),
      ),
      body: SingleChildScrollView(
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              SizedBox(
                height: 450,
                child: GoogleMap(
                  initialCameraPosition: CameraPosition(
                    target: _selectedPosition,
                    zoom: 18,
                  ),
                  onCameraMove: (position) {
                    setState(() {
                      _selectedPosition = position.target;
                    });
                  },
                  markers: {
                    Marker(
                      markerId: const MarkerId('geofence_center'),
                      position: _selectedPosition,
                    ),
                  },
                  myLocationEnabled: true,
                  myLocationButtonEnabled: true,
                ),
              ),
              Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  children: [
                    TextFormField(
                      controller: _nameController,
                      decoration: const InputDecoration(
                        labelText: 'Geofence Name',
                        border: OutlineInputBorder(),
                      ),
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Please enter a name';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 16),
                    TextFormField(
                      controller: _radiusController,
                      keyboardType: TextInputType.number,
                      decoration: const InputDecoration(
                        labelText: 'Radius (meters)',
                        border: OutlineInputBorder(),
                      ),
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Please enter a radius';
                        }
                        final radius = double.tryParse(value);
                        if (radius == null || radius <= 0) {
                          return 'Please enter a valid radius';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 24),
                    SizedBox(
                      width: double.infinity,
                      height: 48,
                      child: ElevatedButton(
                        onPressed: _saveGeofence,
                        style: ElevatedButton.styleFrom(
                          padding: EdgeInsets.zero,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(
                                8),
                          ),
                        ),
                        child: Ink(
                          decoration: BoxDecoration(
                            gradient: LinearGradient(
                              colors: [
                                ColorConstants.primaryColor.withOpacity(0.9),
                                ColorConstants.colorSecondary.withOpacity(0.8),
                              ],
                              begin: Alignment.centerLeft,
                              end: Alignment.centerRight,
                            ),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Container(
                            alignment: Alignment.center,
                            child: const Text(
                              'Save Geofence',
                              style: TextStyle(
                                color: Colors.white,
                                fontFamily: 'Poppins', // optional
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _saveGeofence() async {
    if (!_formKey.currentState!.validate()) return;

    final repository = context.read<GeofenceRepository>();
    final radius = double.parse(_radiusController.text);

    final GeofenceModel geofence = (widget.geofence ??
            GeofenceModel(
              name: _nameController.text,
              latitude: _selectedPosition.latitude,
              longitude: _selectedPosition.longitude,
              radius: radius,
            ))
        .copyWith(
      name: _nameController.text,
      latitude: _selectedPosition.latitude,
      longitude: _selectedPosition.longitude,
      radius: radius,
    );

    await repository.addGeofence(geofence);
    if (mounted) Navigator.pop(context);
  }

  @override
  void dispose() {
    _nameController.dispose();
    _radiusController.dispose();
    super.dispose();
  }
}
