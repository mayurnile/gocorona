import 'package:flutter/material.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:provider/provider.dart';

import '../providers/auth.dart';

class MessageScreen extends StatefulWidget {
  @override
  _MessageScreenState createState() => _MessageScreenState();
}

class _MessageScreenState extends State<MessageScreen> {
  final databaseReference = FirebaseDatabase.instance.reference();
  int yes = 1;
  @override
  void initState() {
    super.initState();
  }

  @override
  void didUpdateWidget(MessageScreen oldWidget) {
   
    super.didUpdateWidget(oldWidget);
  }

  @override
  Widget build(BuildContext context) {
    final mediaQuery = MediaQuery.of(context);
    final textTheme = Theme.of(context).textTheme;
    bool  isCorona = Provider.of<Auth>(context).isCoronaOne;
    //askPatient(context);
    final alertDialog = AlertDialog(
      title: Text(
        'Are You a Corona Patient ?',
        style: textTheme.button.copyWith(
          color: Colors.black.withOpacity(0.8),
        ),
      ),
      content: Text(
        'Please be honest to help save others life too...',
        style: textTheme.body1,
      ),
      actions: <Widget>[
        FlatButton(
          onPressed: () async {
            await Provider.of<Auth>(context).setCoronaOne(true);
            setState(() {
              isCorona = true;
            });
            //Navigator.of(context).pop();
          },
          child: Text('YES'),
        ),
        FlatButton(
          onPressed: () async {
            await Provider.of<Auth>(context).setCoronaOne(false);
            //Navigator.of(context).pop();
            setState(() {
              isCorona = false;
            });
          },
          child: Text('NO'),
        ),
      ],
    );

    print('onbuild : $isCorona');
    return Container(
      height: mediaQuery.size.height,
      width: mediaQuery.size.width,
      child: Stack(
        children: <Widget>[
          Align(
            alignment: Alignment.center,
            child: Text('something here...'),
          ),
          isCorona == null ? alertDialog : SizedBox.shrink(),
        ],
      ),
    );
  }
}
