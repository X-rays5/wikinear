import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:wikinear/results.dart';

import 'util.dart';

class HomePage extends StatefulWidget {
  @override
  _HomePage createState() => _HomePage();
}

class _HomePage extends State<HomePage> {
  final ButtonStyle style = ElevatedButton.styleFrom(textStyle: const TextStyle(fontSize: 20), minimumSize: const Size(200, 40), maximumSize: const Size(200, 40));
  late TextEditingController _addressController;
  late TextEditingController _latitudeController;
  late TextEditingController _longitudeController;

  @override initState() {
    super.initState();
    _addressController = TextEditingController();
    _latitudeController = TextEditingController();
    _longitudeController = TextEditingController();
  }

  Widget _getAddress() {
    return AlertDialog(
      title: const Text('Enter address'),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          TextField(
            controller: _addressController,
            textAlign: TextAlign.left,
            decoration: const InputDecoration(
              border: OutlineInputBorder(),
              hintText: 'Input address',
              labelText: 'Address'
            )
          ),
        ],
      ),
      actions: <Widget>[
        TextButton(
          onPressed: () {
            Navigator.of(context).pop();
          },
          child: const Text('Cancel'),
        ),
        TextButton(
          onPressed: () async {
            Navigator.of(context).pop();
            try {
              var position = await addressToPosition(_addressController.text);
              Navigator.of(context).push(MaterialPageRoute(
                  builder: (BuildContext context) => Results(position)));
            } catch (e) {
              showDialog(
                  context: context,
                  builder: (BuildContext context) => BuildPopUpDialog(context, 'Error', e.toString())
              );
            }
          },
          child: const Text('Ok'),
        ),
      ],
    );
  }

  Widget _getCoordinates() {
    return AlertDialog(
      title: const Text('Enter coordinates'),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          TextField(
              controller: _latitudeController,
              textAlign: TextAlign.left,
              decoration: const InputDecoration(
                  border: OutlineInputBorder(),
                  hintText: 'Input latitude',
                  labelText: 'latitude'
              )
          ),
          Padding(
            padding: EdgeInsets.all(4),
            child: TextField(
                controller: _longitudeController,
                textAlign: TextAlign.left,
                decoration: const InputDecoration(
                    border: OutlineInputBorder(),
                    hintText: 'Input longitude',
                    labelText: 'longitude'
                )
            ),
          )
        ],
      ),
      actions: <Widget>[
        TextButton(
          onPressed: () {
            Navigator.of(context).pop();
          },
          child: const Text('Cancel'),
        ),
        TextButton(
          onPressed: () async {
            Navigator.of(context).pop();
            try {
              var position = Position(longitude: double.parse(_longitudeController.text), latitude: double.parse(_latitudeController.text), timestamp: DateTime.now(), accuracy: 0, altitude: 0, heading: 0, speed: 0, speedAccuracy: 0);
              Navigator.of(context).push(MaterialPageRoute(
                  builder: (BuildContext context) => Results(position)));
            } catch(e) {
              showDialog(
                  context: context,
                  builder: (BuildContext context) => BuildPopUpDialog(context, 'Error', e.toString())
              );
            }
          },
          child: const Text('Ok'),
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Center(child: Text("wikinear"),)
      ),
      body: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ElevatedButton(
              style: style,
              onPressed: () async {
                showDialog(
                    context: context,
                    builder: (BuildContext context) => _getAddress(),
                );
              },
              child: const Text('Address'),
            ),
            Padding(
              padding: const EdgeInsets.all(5),
              child: ElevatedButton(
                      style: style,
                      onPressed: () async {
                        showDialog(
                            context: context,
                            builder: (BuildContext context) => _getCoordinates()
                        );
                      },
                      child: const Text('Coordinates'),
                    ),
            ),
            ElevatedButton(
              style: style,
              onPressed: () async {
                try {
                  var position = await getGpsLocation();
                  Navigator.of(context).push(MaterialPageRoute(
                      builder: (BuildContext context) => Results(position)));
                } catch(e) {
                  showDialog(
                      context: context,
                      builder: (BuildContext context) => BuildPopUpDialog(context, 'Error', e.toString())
                  );
                }
              },
              child: const Text('Current Location'),
            ),
          ],
        ),
      )
    );
  }

}