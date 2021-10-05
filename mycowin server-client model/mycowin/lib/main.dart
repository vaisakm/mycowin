import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'dart:async';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:flutter_ringtone_player/flutter_ringtone_player.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
// FILES
import 'sessiondetailscreen.dart';
import 'package:mycowin2/lastcentersdetailscreen.dart';

// <<< Update your app-server address in this file at line "final response = await http
//        .get(Uri.parse('SERVER_ADDRESS_HERE')) >>>

class Album {
  final List centers;
  final String error;
  final bool status;
  final bool notify;
  final int sessionCount;
  final String lastUpdated;
  final String lastFetched;

  Album({
    required this.status,
    required this.error,
    required this.notify,
    required this.sessionCount,
    required this.lastFetched,
    required this.lastUpdated,
    required this.centers,
  });

  factory Album.fromJson(Map<String, dynamic> json) {
    return Album(
      status: json['status'] ?? false,
      error: json['error'] ?? 'Unknown error',
      notify: json['notify'] ?? false,
      sessionCount: json['session_count'] ?? 0,
      lastFetched: json['last_fetched'] ?? '',
      lastUpdated: json['last_updated'] ?? '',
      centers: json['centers'] ?? [],
    );
  }
}

Future<Album> fetchAlbum({required int timeout}) async {
  try {
    final response = await http
        .get(Uri.parse('SERVER_ADDRESS_HERE'))
        .timeout(Duration(seconds: timeout),
            onTimeout: () => http.Response('Error', 500));

    if (response.statusCode == 200) {
      // If the server did return a 200 OK response,
      // then parse the JSON.
      return Album.fromJson(jsonDecode(response.body));
    } else {
      if (response.statusCode == 500) {
        // If the server did return the above set timeout response,
        // then parse the JSON.
        Map<String, dynamic> dict = {
          'status': false,
          'error': 'Request Timeout!',
          'notify': false,
          'session_count': 0,
          'last_fetched': "",
          'last_updated': "",
          'centers': [],
        };
        return Album.fromJson(dict);
      } else {
        // If the server did not return a 200 OK (//or 500 timeout) response,
        // then parse the JSON.
        Map<String, dynamic> dict = {
          'status': false,
          'error':
              'Bad response from intermediary. Error ${response.statusCode}!',
          'notify': false,
          'session_count': 0,
          'last_fetched': "",
          'last_updated': "",
          'centers': [],
        };
        return Album.fromJson(dict);
      }
    }
  } catch (err) {
    Map<String, dynamic> dict = {
      'status': false,
      'error': 'No connection!',
      'notify': false,
      'session_count': 0,
      'last_fetched': "",
      'last_updated': "",
      'centers': [],
    };
    return Album.fromJson(dict);
  }
}



/*
Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized(); // because, local notifications.
  runApp(MyApp());
}
*/

void main() {
  WidgetsFlutterBinding.ensureInitialized(); // because, local notifications.
  runApp(MyApp());
}



class MyApp extends StatelessWidget {
  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'My Cowin', //used on: @android in task manger/recent apps, @web as tab title, @some desktop window title, @some desktop task switchers
      theme: ThemeData(
        primarySwatch: Colors.lightGreen,
        //colorScheme: ColorScheme.fromSwatch(
        //primarySwatch: Colors.green, accentColor: Colors.lightGreen),
        primaryColor: Colors.lightGreen.shade400,
        textTheme: Typography.blackHelsinki.copyWith(
          bodyText1: Typography.blackHelsinki.bodyText1!.copyWith(
            fontSize: 16,
          ),
          bodyText2: Typography.blackHelsinki.bodyText2!.copyWith(
            fontSize: 16,
          ),
        ),
      ),
      home: MyHomePage(title: 'My Cowin'),
    );
  }
}

class MyHomePage extends StatefulWidget {
  MyHomePage({Key? key, required this.title}) : super(key: key);

  // This widget is the home page of your application. It is stateful, meaning
  // that it has a State object (defined below) that contains fields that affect
  // how it looks.

  // This class is the configuration for the state. It holds the values (in this
  // case the title) provided by the parent (in this case the App widget) and
  // used by the build method of the State. Fields in a Widget subclass are
  // always marked "final".

  final String title;

  @override
  _MyHomePageState createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  //
  static var flutterLocalNotificationsPlugin;

