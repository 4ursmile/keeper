import 'package:flutter/material.dart';
import 'package:flutter_application_1/constants/sizes.dart';
import 'package:flutter_application_1/constants/colors.dart';

class TaskScreen extends StatefulWidget {
  const TaskScreen({super.key});

  @override
  State<TaskScreen> createState() => _TaskScreenState();
}

class _TaskScreenState extends State<TaskScreen> {
  // Replace this with your actual data
  final List<Map<String, dynamic>> _data = [
    {
      "title": "Simple Task",
      "location": "Quận 8, TP. Hồ Chí Minh - 12km away",
      "description":
          "Lorem ipsum dolor sit amet, consectetur adipiscing elit. In maximus placerat fringilla...",
      "points": 12000,
      "imagePath": "assets/images/background.png",
    },
    // Add more data maps here
  ];

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 2,
      child: Scaffold(
        body: NestedScrollView(
          headerSliverBuilder: (BuildContext context, bool innerBoxIsScrolled) {
            return <Widget>[
              const SliverAppBar(
                backgroundColor: Color(0xff006769),
                title: Text(
                  'Tracking',
                  style: TextStyle(
                      color: Colors.white, fontWeight: FontWeight.bold),
                ),
                pinned: true,
                floating: true,
                bottom: TabBar(
                  indicatorColor: Colors.white,
                  labelPadding: EdgeInsets.symmetric(horizontal: 30),
                  isScrollable: false,
                  tabs: [
                    Tab(
                        child: Text('Taken Tasks',
                            style: TextStyle(
                                color: Colors.white,
                                fontSize: Sizes.mediumText))),
                    Tab(
                        child: Text('Given Tasks',
                            style: TextStyle(
                                color: Colors.white,
                                fontSize: Sizes.mediumText))),
                  ],
                ),
              ),
            ];
          },
          body: TabBarView(
            children: <Widget>[
              Container(
                height: 300,
                width: 150,
                child: ListView.builder(
                  itemCount: _data.length,
                  itemBuilder: (context, index) {
                    return _buildListItem(_data[index]);
                  },
                ),
              ),
              Icon(Icons.directions_transit, size: 100),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildListItem(Map<String, dynamic> item) {
    return Padding(
      padding: const EdgeInsets.all(20.0),
      child: Container(
        height: 350,
        width: 150,
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(20.0),
          boxShadow: const [
            BoxShadow(
              color: Colors.grey,
              blurRadius: 1.0,
              offset: Offset(0, 2),
            ),
          ],
        ),
        child: Padding(
          padding: const EdgeInsets.all(0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                height: 160,
                width: double.infinity,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.only(
                    topLeft: Radius.circular(20.0),
                    topRight: Radius.circular(20.0),
                  ),
                  image: DecorationImage(
                    image: AssetImage('assets/images/default_post_img.png'),
                    fit: BoxFit.cover,
                  ),
                ),
              ),
              _buildPaddedText(item['title'],
                  fontSize: Sizes.extraLargeText, fontWeight: FontWeight.bold),
              _buildPaddedText(item['location']),
              _buildPaddedText(item['description']),
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  _buildPaddedText('${item['points']} points',
                      fontSize: Sizes.largeText,
                      textColor: AppColors.primaryColor,
                      fontWeight: FontWeight.bold),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildPaddedText(String text,
      {double? fontSize, Color? textColor, FontWeight? fontWeight}) {
    return Padding(
      padding: const EdgeInsets.only(top: 10.0, left: 20.0, right: 20.0),
      child: Text(
        text,
        style: TextStyle(
            fontSize: fontSize, color: textColor, fontWeight: fontWeight, overflow: TextOverflow.fade),
      ),
    );
  }
}
