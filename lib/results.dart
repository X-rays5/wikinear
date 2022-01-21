import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:optimized_cached_image/optimized_cached_image.dart';
import 'util.dart';

class Results extends StatefulWidget {
  Results(Position pos) : position = pos;

  final Position position;

  @override
  _Results createState () => _Results(position);
}

class _Results extends State<Results> {
  late Future<Map> _results;
  late Position _position;

  _Results(Position position) : _position = position;

  @override
  void initState() {
    super.initState();
    _results = getWikiNear(_position.latitude, _position.longitude);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(),
        body: Column(
          children: [
            FutureBuilder<Map>(
                future: _results,
                builder: (BuildContext context, AsyncSnapshot<Map> snapshot) {
                  if (snapshot.hasData) {
                    if (snapshot.data!.isEmpty) {
                      return const Center(child: Text("No articles found in a 10km radius"));
                    }
                    var data = snapshot.data!.values.toList();
                    return Expanded(
                        child: ListView(
                          scrollDirection: Axis.vertical,
                          shrinkWrap: true,
                          children: [
                            for (int i = 0; i < data.length; i++)
                              ListTile(
                                title: Text(data[i]['title']),
                                leading: OptimizedCacheImage(
                                  imageUrl: data[i].containsKey('thumbnail') ? data[i]['thumbnail']['source'] : '',
                                  width: 60,
                                  height: 60,
                                  placeholder: (context, url) => const CircularProgressIndicator(),
                                  errorWidget: (context, url, error) => const Icon(Icons.error),
                                ),
                                trailing: const Icon(Icons.arrow_forward),
                                onTap: () {
                                  Navigator.of(context).push(MaterialPageRoute(
                                      builder: (BuildContext context) => WebViewWidget('https://m.wikipedia.org/wiki/${data[i]['title']}', data[i]['title'])));
                                },
                              )
                          ],
                        )
                    );
                  } else {
                    if (snapshot.error != null) {
                      return Center(child: Text(snapshot.error.toString()));
                    } else {
                      return const Center(
                        child: CircularProgressIndicator(),
                      );
                    }
                  }
                }
            )
          ],
        )
    );
  }
}