  @override
  void initState() {
    //
    super.initState();
    final AndroidInitializationSettings androidInitializationSettings =
        AndroidInitializationSettings('app_icon');

    /*final IOSInitializationSettings iosInitializationSettings =
      IOSInitializationSettings(
    requestSoundPermission: true,
    requestBadgePermission: true,
    requestAlertPermission: true,
    onDidReceiveLocalNotification: onDidReceiveLocalNotification,
    );*/

    final InitializationSettings initializationSettings =
        InitializationSettings(
      android: androidInitializationSettings,
      //iOS: iOSInitializationSettings
    );

    flutterLocalNotificationsPlugin = FlutterLocalNotificationsPlugin();
    flutterLocalNotificationsPlugin.initialize(
      initializationSettings,
      onSelectNotification: onNotificationSelected,
    );
  }

  Future onNotificationSelected(String? payload) async {}

  Future instantNotification(int? sessionCount) async {
    //
    const AndroidNotificationDetails androidNotificationDetails =
        AndroidNotificationDetails(
            'vaccine_alerts', //channelId: String,   //Required for Android 8.0 or after
            'Vaccine alerts', //channelName: String, //Required for Android 8.0 or after
            'Sends subscribed alert events', //channelDescription: String, //Required for Android 8.0 or after
            importance: Importance.high,
            largeIcon: DrawableResourceAndroidBitmap('app_icon'),
            color: Colors.lightGreen,
            usesChronometer: true,
            priority: Priority.high);

    /*const IOSNotificationDetails iosNotificationDetails =
      IosNotificationDetails();*/

    const NotificationDetails notificationDetails = NotificationDetails(
      android: androidNotificationDetails,
      //iOS: iOSNotificationDetails,
    );

    await flutterLocalNotificationsPlugin.show(
      0,
      "Vaccine available",
      "Found ${sessionCount ?? 0} sessions of your choice",
      notificationDetails,
      payload: "Clicked notification",
    );
  }

  Future stylishNotification(int? sessionCount) async {
    //
    const AndroidNotificationDetails androidNotificationDetails =
        AndroidNotificationDetails(
      'vaccine_alerts', //channelId: String,   //Required for Android 8.0 or after
      'Vaccine alerts', //channelName: String, //Required for Android 8.0 or after
      'Sends subscribed alert events', //channelDescription: String, //Required for Android 8.0 or after
      importance: Importance.high,
      priority: Priority.high,
      color: Colors.lightGreen,
      enableLights: true,
      enableVibration: true,
      usesChronometer: true,
      largeIcon: DrawableResourceAndroidBitmap('app_icon'),
      styleInformation: MediaStyleInformation(
        htmlFormatContent: true,
        htmlFormatTitle: true,
      ),
    );

    /*const IOSNotificationDetails iosNotificationDetails =
    IosNotificationDetails();*/

    const NotificationDetails notificationDetails = NotificationDetails(
      android: androidNotificationDetails,
      //iOS: iOSNotificationDetails,
    );

    await flutterLocalNotificationsPlugin.show(
      1,
      "Vaccine available",
      "Found ${sessionCount ?? 0} sessions of your choice",
      notificationDetails,
    );
  }

  Future cancelNotification() async {
    await flutterLocalNotificationsPlugin.cancelAll();
  }

  List centers = [];
  List lastCenters = [];
  bool? status;
  bool? notify;
  String error = "";
  String lastFetched = "";
  String lastUpdated = "";
  int? sessionCount;
  TextEditingController intervalController = TextEditingController();
  Timer? _timer;
  int currentAttemptCount = 0,
      totalResponseCount = 0,
      totalFailCount = 0,
      hitCount = 0;

  int intervalGiven = 30, intervalShown = 30;
  void setintervalGiven(int x) {
    (x >= 10)
        ? setState(() {
            intervalGiven = x;
            intervalController.text = '$x';
          })
        : setState(() {
            intervalGiven = 10;
            intervalController.text = '$intervalGiven';
          });
  }

  bool timerActiveBool = false;
  bool alarmPlaying = false;

  void setTimerCount() {
    //function without setState call
    if (_timer == null) {
      timerActiveBool = false;
      currentAttemptCount = 0;
    } else {
      timerActiveBool = _timer!.isActive;
      currentAttemptCount = _timer!.tick + 1;
    }
  }

