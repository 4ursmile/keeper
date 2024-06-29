import 'dart:convert';
import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_google_places_hoc081098/flutter_google_places_hoc081098.dart';
import 'package:flutter_google_places_hoc081098/google_maps_webservice_places.dart';
import 'package:geolocator/geolocator.dart';
import 'package:image_picker/image_picker.dart';
import 'package:http/http.dart' as http;
import 'package:http_parser/http_parser.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter_application_1/constants/colors.dart';
import 'package:uuid/uuid.dart';
import 'package:fl_geocoder/fl_geocoder.dart' as geo;
import 'package:google_api_headers/google_api_headers.dart';

import 'package:aws_common/aws_common.dart';
import 'package:aws_signature_v4/aws_signature_v4.dart';

import 'package:http/http.dart' as http;
import 'package:crypto/crypto.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';

import '../../temp2.dart';

final String accessKey = dotenv.env["AWS_ACCESS_KEY_ID"]!;
final String accessSecret = dotenv.env["AWS_SECRET_ACCESS_KEY"]!;

const String region = 'ap-southeast-1';
const String bucketName = 'keeper-storage';
const String folderName = 'img';

class SimpleTask extends StatefulWidget {
  const SimpleTask({Key? key}) : super(key: key);

  @override
  State<SimpleTask> createState() => _SimpleTaskState();
}

class _SimpleTaskState extends State<SimpleTask> {
  String result = "";
  String lat = "";
  String lng = "";
  String? message;
  List<XFile> images = [];
  late geo.FlGeocoder geocoder;
  Future pickImage() async {
    try {
      final image = await ImagePicker().pickImage(source: ImageSource.camera);
      if (image == null) {
        return;
      }

      setState(() {
        images.add(image);
      });
    } on PlatformException catch (e) {
      print('Failed to pick image: $e');
    }
  }

  Future pickMulti() async {
    final List<XFile>? selectedImages = await ImagePicker().pickMultiImage();
    if (selectedImages != null) {
      setState(() {
        images.addAll(selectedImages);
      });
    }
  }

  final AWSSigV4Signer signer = AWSSigV4Signer(
    credentialsProvider:
        AWSCredentialsProvider(AWSCredentials(accessKey, accessSecret)),
  );
  Future<void> uploadImage(XFile imageFile) async {
    print('Uploading image: ${imageFile}');

    var request = http.MultipartRequest('POST',
        Uri.parse('https://3acb-101-53-1-124.ngrok-free.app/uploadfile/'));

    // Add headers
    request.headers.addAll({
      'accept': 'application/json',
    });

    // Add file
    request.files.add(await http.MultipartFile.fromPath(
      'file',
      imageFile.path,
      contentType: MediaType('image', 'jpeg'),
    ));

    // Send request
    var response = await request.send();

    if (response.statusCode == 200) {
      print('Image uploaded successfully');
    } else {
      print('Failed to upload image. Error: ${response.reasonPhrase}');
    }
  }

  void confirmAndUploadImages() {
    for (XFile imageFile in images) {
      print('Uploading image: ${imageFile.path}');
      uploadImage(imageFile);
    }
  }

  final searchController = TextEditingController();
  final String token = '1234567890';
  var uuid = const Uuid();
  List<dynamic> listOfLocation = [];
  @override
  void initState() {
    super.initState();
    searchController.addListener(() {
      _onChange();
    });
    geocoder = geo.FlGeocoder(dotenv.env["MAP_API_KEY"]!);

  }

  _onChange() {
    placeSuggestion(searchController.text);
  }

  void placeSuggestion(String input) async {
    final String apiKey = dotenv.env["MAP_API_KEY"]!;
    try {
      String bassedUrl =
          "https://maps.googleapis.com/maps/api/place/autocomplete/json";
      String request =
          '$bassedUrl?input=$input&key=$apiKey&sessiontoken=$token';
      var response = await http.get(Uri.parse(request));
      var data = json.decode(response.body);
      if (kDebugMode) {
        print(data);
      }
      if (response.statusCode == 200) {
        setState(() {
          print(response.body);
          listOfLocation = json.decode(response.body)['predictions'];
        });
      } else {}
      throw Exception("Fail to load");
    } catch (e) {
      print(e.toString());
    }
  }

