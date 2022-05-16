import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:weather_bloc/pages/search_page.dart';
import 'package:weather_bloc/pages/settings.dart';
import 'package:weather_bloc/widgets/error_dialogue.dart';

import '../constants/constants.dart';
import '../blocs/blocs.dart';

class HomePage extends StatefulWidget {
  const HomePage({Key? key}) : super(key: key);

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  String? _city;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Weather App"),
        actions: [
          IconButton(
            icon: const Icon(Icons.search),
            onPressed: () async {
              _city = await Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => const SearchPage(),
                ),
              );
              if (_city != null) {
                context.read<WeatherBloc>().add(
                      FetchWeatherEvent(city: _city!),
                    );
              }
            },
          ),
          IconButton(
            icon: const Icon(Icons.settings),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => const SettingsPage(),
                ),
              );
            },
          ),
        ],
      ),
      body: _showWeather(),
    );
  }

  String showTemperature(double temperature) {
    final tempUnit = context.watch<TempSettingsBloc>().state.tempUnit;
    if (tempUnit == TempUnit.fehrenheit) {
      return '${((temperature * 9 / 5) + 32).toStringAsFixed(2)} F';
    }

    return "${temperature.toStringAsFixed(2)} C ";
  }

  Widget showIcon(String abbr) {
    return FadeInImage.assetNetwork(
      placeholder: 'assets/loading.gif',
      image: 'https://$kHost/static/img/weather/png/64/$abbr.png',
      width: 64,
      height: 64,
    );
  }

  Widget _showWeather() => BlocConsumer<WeatherBloc, WeatherState>(
        listener: (context, state) {
          if (state.status == WeatherStatus.error) {
            errorDialog(context, state.error.errMsg);
          }
        },
        builder: (context, state) {
          if (state.status == WeatherStatus.initial) {
            return const Center(
              child: Text(
                "Select a city",
                style: TextStyle(
                  fontSize: 20.0,
                ),
              ),
            );
          }

          if (state.status == WeatherStatus.loading) {
            return const Center(
              child: CircularProgressIndicator(),
            );
          }
          if (state.status == WeatherStatus.error &&
              state.weather.title == '') {
            return const Center(
              child: Text(
                "Select a city",
                style: TextStyle(fontSize: 20.0),
              ),
            );
          }

          return ListView(
            children: [
              SizedBox(
                height: MediaQuery.of(context).size.height / 6,
              ),
              Text(
                state.weather.title,
                textAlign: TextAlign.center,
                style: const TextStyle(
                  fontSize: 40.0,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(
                height: 10.0,
              ),
              Text(
                TimeOfDay.fromDateTime(state.weather.lastUpdated)
                    .format(context),
                textAlign: TextAlign.center,
                style: const TextStyle(fontSize: 18.0),
              ),
              const SizedBox(
                height: 60,
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    showTemperature(state.weather.theTemp),
                    style: const TextStyle(
                        fontSize: 30.0, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(
                    height: 10.0,
                  ),
                  Column(
                    children: [
                      Text(
                        showTemperature(state.weather.maxTemp),
                        style: const TextStyle(
                          fontSize: 16.0,
                        ),
                      ),
                      const SizedBox(
                        height: 10,
                      ),
                      Text(
                        showTemperature(state.weather.minTemp),
                        style: const TextStyle(
                          fontSize: 16.0,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
              const SizedBox(
                height: 40.0,
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  const Spacer(),
                  showIcon(state.weather.weatherStateAbbr),
                  const SizedBox(
                    width: 20.0,
                  ),
                  Text(
                    state.weather.weatherStateAbbr,
                    style: const TextStyle(
                      fontSize: 32.0,
                    ),
                  ),
                  const Spacer(),
                ],
              ),
            ],
          );
        },
      );
}
