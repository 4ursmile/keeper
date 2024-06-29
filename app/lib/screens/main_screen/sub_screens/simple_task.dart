import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:image_picker/image_picker.dart';
import 'package:http/http.dart' as http;
import 'package:http_parser/http_parser.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter_application_1/constants/colors.dart';

import 'package:aws_common/aws_common.dart';
import 'package:aws_signature_v4/aws_signature_v4.dart';

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
  List<XFile> images = [];

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
    final key =
        '${DateTime.now().millisecondsSinceEpoch}_${imageFile.path.split('/').last}';
    final url = Uri.parse('https://$bucketName.s3.$region.amazonaws.com/$key');

    String contentType;

    if (imageFile.path.endsWith('.png')) {
      contentType = 'image/png';
    } else if (imageFile.path.endsWith('.jpeg') ||
        imageFile.path.endsWith('.jpg')) {
      contentType = 'image/jpeg';
    } else {
      throw UnsupportedError('Unsupported file type');
    }

    try {
      // var request = http.MultipartRequest('POST', url);
      // request.files
      //     .add(await http.MultipartFile.fromPath('file', imageFile.path));
      // request.fields.addAll({'key': key, 'acl': 'public-read'});

      // var response = await request.send();
      final scope = AWSCredentialScope(
        region: region,
        service: AWSService.s3,
      );

      final bytes = await imageFile.readAsBytes();
      final request = AWSHttpRequest(
        method: AWSHttpMethod.post,
        uri: url,
        body: bytes,
      );

      // Sign the request using AWS Signature Version 4
      final signedRequest = await signer.sign(request, credentialScope: scope);
      final response = await http.put(
        signedRequest.uri,
        headers: signedRequest.headers,
        body: bytes,
      );

      if (response.statusCode == 200) {
        print('--> Response: ${response}');
        print('-->Image uploaded successfully');
        // You can add further handling here if needed
      } else {
        print('--> Response: ${response.reasonPhrase}');
        print('-->Failed to upload image. Status code: ${response.statusCode}');
        // Handle error cases if necessary
      }
    } catch (e) {
      print('-->Error uploading image: $e');
    }

    // final bytes = await imageFile.readAsBytes();

    // try {
    //   final response = await http.put(
    //     url,
    //     headers: <String, String>{
    //       'Content-Type': contentType,
    //       'x-amz-acl': 'public-read',
    //       'x-amz-storage-class': 'REDUCED_REDUNDANCY',
    //       'Access-Control-Allow-Origin': '*',
    //       'Access-Control-Allow-Credentials': 'true',
    //       'Access-Control-Allow-Methods': 'GET,HEAD,OPTIONS,POST,PUT',
    //       'Access-Control-Allow-Headers':
    //           'Access-Control-Allow-Headers, Origin,Accept, X-Requested-With, Content-Type, Access-Control-Request-Method, Access-Control-Request-Headers',
    //     },
    //     body: bytes,
    //   );

    //   if (response.statusCode == 200) {
    //     print('Image uploaded successfully');
    //   } else {
    //     print('Failed to upload image: ${response}');
    //   }
    // } catch (e) {
    //   print('Error uploading image: $e');
    // }
  }

  void confirmAndUploadImages() {
    for (XFile imageFile in images) {
      print('Uploading image: ${imageFile.path}');
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
