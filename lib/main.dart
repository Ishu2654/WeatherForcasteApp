import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

const apiKey = 'c479f821555089f2a81ee36c8c760e36';


void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Weather Forecast',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: WeatherForecast(),
    );
  }
}

class WeatherForecast extends StatefulWidget {
  @override
  _WeatherForecastState createState() => _WeatherForecastState();
}

class _WeatherForecastState extends State<WeatherForecast> {
  String weatherData = 'Fetching Weather Data...';
  TextEditingController countryController = TextEditingController();
  TextEditingController stateController = TextEditingController();
  bool isLoading = false;

  @override
  void initState() {
    super.initState();
    fetchWeatherData('India', 'Bihar');
  }

  Future<void> fetchWeatherData(String country, String state) async {
    final apiUrl = 'http://api.openweathermap.org/data/2.5/weather?q=$state,$country&appid=$apiKey';

    try {
      final response = await http.get(Uri.parse(apiUrl));

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        final weatherDescription = data['weather'][0]['description'];
        final temperatureKelvin = data['main']['temp'];
        final temperature = temperatureKelvin - 273.15;

        setState(() {
          weatherData = 'Weather in $state, $country: $weatherDescription\nTemperature: ${temperature.toStringAsFixed(2)}°C';
        });
      } else {
        throw Exception('Failed to fetch weather data. Status Code: ${response.statusCode}');
      }
    } catch (error) {
      setState(() {
        weatherData = 'Error: $error';
      });
    } finally {
      setState(() {
        isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Weather Forecast'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            TextField(
              controller: countryController,
              decoration: InputDecoration(labelText: 'Country'),
            ),
            TextField(
              controller: stateController,
              decoration: InputDecoration(labelText: 'State'),
            ),
            SizedBox(height: 16),
            ElevatedButton(
              onPressed: () async {
                final country = countryController.text;
                final state = stateController.text;
                setState(() {
                  isLoading = true;
                });
                await fetchWeatherData(country, state);
              },
              child: isLoading ? CircularProgressIndicator() : Text('Fetch Weather'),
            ),
            SizedBox(height: 16),
            Text(weatherData),
          ],
        ),
      ),
    );
  }
}