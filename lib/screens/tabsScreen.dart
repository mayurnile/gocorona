import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../screens/homeScreen.dart';
import '../screens/messageScreen.dart';
import '../screens/distresscall.dart';

import '../providers/auth.dart';
class TabsScreen extends StatefulWidget {
  @override
  _TabsScreenState createState() => _TabsScreenState();
}

class _TabsScreenState extends State<TabsScreen>
    with SingleTickerProviderStateMixin {
  TabController _tabController;
  int selectedIndex = 0;
  List body = [
    Container(
      child: Center(
        child: Text('map screen'),
      ),
    ),
    Container(
      child: Center(
        child: Text('help request screen'),
      ),
    ),
  ];
  @override
  void initState() {
    _tabController = TabController(
      length: 3,
      vsync: this,
      initialIndex: 0,
    );
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    final mediaQuery = MediaQuery.of(context);
    final textTheme = Theme.of(context).textTheme;
    final appBar = AppBar(
      title: Text(
        'Go Corona Go',
        style: textTheme.subtitle,
      ),
      elevation: 0,
      actions: <Widget>[
        IconButton(
          icon: Icon(
            Icons.exit_to_app,
            size: 35,
            color: Colors.white,
          ),
          onPressed: () {
            Provider.of<Auth>(context).logout();
          },
        ),
      ],
    );

    final bottomNavigationBar = TabBar(
      indicatorColor: Colors.white,
      indicatorSize: TabBarIndicatorSize.label,
      indicatorPadding: const EdgeInsets.only(bottom: 4.0),
      controller: _tabController,
      labelStyle: textTheme.subhead.copyWith(
        color: Colors.white,
        fontSize: 20.0,
      ),
      labelColor: Colors.white,
      unselectedLabelColor: Colors.white.withOpacity(0.7),
      unselectedLabelStyle: textTheme.body1,
      tabs: <Widget>[
        Tab(
          text: 'Home',
        ),
        Tab(
          text: 'Message',
        ),
        Tab(
          text: 'Call',
        ),
      ],
    );

    return Scaffold(
      backgroundColor: Theme.of(context).primaryColor,
      body: Stack(
        children: <Widget>[
          Padding(
            padding: const EdgeInsets.only(right: 16.0),
            child: appBar,
          ),
          Positioned(
            top: appBar.preferredSize.height + 14,
            child: Container(
              margin: const EdgeInsets.only(
                top: 8.0,
              ),
              width: mediaQuery.size.width,
              height: (mediaQuery.size.height * 0.9)- bottomNavigationBar.preferredSize.height,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(30.0),
                color: Colors.white,
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.4),
                    blurRadius: 10,
                  ),
                ],
              ),
              child: TabBarView(
                physics: BouncingScrollPhysics(),
                controller: _tabController,
                children: <Widget>[
                  HomeScreen(),
                  MessageScreen(),
                  Distress(),
                ],
              ),
            ),
          ),
        ],
      ),
      bottomNavigationBar: bottomNavigationBar,
    );
  }
}
