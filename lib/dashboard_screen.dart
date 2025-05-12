import 'package:flutter/material.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:syncfusion_flutter_gauges/gauges.dart';

class DashboardScreen extends StatefulWidget {
  @override
  _DashboardScreenState createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  double speed = 0.0;
  double acceleration = 0.0;
  double gforce = 0.0;
  double topSpeed = 0.0;

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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Vehicle Monitor Dashboard"),
        backgroundColor: Colors.deepPurple,
        centerTitle: true,
      ),
      body: ListView(
        padding: const EdgeInsets.all(16.0),
        children: [
          Container(
            height: 250,
            child: SfRadialGauge(
              title: GaugeTitle(
                text: 'Speedometer',
                textStyle: TextStyle(fontSize: 20.0, fontWeight: FontWeight.bold),
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
                      widget: Text('${speed.toStringAsFixed(1)} km/h',
                          style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
                      angle: 90,
                      positionFactor: 0.8,
                    ),
                  ],
                )
              ],
            ),
          ),
          buildDataCard("Top Speed", "$topSpeed km/h", Icons.trending_up, Colors.deepOrange),
          buildDataCard("Acceleration", "$acceleration m/s²", Icons.show_chart, Colors.green),
          buildDataCard("G-Force", "$gforce G", Icons.sync_alt, Colors.purple),
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
