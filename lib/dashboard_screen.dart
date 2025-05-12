import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:syncfusion_flutter_gauges/gauges.dart';
import 'package:url_launcher/url_launcher.dart';

class DashboardScreen extends StatefulWidget {

  _DashboardScreenState createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  double speed = 0.0;
  double acceleration = 0.0;
  double gforce = 0.0;
  double topSpeed = 0.0;

  bool isAnalog = true;

  final DatabaseReference dbRef = FirebaseDatabase.instance.ref("vehicle_data");

  @override
  void initState() {
    super.initState();
    dbRef.onValue.listen((DatabaseEvent event) {
      final data = event.snapshot.value as Map?;
      if (data != null) {
        setState(() {
          speed = double.tryParse(data["speed"].toString()) ?? 0.0;
          acceleration = double.tryParse(data["acceleration"].toString()) ?? 0.0;
          gforce = double.tryParse(data["gforce"].toString()) ?? 0.0;
          if (speed > topSpeed) topSpeed = speed;
        });
      }
    });
  }

  void toggleSpeedometerView() {
    setState(() {
      isAnalog = !isAnalog;
    });
  }

  void openGoogleMaps(double lat, double lng) async {
    final Uri url = Uri.parse('https://www.google.com/maps/search/?api=1&query=$lat,$lng');
    if (await canLaunchUrl(url)) {
      await launchUrl(url, mode: LaunchMode.externalApplication);
    } else {
      throw 'Could not launch Google Maps';
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      appBar: AppBar(
        title: const Text("Vehicle Monitor Dashboard"),
        backgroundColor: Colors.deepPurple,
        centerTitle: true,
      ),
      body: ListView(
        padding: const EdgeInsets.all(16.0),
        children: [
          GestureDetector(
            onTap: toggleSpeedometerView,
            child: Container(
              height: 250,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(16),
                color: Colors.deepPurple,
                boxShadow: [BoxShadow(color: Colors.black26, blurRadius: 8)],
              ),
              child: isAnalog
                  ? Container(
                color: isDarkMode ? Colors.black : Colors.white,
                child: SfRadialGauge(
                  title: GaugeTitle(
                    text: 'Speedometer (Analog)',
                    textStyle: TextStyle(
                      fontSize: 20.0,
                      fontWeight: FontWeight.bold,
                      color: isDarkMode ? Colors.white : Colors.black,
                    ),
                  ),
                  axes: <RadialAxis>[
                    RadialAxis(
                      minimum: 0,
                      maximum: 180,
                      ranges: <GaugeRange>[
                        GaugeRange(startValue: 0, endValue: 60, color: Colors.green),
                        GaugeRange(startValue: 60, endValue: 120, color: Colors.orange),
                        GaugeRange(startValue: 120, endValue: 180, color: Colors.red),
                      ],
                      pointers: <GaugePointer>[
                        NeedlePointer(value: speed, enableAnimation: true),
                      ],
                      annotations: <GaugeAnnotation>[
                        GaugeAnnotation(
                          widget: Text(
                            '${speed.toStringAsFixed(1)} km/h',
                            style: TextStyle(
                              fontSize: 20,
                              fontWeight: FontWeight.bold,
                              color: isDarkMode ? Colors.white : Colors.black,
                            ),
                          ),
                          angle: 90,
                          positionFactor: 0.8,
                        ),
                      ],
                    )
                  ],
                ),
              )
                  : Container(
                color: isDarkMode ? Colors.black : Colors.white,
                child: Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.speed, size: 40, color: Colors.deepPurple),
                      SizedBox(height: 10),
                      Text(
                        '${speed.toStringAsFixed(1)} km/h',
                        style: TextStyle(
                          fontSize: 36,
                          fontWeight: FontWeight.bold,
                          color: isDarkMode ? Colors.white : Colors.deepPurple,
                        ),
                      ),
                      Text(
                        'Speedometer (Digital)',
                        style: TextStyle(
                          fontSize: 16,
                          color: isDarkMode ? Colors.white70 : Colors.black,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
          buildDataCard("Top Speed", "$topSpeed km/h", Icons.trending_up, Colors.deepOrange),
          buildDataCard("Acceleration", "$acceleration m/s²", Icons.show_chart, Colors.green),
          buildDataCard("G-Force", "$gforce G", Icons.sync_alt, Colors.purple),
          ElevatedButton(
            onPressed: () => openGoogleMaps(12.9716, 77.5946), // Example location, replace with dynamic coordinates
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.deepPurple, // Use backgroundColor instead of primary
            ),
            child: Text('Show Live Location'),
          ),
        ],
      ),
    );
  }

  Widget buildDataCard(String title, String value, IconData icon, Color color) {
    return Card(
      elevation: 4,
      shadowColor: color.withOpacity(0.3),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      margin: const EdgeInsets.symmetric(vertical: 10),
      child: ListTile(
        leading: CircleAvatar(
          backgroundColor: color.withOpacity(0.2),
          child: Icon(icon, color: color),
        ),
        title: Text(title, style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18)),
        trailing: Text(value, style: TextStyle(fontSize: 18, color: color)),
      ),
    );
  }
}
