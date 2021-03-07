import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:here_sdk/mapview.dart';
import 'package:here_sdk/core.dart';
import 'package:flutter/services.dart' show rootBundle;

class HereMapLive extends StatefulWidget {
  static const routeName = '/HereMapLive';

  @override
  _HereMapLiveState createState() => _HereMapLiveState();
}

class _HereMapLiveState extends State<HereMapLive> {
  GeoCoordinates geoCoordinates = new GeoCoordinates(12, -121);

  @override
  void dispose() {
    // TODO: implement dispose
    super.dispose();
    geoCoordinates = null;
  }

  void _updateLocation(Map<String, double> obj) {
    double lat;
    double lng;
    if (obj == null) {
      return;
    }
    obj.forEach((key, value) => key == 'lat' ? lat = value : lng = value);

    setState(() {
      geoCoordinates = new GeoCoordinates(lat, lng);
    });
    print('obj == $obj');
    print('geoCoordinates $geoCoordinates $lat, $lng');
  }

  @override
  Widget build(BuildContext context) {
    final Map<String, double> obj = ModalRoute.of(context).settings.arguments;
    _updateLocation(obj);

    return Scaffold(
      appBar: AppBar(
        title: Text('Static Map'),
      ),
      body: obj == null
          ? HereMap(
              onMapCreated: _onMapCreated,
            )
          : HereMap(
              onMapCreated: _onMapCreated,
            ),
    );
  }

  Future<void> _onMapCreated(HereMapController hereMapController) async {
    print('geoCoordinates -- $geoCoordinates ${geoCoordinates.latitude}');
    MapImage _circleMapImage;
    if (_circleMapImage == null) {
      Uint8List imagePixelData = await _loadFileAsUint8List('circle.png');
      _circleMapImage =
          MapImage.withPixelDataAndImageFormat(imagePixelData, ImageFormat.png);
    }

    MapMarker mapMarker = MapMarker(geoCoordinates, _circleMapImage);

    hereMapController.mapScene.addMapMarker(mapMarker);

    hereMapController.mapScene.loadSceneForMapScheme(MapScheme.normalNight,
        (MapError error) {
      if (error != null) {
        print('Map scene not loaded. MapError: ${error.toString()}');
        return;
      }
      print('error -- $error');
      const double distanceToEarthInMeters = 3000;
      print(' hereMapController geoCoordinates -- $geoCoordinates ${geoCoordinates.latitude} ${geoCoordinates.longitude}');
      hereMapController.camera
          .lookAtPointWithDistance(geoCoordinates, distanceToEarthInMeters);
    });
    // hereMapController.release();
  }

  Future<Uint8List> _loadFileAsUint8List(String fileName) async {
    // The path refers to the assets directory as specified in pubspec.yaml.
    ByteData fileData = await rootBundle.load('assets/' + fileName);
    return Uint8List.view(fileData.buffer);
  }
}
