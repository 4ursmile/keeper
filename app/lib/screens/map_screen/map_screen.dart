// import 'dart:async';
// import 'dart:typed_data';
// import 'dart:convert';
// import 'dart:ui' as ui;
// import 'dart:ui';
// import 'dart:math' as math;
//
// import 'package:custom_info_window/custom_info_window.dart';
// import 'package:flutter/material.dart';
// import 'package:flutter/services.dart';
// import 'package:flutter_dotenv/flutter_dotenv.dart';
// import 'package:flutter_polyline_points/flutter_polyline_points.dart';
// import 'package:google_maps_flutter/google_maps_flutter.dart';
// import 'package:location/location.dart';
// import 'package:shared_preferences/shared_preferences.dart';
//
// import 'package:http/http.dart' as http;
//
// import 'package:flutter_application_1/screens/map_screen/task_request_modal.dart';
//
//
// var taskLength = 0;
//
// class Task {
//   final int taskID;
//   final String images;
//   final String description;
//   final Map<String, dynamic> location;
//   final double gmv;
//   final double discount;
//   final int giveruserID;
//   final String note;
//
//   Task({
//     required this.taskID,
//     required this.images,
//     required this.description,
//     required this.location,
//     required this.gmv,
//     required this.discount,
//     required this.giveruserID,
//     required this.note,
//   });
//
//   double calculateDistance(double lat1, double lon1, double lat2, double lon2) {
//     const int earthRadius = 6371; // in kilometers
//     double result = math.sqrt(math.pow(lat1 - lat2, 2) + math.pow(lon1 - lon2, 2));
//
//     return result;
//   }
//
//
// }
//
// // Save list class tasks
// List<Task> globalTasks = [];
//
// class MapScreen extends StatefulWidget {
//   const MapScreen({super.key});
//
//   @override
//   State<MapScreen> createState() => _MapScreenState();
// }
//
// class _MapScreenState extends State<MapScreen> {
//   CustomInfoWindowController _customInfoWindowController =
//       CustomInfoWindowController();
//   Location _locationController = Location();
//   static const LatLng _pGooglePlex = LatLng(37.4223, -122.0090);
//   static const LatLng _pApplePark = LatLng(37.3346, -122.4434);
//   LatLng? _currentP;
//   final Completer<GoogleMapController> _mapController = Completer();
//   final StreamController<List<Marker>> _markersStreamController =
//       StreamController<List<Marker>>.broadcast();
//   List<Marker> _markers = [];
//   late String _mapStyle;
//   List<Polyline> _polylines = [];
//
//   @override
//   void initState() {
//     super.initState();
//     getLocationUpdates().then((_) {
//       fetchAndProcessTasks();
//       _addInitialMarker();
//       loadData();
//
//     });
//     rootBundle.loadString('assets/daymode.json').then((string) {
//       _mapStyle = string;
//     });
//   }
//
//   @override
//   void dispose() {
//     _mapController.future.then((value) => value.dispose());
//     _markersStreamController.close();
//     _customInfoWindowController.dispose();
//     super.dispose();
//   }
//
//   Future<Uint8List?> _loadNetworkImage(String path) async {
//     final completer = Completer<ImageInfo>();
//     var img = AssetImage(path);
//     img.resolve(const ImageConfiguration(size: Size.fromHeight(5))).addListener(
//           ImageStreamListener((info, _) => completer.complete(info)),
//         );
//     final imageInfo = await completer.future;
//     final byteData = await imageInfo.image.toByteData(
//       format: ImageByteFormat.png,
//     );
//     return byteData?.buffer.asUint8List();
//   }
//
//   void _addInitialMarker() async {
//     if (_currentP != null) {
//       _markers.add(
//         Marker(
//           markerId: MarkerId("_currentLocation"),
//           icon: BitmapDescriptor.defaultMarker,
//           position: _currentP!,
//         ),
//       );
//     }
//     _markersStreamController.add(_markers);
//
//   }
//
//   Future<String> getJsonFile(String path) async {
//     return await rootBundle.loadString(path);
//   }
//
//   List<String> images = [
//     'assets/images/fav.png',
//     'assets/images/fav.png',
//     'assets/images/fav.png',
//
//   ];
//
//   List<LatLng> _latLang = [
//       LatLng(10.8752047, 106.8004876),
//       LatLng(10.875217, 106.8001276),
//       LatLng(10.8722047, 106.8104876),
//   ];
//
//   loadData() async {
//     // get user id from shared preferences
//     SharedPreferences prefs = await SharedPreferences.getInstance();
//     int? takerId = prefs.getInt('id');
//
//     // get tasks
//
//     // get task length from task list
//
//     print('--> length ${globalTasks.length}');
//
//     for (int i = 0; i < images.length; i++) {
//       Uint8List? image = await _loadNetworkImage('assets/icons/point.png');
//       print('--> globalTasks[i].location ${globalTasks[i].location}');
//       final ui.Codec markerImageCodec = await instantiateImageCodec(
//         image!.buffer.asUint8List(),
//         targetHeight: 100,
//         targetWidth: 100,
//       );
//       final FrameInfo frameInfo = await markerImageCodec.getNextFrame();
//       final ByteData? byteData = await frameInfo.image.toByteData(
//         format: ImageByteFormat.png,
//       );
//
//       var markerPosition = LatLng(
//         globalTasks[i].location['latitude'],
//         globalTasks[i].location['longitude'],
//       );
//
//       print('--> markerPosition $markerPosition');
//       Uint8List? imageBytes = await _loadNetworkImage('assets/icons/point.png');
//       final BitmapDescriptor markerIcon = BitmapDescriptor.fromBytes(imageBytes!);
//       _markers.add(Marker(
//         markerId: MarkerId(i.toString()),
//         position: markerPosition,
//         icon: markerIcon,
//         anchor: Offset(.1, .1),
//         // infoWindow: InfoWindow(title: 'This is title marker: ' + i.toString(),),
//         // onTap: () {
//         //   _drawPolyline(_latLang[i]);
//         //   _customInfoWindowController.addInfoWindow!(
//         //       Container(
//         //         width: 300,
//         //         height: 200,
//         //         decoration: BoxDecoration(
//         //           color: Colors.white,
//         //           border: Border.all(color: Colors.grey),
//         //           borderRadius: BorderRadius.circular(10.0),
//         //         ),
//         //         child: Column(
//         //           mainAxisAlignment: MainAxisAlignment.start,
//         //           crossAxisAlignment: CrossAxisAlignment.start,
//         //           children: [
//         //             Container(
//         //               width: 300,
//         //               height: 100,
//         //               decoration: const BoxDecoration(
//         //                 image: DecorationImage(
//         //                     image: NetworkImage(
//         //                         'https://images.pexels.com/photos/1566837/pexels-photo-1566837.jpeg?cs=srgb&dl=pexels-narda-yescas-1566837.jpg&fm=jpg'),
//         //                     fit: BoxFit.fitWidth,
//         //                     filterQuality: FilterQuality.high),
//         //                 borderRadius: BorderRadius.all(
//         //                   Radius.circular(10.0),
//         //                 ),
//         //                 color: Colors.red,
//         //               ),
//         //             ),
//         //             const Padding(
//         //               padding: EdgeInsets.only(top: 10, left: 10, right: 10),
//         //               child: Row(
//         //                 children: [
//         //                   SizedBox(
//         //                     width: 100,
//         //                     child: Text(
//         //                       'Beef Tacos',
//         //                       maxLines: 1,
//         //                       overflow: TextOverflow.fade,
//         //                       softWrap: false,
//         //                       style: TextStyle(color: Colors.black),
//         //                     ),
//         //                   ),
//         //                   Spacer(),
//         //                   Text(
//         //                     '.3 mi.',
//         //                     style: TextStyle(color: Colors.black),
//         //                   )
//         //                 ],
//         //               ),
//         //             ),
//         //             const Padding(
//         //               padding: EdgeInsets.only(top: 10, left: 10, right: 10),
//         //               child: Text(
//         //                 'Help me finish these tacos! I got a platter from Costco and it’s too much.',
//         //                 maxLines: 2,
//         //                 style: TextStyle(color: Colors.black),
//         //               ),
//         //             ),
//         //           ],
//         //         ),
//         //       ),
//         //       LatLng(_latLang[i].latitude, _latLang[i].longitude));
//         //   setState(() {});
//         // },
//       ));
//       _markersStreamController.add(_markers);
//     }
//   }
//
//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(
//         iconTheme: const IconThemeData(color: Colors.white),
//         backgroundColor: Colors.transparent,
//       ),
//       extendBodyBehindAppBar: true,
//       body: StreamBuilder<List<Marker>>(
//         stream: _markersStreamController.stream,
//         builder: (context, snapshot) {
//           if (snapshot.connectionState == ConnectionState.waiting) {
//             return const Center(child: CircularProgressIndicator());
//           } else if (snapshot.hasError) {
//             return Center(child: Text('Error: ${snapshot.error}'));
//           } else if (!snapshot.hasData) {
//             return const Center(child: Text('No data available'));
//           } else {
//             return Stack(
//               children: [
//                 GoogleMap(
//                   onTap: (position) {
//                     _customInfoWindowController.hideInfoWindow!();
//                   },
//                   onCameraMove: (position) {
//                     _customInfoWindowController.onCameraMove!();
//                   },
//                   myLocationButtonEnabled: true,
//                   myLocationEnabled: true,
//                   onMapCreated: (GoogleMapController controller) async {
//                     _customInfoWindowController.googleMapController =
//                         controller;
//                     _mapController.complete(controller);
//                     // _mapController.future.then((value) {
//                     //   value.setMapStyle(_mapStyle);
//                     // });
//                   },
//                   initialCameraPosition:
//                       CameraPosition(target: _pGooglePlex, zoom: 13),
//                   markers: Set<Marker>.of(snapshot.data!),
//                   polylines: Set<Polyline>.of(_polylines),
//                   circles: _currentP != null
//                       ? {
//                           Circle(
//                             circleId: CircleId("1"),
//                             center: LatLng(
//                                 _currentP!.latitude, _currentP!.longitude),
//                             radius: 430,
//                             strokeWidth: 0,
//                             fillColor: Color(0xff006491).withOpacity(0.2),
//                           ),
//                         }
//                       : {},
//                 ),
//                 CustomInfoWindow(
//                   controller: _customInfoWindowController,
//                   height: 200,
//                   width: 300,
//                   offset: 35,
//                 ),
//               ],
//             );
//           }
//         },
//       ),
//     );
//   }
//
//   Future<void> fetchAndProcessTasks() async {
//     try {
//       String baseUrl = "https://3acb-101-53-1-124.ngrok-free.app";
//       String request = '$baseUrl/users/tasks/';
//       var response = await http.get(Uri.parse(request));
//
//       if (response.statusCode == 200) {
//         var tasksData = await json.decode(response.body) as List<dynamic>;
//
//         print('--> Tasks Response is ${response.body}');
//
//         List<Task> tasks = await tasksData.map((taskData) {
//           return Task(
//             taskID: taskData['taskID'],
//             images: taskData['images'],
//             description: taskData['description'],
//             location: taskData['location'],
//             gmv: taskData['gmv'].toDouble(),
//             discount: taskData['discount'].toDouble(),
//             giveruserID: taskData['giveruserID'],
//             note: taskData['note'],
//           );
//         }).toList();
//
//         globalTasks = tasks;
//         taskLength = tasks.length;
//         print('--> List task is ${globalTasks}');
//
//         print('-->Current P is $_currentP');
//         // Ensure _currentP is not null before using it
//         if (_currentP != null) {
//           // Find task with minimum distance
//           Task? minDistanceTask;
//           double minDistance = double.infinity;
//
//
//
//           for (Task task in tasks) {
//             double taskLat = task.location['latitude'];
//             double taskLon = task.location['longitude'];
//             double distance = task.calculateDistance(
//                 _currentP!.latitude, _currentP!.longitude, taskLat, taskLon);
//
//             if (distance < minDistance) {
//               minDistance = distance;
//               minDistanceTask = task;
//             }
//           }
//
//
//           // Output the task with the minimum distance
//           if (minDistanceTask != null) {
//             print(
//                 '-->Task ID ${minDistanceTask.taskID} has the minimum distance of $minDistance kilometers.');
//           } else {
//             print('No tasks found.');
//           }
//         }
//       } else {
//         throw Exception(
//             "Failed to load data. Status code: ${response.statusCode}");
//       }
//     } catch (e) {
//       print('Error: ${e.toString()}');
//     }
//   }
//   Future<void> _cameraToPosition(LatLng pos) async {
//     final GoogleMapController controller = await _mapController.future;
//     CameraPosition _newCameraPosition = CameraPosition(target: pos, zoom: 16);
//     await controller
//         .animateCamera(CameraUpdate.newCameraPosition(_newCameraPosition));
//   }
//
//   Future<void> getLocationUpdates() async {
//     bool _serviceEnabled;
//     PermissionStatus _permissionGranted;
//
//     _serviceEnabled = await _locationController.serviceEnabled();
//     if (_serviceEnabled) {
//       _serviceEnabled = await _locationController.requestService();
//     } else {
//       return;
//     }
//
//     _permissionGranted = await _locationController.hasPermission();
//     if (_permissionGranted == PermissionStatus.denied) {
//       _permissionGranted = await _locationController.requestPermission();
//       if (_permissionGranted != PermissionStatus.granted) {
//         return;
//       }
//     }
//
//     _locationController.onLocationChanged
//         .listen((LocationData currentLocation) {
//       if (currentLocation.latitude != null &&
//           currentLocation.longitude != null) {
//         _currentP =
//             LatLng(currentLocation.latitude!, currentLocation.longitude!);
//         print(
//             '_currentP ${currentLocation.latitude!}, ${currentLocation.longitude!}');
//         _cameraToPosition(_currentP!);
//         _addInitialMarker();
//       }
//     });
//   }
//
//   // Future<void> _drawPolyline(LatLng markerPosition) async {
//   //   List<LatLng> polylineCoordinates = [];
//   //   PolylinePoints polylinePoints = PolylinePoints();
//   //   PolylineResult result = await polylinePoints.getRouteBetweenCoordinates(
//   //     googleApiKey: 'AIzaSyDvjZL5tOtbI9aMH6D4QQ4jeji7-DSNV9M',
//   //     request: PolylineRequest(
//   //       origin: PointLatLng(_currentP!.latitude, _currentP!.longitude),
//   //       destination: PointLatLng(markerPosition.latitude, markerPosition.longitude),
//   //       mode: TravelMode.driving,
//   //     ),
//   //   );
//   //
//   //   if (result.points.isNotEmpty) {
//   //     result.points.forEach((PointLatLng point) {
//   //       polylineCoordinates.add(LatLng(point.latitude, point.longitude));
//   //     });
//   //
//   //     setState(() {
//   //       _polylines.add(Polyline(
//   //         polylineId: PolylineId(markerPosition.toString()),
//   //         color: Colors.blue,
//   //         points: polylineCoordinates,
//   //         width: 5,
//   //       ));
//   //     });
//   //   } else {
//   //     print(result.errorMessage);
//   //   }
//   // }
//   Future<void> _drawPolyline(LatLng markerPosition) async {
//     List<LatLng> polylineCoordinates = [];
//     PolylinePoints polylinePoints = PolylinePoints();
//     PolylineResult result = await polylinePoints.getRouteBetweenCoordinates(
//       googleApiKey: dotenv.env["MAP_API_KEY"],
//       request: PolylineRequest(
//         origin: PointLatLng(_currentP!.latitude, _currentP!.longitude),
//         destination:
//             PointLatLng(markerPosition.latitude, markerPosition.longitude),
//         mode: TravelMode.driving,
//       ),
//     );
//
//     if (result.points.isNotEmpty) {
//       result.points.forEach((PointLatLng point) {
//         polylineCoordinates.add(LatLng(point.latitude, point.longitude));
//       });
//
//       setState(() {
//         // Clear existing polylines
//         _polylines.clear();
//
//         // Add new polyline
//         _polylines.add(Polyline(
//           polylineId: PolylineId(markerPosition.toString()),
//           color: Colors.blue,
//           points: polylineCoordinates,
//           width: 5,
//         ));
//       });
//     } else {
//       print(result.errorMessage);
//     }
//   }
// }
import 'dart:async';
import 'dart:typed_data';
import 'dart:ui' as ui;
import 'dart:ui';

