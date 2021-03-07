import 'package:flutter/cupertino.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

class Marker with ChangeNotifier {
  String _authToken;
  String _userId;
  String id;
  Marker previousMarker;

  Marker(this._authToken, this._userId, this.previousMarker);

  Map<String, dynamic> _locationData = {
    'isMoving': true,
    'uuid': '8adad935-a1ac-4c77-b0b6-f1e64507fa45',
    'timestamp': '2021-02-20T05:41:05.130Z',
    'odometer': 27288454,
    'latitude': 37.6216282,
    'longitude': -121.7393319,
    'accuracy': 5,
    'speed': 10.78,
    'heading': 260.64,
    'altitude': 0,
    'activityType': 'still',
    'batteryIsCharging': false,
    'batteryLevel': 1,
  };

  Map<String, dynamic> get locationData {
    return {..._locationData};
  }

  double get lat {
    return _locationData['latitude'];
  }

  double get lng {
    return _locationData['longitude'];
  }

  String url = 'https://location-app---flutter-default-rtdb.firebaseio.com';

  Future<void> updateLocation({
    bool isMoving,
    String uuid,
    String timestamp,
    double odometer,
    double latitude,
    double longitude,
    double accuracy,
    double speed,
    double altitude,
    double heading,
    String activityType,
    bool batteryIsCharging,
    double batteryLevel,
  }) async {
    final getValue = await http
        .get('$url/$_userId/locations/live-location.json?auth=$_authToken');

    Map<String, dynamic> assignValue = {
      'isMoving': isMoving,
      'uuid': uuid,
      'timestamp': timestamp,
      'odometer': odometer,
      'latitude': latitude,
      'longitude': longitude,
      'accuracy': accuracy,
      'speed': speed,
      'altitude': altitude,
      'heading': heading,
      'activityType': activityType,
      'batteryIsCharging': batteryIsCharging,
      'batteryLevel': batteryLevel,
    };

    _locationData.updateAll((id, value) {
      return assignValue[id];
    });

    id = _getId(getValue);

    notifyListeners();

    JsonEncoder encoder = new JsonEncoder.withIndent("     ");

    bool isTrue = _isThere(getValue);

    if (isTrue) {
      _save(id, _authToken);
      return await patchUrl(id, encoder.convert(assignValue));
    } else
      return await postUrl(encoder.convert(assignValue));
  }

  //METHOD
  _save(String _id, String _authToken) async {
    final prefs = await SharedPreferences.getInstance();
    final key = 'location_id';
    final value = _id;
    prefs.setString(key, value);
    prefs.setString('auth_token', _authToken);
    print('saved $value');
  }

  bool _isThere(getValue) {
    if (getValue.body.length <= 7) return false;
    return true;
  }

  String _getId(getValue) {
    String id;

    var jsonValue = json.decode(getValue.body) as Map<String, dynamic>;
    jsonValue.forEach((key, value) {
      id = key;
    });
    return id;
  }

  Future<void> patchUrl(String _id, String assignValue) async {
    try {
      await http
          .patch(
            '$url/$_userId/locations/live-location/$_id.json?auth=$_authToken',
            body: assignValue,
          )
          .then((value) => print(value.reasonPhrase));
    } catch (error) {
      print('error -- $error');
    }
  }

  Future<void> postUrl(String assignValue) async {
    await http.post(
      '$url/$_userId/locations/live-location.json?auth=$_authToken',
      body: assignValue,
    );
  }

  final List searchGetValue = [];
  double lattitudeS;
  double longitudeS;

  double get searchLat {
    return lattitudeS;
  }

  double get searchLng {
    return longitudeS;
  }

  // List get searchValue{
  //   return [...];
  // }

  Future<void> getUrl(String _token, String _userId) async {
    String _keyId;
    final response = await http
        .get('$url/$_userId/locations/live-location.json?auth=$_token');
    Map<String, dynamic> searchResponse =
        json.decode(response.body) as Map<String, dynamic>;
    searchResponse.forEach((key, value) {
      _keyId = key;
    });
    searchResponse = searchResponse[_keyId];
    print(json.decode(response.body));
    print(searchResponse);
    print('id $_keyId');
    if (searchGetValue.length >= 13) searchGetValue.removeRange(0, 13);
    searchResponse.forEach((key, value) {
      searchGetValue.add('${key.toUpperCase()} = $value');
      if (key == 'latitude') lattitudeS = value;
      if (key == 'longitude') longitudeS = value;
    });
    notifyListeners();
    return response;
  }
}
