import 'package:animated_bottom_navigation_bar/animated_bottom_navigation_bar.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_application_1/navigation/nav_models.dart';
import 'package:flutter_application_1/screens/map_screen/map_screen.dart';

import 'package:flutter_application_1/screens/temp.dart';

import 'package:flutter_application_1/screens/tracking_screen/task_screen.dart';
import 'package:flutter_application_1/constants/colors.dart';


import '../navigation/nav_bar.dart';
import '../navigation/tab_page.dart';
import 'main_screen/main_screen.dart';
import 'newfeed_screen/newfeed_screen.dart';

class TabScreens extends StatefulWidget {
  const TabScreens({super.key});

  @override
  State<TabScreens> createState() => _TabScreensState();
}

class _TabScreensState extends State<TabScreens> {
  final homeNavKey = GlobalKey<NavigatorState>();
  final searchNavKey = GlobalKey<NavigatorState>();
  final notificationNavKey = GlobalKey<NavigatorState>();
  final profileNavKey = GlobalKey<NavigatorState>();
  int selectedTab = 0;
  List<NavModel> items = [];

  @override
  void initState() {
    super.initState();
    items = [
      NavModel(
        page: const MainScreen(),
        navKey: homeNavKey,
      ),
      NavModel(
        page: NewFeedScreen(),
        navKey: searchNavKey,
      ),
      NavModel(
        page: const TaskScreen(),
        navKey: notificationNavKey,
      ),
      NavModel(
        page: const TabPage(tab: 4),
        navKey: profileNavKey,
      ),
    ];
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: IndexedStack(
        index: selectedTab,
        children: items
            .map((page) => Navigator(
                  key: page.navKey,
                  onGenerateInitialRoutes: (navigator, initialRoute) {
                    return [MaterialPageRoute(builder: (context) => page.page)];
                  },
                ))
            .toList(),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
      floatingActionButton: Visibility(
        visible: MediaQuery.of(context).viewInsets.bottom == 0.0,
        child: Container(
          margin: const EdgeInsets.only(top: 30),
          height: 64,
          width: 64,
          child: FloatingActionButton(
            backgroundColor: AppColors.primaryColor,
            elevation: 0,
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const MapScreen()));
            },
            shape: RoundedRectangleBorder(
              side: const BorderSide(width: 3, color: AppColors.primaryColor),
              
              borderRadius: BorderRadius.circular(100),
            ),
            // child: const Icon(
            //   Icons.add,
            //   color: Colors.green,
            // ),
            child: Image.asset('assets/icons/fav.png', color: Colors.white)
          ),
        ),
      ),
      bottomNavigationBar: NavBar(
        pageIndex: selectedTab,
        onTap: (index) {
          if (index == selectedTab) {
            items[index]
                .navKey
                .currentState
                ?.popUntil((route) => route.isFirst);
          } else {
            setState(() {
              selectedTab = index;
            });
          }
        },
      ),
    );
  }
}
