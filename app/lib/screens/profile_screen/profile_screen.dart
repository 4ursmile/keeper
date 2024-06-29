import 'package:animate_do/animate_do.dart';
import 'package:flutter/material.dart';

import '../../constants/colors.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(),
      body: Align(
        alignment: Alignment.center,
        child: Column(
          children: [
            CircleAvatar(
              radius: 70,
              backgroundColor:Colors.green,
            ),
            Padding(
              padding: EdgeInsets.only(top: 18),
              child: Text('User', style: TextStyle(fontSize: 30, fontWeight: FontWeight.bold)),
            ),
            Padding(
              padding: EdgeInsets.only(top: 8),
              child: Text('20 points', style: TextStyle(fontSize: 20)),
            ),
            Padding(
              padding: EdgeInsets.only(top: 18),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  _taskWidget(text: '50 given tasks'),
                  const SizedBox(width: 20),
                  _taskWidget(text: '50 taken tasks'),
                ],
              ),
            ),
            Spacer(),
            Padding(
              padding: EdgeInsets.only(bottom: 80),
              child: SizedBox(
                height: 50,
                width: 150,
                child: FadeInUp(
                  duration: Duration(milliseconds: 1500),
                  child: ElevatedButton(
                    onPressed: () {
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.primaryColor,
                    ),
                    child: Text(
                      'Log out',
                      style: TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),
              ),
            )
          ]
        ),
      )
    );
  }

  Widget _taskWidget({required text}) {
    return Container(
        height: 50,
        width: 150,
        decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(20),
            boxShadow: [
              BoxShadow(
                color: Colors.black26,
                blurRadius: 3.0,
                spreadRadius: 1,
                offset: Offset(0, 3),
              ),
            ]
        ),
        child: Center(child: Text(text, style: TextStyle(fontSize: 20))));
  }
}
