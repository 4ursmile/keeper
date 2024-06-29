import 'package:flutter/material.dart';

class TaskScreen extends StatefulWidget {
  const TaskScreen({super.key});

  @override
  State<TaskScreen> createState() => _TaskScreenState();
}

class _TaskScreenState extends State<TaskScreen> {
  // Replace this with your actual data
  List<Map<String, dynamic>> _data = [
    {
      "title": "Simple Task",
      "location": "Quận 8, TP. Hồ Chí Minh - 12km away",
      "description":
      "Lorem ipsum dolor sit amet, consectetur adipiscing elit. In maximus placerat fringilla...",
      "points": 12000,
      // Add an image path here (e.g., "assets/images/girl.png")
      "imagePath": "assets/icons/images/background.png",
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
                  title: Text('Tracking', style: TextStyle(color: Colors.white)),
                  pinned: true,
                  floating: true,
                  bottom: TabBar(
                    indicatorColor: Colors.white,
                    labelPadding: EdgeInsets.symmetric(horizontal: 30),
                    isScrollable: false,
                    tabs: [
                      Tab(child: Text('Taken Tasks', style: TextStyle(color: Colors.white),)),
                      Tab(child: Text('Given Tasks', style: TextStyle(color: Colors.white))),
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
          )),
    );

  }

  Widget _buildListItem(Map<String, dynamic> item) {
    return Container(
      padding: EdgeInsets.all(30),
      height: 200,
      width: 150,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(30.0),
        boxShadow: const [
          BoxShadow(
            color: Colors.grey,
            blurRadius: 1.0,
            // spreadRadius: 0.001,
            offset: Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        children: [
          Row(
            children: [
              Text('Filter'), // Add a label for filter icon
              // Add your filter icon here
              Spacer(),
              Text(item['title']),
            ],
          ),
          Text(item['location']),
          Text(item['description']),
          Spacer(),
          Text('${item['points']} points'),
          Image.asset("assets/icons/activity.png"),
        ],
      ),
    );
  }
}