  void starttimer() {
    _timer?.cancel();
    if (centers.isNotEmpty) {
      lastCenters = centers;
      centers = [];
    } else {
      lastCenters = [];
    }
    setState(() {
      status = null;
      notify = null;
      error = "";
      sessionCount = null;
      timerActiveBool = true;
      currentAttemptCount = 1;
      intervalShown = intervalGiven;
    });
    _displayResult();
    _timer = Timer.periodic(Duration(seconds: intervalShown), (Timer _t) {
      if (!timerActiveBool)
        stoptimer();
      else {
        setState(() {
          setTimerCount();
        });
        _displayResult();
      }
    });
  }

  void stoptimer() {
    setState(() {
      timerActiveBool = false;
      _timer?.cancel();
    });
  }

  void stopringtone() {
    try {
      FlutterRingtonePlayer.stop();
      setState(() {
        alarmPlaying = false;
      });
    } catch (err) {
      setState(() {
        alarmPlaying = false;
      });
    }
  }

  void _displayResult() {
    fetchAlbum(timeout: 20).then((result) {
      status = result.status;
      result.status ? totalResponseCount++ : totalFailCount++;
      notify = result.notify;
      error = result.error;
      sessionCount = result.sessionCount;
      if (result.sessionCount > 0) {
        hitCount++;
        lastCenters = centers = result.centers;
      } else {
        centers = result.centers;
      }
      if (result.lastFetched.isNotEmpty) lastFetched = result.lastFetched;
      if (result.lastUpdated.isNotEmpty) lastUpdated = result.lastUpdated;

      if (notify == true) {
        FlutterRingtonePlayer.playRingtone(looping: false, asAlarm: true);
        alarmPlaying = true;

        stylishNotification(sessionCount);
      }
      setState(() {});
    });
  }

