import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:http/http.dart' as http;

class MyMapScreen extends StatefulWidget {
  @override
  _MyMapScreenState createState() => _MyMapScreenState();
}

class _MyMapScreenState extends State<MyMapScreen> {
  late GoogleMapController _mapController;
  Set<Polyline> _polylines = {};
  List<LatLng> _routeCoords = [];
  final LatLng _startLocation = LatLng(41.982922,21.468419); // Skopje
  final LatLng _endLocation = LatLng(42.004863,21.410021); // Ohrid
  final String _apiKey = '<YOUR_API_KEY>'; 

  @override
  void initState() {
    super.initState();
    _fetchRoute();
  }

  Future<void> _fetchRoute() async {
    final String url =
        'https://maps.googleapis.com/maps/api/directions/json?origin=${_startLocation.latitude},${_startLocation.longitude}&destination=${_endLocation.latitude},${_endLocation.longitude}&key=$_apiKey';

    try {
      final response = await http.get(Uri.parse(url));
      if (response.statusCode == 200) {
        final data = json.decode(response.body);

        if (data['routes'].isNotEmpty) {
          final points = data['routes'][0]['overview_polyline']['points'];
          _routeCoords = _decodePolyline(points);

          setState(() {
            _polylines.add(
              Polyline(
                polylineId: PolylineId('route'),
                points: _routeCoords,
                color: Colors.blue,
                width: 5,
              ),
            );
          });
        } else {
          print('No route found');
        }
      } else {
        print('Failed to fetch directions: ${response.body}');
      }
    } catch (e) {
      print('Error fetching route: $e');
    }
  }

  _decodePolyline(String polyline) { final List coordinates = []; int index = 0, len = polyline.length; int lat = 0, lng = 0;

  while (index < len) {
    int shift = 0, result = 0;
    int b;
    do {
      b = polyline.codeUnitAt(index++) - 63;
      result |= (b & 0x1F) << shift;
      shift += 5;
    } while (b >= 0x20);
    int dlat = ((result & 1) != 0 ? ~(result >> 1) : (result >> 1));
    lat += dlat;

    shift = 0;
    result = 0;
    do {
      b = polyline.codeUnitAt(index++) - 63;
      result |= (b & 0x1F) << shift;
      shift += 5;
    } while (b >= 0x20);
    int dlng = ((result & 1) != 0 ? ~(result >> 1) : (result >> 1));
    lng += dlng;

    coordinates.add(LatLng(lat / 1E5, lng / 1E5));
  }

  return coordinates;

  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Route from Skopje to Ohrid'),
      ),
      body: GoogleMap(
        initialCameraPosition: CameraPosition(
          target: _startLocation,
          zoom: 12, 
        ),
        onMapCreated: (controller) {
          _mapController = controller;
        },
        myLocationEnabled: true,
        myLocationButtonEnabled: true,
        polylines: _polylines,
        markers: {
          Marker(
            markerId: MarkerId('start'),
            position: _startLocation,
            infoWindow: InfoWindow(title: 'Start: You'),
          ),
          Marker(
            markerId: MarkerId('end'),
            position: _endLocation,
            infoWindow: InfoWindow(title: 'End: Finki'),
          ),
        },
      ),

    );
  }
}