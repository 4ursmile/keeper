import 'dart:io';
import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:image_picker/image_picker.dart';
import 'package:flutter_application_1/constants/colors.dart';

import 'package:aws_common/aws_common.dart';
import 'package:aws_signature_v4/aws_signature_v4.dart';

import 'package:http/http.dart' as http;
import 'package:crypto/crypto.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';


// For S3 bucket
String ACCESS_KEY = dotenv.env['AWS_ACCESS_KEY_ID']!;
String ACCESS_SECRET = dotenv.env['AWS_SECRET_ACCESS_KEY']!;
const String region = 'ap-southeast-1';
const String bucketName = 'keeper-storage';
const String folderName = 'img';

class SimpleTask extends StatefulWidget {
  const SimpleTask({super.key});

  @override
  State<SimpleTask> createState() => _SimpleTaskState();
}


class _SimpleTaskState extends State<SimpleTask> {
  File? image;
  List<XFile> images = [];
  final signer = AWSSigV4Signer(credentialsProvider: AWSCredentialsProvider.environment());

  Future pickImage() async {
    try {
      final image = await ImagePicker().pickImage(source: ImageSource.camera);
      if (image == null) {
        return;
      }
      
      print('-->Image path: ${image.path}');
      setState(() {
        images.add(image);
      });
    } on PlatformException catch (e) {
      print('-->Failed to fetch: $e');
    }
  }

  Future pickMulti() async {
    final List<XFile>? selectedImage = await ImagePicker().pickMultiImage();
    if (selectedImage!.isNotEmpty) {
      images.addAll(selectedImage);
    }
    setState(() {});
  }

  Future<void> uploadImage(XFile imageFile) async {
    // Generate a pre-signed URL for uploading to S3
    final key =
        '$folderName/${DateTime.now().millisecondsSinceEpoch}_${imageFile.path.split('/').last}';
    final url = Uri.https('$bucketName.s3.$region.amazonaws.com', '/$key');

    // Determine the content type based on the file extension
    String contentType;
    if (imageFile.path.endsWith('.png')) {
      contentType = 'image/png';
    } else if (imageFile.path.endsWith('.jpeg') ||
        imageFile.path.endsWith('.jpg')) {
      contentType = 'image/jpeg';
    } else {
      throw UnsupportedError('Unsupported file type');
    }
    final headers = <String, String>{
      'Content-Type': contentType, // Adjust according to your image type
    };

    // Create a PUT request for uploading the image
    final request = AWSHttpRequest(
      method: AWSHttpMethod.put,
      uri: url,
      headers: headers,
      body: await imageFile.readAsBytes(),
    );

    // Sign the request using AWS SigV4
    final scope = AWSCredentialScope(
      region: region,
      service: AWSService.s3,
    );
    final signedRequest = await signer.sign(
      request,
      credentialScope: scope,
    );

    // Upload the image file
    final response = await http.put(
      signedRequest.uri,
      headers: signedRequest.headers,
      body: signedRequest.body,
    );

    // Handle the response
    if (response.statusCode == 200) {
      print('-->Image uploaded successfully!');
    } else {
      print('-->Failed to upload image. Status code: ${response.statusCode}');
      print(response.body);
    }
  }

  void confirmAndUploadImages() {
    for (XFile imageFile in images) {
      print('-->Uploading image: ${imageFile.path}');
      print('API KEY: ${ACCESS_KEY}');
      print('API SECRET: ${ACCESS_SECRET}');

      uploadImage(imageFile);
    }
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
              child: GestureDetector(
                onTap: () => pickMulti(),
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
                Container(width: 300, height: 100, child: TextField()),
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
}