import 'package:custom_info_window/custom_info_window.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter_polyline_points/flutter_polyline_points.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:location/location.dart';

class MapScreen extends StatefulWidget {
  const MapScreen({super.key});

  @override
  State<MapScreen> createState() => _MapScreenState();
}

// class _MapScreenState extends State<MapScreen> {
//   Location _locationController = new Location();
//   static const LatLng _pGooglePlex = LatLng(37.4223, -122.0090);
//   static const LatLng _pApplePark = LatLng(37.3346, -122.4434);
//   LatLng? _currentP;
//   final Completer<GoogleMapController> _mapController = Completer();
//   // late final GoogleMapController _mapController;
//   final StreamController<List<Marker>> _markersStreamController = StreamController<List<Marker>>.broadcast();
//   List<Marker> _markers = <Marker>[];
//   late String _mapStyle;
//   @override
//   void initState() {
//     super.initState();
//     getLocationUpdates().then((_) {
//       _addInitialMarker();
//       loadData();
//     });
//     rootBundle.loadString('assets/daymode.json').then((string) {
//       _mapStyle = string;
//     });
//   }
//
//   @override
//   void dispose() {
//     _markersStreamController.close();
//     super.dispose();
//   }
//
//   void _addInitialMarker() {
//     if (_currentP != null) {
//       _markers.add(
//         Marker(
//           markerId: MarkerId("_currentLocation"),
//           icon: BitmapDescriptor.defaultMarker,
//           position: _currentP!,
//         ),
//       );
//       _markersStreamController.add(_markers);
//     }
//   }
//
//   Future<String> getJsonFile(String path) async {
//     return await rootBundle.loadString(path);
//   }
//
//   List<String> images = [
//     'assets/images/fav.png',
//     'assets/images/fav.png',
//     'assets/images/fav.png',
//     'assets/images/fav.png',
//     'assets/images/fav.png',
//     'assets/images/fav.png',
//   ];
//
//   List<LatLng> _latLang = [
//     LatLng(37.665532, -121.803044),
//     LatLng(37.662816, -121.811789),
//     LatLng(37.657648, -121.800465),
//     LatLng(37.667943, -121.799577),
//     LatLng(37.663721, -121.798148),
//     LatLng(37.659932, -121.807211)
//   ];
//
//   Future<Uint8List?> _loadNetworkImage(String path) async {
//     final completer = Completer<ImageInfo>();
//     var img = NetworkImage(path);
//     img.resolve(const ImageConfiguration(size: Size.fromHeight(10))).addListener(
//       ImageStreamListener((info, _) => completer.complete(info)),
//     );
//     final imageInfo = await completer.future;
//     final byteData = await imageInfo.image.toByteData(
//       format: ui.ImageByteFormat.png,
//     );
//     return byteData?.buffer.asUint8List();
//   }
//
//   loadData() async {
//     for (int i = 0; i < images.length; i++) {
//       Uint8List? image = await _loadNetworkImage(
//           'https://images.bitmoji.com/3d/avatar/201714142-99447061956_1-s5-v1.webp');
//
//       final ui.Codec markerImageCodec = await instantiateImageCodec(
//         image!.buffer.asUint8List(),
//         targetHeight: 200,
//         targetWidth: 200,
//       );
//       final FrameInfo frameInfo = await markerImageCodec.getNextFrame();
//       final ByteData? byteData = await frameInfo.image.toByteData(
//         format: ImageByteFormat.png,
//       );
//
//       final Uint8List resizedMarkerImageBytes = byteData!.buffer.asUint8List();
//       _markers.add(Marker(
//         markerId: MarkerId(i.toString()),
//         position: _latLang[i],
//         icon: BitmapDescriptor.fromBytes(resizedMarkerImageBytes),
//         anchor: Offset(.1, .1),
//         infoWindow: InfoWindow(title: 'This is title marker: ' + i.toString()),
//       ));
//       _markersStreamController.add(_markers);
//     }
//   }
//
//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(),
//       body: StreamBuilder<List<Marker>>(
//         stream: _markersStreamController.stream,
//         builder: (context, snapshot) {
//           if (snapshot.connectionState == ConnectionState.waiting) {
//             return const Center(child: CircularProgressIndicator());
//           } else if (snapshot.hasError) {
//             return Center(child: Text('Error: ${snapshot.error}'));
//           } else if (!snapshot.hasData) {
//             return const Center(child: Text('No data available'));
//           } else {
//             return GoogleMap(
//               myLocationButtonEnabled: true,
//               myLocationEnabled: true,
//               onMapCreated: (GoogleMapController controller) async {
//                 _mapController.complete(controller);
//                 _mapController.future.then((value) {
//                   value.setMapStyle(_mapStyle);
//                 });
//               },
//               initialCameraPosition: CameraPosition(target: _pGooglePlex, zoom: 13),
//               markers: Set<Marker>.of(snapshot.data!),
//               circles: _currentP != null
//                   ? {
//                 Circle(
//                   circleId: CircleId("1"),
//                   center: LatLng(_currentP!.latitude, _currentP!.longitude),
//                   radius: 430,
//                   strokeWidth: 2,
//                   fillColor: Color(0xff006491).withOpacity(0.2),
//                 ),
//               }
//                   : {},
//             );
//           }
//         },
//       ),
//     );
//   }
//
//   Future<void> _cameraToPosition(LatLng pos) async {
//     final GoogleMapController controller = await _mapController.future;
//     CameraPosition _newCameraPosition = CameraPosition(target: pos, zoom: 16);
//     await controller.animateCamera(CameraUpdate.newCameraPosition(_newCameraPosition));
//   }
//
//   Future<void> getLocationUpdates() async {
//     bool _serviceEnabled;
//     PermissionStatus _permissionGranted;
//
//     _serviceEnabled = await _locationController.serviceEnabled();
//     if (_serviceEnabled) {
//       _serviceEnabled = await _locationController.requestService();
//     } else {
//       return;
//     }
//
//     _permissionGranted = await _locationController.hasPermission();
//     if (_permissionGranted == PermissionStatus.denied) {
//       _permissionGranted = await _locationController.requestPermission();
//       if (_permissionGranted != PermissionStatus.granted) {
//         return;
//       }
//     }
//
//     _locationController.onLocationChanged.listen((LocationData currentLocation) {
//       if (currentLocation.latitude != null && currentLocation.longitude != null) {
//         _currentP = LatLng(currentLocation.latitude!, currentLocation.longitude!);
//         print('_currentP ${currentLocation.latitude!}, ${currentLocation.longitude!}');
//         _cameraToPosition(_currentP!);
//         _addInitialMarker();
//       }
//     });
//   }
//
//   Future<List<LatLng>> getPolylinePoints() async {
//     List<LatLng> polylineCoordinates = [];
//     PolylinePoints polylinePoints = PolylinePoints();
//     PolylineResult result = await polylinePoints.getRouteBetweenCoordinates(
//       googleApiKey: 'AIzaSyDvjZL5tOtbI9aMH6D4QQ4jeji7-DSNV9M',
//       request: PolylineRequest(
//         origin: PointLatLng(_pGooglePlex.latitude, _pGooglePlex.longitude),
//         destination: PointLatLng(_pApplePark.latitude, _pApplePark.longitude),
//         mode: TravelMode.driving,
//       ),
//     );
//
//     if (result.points.isNotEmpty) {
//       result.points.forEach((PointLatLng point) {
//         polylineCoordinates.add(LatLng(point.latitude, point.longitude));
//       });
//     } else {
//       print(result.errorMessage);
//     }
//     return polylineCoordinates;
//   }
// }
class _MapScreenState extends State<MapScreen> {

