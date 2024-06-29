import 'package:flutter/material.dart';
import 'package:flutter_application_1/screens/main_screen/sub_screens/simple_task.dart';

import 'components/function_button.dart';

class MainScreen extends StatefulWidget {
  const MainScreen({super.key});

  @override
  State<MainScreen> createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> {
  final items = <FunctionButton>[
    FunctionButton(icon: 'assets/icons/cash.png', name: 'Cash', onTap: () {}),
    FunctionButton(
        icon: 'assets/icons/wallet.png', name: 'Wallet', onTap: () {}),
    FunctionButton(icon: 'assets/icons/scan.png', name: 'Scan', onTap: () {}),
    FunctionButton(icon: 'assets/icons/qr.png', name: 'QR code', onTap: () {}),
  ];

  @override
  Widget build(BuildContext context) {
    final tasksButton = [
      FunctionButton(
          icon: 'assets/icons/simple.png',
          name: 'Simple Tasks',
          height: 160,
          width: 150,
          iconHeight: 100,
          fontSize: 15,
          spacing: 25,
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
          spacing: 25,
          onTap: () {}),
      FunctionButton(
          icon: 'assets/icons/campaign.png',
          name: 'Campaigns',
          height: 160,
          width: 150,
          iconHeight: 100,
          fontSize: 15,
          spacing: 25,
          onTap: () {}),
      FunctionButton(
          icon: 'assets/icons/public.png',
          name: 'Public Projects',
          height: 160,
          width: 150,
          iconHeight: 100,
          fontSize: 15,
          spacing: 25,
          onTap: () {}),
    ];
    return Scaffold(
      extendBody: true,
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        title: Text('My App'),
        forceMaterialTransparency: true,
        actions: [
          IconButton(
            icon: Icon(
              Icons.settings,
              color: Colors.black,
            ),
            onPressed: () {
              // do something
            },
          )
        ],
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            Container(
              height: 250,
              child: Stack(children: [
                Container(
                    width: 500,
                    height: MediaQuery.of(context).size.height * 0.25,
                    decoration: BoxDecoration(
                      color: Color(0xff006769),
                      borderRadius: BorderRadius.only(
                          bottomLeft: Radius.circular(30),
                          bottomRight: Radius.circular(30)),
                    )),
                Positioned(
                    left: 30,
                    right: 30,
                    top: 160,
                    child: Container(
                        height: 70,
                        width: 100,
                        decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.all(Radius.circular(20)),
                            boxShadow: [
                              BoxShadow(color: Colors.black, blurRadius: 3.0),
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
                                      color: Colors.black26,
                                      blurRadius: 10.0,
                                      spreadRadius: 1,
                                      offset: Offset(0, 4)),
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
