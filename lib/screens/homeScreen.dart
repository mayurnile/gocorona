import 'package:flutter/material.dart';

import '../widgets/notification_panel.dart';
import '../widgets/heat_map.dart';

import '../constants/constants.dart';

class HomeScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final mediaQuery = MediaQuery.of(context);
    final textTheme = Theme.of(context).textTheme;

    return Container(
      margin: const EdgeInsets.only(
        top: 8.0,
      ),
      height: mediaQuery.size.height,
      width: mediaQuery.size.width,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(30),
          topRight: Radius.circular(30),
        ),
      ),
      child: SingleChildScrollView(
        physics: BouncingScrollPhysics(),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 10.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              Padding(
                padding: const EdgeInsets.all(16.0),
                child: Row(
                  children: <Widget>[
                    Text(
                      'Heat Map',
                      style: textTheme.subhead,
                    ),
                    IconButton(
                      icon: Icon(
                        Icons.zoom_out_map,
                        color: Colors.black,
                      ),
                      onPressed: () {
                        Navigator.of(context).pushNamed(Routes.MAP_SCREEN);
                      },
                    ),
                  ],
                ),
              ),
              Container(
                margin: const EdgeInsets.symmetric(
                  vertical: 0.0,
                  horizontal: 16.0,
                ),
                height: mediaQuery.size.height * 0.4,
                width: mediaQuery.size.width,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(30),
                  color: Colors.white,
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.5),
                      blurRadius: 4,
                    ),
                  ],
                ),
                //TODO, MAP LOGIC HERE
                child: Center(
                  // child:
                  // Text('map here..'),
                  //use it only when in need avoid unnecessary requests google paise leta hai saala
                  child: HeatMap(),
                ),
              ),
              Padding(
                padding: const EdgeInsets.all(16.0),
                child: Text(
                  'Notifications',
                  style: textTheme.subhead,
                ),
              ),
              Container(
                margin: const EdgeInsets.symmetric(
                  vertical: 0.0,
                  horizontal: 16.0,
                ),
                height: mediaQuery.size.height * 0.3,
                width: mediaQuery.size.width,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(30),
                  color: Colors.white,
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.5),
                      blurRadius: 4,
                    ),
                  ],
                ),
                //TODO, show notifications HERE
                child: Center(
                  child: NotificationPanel(),
                  // Text('notifications here...'),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
