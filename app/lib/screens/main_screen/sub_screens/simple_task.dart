import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:image_picker/image_picker.dart';
import 'package:flutter_application_1/constants/colors.dart';

class SimpleTask extends StatefulWidget {
  const SimpleTask({super.key});

  @override
  State<SimpleTask> createState() => _SimpleTaskState();
}

class _SimpleTaskState extends State<SimpleTask> {
  File? image;
  List<XFile> images = [];
  Future pickImage() async {
    try {
      final image = await ImagePicker().pickImage(source: ImageSource.camera);
      if (image == null) {
        return;
      }
      final imageTemporary = File(image.path);
      setState(() {
        // this.image = imageTemporary;;
        images.add(image);
      });
    } on PlatformException catch (e) {
      print('Failed to fetch: $e');
    }
  }

  Future pickMulti() async {
    final List<XFile>? selectedImage = await ImagePicker().pickMultiImage();
    if (selectedImage!.isNotEmpty) {
      images.addAll(selectedImage);
    }
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
            backgroundColor: Color(0xff006769),
            title: Text(
              'Simple Tasks',
              style: TextStyle(color: Colors.white),
            )),
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
                                  // BoxShadow(color: Colors.black26, blurRadius: 4.0),
                                  BoxShadow(
                                      color: Colors.black26,
                                      blurRadius: 5.0,
                                      spreadRadius: 1,
                                      offset: Offset(0, 4)),
                                ]),
                            child: const Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Icon(Icons.camera_alt_outlined),
                                  SizedBox(height: 10),
                                  Text('Camera')
                                ])),
                      ),
                      const SizedBox(
                        width: 30,
                      ),
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
                                  // BoxShadow(color: Colors.black26, blurRadius: 4.0),
                                  BoxShadow(
                                      color: Colors.black26,
                                      blurRadius: 5.0,
                                      spreadRadius: 1,
                                      offset: Offset(0, 4)),
                                ]),
                            child: const Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Icon(Icons.image_outlined),
                                  SizedBox(height: 10),
                                  Text('Gallery')
                                ])),
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
                                ));
                          }),
                    )
                  : const SizedBox(
                      height: 0,
                      width: 0,
                    ),
              const SizedBox(height: 30),
              Column(
                children: [
                  Padding(
                    padding: const EdgeInsets.only(left: 40.0),
                    child: Align(
                        alignment: Alignment.centerLeft,
                        child: const Text('Description',
                            style: TextStyle(
                                fontWeight: FontWeight.bold, fontSize: 20))),
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
                            Text('Location',
                                style: TextStyle(
                                    fontWeight: FontWeight.bold, fontSize: 20)),
                          ],
                        )),
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
                        child: Text('Number of takers',
                            style: TextStyle(
                                fontWeight: FontWeight.bold, fontSize: 20))),
                  ),
                  Container(width: 300, height: 100, child: TextField()),
                ],
              ),
              Column(
                children: [
                  SizedBox(
                    width: 200, // Specify the width you want
                    height: 50, // Specify the height you want

                    child: ElevatedButton(
                      onPressed: () {
                        
                      },
                      style: ElevatedButton.styleFrom(
                          backgroundColor: AppColors
                              .primaryColor // Set the button's background color
                          ),
                      child: Text(
                        'Confirm',
                        style: TextStyle(
                            color: Colors.white, fontWeight: FontWeight.bold),
                      ),
                    ),
                  ),
                  Container(
                    width: 300,
                    height: 100,
                  ),
                ],
              )
            ])));
  }
}
