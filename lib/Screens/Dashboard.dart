import 'package:bottom_indicator_bar_svg/bottom_indicator_bar_svg.dart';
import 'package:flutter/material.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:geocoding/geocoding.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

import 'package:http/http.dart' as http;
import 'dart:convert';

import '../colors.dart';
import 'Profile.dart';

const apiKey = "49d5eb15e8807e49d0ad451ca8e64ebe";
const units = "metric";

class Dashboard extends StatefulWidget {
  const Dashboard({Key? key}) : super(key: key);

  @override
  State<Dashboard> createState() => _DashboardState();
}

class _DashboardState extends State<Dashboard> {
  Map<String, dynamic>? weatherData;
  TextEditingController _cityController = TextEditingController();

  List<BottomIndicatorNavigationBarItem> items = [
    BottomIndicatorNavigationBarItem(icon: Icons.home, label: Text('Home')),
    BottomIndicatorNavigationBarItem(icon: Icons.person, label: 'Profile'),
  ];

  int currentIndex=0;
  GoogleMapController? _mapController;
  Set<Marker> _markers = {};
  LatLng? _selectedLocation;

  @override
  void initState() {
    super.initState();
    _cityController.text="Islamabad";
    fetchWeatherData().then((data) {
      setState(() {
        weatherData = data;
      });
    }).catchError((error) {
      print('Error fetching weather data: $error');
    });
  }

  Future<Map<String, dynamic>> fetchWeatherData() async {
    final url =
        'https://api.openweathermap.org/data/2.5/weather?q=${_cityController.text}&appid=$apiKey&units=$units';

    final response = await http.get(Uri.parse(url));
    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      return data;
    } else {
      throw Exception('Failed to fetch weather data');
    }
  }

  Future<Map<String, dynamic>> fetchWeatherDataForLocation(
      double latitude, double longitude) async {
    final url =
        'https://api.openweathermap.org/data/2.5/weather?lat=$latitude&lon=$longitude&appid=$apiKey&units=$units';

    final response = await http.get(Uri.parse(url));
    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      return data;
    } else {
      throw Exception('Failed to fetch weather data');
    }
  }


  String getWeatherImage() {
    if (weatherData != null) {
      final weatherCode = weatherData!['weather'][0]['icon'];

      // Map weather condition codes to corresponding image assets
      if (weatherCode == '01d') {
        return 'assets/weather/sunny.png';
      } else if (weatherCode == '02d') {
        return 'assets/weather/partly_cloudy.png';
      } else if (weatherCode == '03d' || weatherCode == '04d') {
        return 'assets/weather/cloudy.png';
      } else if (weatherCode == '09d' || weatherCode == '10d') {
        return 'assets/weather/rainy.png';
      } else if (weatherCode == '11d') {
        return 'assets/weather/rainy.png';
      } else if (weatherCode == '13d') {
        return 'assets/weather/snow.png';
      } else if (weatherCode == '50d') {
        return 'assets/weather/mist.png';
      }
    }

    // Return a default image if weatherData is null or weather code is not matched
    return 'assets/weather/sunny.png';
  }

  void _onMapCreated(GoogleMapController controller) {
    _mapController = controller;
  }

  void _moveToSelectedLocation(LatLng location) async {
    setState(() {
      _selectedLocation = location;
      _markers = {
        Marker(
          markerId: MarkerId('Selected Location'),
          position: location,
        ),
      };
    });

    _moveCameraToLocation(location);

    try {
      List<Placemark> placemarks = await placemarkFromCoordinates(
        location.latitude,
        location.longitude,
      );

      if (placemarks.isNotEmpty) {
        Placemark placemark = placemarks.first;
        setState(() {
          _cityController.text = placemark.locality ?? '';
        });
      } else {
        setState(() {
          _cityController.text = '';
        });
      }

      fetchWeatherDataForLocation(location.latitude, location.longitude)
          .then((data) {
        setState(() {
          weatherData = data;
        });
      }).catchError((error) {
        print('Error fetching weather data: $error');
      });
    } catch (error) {
      print('Error retrieving placemarks: $error');
    }
  }

  void _moveCameraToLocation(LatLng location) {
    if (_mapController != null) {
      final cameraUpdate = CameraUpdate.newLatLng(location);
      _mapController!.animateCamera(cameraUpdate);
    }
  }



  @override
  Widget build(BuildContext context) {
    EasyLoading.dismiss();
    return Scaffold(
      appBar: AppBar(
        automaticallyImplyLeading: false,
        title: Text(
          "Dashboard",
          style: TextStyle(
            color: Colors.white,
          ),
        ),
        actions: [
          IconButton(
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => ProfileScreen()),
              );
            },
            icon: Icon(Icons.settings, color: Colors.white),
          ),
        ],
      ),
      body: Container(
        alignment: Alignment.center,
        padding: EdgeInsets.all(16.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.start,
          children: [
            Text(
              "Current Weather",
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
              ),
            ),
            SizedBox(height: 20),
            TextField(
              controller: _cityController,
              decoration: InputDecoration(
                labelText: 'City',
                border: OutlineInputBorder(),
              ),
            ),
            SizedBox(height: 20),
            if (weatherData != null)
              Image.asset(
                getWeatherImage(),
                width: 100,
                height: 100,
              ),
            SizedBox(height: 20),
            if (weatherData != null)
              Column(
                children: [
                  Text(
                    '${weatherData!['main']['temp']}°C',
                    style: TextStyle(
                      fontSize: 40,
                    ),
                  ),
                  SizedBox(height: 10),
                  Text(
                    '${weatherData!['weather'][0]['description']}',
                    style: TextStyle(
                      fontSize: 16,
                    ),
                  ),
                ],
              ),
            if (weatherData == null) CircularProgressIndicator(),
            SizedBox(height: 20),
            ElevatedButton(
              onPressed: () {
                // Refresh weather data
                setState(() {
                  weatherData = null;
                });
                fetchWeatherData().then((data) {
                  setState(() {
                    weatherData = data;
                  });
                }).catchError((error) {
                  print('Error fetching weather data: $error');
                });
              },
              child: Text('Refresh'),
            ),
            SizedBox(height: 20),
            ElevatedButton(
              onPressed: () {
                showModalBottomSheet(
                  context: context,
                  builder: (_) => Container(
                    height: MediaQuery.of(context).size.height * 0.7,
                    child: GoogleMap(
                      onMapCreated: _onMapCreated,
                      initialCameraPosition: CameraPosition(
                        zoom: 5,
                        target: LatLng(33.6844, 73.0479),
                      ),
                      onTap: (LatLng location) {
                        _moveToSelectedLocation(location);
                      },
                      markers: _markers,
                    ),
                  ),
                );
              },
              child: Text('Select Location'),
            ),
          ],
        ),
      ),

      bottomNavigationBar: BottomIndicatorBar(
        onTap: (index) {
          setState(() {
            currentIndex = index;
          });

          if (index == 1) {
            // Navigate to the Dashboard screen
            Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => ProfileScreen()),
            );
          }
        },
        currentIndex: currentIndex,
        items: items,
        iconSize: 30.0,
        barHeight: 70.0,
        activeColor: Colors.white,
        inactiveColor: Colors.white38,
        indicatorColor: Colors.blue,
        backgroundColor: AppColors.primaryColor,
        indicatorHeight: 0,
      ),
    );
  }
}