  CustomInfoWindowController _customInfoWindowController =
  CustomInfoWindowController();
  Location _locationController = Location();
  static const LatLng _pGooglePlex = LatLng(37.4223, -122.0090);
  static const LatLng _pApplePark = LatLng(37.3346, -122.4434);
  LatLng? _currentP;
  final Completer<GoogleMapController> _mapController = Completer();
  final StreamController<List<Marker>> _markersStreamController = StreamController<List<Marker>>.broadcast();
  List<Marker> _markers = [];
  late String _mapStyle;
  List<Polyline> _polylines = [];

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
    _mapController.future.then((value) => value.dispose());
    _markersStreamController.close();
    _customInfoWindowController.dispose();
    super.dispose();
  }

  Future<Uint8List?> _loadNetworkImage(String path) async {
    final completer = Completer<ImageInfo>();
    var img = AssetImage(path);
    img.resolve(const ImageConfiguration(size: Size.fromHeight(5))).addListener(
      ImageStreamListener((info, _) => completer.complete(info)),
    );
    final imageInfo = await completer.future;
    final byteData = await imageInfo.image.toByteData(
      format: ImageByteFormat.png,
    );
    return byteData?.buffer.asUint8List();
  }

  void _addInitialMarker() async {
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
    LatLng(10.875250046043002, 106.80013368190123),
    LatLng(10.875225, 106.880482),
    LatLng(10.875226, 106.880482),
    LatLng(10.875224, 106.880483),
    LatLng(10.875224, 106.880484),
    LatLng(10.875227, 106.880485),
  ];

  loadData() async {
    for (int i = 0; i < images.length; i++) {
      Uint8List? image = await _loadNetworkImage(
          'assets/icons/point.png');

      final ui.Codec markerImageCodec = await instantiateImageCodec(
        image!.buffer.asUint8List(),
        targetHeight: 100,
        targetWidth: 100,
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
        // infoWindow: InfoWindow(title: 'This is title marker: ' + i.toString(),),
        onTap: () {
          _drawPolyline(_latLang[i]);
          _customInfoWindowController.addInfoWindow!(
              Container(
                width: 300,
                height: 200,
                decoration: BoxDecoration(
                  color: Colors.white,
                  border: Border.all(color: Colors.grey),
                  borderRadius: BorderRadius.circular(10.0),
                ),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.start,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children:  [
                    Container(
                      width: 300,
                      height: 100,
                      decoration: const BoxDecoration(
                        image:  DecorationImage(
                            image: NetworkImage('https://cdn.pixabay.com/photo/2017/09/08/18/20/garbage-2729608_640.jpg'),
                            fit: BoxFit.fitWidth,
                            filterQuality: FilterQuality.high),
                        borderRadius:  BorderRadius.all(
                          Radius.circular(10.0),
                        ),
                        color: Colors.red,
                      ),
                    ),
                    const   Padding(
                      padding:  EdgeInsets.only(top: 10 , left: 10 , right: 10),
                      child: Row(
                        children: [
                          SizedBox(
                            width: 100,
                            child: Text(
                              'Beef Tacos',
                              maxLines: 1,
                              overflow: TextOverflow.fade,
                              softWrap: false,
                              style: TextStyle(color: Colors.black),
                            ),
                          ),
                          Spacer(),
                          Text(
                            '.3 mi.',
                            style: TextStyle(color: Colors.black),

                          )
                        ],
                      ),
                    ),
                    const  Padding(
                      padding:  EdgeInsets.only(top: 10 , left: 10 , right: 10),
                      child: Text(
                        'Help me finish these garbage!',
                        maxLines: 2,
                        style: TextStyle(color: Colors.black),

                      ),
                    ),

                  ],
                ),
              ),
              LatLng(_latLang[i].latitude, _latLang[i].longitude)
          );
          setState(() {

          });
        },
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
            return Stack(
              children: [
                GoogleMap(
                  onTap: (position) {
                    _customInfoWindowController.hideInfoWindow!();
                  },
                  onCameraMove: (position) {
                    _customInfoWindowController.onCameraMove!();
                  },
                  myLocationButtonEnabled: true,
                  myLocationEnabled: true,
                  onMapCreated: (GoogleMapController controller) async {
                    _customInfoWindowController.googleMapController = controller;
                    _mapController.complete(controller);
                    _mapController.future.then((value) {
                      value.setMapStyle(_mapStyle);
                    });
                  },
                  initialCameraPosition: CameraPosition(target: _pGooglePlex, zoom: 13),
                  markers: Set<Marker>.of(snapshot.data!),
                  polylines: Set<Polyline>.of(_polylines),
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
                ),
                CustomInfoWindow(
                  controller: _customInfoWindowController,
                  height: 200,
                  width: 300,
                  offset: 35,
                ),
              ],
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

  // Future<void> _drawPolyline(LatLng markerPosition) async {
  //   List<LatLng> polylineCoordinates = [];
  //   PolylinePoints polylinePoints = PolylinePoints();
  //   PolylineResult result = await polylinePoints.getRouteBetweenCoordinates(
  //     googleApiKey: 'AIzaSyDvjZL5tOtbI9aMH6D4QQ4jeji7-DSNV9M',
  //     request: PolylineRequest(
  //       origin: PointLatLng(_currentP!.latitude, _currentP!.longitude),
  //       destination: PointLatLng(markerPosition.latitude, markerPosition.longitude),
  //       mode: TravelMode.driving,
  //     ),
  //   );
  //
  //   if (result.points.isNotEmpty) {
  //     result.points.forEach((PointLatLng point) {
  //       polylineCoordinates.add(LatLng(point.latitude, point.longitude));
  //     });
  //
  //     setState(() {
  //       _polylines.add(Polyline(
  //         polylineId: PolylineId(markerPosition.toString()),
  //         color: Colors.blue,
  //         points: polylineCoordinates,
  //         width: 5,
  //       ));
  //     });
  //   } else {
  //     print(result.errorMessage);
  //   }
  // }
  Future<void> _drawPolyline(LatLng markerPosition) async {
    List<LatLng> polylineCoordinates = [];
    PolylinePoints polylinePoints = PolylinePoints();
    PolylineResult result = await polylinePoints.getRouteBetweenCoordinates(
      googleApiKey: dotenv.env["MAP_API_KEY"],
      request: PolylineRequest(
        origin: PointLatLng(_currentP!.latitude, _currentP!.longitude),
        destination: PointLatLng(markerPosition.latitude, markerPosition.longitude),
        mode: TravelMode.driving,
      ),
    );

    if (result.points.isNotEmpty) {
      result.points.forEach((PointLatLng point) {
        polylineCoordinates.add(LatLng(point.latitude, point.longitude));
      });

      setState(() {
        // Clear existing polylines
        _polylines.clear();

        // Add new polyline
        _polylines.add(Polyline(
          polylineId: PolylineId(markerPosition.toString()),
          color: Colors.blue,
          points: polylineCoordinates,
          width: 5,
        ));
      });
    } else {
      print(result.errorMessage);
    }
  }
}