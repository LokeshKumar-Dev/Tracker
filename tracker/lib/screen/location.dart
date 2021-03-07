import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_background_geolocation/flutter_background_geolocation.dart'
    as bg;
import 'package:location_app/screen/auth_screen/auth_screen-S.dart';
import 'package:provider/provider.dart';
import 'package:clipboard_manager/clipboard_manager.dart';

import '../provider/location_provider.dart';

import 'hereMap_screen.dart';
import '../search_decision.dart';

JsonEncoder encoder = new JsonEncoder.withIndent("     ");

class LocationBg extends StatefulWidget {
  static const routeName = '/LocationBg';
  @override
  _LocationBgState createState() => new _LocationBgState();
}

class _LocationBgState extends State<LocationBg> {
  bool _enabled;
  String _content;
  double lat;
  double lng;

  @override
  void initState() {
    _enabled = true;
    _content = '';
    lat = 0;
    lng = 0;
    _initPlatformState();
  }

  Future<Null> _initPlatformState() async {
    bg.BackgroundGeolocation.onLocation(_onLocation);

    bg.BackgroundGeolocation.ready(bg.Config(
      enableHeadless: true,
      stopOnTerminate: false,
      startOnBoot: true,
      isMoving: true,
    ));

    ///////START
    await bg.BackgroundGeolocation.start();
    await bg.BackgroundGeolocation.changePace(true);
  }

  @override
  void dispose() {
    // TODO: implement dispose
    // bg.BackgroundGeolocation.destroyLocation(uuid)
    bg.BackgroundGeolocation.stop();
    super.dispose();
  }

  void _onClickEnable(enabled) {
    if (enabled) {
      bg.BackgroundGeolocation.start().then((bg.State state) {
        setState(() {
          _enabled = state.enabled;
        });
      });
    } else {
      bg.BackgroundGeolocation.stop().then((bg.State state) {
        // Reset odometer.
        bg.BackgroundGeolocation.setOdometer(0.0);

        setState(() {
          _enabled = state.enabled;
        });
      });
    }
  }

  // Manually fetch the current position.
  void _onClickGetCurrentPosition() {
    bg.BackgroundGeolocation.getCurrentPosition(
            persist: false, // <-- do not persist this location
            desiredAccuracy: 0, // <-- desire best possible accuracy
            timeout: 30000, // <-- wait 30s before giving up.
            samples: 3 // <-- sample 3 location before selecting best.
            )
        .then((bg.Location location) {
      print('[getCurrentPosition] - $location');
    }).catchError((error) {
      print('[getCurrentPosition] ERROR: $error');
    });
  }

  ////
  // Event handlers
  //

  Future<void> _onLocation(bg.Location location) async {
    Provider.of<Marker>(context, listen: false).updateLocation(
      odometer: location.odometer,
      accuracy: location.coords.accuracy,
      altitude: location.coords.altitude,
      heading: location.coords.heading,
      batteryIsCharging: location.battery.isCharging,
      latitude: location.coords.latitude,
      batteryLevel: location.battery.level,
      longitude: location.coords.longitude,
      speed: location.coords.speed,
      activityType: location.activity.type,
      uuid: location.uuid,
      timestamp: location.timestamp,
      isMoving: location.isMoving,
    );

    if (mounted)
      setState(() {
        _content =
            "ODOMETER = ${location.odometer},\nACCURACY = ${location.coords.accuracy},\nALTITUDE = ${location.coords.altitude},\nHeading = ${location.coords.heading},\nBATTERY IS CHARGING = ${location.battery.isCharging},\nLATITUDE = ${location.coords.latitude},\nBATTERY LEVEL = ${location.battery.level},\nLONGITUDE = ${location.coords.longitude},\nSPEED = ${location.coords.speed},\nACTIVITY TYPE = ${location.activity.type},\nUUID = ${location.uuid},\nTIME STAMP = ${location.timestamp},\nIS MOVING = ${location.isMoving},\n";
        lat = location.coords.latitude;
        lng = location.coords.longitude;
      });
  }

  @override
  Widget build(BuildContext context) {
    final deviceSize = MediaQuery.of(context).size;
    print('location scren');
    return Scaffold(
      backgroundColor: Theme.of(context).backgroundColor,
      appBar: AppBar(
          title: const Text(
            'Geolocation Console',
            style: TextStyle(fontWeight: FontWeight.w700),
          ),
          actions: <Widget>[
            Switch(
              value: _enabled,
              onChanged: _onClickEnable,
              activeColor: Color.fromRGBO(34, 40, 49, 1),
              inactiveThumbColor: Color.fromRGBO(34, 40, 49, .4),
            ),
            IconButton(
                icon: Icon(Icons.copy_outlined),
                onPressed: () {
                  ClipboardManager.copyToClipBoard('$lat $lng').then((result) {
                    final snackBar = SnackBar(
                      content: Text(
                        'Copied to Clipboard',
                        style: TextStyle(color: Colors.grey[200]),
                        textAlign: TextAlign.center,
                      ),
                      backgroundColor: Color.fromRGBO(242, 163, 101, 1),
                    );
                    Scaffold.of(context).showSnackBar(snackBar);
                  });
                }),
            IconButton(
                icon: Icon(Icons.add),
                onPressed: () {
                  Navigator.of(context).pushNamed(AuthScreenSignin.routeName);
                })
          ]),
      body: SingleChildScrollView(
        child: Container(
          margin: EdgeInsets.symmetric(horizontal: 8),
          height: deviceSize.height - 100,
          child: Center(
            child: _content != null
                ? Text(
                    '$_content',
                    style: Theme.of(context).textTheme.headline6,
                  )
                : CircularProgressIndicator(),
          ),
        ),
      ),
      bottomNavigationBar: BottomAppBar(
          color: Theme.of(context).cardColor,
          child: Container(
              padding: const EdgeInsets.only(left: 5.0, right: 5.0),
              child: Row(
                  mainAxisSize: MainAxisSize.max,
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: <Widget>[
                    IconButton(
                      icon: Icon(Icons.gps_fixed),
                      onPressed: _onClickGetCurrentPosition,
                    ),
                    IconButton(
                      icon: Icon(
                        Icons.search,
                        size: 29,
                      ),
                      onPressed: () {
                        Navigator.of(context).pushNamed(SearchScreen.routeName);
                      },
                    ),
                    IconButton(
                      icon: Icon(Icons.location_on),
                      onPressed: () {
                        Navigator.of(context).pushNamed(HereMapLive.routeName,
                            arguments: <String, double>{
                              'lat': lat,
                              'lng': lng
                            });
                      },
                    ),
                  ]))),
    );
  }
}
