import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:here_sdk/core.dart';
import 'package:http/http.dart' as http;
import 'package:flutter_background_geolocation/flutter_background_geolocation.dart'
    as bg;

import 'provider/location_provider.dart';

import 'screen/location.dart';
import 'screen/hereMap_screen.dart';
import 'search_decision.dart';

//Auth
import 'screen/auth_screen/auth_screen-L.dart';
import 'screen/auth_screen/auth_screen-S.dart';
import 'provider/auth_provider.dart';

import 'package:shared_preferences/shared_preferences.dart';

void headlessTask(bg.HeadlessEvent headlessEvent) async {
  String url = 'https://location-app---flutter-default-rtdb.firebaseio.com/';

  final prefs = await SharedPreferences.getInstance();
  final String userId = prefs.getString('user_id') ?? 0;
  final String locationId = prefs.getString('location_id') ?? 0;
  final String authToken = prefs.getString('auth_token') ?? 0;
  //METHOD
  bool _isThere(getValue) {
    if (getValue.body.length <= 7) return false;
    return true;
  }

  Future<void> patchUrl(String _id, String assignValue) async {
    try {
      await http
          .patch(
            '$url/$userId/locations/live-location/$_id.json?auth=$authToken',
            body: assignValue,
          )
          .then((value) => print(value.body));
    } catch (error) {
      print('error -- $error');
    }
  }

  Future<void> postUrl(String assignValue) async {
    await http.post(
      '$url/$userId/locations/live-location.json?auth=$authToken',
      body: assignValue,
    );
  }

  // Implement a 'case' for only those events you're interested in.
  switch (headlessEvent.name) {
    case bg.Event.TERMINATE:
      bg.State state = headlessEvent.event;
      break;
    case bg.Event.LOCATION:
      bg.Location location = headlessEvent.event;

      Map<String, dynamic> assignValue = {
        'odometer': location.odometer,
        'accuracy': location.coords.accuracy,
        'altitude': location.coords.altitude,
        'heading': location.coords.heading,
        'batteryIsCharging': location.battery.isCharging,
        'latitude': location.coords.latitude,
        'batteryLevel': location.battery.level,
        'longitude': location.coords.longitude,
        'speed': location.coords.speed,
        'activityType': location.activity.type,
        'uuid': location.uuid,
        'timestamp': location.timestamp,
        'isMoving': location.isMoving,
      };

      if (userId != null) {
        return await patchUrl(locationId, encoder.convert(assignValue));
      } else
        return await postUrl(encoder.convert(assignValue));
      break;
    case bg.Event.MOTIONCHANGE:
      bg.Location location = headlessEvent.event;
      print('- Location: $location');
      break;
  }
}

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  SdkContext.init(IsolateOrigin.main);
  await Firebase.initializeApp();
  runApp(MyApp());
  bg.BackgroundGeolocation.registerHeadlessTask(headlessTask);
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider.value(
      value: Auth(),
      child: ChangeNotifierProxyProvider<Auth, Marker>(
        create: (ctx) => Marker(null, null, null),
        update: (ctx, auth, previousMarker) =>
            Marker(auth.token, auth.userId, previousMarker),
        child: Consumer<Auth>(
          builder: (ctx, auth, _) => MaterialApp(
            title: 'Location App',
            theme: ThemeData(
              primaryColor: Colors.grey[200],
              backgroundColor: Color.fromRGBO(34, 40, 49, 1),
              cardColor: Color.fromRGBO(242, 163, 101, 1),
              appBarTheme: AppBarTheme(
                color: Color.fromRGBO(242, 163, 101, 1),
              ),
              floatingActionButtonTheme: FloatingActionButtonThemeData(
                backgroundColor: Color.fromRGBO(242, 163, 101, 1),
                foregroundColor: Color.fromRGBO(34, 40, 49, 1),
              ),
              textTheme: TextTheme(
                headline1:
                    TextStyle(fontSize: 35.0, fontWeight: FontWeight.bold),
                headline3: TextStyle(
                  fontSize: 30.0,
                  fontWeight: FontWeight.w600,
                  color: Colors.grey[200],
                ),
                headline6: TextStyle(fontSize: 25.0, color: Colors.grey[300]),
                bodyText2: TextStyle(fontSize: 14.0, fontFamily: 'Hind'),
              ),
            ),
            // home: SearchResultScreen(),
            home: auth.isAuth ? LocationBg() : AuthScreenLogin(false),
            routes: {
              SearchScreen.routeName: (ctx) => SearchScreen(),
              HereMapLive.routeName: (ctx) => HereMapLive(),
              AuthScreenLogin.routeName: (ctx) => AuthScreenLogin(false),
              AuthScreenSignin.routeName: (ctx) => AuthScreenSignin(),
            },
          ),
        ),
      ),
    );
  }
}
//34, 40, 49 darkblue
// 48, 71, 94 darkblue - lite
// 242, 163, 101 yellow
