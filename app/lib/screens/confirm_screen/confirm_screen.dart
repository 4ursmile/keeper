import 'dart:convert';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:animate_do/animate_do.dart';
import 'package:http_parser/http_parser.dart';
import '../../constants/colors.dart';
import '../../models/task.dart';

class ConfirmScreen extends StatefulWidget {
  final Task task; // Add a Task object

  const ConfirmScreen({Key? key, required this.task}) : super(key: key);

  @override
  State<ConfirmScreen> createState() => _ConfirmScreenState();
}

class _ConfirmScreenState extends State<ConfirmScreen> {
  final TextEditingController _controller = TextEditingController();
  bool _showHintText = true;
  @override
  void initState() {
    super.initState();
    _controller.addListener(() {
      setState(() {
        _showHintText = _controller.text.isEmpty;
      });
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  Future<void> uploadImages() async {

      var request = http.MultipartRequest(
        'POST',
        Uri.parse('https://3acb-101-53-1-124.ngrok-free.app/upload/'),
      );

      // Add headers
      request.headers.addAll({
        'accept': 'application/json',
      });

      // Add file
      request.files.add(await http.MultipartFile.fromPath(
        'file',
        widget.task.images!,
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


  Future<void> _pushTaskToServer() async {
    // Convert task object to JSON string
    // print('--> Model ${widget.task.toJson()}');
    // String jsonData = jsonEncode(widget.task.toJson());
    var taskData = {
      'images': widget.task.images,
      'description': widget.task.description,
      'location': {
        'longitude': widget.task.location!.longitude,
        'latitude': widget.task.location!.latitude,
        'note': widget.task.location!.note,
      },
      'gmv': widget.task.gmv,
      'discount': 10.0, // Example discount, adjust as needed
    };
    print('--> JSON ${taskData}');
    try {
      // Send POST request to the server
      var response = await http.post(
        Uri.parse("https://3acb-101-53-1-124.ngrok-free.app/users/2/tasks/?user_note=2"),
        headers: {
          HttpHeaders.contentTypeHeader: 'application/json',
        },
        body: jsonEncode(taskData),
      );
      await uploadImages();
      // Check if request was successful
      if (response.statusCode == 200) {
        // Show success dialog
        // showDialog(
        //   context: context,
        //   builder: (BuildContext context) {
        //     return AlertDialog(
        //       title: Text('Success'),
        //       content: Text('Task has been successfully sent.'),
        //       actions: <Widget>[
        //         TextButton(
        //           child: Text('OK'),
        //           onPressed: () {
        //             Navigator.of(context).pop(); // Close the dialog
        //           },
        //         ),
        //       ],
        //     );
        //   },
        // );
        showDialog(
          context: context,
          builder: (BuildContext context) {
            return AlertDialog(
              content: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(Icons.check, color: Colors.green),
                  Text("Your task has been published!", style: TextStyle(fontWeight: FontWeight.bold)),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      ElevatedButton(
                        onPressed: () {
                          // Handle "Home" button press
                        },
                        child: Text("Home"),
                      ),
                      ElevatedButton(
                        onPressed: () {
                          // Handle "Tracking" button press
                        },
                        child: Text("Tracking"),
                      ),
                    ],
                  ),
                ],
              ),
            );
          },
        );

      } else {
        // Handle server error
        showDialog(
          context: context,
          builder: (BuildContext context) {
            return AlertDialog(
              title: Text('Error'),
              content: Text('Failed to send task. Server returned ${response.statusCode}.'),
              actions: <Widget>[
                TextButton(
                  child: Text('OK'),
                  onPressed: () {
                    Navigator.of(context).pop(); // Close the dialog
                  },
                ),
              ],
            );
          },
        );
      }
    } catch (e) {
      // Handle network errors or exceptions
      showDialog(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            title: Text('Error'),
            content: Text('Failed to send task. Error: $e'),
            actions: <Widget>[
              TextButton(
                child: Text('OK'),
                onPressed: () {
                  Navigator.of(context).pop(); // Close the dialog
                },
              ),
            ],
          );
        },
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Color(0xff006769),
        leading: BackButton(color: Colors.white),
        titleSpacing: 0,
        title: Text(
          'Confirm Your Task',
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
        ),
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.only(top: 40.0),
          child: Column(
            children: [
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16.0),
                child: Image.file(
                    File(widget.task.images!), height: 150),
              ),
              const SizedBox(height: 30),
              Padding(
                padding: const EdgeInsets.only(left: 20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('Description',
                        style: TextStyle(
                            fontWeight: FontWeight.bold, fontSize: 20)),
                    const SizedBox(height: 10),
                    Padding(
                      padding: const EdgeInsets.only(right: 8.0),
                      child: Text(widget.task.description!),
                    ),
                    const SizedBox(height: 20),
                    Text('Location',
                        style: TextStyle(
                            fontWeight: FontWeight.bold, fontSize: 20)),
                    const SizedBox(height: 10),
                    Padding(
                      padding: const EdgeInsets.only(right: 8.0),
                      child: Text(widget.task.location!.note!),
                    ),
                    const SizedBox(height: 20),
                    Text('Number of Takers',
                        style: TextStyle(
                            fontWeight: FontWeight.bold, fontSize: 20)),
                    const SizedBox(height: 10),
                    Padding(
                      padding: const EdgeInsets.only(right: 8.0),
                      child: Text('5 people'), // Replace with dynamic data if available
                    ),
                    const SizedBox(height: 20),
                    Text('Estimate price',
                        style: TextStyle(
                            fontWeight: FontWeight.bold, fontSize: 20)),
                    const SizedBox(height: 10),
                    Align(
                      alignment: Alignment.center,
                      child: Padding(
                        padding: const EdgeInsets.only(right: 8.0),
                        child: SizedBox(
                          height: 100,
                          width: 300,
                          child: TextField(
                            onChanged: (value) {
                              widget.task.gmv = int.parse(value);
                            },
                            controller: _controller,
                            keyboardType: TextInputType.number,
                            decoration: InputDecoration(
                              hintText: _showHintText ? widget.task.gmv.toString() : null,
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(20.0),
                              ),
                            ),
                          ),
                        ),
                      ),
                    ),
                    Center(
                      child: SizedBox(
                        width: 200,
                        height: 50,
                        child: ElevatedButton(
                          onPressed: () {
                            _pushTaskToServer(); // Call function to push task to server
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
                    ),
                    SizedBox(
                      width: 300,
                      height: 100,
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
