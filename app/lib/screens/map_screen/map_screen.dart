import 'dart:async';
import 'dart:typed_data';
import 'dart:ui' as ui;
import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_polyline_points/flutter_polyline_points.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:location/location.dart';

class MapScreen extends StatefulWidget {
  const MapScreen({super.key});

  @override
  State<MapScreen> createState() => _MapScreenState();
}

class _MapScreenState extends State<MapScreen> {
  Location _locationController = new Location();
  static const LatLng _pGooglePlex = LatLng(37.4223, -122.0090);
  static const LatLng _pApplePark = LatLng(37.3346, -122.4434);
  LatLng? _currentP;
  final Completer<GoogleMapController> _mapController = Completer();
  // late final GoogleMapController _mapController;
  final StreamController<List<Marker>> _markersStreamController = StreamController<List<Marker>>.broadcast();
  List<Marker> _markers = <Marker>[];
  late String _mapStyle;
  @override
  void initState() {
    super.initState();
    getLocationUpdates().then((_) {
      _addInitialMarker();
      loadData();
    });
    rootBundle.loadString('assets/daymode.json').then((string) {
      _mapStyle = string;
    });
  }

  @override
  void dispose() {
    _markersStreamController.close();
    super.dispose();
  }

  void _addInitialMarker() {
    if (_currentP != null) {
      _markers.add(
        Marker(
          markerId: MarkerId("_currentLocation"),
          icon: BitmapDescriptor.defaultMarker,
          position: _currentP!,
        ),
      );
      _markersStreamController.add(_markers);
    }
  }

  Future<String> getJsonFile(String path) async {
    return await rootBundle.loadString(path);
  }

  List<String> images = [
    'assets/images/fav.png',
    'assets/images/fav.png',
    'assets/images/fav.png',
    'assets/images/fav.png',
    'assets/images/fav.png',
    'assets/images/fav.png',
  ];

  List<LatLng> _latLang = [
    LatLng(37.665532, -121.803044),
    LatLng(37.662816, -121.811789),
    LatLng(37.657648, -121.800465),
    LatLng(37.667943, -121.799577),
    LatLng(37.663721, -121.798148),
    LatLng(37.659932, -121.807211)
  ];

  Future<Uint8List?> _loadNetworkImage(String path) async {
    final completer = Completer<ImageInfo>();
    var img = NetworkImage(path);
    img.resolve(const ImageConfiguration(size: Size.fromHeight(10))).addListener(
      ImageStreamListener((info, _) => completer.complete(info)),
    );
    final imageInfo = await completer.future;
    final byteData = await imageInfo.image.toByteData(
      format: ui.ImageByteFormat.png,
    );
    return byteData?.buffer.asUint8List();
  }

  loadData() async {
    for (int i = 0; i < images.length; i++) {
      Uint8List? image = await _loadNetworkImage(
          'https://images.bitmoji.com/3d/avatar/201714142-99447061956_1-s5-v1.webp');

      final ui.Codec markerImageCodec = await instantiateImageCodec(
        image!.buffer.asUint8List(),
        targetHeight: 200,
        targetWidth: 200,
      );
      final FrameInfo frameInfo = await markerImageCodec.getNextFrame();
      final ByteData? byteData = await frameInfo.image.toByteData(
        format: ImageByteFormat.png,
      );

      final Uint8List resizedMarkerImageBytes = byteData!.buffer.asUint8List();
      _markers.add(Marker(
        markerId: MarkerId(i.toString()),
        position: _latLang[i],
        icon: BitmapDescriptor.fromBytes(resizedMarkerImageBytes),
        anchor: Offset(.1, .1),
        infoWindow: InfoWindow(title: 'This is title marker: ' + i.toString()),
      ));
      _markersStreamController.add(_markers);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(),
      body: StreamBuilder<List<Marker>>(
        stream: _markersStreamController.stream,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          } else if (!snapshot.hasData) {
            return const Center(child: Text('No data available'));
          } else {
            return GoogleMap(
              myLocationButtonEnabled: true,
              myLocationEnabled: true,
              onMapCreated: (GoogleMapController controller) async {
                _mapController.complete(controller);
                _mapController.future.then((value) {
                  value.setMapStyle(_mapStyle);
                });
              },
              initialCameraPosition: CameraPosition(target: _pGooglePlex, zoom: 13),
              markers: Set<Marker>.of(snapshot.data!),
              circles: _currentP != null
                  ? {
                Circle(
                  circleId: CircleId("1"),
                  center: LatLng(_currentP!.latitude, _currentP!.longitude),
                  radius: 430,
                  strokeWidth: 2,
                  fillColor: Color(0xff006491).withOpacity(0.2),
                ),
              }
                  : {},
            );
          }
        },
      ),
    );
  }

  Future<void> _cameraToPosition(LatLng pos) async {
    final GoogleMapController controller = await _mapController.future;
    CameraPosition _newCameraPosition = CameraPosition(target: pos, zoom: 16);
    await controller.animateCamera(CameraUpdate.newCameraPosition(_newCameraPosition));
  }

  Future<void> getLocationUpdates() async {
    bool _serviceEnabled;
    PermissionStatus _permissionGranted;

    _serviceEnabled = await _locationController.serviceEnabled();
    if (_serviceEnabled) {
      _serviceEnabled = await _locationController.requestService();
    } else {
      return;
    }

    _permissionGranted = await _locationController.hasPermission();
    if (_permissionGranted == PermissionStatus.denied) {
      _permissionGranted = await _locationController.requestPermission();
      if (_permissionGranted != PermissionStatus.granted) {
        return;
      }
    }

    _locationController.onLocationChanged.listen((LocationData currentLocation) {
      if (currentLocation.latitude != null && currentLocation.longitude != null) {
        _currentP = LatLng(currentLocation.latitude!, currentLocation.longitude!);
        print('_currentP ${currentLocation.latitude!}, ${currentLocation.longitude!}');
        _cameraToPosition(_currentP!);
        _addInitialMarker();
      }
    });
  }

  Future<List<LatLng>> getPolylinePoints() async {
    List<LatLng> polylineCoordinates = [];
    PolylinePoints polylinePoints = PolylinePoints();
    PolylineResult result = await polylinePoints.getRouteBetweenCoordinates(
      googleApiKey: 'AIzaSyDvjZL5tOtbI9aMH6D4QQ4jeji7-DSNV9M',
      request: PolylineRequest(
        origin: PointLatLng(_pGooglePlex.latitude, _pGooglePlex.longitude),
        destination: PointLatLng(_pApplePark.latitude, _pApplePark.longitude),
        mode: TravelMode.driving,
      ),
    );

    if (result.points.isNotEmpty) {
      result.points.forEach((PointLatLng point) {
        polylineCoordinates.add(LatLng(point.latitude, point.longitude));
      });
    } else {
      print(result.errorMessage);
    }
    return polylineCoordinates;
  }
}