  //check if location permission is enable
  Future<bool> checkPermission() async {
    bool isEnable = false;
    LocationPermission permission;

    //check if location is enable
    isEnable = await Geolocator.isLocationServiceEnabled();
    if (!isEnable) {
      return false;
    }

    //check if use allow location permission
    permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      // if permission is denied then request user to allow permission again
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) {
        // if permission denied again
        return false;
      }
    }

    if (permission == LocationPermission.deniedForever) {
      return false;
    }

    return true;
  }

  final addresses = <geo.Result>[];

  //get user current location
  getUserLocation() async {
    print ('--> Get Location');
    var isEnable = await checkPermission();
    print('--> Granted');
    if (isEnable) {
      Position location = await Geolocator.getCurrentPosition();
      result = "";
      lat = location.latitude.toString();
      lng = location.longitude.toString();
      // try {
      //   final geocoder = FlGeocoder(dotenv.env["MAP_API_KEY"]!);
      //   print('--> Map ${dotenv.env["MAP_API_KEY"]!}');
      //   final coordinates = Location(40.714224, -73.961452);
      //   final results = await geocoder.findAddressesFromLocationCoordinates(
      //     location: coordinates,
      //     useDefaultResultTypeFilter: true,
      //     // resultType: 'route', // Optional. For custom filtering.
      //   );
      //   print('--> address hêh $results');
      //
      // } catch (e) {
      //   print('--> Error $e');
      // }
      final coordinates = geo.Location(location.latitude, location.longitude);
      try {
        final results =
        await geocoder.findAddressesFromLocationCoordinates(
          location: coordinates,
          useDefaultResultTypeFilter: false,
          // resultType: 'route', // Optional. For custom filter.
        );

        addresses.clear();
        addresses.addAll(results);
        print('-> ok hêh ${addresses[0].formattedAddress}');
        message = addresses[0].formattedAddress;
        setState(() {});
      } on geo.GeocodeFailure catch (e) {
        // Do some debugging or show an error message.
        print(e.message ?? 'Unknown error occured.');
        showSnackBarColored(
          e.message ?? 'Unknown error occured.',
          SnackBarType.error,
        );
      } catch (e) {
        // Do some debugging or show an error message.
        print('--> Failed' + e.toString());
        showSnackBarColored(e.toString(), SnackBarType.error);
      }
      // message = geocodeFromPoint.first.addressLine;
      if (message == null) {
        print('--> Cannot get adress $message');
      }
      print('--> Get Address $message');
      // ScaffoldMessenger.of(context).showSnackBar(
      //   SnackBar(
      //     content: Text(message!),
      //   ),
      // );
      setState(() {
      });
    } else {
      setState(() {
        result = "Permission is not allow";
      });
    }
  }

  Widget displayLocation() {
    return Container(
      padding: EdgeInsets.all(8),
      child:
        Text(message ?? 'Nothing',  style: TextStyle(fontSize: 15),),

    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Color(0xff006769),
        title: Text(
          'Simple Tasks',
          style: TextStyle(color: Colors.white),
        ),
      ),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Center(
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  GestureDetector(
                    onTap: () => pickImage(),
                    child: Container(
                      margin: EdgeInsets.only(top: 30),
                      height: 110,
                      width: 150,
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(30.0),
                        boxShadow: const [
                          BoxShadow(
                            color: Colors.black26,
                            blurRadius: 5.0,
                            spreadRadius: 1,
                            offset: Offset(0, 4),
                          ),
                        ],
                      ),
                      child: const Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(Icons.camera_alt_outlined),
                          SizedBox(height: 10),
                          Text('Camera'),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(width: 30),
                  GestureDetector(
                    onTap: () => pickMulti(),
                    child: Container(
                      margin: EdgeInsets.only(top: 30),
                      height: 110,
                      width: 150,
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(30.0),
                        boxShadow: const [
                          BoxShadow(
                            color: Colors.black26,
                            blurRadius: 5.0,
                            spreadRadius: 1,
                            offset: Offset(0, 4),
                          ),
                        ],
                      ),
                      child: const Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(Icons.image_outlined),
                          SizedBox(height: 10),
                          Text('Gallery'),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 30),
            images.isNotEmpty
                ? Container(
                    height: 100,
                    width: 300,
                    child: ListView.builder(
                      scrollDirection: Axis.horizontal,
                      itemCount: images.length,
                      itemBuilder: (BuildContext context, index) {
                        return Padding(
                          padding: const EdgeInsets.only(right: 20),
                          child: Image.file(
                            File(images[index].path),
                            height: 100,
                            width: 100,
                          ),
                        );
                      },
                    ),
                  )
                : const SizedBox(height: 0, width: 0),
            const SizedBox(height: 30),
            Column(
              children: [
                Padding(
                  padding: const EdgeInsets.only(left: 40.0),
                  child: Align(
                    alignment: Alignment.centerLeft,
                    child: const Text(
                      'Description',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 20,
                      ),
                    ),
                  ),
                ),
                Container(width: 300, height: 100, child: TextField()),
              ],
            ),
            Column(
              children: [
                const Padding(
                  padding: EdgeInsets.only(left: 40.0),
                  child: Align(
                    alignment: Alignment.centerLeft,
                    child: Row(
                      children: [
                        Icon(Icons.location_on),
                        Text(
                          'Location',
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 20,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                Center(
                  child: Column(
                    children: [
                      displayLocation(),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          GestureDetector(
                            onTap: () => _handlePressButton(),
                            child: Container(
                              margin: EdgeInsets.only(top: 30),
                              height: 110,
                              width: 150,
                              decoration: BoxDecoration(
                                color: Colors.white,
                                borderRadius: BorderRadius.circular(30.0),
                                boxShadow: const [
                                  BoxShadow(
                                    color: Colors.black26,
                                    blurRadius: 5.0,
                                    spreadRadius: 1,
                                    offset: Offset(0, 4),
                                  ),
                                ],
                              ),
                              child: const Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Icon(Icons.search),
                                  SizedBox(height: 10),
                                  Text('Search place'),
                                ],
                              ),
                            ),
                          ),
                          const SizedBox(width: 30),
                          GestureDetector(
                            onTap: () => getUserLocation(),
                            child: Container(
                              margin: EdgeInsets.only(top: 30),
                              height: 110,
                              width: 150,
                              decoration: BoxDecoration(
                                color: Colors.white,
                                borderRadius: BorderRadius.circular(30.0),
                                boxShadow: const [
                                  BoxShadow(
                                    color: Colors.black26,
                                    blurRadius: 5.0,
                                    spreadRadius: 1,
                                    offset: Offset(0, 4),
                                  ),
                                ],
                              ),
                              child: const Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Icon(
                                    Icons.my_location,
                                    color: Colors.black,
                                  ),
                                  SizedBox(height: 10),
                                  Text('My Location'),
                                ],
                              ),
                            ),
                          ),
                        ],
                      ),

                    ],
                  ),
                ),
                // // const SizedBox(height: 15),
                // ElevatedButton(
                //   onPressed: _handlePressButton,
                //   child: const Text('Search places'),
                // ),
                const SizedBox(height: 80),
              ],
            ),
            Column(
              children: [
                const Padding(
                  padding: EdgeInsets.only(left: 40.0),
                  child: Align(
                    alignment: Alignment.centerLeft,
                    child: Text(
                      'Number of takers',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 20,
                      ),
                    ),
                  ),
                ),
                Container(width: 300, height: 100, child: TextField()),
              ],
            ),
            Column(
              children: [
                SizedBox(
                  width: 200,
                  height: 50,
                  child: ElevatedButton(
                    onPressed: () {
                      confirmAndUploadImages();
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.primaryColor,
                    ),
                    child: Text(
                      'Confirm',
                      style: TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),
                Container(
                  width: 300,
                  height: 100,
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _handlePressButton() async {
    void onError(PlacesAutocompleteResponse response) {
      // ScaffoldMessenger.of(context).showSnackBar(
      //   SnackBar(
      //     content: Text(response.errorMessage ?? 'Unknown error'),
      //   ),
      // );
    }
    // show input autocomplete with selected mode
    // then get the Prediction selected
    final p = await PlacesAutocomplete.show(
      context: context,
      apiKey: dotenv.env['MAP_API_KEY']!,
      onError: onError,
      mode: Mode.overlay,
      language: 'fr',
      components: [const Component(Component.country, 'fr')],
      resultTextStyle: Theme.of(context).textTheme.titleMedium,
    );
    if (!mounted) {
      return;
    }
    await displayPrediction(p, ScaffoldMessenger.of(context));
  }

  Future<void> displayPrediction(
      Prediction? p, ScaffoldMessengerState messengerState) async {
    if (p == null) {
      return;
    }

    // get detail (lat/lng)
    final places = GoogleMapsPlaces(
      apiKey: dotenv.env['MAP_API_KEY']!,
      apiHeaders: await const GoogleApiHeaders().getHeaders(),
    );

    final detail = await places.getDetailsByPlaceId(p.placeId!);
    final geometry = detail.result.geometry!;
    final lat = geometry.location.lat;
    final lng = geometry.location.lng;
    message = p.description;
    setState(() {

    });
    // messengerState.showSnackBar(
    //   SnackBar(
    //     content: Text('${p.description} - $lat/$lng'),
    //   ),
    // );
  }
}
