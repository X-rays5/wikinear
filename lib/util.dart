import 'dart:convert';
import 'dart:io';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:geolocator/geolocator.dart';
import 'package:http/http.dart' as http;
import 'package:webview_flutter/webview_flutter.dart';

Future<Position> getGpsLocation({LocationAccuracy accuracy = LocationAccuracy.medium}) async {
  bool serviceEnabled;
  LocationPermission permission;

  // Test if location services are enabled.
  serviceEnabled = await Geolocator.isLocationServiceEnabled();
  if (!serviceEnabled) {
    // Location services are not enabled don't continue
    // accessing the position and request users of the
    // App to enable the location services.
    return Future.error('Location services are disabled.');
  }

  permission = await Geolocator.checkPermission();
  if (permission == LocationPermission.denied) {
    permission = await Geolocator.requestPermission();
    if (permission == LocationPermission.denied) {
      // Permissions are denied, next time you could try
      // requesting permissions again (this is also where
      // Android's shouldShowRequestPermissionRationale
      // returned true. According to Android guidelines
      // your App should show an explanatory UI now.
      return Future.error('Location permissions are denied');
    }
  }

  if (permission == LocationPermission.deniedForever) {
    // Permissions are denied forever, handle appropriately.
    return Future.error(
        'Location permissions are permanently denied, we cannot request permissions.');
  }

  // When we reach here, permissions are granted and we can
  // continue accessing the position of the device.
  return await Geolocator.getCurrentPosition(desiredAccuracy: accuracy);
}

Future<Position> addressToPosition(String address) async {
  var url = Uri.parse('http://api.positionstack.com/v1/forward?access_key=${dotenv.env['POSITIONSTACK_API_KEY']}&query=$address');
  var res = await http.get(url);
  if (res.statusCode == 200) {
    if (res.body.isNotEmpty && res.body != '{}') {
      var body = json.decode(res.body);
      if (!body.containsKey('error')) {
        if (body['data'].isNotEmpty) {
          var tmpPos = body['data'][0];
          return Position(longitude: tmpPos['longitude'], latitude: tmpPos['latitude'], timestamp: DateTime.now(), accuracy: 0, altitude: 0, heading: 0, speed: 0, speedAccuracy: 0);
        } else {
          return Future.error('Invalid address');
        }
      } else {
        return Future.error(body['error']['message']);
      }
    } else {
      return Future.error('Received empty body when getting pages');
    }
  } else {
    return Future.error('Non 200 response code: ${res.statusCode.toString()}');
  }
}

/**
 * @param lat latitude
 * @param lon longtidate
 * @param radius radius around cordinates in km
 * @param limit max amount of pages to get
 */
Future<Map> getWikiNear(double lat, double lon, {int radius = 10000, int limit = 100}) async {
  var url = Uri.parse('https://en.wikipedia.org/w/api.php?format=json&action=query&generator=geosearch&prop=pageimages&ggscoord=$lat|$lon&ggsradius=$radius&ggslimit=$limit');
  var res = await http.get(url);
  if (res.statusCode == 200) {
    if (res.body.isNotEmpty && res.body != '{}') {
      var body = json.decode(res.body);
      if (!body.containsKey('error')) {
        return body['query']['pages'];
      } else {
        return Future.error(body['error']['info']);
      }
    } else {
      return Future.error('Received empty body when getting pages');
    }
  } else {
    return Future.error('Non 200 response code: ${res.statusCode.toString()}');
  }
}

class WebViewWidget extends StatelessWidget {
  WebViewWidget(String url, String title, {Key? key}) : _url = url, _title = title, super(key: key) {
    if (Platform.isAndroid) WebView.platform = AndroidWebView();
  }

  final String _url;
  final String _title;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(_title),
      ),
      body: WebView(
          initialUrl: _url
      ),
    );
  }
}

Widget BuildPopUpDialog(BuildContext context, String title, String message) {
  return AlertDialog(
    title: Text(title),
    content: Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        Text(message),
      ],
    ),
    actions: <Widget>[
      TextButton(
        onPressed: () {
          Navigator.of(context).pop();
        },
        child: const Text('Close'),
      ),
    ],
  );
}