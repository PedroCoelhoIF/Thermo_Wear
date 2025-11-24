import 'package:flutter/material.dart';
import 'package:thermo_wear/thermo_wear.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'ThermoWear Example',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        brightness: Brightness.dark,
        primarySwatch: Colors.blue,
      ),
      home: const SafeArea(
        child: ThermoWearWidget(
          welcomeTitle: 'ThermoWear',
          welcomeMessage: 'Incline seu smartwatch\npara ver a temperatura',
          tiltThreshold: 3.0, // Sensibilidade média
        ),
      ),
    );
  }
}
