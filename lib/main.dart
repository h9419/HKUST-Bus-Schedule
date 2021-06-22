import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/services.dart';
import 'package:http/http.dart' as http;
import 'package:timer_builder/timer_builder.dart';

import 'customWidgets.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  SystemChrome.setPreferredOrientations(
      [DeviceOrientation.portraitUp, DeviceOrientation.portraitDown]);
  SystemChrome.setEnabledSystemUIOverlays(SystemUiOverlay.values);
  SystemChrome.setSystemUIOverlayStyle(SystemUiOverlayStyle(
    statusBarColor: Colors.grey[900],
    // For Android.
    // Use [light] for white status bar and [dark] for black status bar.
    statusBarIconBrightness: Brightness.light,
    // For iOS.
    // Use [dark] for white status bar and [light] for black status bar.
    statusBarBrightness: Brightness.dark,
  ));
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Bus Schedule',
      theme: ThemeData(
        primarySwatch: Colors.grey,
        accentColor: Colors.grey,
        brightness: Brightness.dark,
      ),
      debugShowCheckedModeBanner: false,
      home: MyHomePage(title: 'Bus Schedule'),
    );
  }
}

class MyHomePage extends StatefulWidget {
  MyHomePage({Key? key, required this.title}) : super(key: key);

  final String title;

  @override
  _MyHomePageState createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> with WidgetsBindingObserver {
  List<dynamic> hkust_north_buses = [];
  List<dynamic> hkust_south_buses = [];

  int sortingETA(a, b) {
    final timeA = a["eta"] == null
        ? DateTime.now().subtract(Duration(minutes: 10))
        : DateTime.parse(a["eta"]);
    final timeB = b["eta"] == null
        ? DateTime.now().subtract(Duration(minutes: 10))
        : DateTime.parse(b["eta"]);
    return timeA.difference(timeB).inSeconds;
  }

  Future<void> getNorthBuses() async {
    hkust_north_buses.clear();
    http
        .get(Uri.parse(
            'https://data.etabus.gov.hk/v1/transport/kmb/stop-eta/B3E60EE895DBBF06'))
        // 'https://data.etabus.gov.hk/v1/transport/kmb/eta/B002CEF0DBC568F5/91M/1'
        .then((value) => {
              setState(() {
                hkust_north_buses += jsonDecode(value.body)["data"].toList();
                hkust_north_buses.sort(sortingETA);
              })
            });
    http
        .get(Uri.parse(
            'https://data.etabus.gov.hk/v1/transport/kmb/stop-eta/3592A0182BF020C7'))
        .then((value) => {
              setState(() {
                hkust_north_buses += jsonDecode(value.body)["data"].toList();
                hkust_north_buses.sort(sortingETA);
              })
            });
    http
        .get(Uri.parse(
            'https://data.etabus.gov.hk/v1/transport/kmb/stop-eta/C1AAFE0EB8BD89C7'))
        .then((value) => {
              setState(() {
                hkust_north_buses += jsonDecode(value.body)["data"].toList();
                hkust_north_buses.sort(sortingETA);
              })
            });
  }

  Future<void> getSouthBuses() async {
    hkust_south_buses.clear();
    http
        .get(Uri.parse(
            'https://data.etabus.gov.hk/v1/transport/kmb/stop-eta/B002CEF0DBC568F5'))
        .then((value) => {
              setState(() {
                hkust_south_buses += jsonDecode(value.body)["data"].toList();
                hkust_south_buses.sort(sortingETA);
              })
            });
    http
        .get(Uri.parse(
            'https://data.etabus.gov.hk/v1/transport/kmb/stop-eta/E9018F8A7E096544'))
        .then((value) => {
              setState(() {
                hkust_south_buses += jsonDecode(value.body)["data"].toList();
                hkust_south_buses.sort(sortingETA);
              })
            });
  }

  void _refresh() {
    getNorthBuses();
    getSouthBuses();
  }

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance?.addObserver(this);
    Future.delayed(Duration.zero, () {
      _refresh();
    });
  }

  @override
  void dispose() {
    WidgetsBinding.instance?.removeObserver(this);
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(final AppLifecycleState state) {
    if (state == AppLifecycleState.resumed) {
      _refresh();
    }
  }

  @override
  Widget build(BuildContext context) {
    const customColumnWidths = {
      0: FlexColumnWidth(3),
      1: FlexColumnWidth(6),
      2: FlexColumnWidth(4),
      3: FlexColumnWidth(4),
    };
    return TimerBuilder.periodic(
      Duration(seconds: 10),
      builder: (context) {
        return Scaffold(
          // appBar: AppBar(
          //   title: Text(widget.title),
          // ),
          body: SafeArea(
            child: DefaultTextStyle(
              style: TextStyle(fontSize: 16),
              child: RefreshIndicator(
                onRefresh: () async {
                  _refresh();
                  // await Future.delayed(Duration(milliseconds: 100));
                },
                child: ListView(
                  children: [
                    [hkust_north_buses, "HKUST (North)"],
                    [hkust_south_buses, "HKUST (South)"],
                  ].map((buses) {
                    return Column(
                      children: [
                        (buses[0] as List<dynamic>).isEmpty
                            ? Container()
                            : CustomBanner(buses[1].toString()),
                        Table(
                          defaultVerticalAlignment:
                              TableCellVerticalAlignment.middle,
                          columnWidths: customColumnWidths,
                          children: (buses[0] as List<dynamic>).map((entry) {
                            if (entry["service_type"] == 1)
                              return ETACard(entry["route"], entry["eta"],
                                  entry["rmk_en"]);
                            return TableRow(children: [
                              TableCell(child: Container()),
                              TableCell(child: Container()),
                              TableCell(child: Container()),
                              TableCell(child: Container())
                            ]);
                          }).toList(),
                        ),
                      ],
                    );
                  }).toList(),
                ),
              ),
            ),
          ),
          // floatingActionButton: FloatingActionButton(
          //   onPressed: _refresh,
          //   tooltip: 'Refresh',
          //   child: Icon(Icons.refresh),
          // ), // This trailing comma makes auto-formatting nicer for build methods.
        );
      },
    );
  }
}
