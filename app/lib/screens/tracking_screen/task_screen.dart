import 'package:flutter/material.dart';

class TaskScreen extends StatefulWidget {
  const TaskScreen({super.key});

  @override
  State<TaskScreen> createState() => _TaskScreenState();
}

class _TaskScreenState extends State<TaskScreen> {
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
                  child: ListView(
                    children: [
                      Placeholder(fallbackHeight: 50),
                      Placeholder(fallbackHeight: 50),
                      Placeholder(fallbackHeight: 50),
                      Placeholder(fallbackHeight: 50),
                      Placeholder(fallbackHeight: 50),
                      Placeholder(fallbackHeight: 50),
                      Placeholder(fallbackHeight: 50),
                      Placeholder(fallbackHeight: 50),
                      Placeholder(fallbackHeight: 50),
                      Placeholder(fallbackHeight: 50),
                      Placeholder(fallbackHeight: 50),
                      Placeholder(fallbackHeight: 50),
                      Placeholder(fallbackHeight: 50),
                    ]
                  )
                ),
                Icon(Icons.directions_transit, size: 350),
              ],
            ),
          )),
    );

  }
}
