import 'package:flutter/material.dart';
import 'package:iconic/iconic.dart';
import 'package:typicons_flutter/typicons_flutter.dart';

class NewFeedScreen extends StatefulWidget {
  const NewFeedScreen({super.key});

  @override
  State<NewFeedScreen> createState() => _NewFeedScreenState();
}

class _NewFeedScreenState extends State<NewFeedScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          title: Text('New feed',
              style:
                  TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
          backgroundColor: Color(0xff006769),
        ),
        body: SingleChildScrollView(
          child: Column(children: [
            PostWidget(),
            PostWidget(),
            PostWidget(),
            PostWidget(),
          ]),
        ));
  }
}

class ButtonRow extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      children: <Widget>[
        CustomButton(
          text: 'Likes',
          icon: Typicons.heart_outline,
          onPressed: () {
            print('Likes button pressed');
          },
        ),
        CustomButton(
          text: 'Comments',
          icon: Typicons.message,
          onPressed: () {
            print('Comments button pressed');
          },
        ),
        CustomButton(
          text: 'Share',
          icon: Typicons.export_outline,
          onPressed: () {
            print('Share button pressed');
          },
        ),
      ],
    );
  }
}

class PostWidget extends StatelessWidget {
  const PostWidget({super.key});

  @override
  Widget build(BuildContext context) {
    return Align(
      alignment: Alignment.center,
      child: Container(
          
          height: 310,
          width: 400,
          decoration: BoxDecoration(
            color: Colors.white,
            
            
            
          ),
          child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Padding(
                  padding: EdgeInsets.only(left: 20, top: 20),
                  child: Row(
                    children: [
                      CircleAvatar(
                        radius: 25,
                        backgroundImage: AssetImage('assets/images/default_profile.png'),
                        //Text
                      ),
                      const SizedBox(width: 20),
                      Text(
                          'User1',
                          style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)
                      ),

                    ],
                  ),
                ),
                const SizedBox(height: 10),
                Image.asset(
                  'assets/images/default_post_img.png',
                  fit: BoxFit.cover,
                  height: 160,
                  width: double.infinity,
                ),
                const SizedBox(height: 10),
                ButtonRow(),
              ])),
    );
  }
}


class CustomButton extends StatelessWidget {
  final String text;
  final IconData icon;
  final VoidCallback onPressed;

  CustomButton({required this.text, required this.icon, required this.onPressed});

  @override
  Widget build(BuildContext context) {
    return TextButton.icon(
      onPressed: onPressed,
      icon: Icon(icon, color: Colors.black),
      label: Text(
        text,
        style: TextStyle(color: Colors.black),
      ),
      style: TextButton.styleFrom(
        padding: EdgeInsets.symmetric(horizontal: 5),
      ),
    );
  }
}