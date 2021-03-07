import 'package:flutter/material.dart';
import 'package:clipboard_manager/clipboard_manager.dart';

import '../provider/auth_provider.dart';
import '../provider/location_provider.dart';
import 'package:location_app/screen/hereMap_screen.dart';
import 'package:provider/provider.dart';

class SearchResultScreen extends StatefulWidget {
  static const routeName = '/searchResult';

  @override
  _SearchResultScreenState createState() => _SearchResultScreenState();
}

class _SearchResultScreenState extends State<SearchResultScreen> {
  String _token;
  String _userId;
  double lat;
  double lng;
  List _getValue;
  @override
  void didChangeDependencies() {
    // TODO: implement didChangeDependencies
    super.didChangeDependencies();
    _userId = Provider.of<Auth>(context, listen: false).searchUserId;
    _token = Provider.of<Auth>(context, listen: false).searchToken;
    lat = Provider.of<Marker>(context, listen: false).searchLat;
    lng = Provider.of<Marker>(context, listen: false).searchLng;
    _getValue = Provider.of<Marker>(context).searchGetValue;
    // lat = Provider
  }

  @override
  void dispose() {
    print('dispose');
    Provider.of<Auth>(context, listen: false).searchLogout();
    // TODO: implement dispose
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    Provider.of<Marker>(context, listen: false).getUrl(
      _token,
      _userId,
    );
    print(_getValue);
    final deviceSize = MediaQuery.of(context).size;
    return Scaffold(
      backgroundColor: Theme.of(context).backgroundColor,
      appBar: AppBar(
        title: Text('Search Live Console'),
        actions: [
          IconButton(
              icon: Icon(Icons.copy_outlined),
              onPressed: () {
                ClipboardManager.copyToClipBoard('$lat $lng').then((result) {
                  final snackBar = SnackBar(
                    content: Text(
                      'Copied to Clipboard',
                      style: TextStyle(color: Colors.grey[200]),
                    ),
                    backgroundColor: Color.fromRGBO(242, 163, 101, 1),
                  );
                  Scaffold.of(context).showSnackBar(snackBar);
                });
              }),
        ],
      ),
      body: _getValue.length == 0
          ? Container(
              height: deviceSize.height,
              width: deviceSize.width,
              child: Center(
                child: CircularProgressIndicator(
                  valueColor:
                      new AlwaysStoppedAnimation<Color>(Colors.grey[200]),
                ),
              ),
            )
          : Center(
              child: ListView.builder(
                itemBuilder: (ctx, value) => Text(
                  _getValue[value],
                  style: Theme.of(context).textTheme.headline6,
                ),
                itemCount: 13,
              ),
            ),
      floatingActionButton: FloatingActionButton(
        child: Icon(Icons.location_on),
        onPressed: () {
          Navigator.of(context).pushNamed(HereMapLive.routeName,
              arguments: <String, double>{'lat': lat, 'lng': lng});
        },
      ),
    );
  }
}
