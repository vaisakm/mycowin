import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class DetailScreen extends StatelessWidget {
  // In the constructor, require an object.
  const DetailScreen({Key? key, required this.session}) : super(key: key);

  // Declare a field that holds the passed object.
  final session;

  @override
  Widget build(BuildContext context) {
    // Use the object to create the UI.
    return Scaffold(
      appBar: PreferredSize(
        preferredSize: Size.fromHeight(80),
        child: AppBar(
          toolbarHeight: 80,
          backgroundColor: Colors.white,
          title: Wrap(
            spacing: 7,
            runSpacing: 7,
            direction: Axis.vertical,
            alignment: WrapAlignment.end,
            runAlignment: WrapAlignment.end,
            crossAxisAlignment: WrapCrossAlignment.start,
            children: [
              Padding(
                padding: EdgeInsets.only(top: 10),
              ),
              Text(
                session['center'],
                style: Theme.of(context).textTheme.bodyText1?.copyWith(
                      color: Colors.lightGreen,
                      fontSize: 20,
                    ),
              ),
              Text(
                session['date'],
                style: Theme.of(context).textTheme.bodyText1,
              ),
            ],
          ),
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: ListView(
          scrollDirection: Axis.vertical,
          children: getWidgets(),
        ),
      ),
    );
  }

  List<Widget> getWidgets() {
    List<Widget> temp = [];
    session.forEach((k, v) => temp.add(ListTile(
          dense: false,
          tileColor: CupertinoColors.extraLightBackgroundGray,
          hoverColor: Colors.green,
          selectedTileColor: Colors.blue,
          minLeadingWidth: 100,
          horizontalTitleGap: 20,
          shape: Border(
            top: BorderSide(color: Colors.amberAccent),
            left: BorderSide(color: Colors.amberAccent),
          ),
          leading: Text(k),
          title: Text(v.toString()),
        )));
    return temp;
  }
}
