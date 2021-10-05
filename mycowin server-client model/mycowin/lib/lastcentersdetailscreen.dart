import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class LastCentersScreen extends StatelessWidget {
  // In the constructor, require an object.
  const LastCentersScreen({Key? key, required this.lastCenters})
      : super(key: key);

  // Declare a field that holds the passed object.
  final lastCenters;

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
                'Was available earlier here:',
                style: Theme.of(context).textTheme.bodyText1?.copyWith(
                      color: Colors.blueGrey,
                      fontSize: 20,
                    ),
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
    lastCenters.forEach((session) => temp.add(
          ListTile(
            dense: false,
            tileColor: CupertinoColors.lightBackgroundGray,
            hoverColor: Colors.green,
            selectedTileColor: Colors.blue,
            shape: Border(
              top: BorderSide(color: Colors.blueGrey),
              left: BorderSide(color: Colors.blueGrey),
            ),
            title: Text(
              session['center'],
              //style: Theme.of(context).textTheme.bodyText1,
            ),
            subtitle: Text(
              "${session['date']}" +
                  " dose 1: ${session['available_capacity_dose1']}" +
                  " dose 2: ${session['available_capacity_dose2']}",
              //style: Theme.of(context).textTheme.bodyText2,
            ),
          ),
        ));
    return temp;
  }
}
