import 'dart:async';

import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';

import 'package:yandex_mapkit/yandex_mapkit.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  YandexMapController? controller;
  Position? position;
  var lat;
  var long;
  @override
  void initState() {
    super.initState();
  }

  initPosition() async {
    position = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.low);
    lat = position!.latitude;
    long = position!.longitude;
    setState(() {});
  }

  final animation =
      const MapAnimation(type: MapAnimationType.smooth, duration: 2.0);

  var _response;
  String token =
      "eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJ0b2tlbl90eXBlIjoiYWNjZXNzIiwiZXhwIjoxNzE1OTkxMzc3LCJpYXQiOjE3MTU3NzUzNzcsImp0aSI6IjA5ODg3MjY0Mjg3MDQ2MjE4YTU1NjQ1NjQzNGE3OWVhIiwidXNlcl9pZCI6M30.GUY8GWiE-Kuqw-lBpNdvAfAmUjjyDOQdpSkGwWFn37o";
  Future<void> _sendPostRequest() async {
    if (lat == null || long == null) {
      return;
    }

    final dio = Dio();
    const url = 'https://quiz.4fun.uz/get_distance/';
    //String url = ' https://quiz.4fun.uz/token/';
    final data = {
      'latitude': lat,
      'longitude': long,
    };

    try {
      final response = await dio.post(url,
          data: data,
          options: Options(headers: {
            'Content-Type': 'application/json',
            'Accept': 'application/json',
            'Authorization': "Bearer $token"
          }));
      if (response.statusCode == 200) {
        final responseData = response.data as Map<String, dynamic>;
        setState(() {
          _response = '${responseData['message']}';
        });
      }
    } catch (e) {
      print(e);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          title: Text(_response.toString()),
        ),
        body: Stack(
          children: [
            YandexMap(
              onMapCreated: (YandexMapController yandexMapController) async {
                controller = yandexMapController;
                await controller!.moveCamera(CameraUpdate.newCameraPosition(
                    CameraPosition(
                        target: Point(latitude: lat, longitude: long),
                        zoom: 12)));
              },
            ),
            const Positioned(
                left: 0,
                right: 0,
                top: 0,
                bottom: 0,
                child: Icon(
                  Icons.location_on,
                  color: Colors.red,
                  size: 40,
                )),
            Positioned(
                left: 50,
                right: 50,
                bottom: 30,
                child: ElevatedButton(
                    onPressed: () async {
                      await Geolocator.requestPermission();
                      await initPosition();
                      await controller!.moveCamera(
                          CameraUpdate.newCameraPosition(CameraPosition(
                              target: Point(latitude: lat, longitude: long),
                              zoom: 15)),
                          animation: animation);
                      await _sendPostRequest();
                      print(position.toString());
                      print(_response.toString());
                    },
                    child: const Text('MASOFA'))),
          ],
        ));
  }
}
