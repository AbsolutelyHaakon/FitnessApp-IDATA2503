import 'package:fitnessapp_idata2503/styles.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:location/location.dart';
import 'dart:math' show cos, sqrt, asin;

class RoutePlanner extends StatefulWidget {
  final List<LatLng>? initialRoute;

  RoutePlanner({this.initialRoute});

  @override
  _RoutePlannerState createState() => _RoutePlannerState();
}

class _RoutePlannerState extends State<RoutePlanner> {
  GoogleMapController? _controller;
  LocationData? _currentLocation;
  List<LatLng> _routePoints = [];
  BitmapDescriptor? _customMarker;
  double _totalDistance = 0.0;

  @override
  void initState() {
    super.initState();
    _routePoints = widget.initialRoute ?? [];
    _totalDistance = _calculateTotalDistance();
    _getCurrentLocation();
  }

  // Save the route
  Future<void> _saveRoute() async {
    if (kDebugMode) {
      print('Route saved: $_routePoints');
    }

    if (_routePoints.length < 2) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Route must have at least 2 points',
              style: TextStyle(color: AppColors.fitnessPrimaryTextColor)),
          backgroundColor: AppColors.fitnessWarningColor,
        ),
      );
      return;
    }
  }

  // Get the current location of the user
  Future<void> _getCurrentLocation() async {
    Location location = Location();
    _currentLocation = await location.getLocation();
    setState(() {});
  }

  // When the map is created, set the controller
  void _onMapCreated(GoogleMapController controller) {
    _controller = controller;
  }

  // Add a point to the route
  void _addRoutePoint(LatLng point) {
    setState(() {
      _routePoints.add(point);
      _totalDistance = _calculateTotalDistance();
    });
  }

  // Remove the last point from the route
  void _removeLastRoutePoint() {
    if (_routePoints.isNotEmpty) {
      setState(() {
        _routePoints.removeLast();
        _totalDistance = _calculateTotalDistance();
      });
    }
  }

  // Calculate the total distance of the route
  double _calculateTotalDistance() {
    double totalDistance = 0.0;
    for (int i = 0; i < _routePoints.length - 1; i++) {
      totalDistance += _coordinateDistance(
        _routePoints[i].latitude,
        _routePoints[i].longitude,
        _routePoints[i + 1].latitude,
        _routePoints[i + 1].longitude,
      );
    }
    return totalDistance;
  }

  // Calculate the distance between two coordinates
  double _coordinateDistance(lat1, lon1, lat2, lon2) {
    var p = 0.017453292519943295;
    var c = cos;
    var a = 0.5 -
        c((lat2 - lat1) * p) / 2 +
        c(lat1 * p) * c(lat2 * p) * (1 - c((lon2 - lon1) * p)) / 2;
    return 12742 * asin(sqrt(a));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Route Planner',
          style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                color: AppColors.fitnessPrimaryTextColor,
              ),
        ),
        titleSpacing: 40,
        backgroundColor: AppColors.fitnessBackgroundColor,
        leading: IconButton(
          icon: const Icon(CupertinoIcons.back,
              color: AppColors.fitnessMainColor),
          onPressed: () {
            Navigator.of(context).pop();
          },
        ),
      ),
      body: Stack(
        children: [
          _currentLocation == null
              ? Center(child: CircularProgressIndicator())
              : GoogleMap(
                  onMapCreated: _onMapCreated,
                  initialCameraPosition: CameraPosition(
                    target: LatLng(_currentLocation!.latitude!,
                        _currentLocation!.longitude!),
                    zoom: 14.0,
                  ),
                  zoomControlsEnabled: false,
                  markers: {
                    ..._routePoints.map((point) => Marker(
                          markerId: MarkerId(point.toString()),
                          position: point,
                          icon: _customMarker ?? BitmapDescriptor.defaultMarker,
                        )),
                  },
                  onTap: _addRoutePoint,
                  polylines: {
                    Polyline(
                      polylineId: PolylineId('route'),
                      points: _routePoints,
                      color: Colors.blue,
                      width: 5,
                    ),
                  },
                ),
          Positioned(
            top: 10,
            left: 10,
            child: Container(
              padding: EdgeInsets.all(8),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(10),
                color: AppColors.fitnessMainColor,
              ),
              child: Text(
                'Total Distance: ${_totalDistance.toStringAsFixed(2)} km',
                style: const TextStyle(
                    fontSize: 16, color: AppColors.fitnessPrimaryTextColor),
              ),
            ),
          ),
        ],
      ),
      floatingActionButton: Column(
        mainAxisAlignment: MainAxisAlignment.end,
        children: [
          FloatingActionButton(
            onPressed: () {
              _saveRoute();
            },
            backgroundColor: AppColors.fitnessMainColor,
            foregroundColor: AppColors.fitnessPrimaryTextColor,
            child: const Icon(Icons.save),
          ),
          const SizedBox(height: 10),
          FloatingActionButton(
            onPressed: _removeLastRoutePoint,
            backgroundColor: AppColors.fitnessMainColor,
            foregroundColor: AppColors.fitnessPrimaryTextColor,
            child: const Icon(Icons.undo),
          ),
        ],
      ),
      backgroundColor: AppColors.fitnessBackgroundColor,
    );
  }
}