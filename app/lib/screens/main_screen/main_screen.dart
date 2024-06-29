import 'package:aws_signature_v4/aws_signature_v4.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_application_1/screens/main_screen/sub_screens/simple_task.dart';

import 'components/function_button.dart';
import 'package:flutter_application_1/constants/sizes.dart';
import 'package:flutter_application_1/constants/colors.dart';

class MainScreen extends StatefulWidget {
  const MainScreen({super.key});

  @override
  State<MainScreen> createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> {

  late String qrCode;
  @override
  Widget build(BuildContext context) {
    final items = <FunctionButton>[
      FunctionButton(
          icon: 'assets/icons/cash.png', name: 'Cash in', onTap: () {}),
      FunctionButton(
          icon: 'assets/icons/wallet.png',
          name: 'Cash out',
          width: 50,
          onTap: () {}),
      FunctionButton(icon: 'assets/icons/scan.png', name: 'Scan', onTap: () {}),
      FunctionButton(icon: 'assets/icons/qr.png', name: 'QR code', onTap: () {}),
    ];
    final tasksButton = [
      FunctionButton(
          icon: 'assets/icons/simple.png',
          name: 'Simple Tasks',
          height: 160,
          width: 150,
          iconHeight: 100,
          fontSize: 15,
          spacing: 3,
          onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => const SimpleTask()),
            );
          }),
      FunctionButton(
          icon: 'assets/icons/complicated.png',
          name: 'Complicated Tasks',
          height: 160,
          width: 150,
          iconHeight: 100,
          fontSize: 15,
          spacing: 3,
          onTap: () {}),
      FunctionButton(
          icon: 'assets/icons/campaign.png',
          name: 'Campaigns',
          height: 160,
          width: 150,
          iconHeight: 100,
          fontSize: 15,
          spacing: 3,
          onTap: () {}),
      FunctionButton(
          icon: 'assets/icons/public.png',
          name: 'Public Projects',
          height: 160,
          width: 150,
          iconHeight: 100,
          fontSize: 15,
          spacing: 3,
          onTap: () {}),
    ];
    return Scaffold(
      extendBody: true,
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        title: Padding(
          padding: const EdgeInsets.only(
            left: 8.0,
            top: 10.0,
            
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Balance',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: Sizes.largeText,
                ),
              ),
              Text(
                '\$1234.56', // Replace with your balance variable
                style: TextStyle(
                  color: Colors.white,
                  fontSize: Sizes.titleSize, 
                  fontWeight: FontWeight.bold
                ),
              ),
            ],
          ),
        ),
        forceMaterialTransparency: true,
        actions: [
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: IconButton(
              icon: Icon(
                Icons.settings,
                color: Colors.white,
              ),
              onPressed: () {
                // do something
              },
            ),
          ),
        ],
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            Container(
              height: 230,
              child: Stack(children: [
                Container(
                    width: 500,
                    height: MediaQuery.of(context).size.height * 0.20,
                    decoration: BoxDecoration(
                      color: AppColors.primaryColor,
                      borderRadius: BorderRadius.only(
                          bottomLeft: Radius.circular(30),
                          bottomRight: Radius.circular(30)),
                    )),
                Positioned(
                    left: 20,
                    right: 20,
                    top: 140,
                    child: Container(
                        height: 70,
                        width: 150,
                        decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.all(Radius.circular(20)),
                            boxShadow: [
                              BoxShadow(color: Colors.grey, blurRadius: 3.0),
                            ]),
                        child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                            children: items)))
              ]),
            ),
            Column(
              children: [
                Container(
                  height: 500,
                  width: double.infinity,
                  child: GridView.builder(
                    gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: 2, // Number of columns
                      crossAxisSpacing:
                          10.0, // Horizontal spacing between items
                      mainAxisSpacing: 10.0, // Vertical spacing between items
                    ),
                    itemCount: 4, // Number of items
                    itemBuilder: (context, index) {
                      return Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: Container(
                            alignment: Alignment.center,
                            decoration: BoxDecoration(
                                color: Colors.white,
                                borderRadius: BorderRadius.circular(30.0),
                                boxShadow: [
                                  // BoxShadow(color: Colors.black26, blurRadius: 4.0),
                                  BoxShadow(
                                      color: Colors.grey.shade200,
                                      blurRadius: 5.0,
                                      spreadRadius: 0.5,
                                      offset: Offset(0, 2)),
                                ]),
                            child: tasksButton[index]),
                      );
                    },
                    padding: EdgeInsets.all(10.0), // Padding around the grid
                  ),
                )
              ],
            )
          ],
        ),
      ),
    );
  }
}