  /*@override
  void dispose() {
    if (_timer != null) {
      _timer!.cancel();
      super.dispose();
    }
  }*/

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
          // Here we take the value from the MyHomePage object that was created by
          // the App.build method, and use it to set our appbar title.
          title: timerActiveBool
              ? Row(
                  children: [Text(widget.title), Icon(Icons.sensors_outlined)])
              : Text(widget.title)),
      body: Padding(
        padding: EdgeInsets.symmetric(vertical: 10, horizontal: 10),
        child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: <Widget>[
              TextFormField(
                  controller: intervalController,
                  keyboardType: TextInputType.number,
                  inputFormatters: <TextInputFormatter>[
                    FilteringTextInputFormatter.allow(RegExp(r'[0-9]')),
                  ],
                  //onChanged: (newText) { if (newText != "") setintervalGiven(int.parse(newText)); },
                  onSaved: (newText) {
                    if (newText?.isNotEmpty == true)
                      setintervalGiven(int.parse(newText!));
                  },
                  onFieldSubmitted: (newText) {
                    if (newText.isNotEmpty)
                      setintervalGiven(int.parse(newText));
                  },
                  decoration: InputDecoration(
                      labelText: "Search interval (seconds)",
                      hintText: "$intervalGiven ( Reccommended: 180)",
                      icon: Icon(Icons.sensors_rounded))),
              Padding(padding: EdgeInsets.symmetric(vertical: 5)),
              Row(crossAxisAlignment: CrossAxisAlignment.start, children: <
                  Widget>[
                timerActiveBool
                    ? OutlinedButton(
                        style: ButtonStyle(
                          foregroundColor: MaterialStateProperty.all<Color>(
                              Colors.red[500]!),
                        ),
                        onPressed: stoptimer,
                        child: Text('Stop search'),
                      )
                    : OutlinedButton(
                        style: ButtonStyle(
                          foregroundColor: MaterialStateProperty.all<Color>(
                              Colors.red[100]!),
                        ),
                        onPressed: null,
                        child: Text('Stop search'),
                      ),
                Padding(
                  padding: EdgeInsets.symmetric(horizontal: 10),
                  child: alarmPlaying
                      ? OutlinedButton(
                          style: ButtonStyle(
                            foregroundColor: MaterialStateProperty.all<Color>(
                                Colors.orange[500]!),
                          ),
                          onPressed: stopringtone,
                          child: Text('Stop Alarm'),
                        )
                      : OutlinedButton(
                          style: ButtonStyle(
                            foregroundColor: MaterialStateProperty.all<Color>(
                                Colors.orange[100]!),
                          ),
                          onPressed: null,
                          child: Text('Stop Alarm'),
                        ),
                ),
                OutlinedButton(
                  style: ButtonStyle(
                    foregroundColor:
                        MaterialStateProperty.all<Color>(Colors.green[500]!),
                  ),
                  onPressed: () {
                    setState(() {
                      totalResponseCount = totalFailCount = 0;
                    });
                  },
                  child: Text('Reset stats'),
                ),
              ]),
              /*Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[]),*/
              Padding(padding: EdgeInsets.only(top: 10)),
              Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: <Widget>[
                  Text(
                    'Auto Search: ${timerActiveBool ? "ON    Attempt count: $currentAttemptCount" : "OFF    Last run count: $currentAttemptCount"}\n' +
                        'Response/Fails: $totalResponseCount / $totalFailCount    Hits :$hitCount\n' +
                        '''Check interval: ${(!timerActiveBool || intervalGiven == intervalShown) ? "$intervalGiven seconds" : "$intervalShown seconds ($intervalGiven after restart)"}\n''' +
                        'STATUS: ${status ?? ""}    Notify: ${notify ?? ""}\n' +
                        'Feedback: $error\n' +
                        'Last Updated: $lastUpdated\n' +
                        'Last Fetched: $lastFetched\n' +
                        ' - - - - - ',
                  ),
                  Text(
                    'Matching vaccination sessions: ${sessionCount ?? ""}\n' +
                        'Available centers: ${centers.isNotEmpty ? '' : 'None'}',
                  ),
                  Padding(padding: EdgeInsets.only(top: 10)),
                  centers.isNotEmpty
                      ? Container(
                          constraints:
                              BoxConstraints(minHeight: 250, maxHeight: 250),
                          decoration: BoxDecoration(
                            //borderRadius: BorderRadius.circular(5),
                            border: Border(
                              top: BorderSide(
                                  width: 2.0,
                                  color: Colors.lightGreen.shade500),
                              left: BorderSide(
                                  width: 1.0,
                                  color: Colors.lightGreen.shade900),
                              right: BorderSide(
                                  width: 2.0,
                                  color: Colors.lightGreen.shade500),
                              bottom: BorderSide(
                                  width: 1.0,
                                  color: Colors.lightGreen.shade900),
                            ),
                          ),
                          child: ListView.builder(
                            shrinkWrap: false,
                            scrollDirection: Axis.vertical,
                            itemCount: centers.length,
                            itemExtent: 60,
                            itemBuilder: (context, index) {
                              return Container(
                                constraints:
                                    BoxConstraints.loose(Size(double.infinity, 60)),
                                decoration: BoxDecoration(
                                  gradient: LinearGradient(
                                    begin: Alignment.topCenter,
                                    end: Alignment.bottomCenter,
                                    colors: [
                                      Colors.lightGreen.shade100,
                                      Colors.white,
                                      Colors.lightGreen.shade50
                                    ],
                                  ),
                                ),
                                child: ListTile(
                                  //onTap: null,
                                  hoverColor: Colors.green,
                                  selectedTileColor: Colors.lightGreen,
                                  title: Text(
                                    centers[index]['center'],
                                    style:
                                        Theme.of(context).textTheme.bodyText1,
                                  ),
                                  subtitle: Text(
                                    "${centers[index]['date']}" +
                                        " dose 1: ${centers[index]['available_capacity_dose1']}" +
                                        " dose 2: ${centers[index]['available_capacity_dose2']}",
                                    style:
                                        Theme.of(context).textTheme.bodyText2,
                                  ),
                                  onTap: () {
                                    Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                        builder: (context) => DetailScreen(
                                            session: centers[index]),
                                      ),
                                    );
                                  },
                                ),
                              );
                            },
                          ),
                        )
                      : lastCenters.isNotEmpty
                          ? SingleChildScrollView(
                              child: Column(
                                children: [
                                  Text(' - - - - - '),
                                  ListTile(
                                    tileColor: CupertinoColors.inactiveGray,
                                    leading: Text('Was available earlier: '),
                                    title:
                                        Text('${lastCenters.length} centers '),
                                    trailing: Icon(
                                      Icons.arrow_right,
                                      color: Colors.blueGrey,
                                      size: 20,
                                    ),
                                    onTap: () => Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                        builder: (context) => LastCentersScreen(
                                            lastCenters: lastCenters),
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            )
                          : Text(''),
                ],
              )
            ]),
      ),
      floatingActionButton: FloatingActionButton(
          backgroundColor: Colors.white54,
          foregroundColor: Colors.black87,
          onPressed: starttimer,
          tooltip: 'Start',
          child: Icon(
            Icons.find_in_page_sharp,
            size: 35,
          )), // This trailing comma makes auto-formatting nicer for build methods.
    );
  }
}
