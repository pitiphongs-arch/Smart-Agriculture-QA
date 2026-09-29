import 'dart:async';
import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

void main() {
  runApp(const SmartFarmApp());
}

class SmartFarmApp extends StatelessWidget {
  const SmartFarmApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Smart Agriculture',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.green),
        useMaterial3: true,
      ),
      home: const DashboardPage(),
    );
  }
}

class DashboardPage extends StatefulWidget {
  const DashboardPage({super.key});

  @override
  State<DashboardPage> createState() => _DashboardPageState();
}

class _DashboardPageState extends State<DashboardPage> {
  final String apiUrl =
      'http://localhost:8080/smart_farm/api/get_latest.php';

  double temperature = 0;
  double humidity = 0;
  int apple = 0;
  int mango = 0;
  int orange = 0;

  Timer? timer;

  @override
  void initState() {
    super.initState();

    fetchData();

    timer = Timer.periodic(
      const Duration(seconds: 3),
      (timer) {
        fetchData();
      },
    );
  }

  Future<void> fetchData() async {
    try {
      final response = await http.get(Uri.parse(apiUrl));

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);

        setState(() {
          temperature =
              double.parse(data['telemetry']['temperature'].toString());

          humidity =
              double.parse(data['telemetry']['humidity'].toString());

          apple = int.parse(
            data['inventory']['apple_count'].toString(),
          );

          mango = int.parse(
            data['inventory']['mango_count'].toString(),
          );

          orange = int.parse(
            data['inventory']['orange_count'].toString(),
          );
        });
      }
    } catch (e) {
      print('Error: $e');
    }
  }

  @override
  void dispose() {
    timer?.cancel();
    super.dispose();
  }

  Widget dataCard(
    String title,
    String value,
    IconData icon,
  ) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            Icon(icon, size: 40),
            const SizedBox(height: 10),
            Text(
              title,
              style: const TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              value,
              style: const TextStyle(fontSize: 24),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Smart Agriculture'),
        centerTitle: true,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: ListView(
          children: [
            const Text(
              'Farm Dashboard',
              style: TextStyle(
                fontSize: 26,
                fontWeight: FontWeight.bold,
              ),
            ),

            const SizedBox(height: 20),

            dataCard(
              'Temperature',
              '${temperature.toStringAsFixed(1)} °C',
              Icons.thermostat,
            ),

            dataCard(
              'Humidity',
              '${humidity.toStringAsFixed(1)} %',
              Icons.water_drop,
            ),

            dataCard(
              'Apple',
              '$apple',
              Icons.apple,
            ),

            dataCard(
              'Mango',
              '$mango',
              Icons.eco,
            ),

            dataCard(
              'Orange',
              '$orange',
              Icons.circle,
            ),
          ],
        ),
      ),
    );
  }
}