
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:location/location.dart';
import 'package:http/http.dart' as http;

class GoogleMapScreen extends StatefulWidget {
  final LatLng destination;

  GoogleMapScreen({Key? key, required this.destination}) : super(key: key);

  @override
  _GoogleMapScreenState createState() => _GoogleMapScreenState();
}

class _GoogleMapScreenState extends State<GoogleMapScreen> {
  late GoogleMapController _mapController;
  late LocationData _currentLocation;
  late Location location;
  List<LatLng> _routeCoords = [];
  late Set<Polyline> _polylines;
  late String _directions;
  late LatLng _destination;


  @override
  void initState() {
    super.initState();
    location = Location();
    _polylines = {};
    _directions = '';
   
    _destination = widget.destination;
  }

  Future<void> _getCurrentLocation() async {
    try {
      _currentLocation = await location.getLocation();
      _goToLocation(_currentLocation.latitude!, _currentLocation.longitude!);

      _fetchRouteAndDrawPolyline();
    } catch (e) {
      print("Error getting location: $e");
    }
  }

  void _onMapCreated(GoogleMapController controller) {
    _mapController = controller;
    _getCurrentLocation();
  }


  Future<void> _goToLocation(double lat, double long) async {
    if (_mapController != null) {
      _mapController.animateCamera(CameraUpdate.newCameraPosition(
        CameraPosition(target: LatLng(lat, long), zoom: 14),
      ));
    } else {
      print("MapController is not initialized yet.");
    }
  }

  Future<void> _fetchRouteAndDrawPolyline() async {
    final String apiUrl = 'https://maps.googleapis.com/maps/api/directions/json?'
        'origin=${_currentLocation.latitude},${_currentLocation.longitude}'
        '&destination=${_destination.latitude},${_destination.longitude}'
        '&key=';

    final http.Response response = await http.get(Uri.parse(apiUrl));
    final decoded = json.decode(response.body);

    if (decoded["routes"] != null && decoded["routes"].isNotEmpty) {
      _routeCoords = _decodeEncodedPolyline(
          decoded["routes"][0]["overview_polyline"]["points"]);

      _updateDirections(decoded["routes"][0]["legs"][0]["steps"]);

      setState(() {
        _polylines.add(Polyline(
          polylineId: PolylineId("route"),
          points: _routeCoords,
          color: Colors.blue,
          width: 4,
        ));
      });
    }
  }

  List<LatLng> _decodeEncodedPolyline(String encoded) {
    List<LatLng> points = [];
    int index = 0, len = encoded.length;
    int lat = 0, lng = 0;

    while (index < len) {
      int b, shift = 0, result = 0;
      do {
        b = encoded.codeUnitAt(index++) - 63;
        result |= (b & 0x1f) << shift;
        shift += 5;
      } while (b >= 0x20);
      int dlat = ((result & 1) != 0 ? ~(result >> 1) : (result >> 1));
      lat += dlat;

      shift = 0;
      result = 0;
      do {
        b = encoded.codeUnitAt(index++) - 63;
        result |= (b & 0x1f) << shift;
        shift += 5;
      } while (b >= 0x20);
      int dlng = ((result & 1) != 0 ? ~(result >> 1) : (result >> 1));
      lng += dlng;

      points.add(LatLng(lat / 1E5, lng / 1E5));
    }
    return points;
  }

  void _updateDirections(List<dynamic> steps) {
    _directions = '';
    for (var step in steps) {
      _directions += '${step["html_instructions"]} (${step["distance"]["text"]})\n';
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Навигација'),
      ),
      body: Column(
        children: [
          Expanded(
            child: GoogleMap(
              onMapCreated: _onMapCreated,
              initialCameraPosition: CameraPosition(
                target: LatLng(0, 0),
                zoom: 12,
              ),
              myLocationEnabled: true,
              myLocationButtonEnabled: true,
              polylines: _polylines,
              markers: <Marker>{
                Marker(
                  markerId: MarkerId('start'),
                  position: _routeCoords.isNotEmpty ? _routeCoords.first : LatLng(0, 0),
                  icon: BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueRose),
                  infoWindow: InfoWindow(
                    title: 'Start',
                  ),
                ),
                Marker(
                  markerId: MarkerId('end'),
                  position: _routeCoords.isNotEmpty ? _routeCoords.last : LatLng(0, 0),
                  icon: BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueRed),
                  infoWindow: InfoWindow(
                    title: 'End',
                  ),
                ),
              },
            ),
          ),
        ],
      ),
    );
  }
}