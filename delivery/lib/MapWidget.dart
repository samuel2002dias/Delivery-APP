import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

class MapWidget extends StatefulWidget {
  final LatLng initialLocation;
  final Function(LatLng) onLocationSelected;

  const MapWidget({
    Key? key,
    required this.initialLocation,
    required this.onLocationSelected,
  }) : super(key: key);

  @override
  _MapWidgetState createState() => _MapWidgetState();
}

class _MapWidgetState extends State<MapWidget> {
  late GoogleMapController mapController;
  late LatLng _selectedLocation;
  bool _isMapInteracting = false;

  @override
  void initState() {
    super.initState();
    _selectedLocation = widget.initialLocation;
  }

  void _onMapCreated(GoogleMapController controller) {
    mapController = controller;
  }

  void _onTap(LatLng location) {
    setState(() {
      _selectedLocation = location;
    });
    widget.onLocationSelected(location);
  }

  void _onCameraMove(CameraPosition position) {
    setState(() {
      _isMapInteracting = true;
      _selectedLocation = position.target;
    });
  }

  void _onCameraIdle() {
    if (_isMapInteracting) {
      setState(() {
        _isMapInteracting = false;
      });
      widget.onLocationSelected(_selectedLocation);
    }
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onPanDown: (_) {
        setState(() {
          _isMapInteracting = true;
        });
      },
      onPanCancel: () {
        setState(() {
          _isMapInteracting = false;
        });
      },
      onPanEnd: (_) {
        setState(() {
          _isMapInteracting = false;
        });
      },
      child: Center(
        child: SizedBox(
          height: 300,
          child: GoogleMap(
            onMapCreated: _onMapCreated,
            initialCameraPosition: CameraPosition(
              target: _selectedLocation,
              zoom: 10.0,
            ),
            onTap: _onTap,
            onCameraMove: _onCameraMove,
            onCameraIdle: _onCameraIdle,
            myLocationEnabled: true,
            myLocationButtonEnabled: true,
            zoomControlsEnabled: true,
            markers: {
              Marker(
                markerId: const MarkerId('selected-location'),
                position: _selectedLocation,
              ),
            },
          ),
        ),
      ),
    );
  }
}
