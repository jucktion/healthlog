import 'dart:convert';
import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key});

  @override
  _MyHomePageState createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  List<FlSpot> systolicData = [];
  List<FlSpot> diastolicData = [];
  List<FlSpot> dateData = [];

  @override
  void initState() {
    super.initState();
    parseBloodPressureData();
  }

  void parseBloodPressureData() {
    String rawData =
        '[{"id": 17, "user": 33, "type": "bp", "content": {"systolic":150,"diastolic":89,"heartrate":78,"arm":"left"}, "comments": "new", "date": "2024-01-05T13:20:21.664486"}, {"id": 21, "user": 33, "type": "bp", "content": {"systolic":150,"diastolic":100,"heartrate":88,"arm":"ll"}, "comments": "new", "date": "2023-09-27T23:01:56.187535"}]';
    List<dynamic> jsonList = jsonDecode(rawData);

    int index = 0;
    for (var item in jsonList) {
      final content = item['content'];
      final systolic = content['systolic'].toDouble();
      final diastolic = content['diastolic'].toDouble();
      //final dates = item['date'].toString();

      // Assuming you want to plot points based on their order in the dataset
      systolicData.add(FlSpot(index.toDouble(), systolic));
      diastolicData.add(FlSpot(index.toDouble(), diastolic));

      index++;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Blood Pressure Chart'),
      ),
      body: LineChart(
        LineChartData(
          minX: 0,
          maxX: 11,
          minY: 0,
          maxY: 300,
          gridData: const FlGridData(show: false),
          titlesData: const FlTitlesData(show: false),
          borderData: FlBorderData(show: false),
          lineBarsData: [
            LineChartBarData(
              spots: systolicData,
              isCurved: true,
              color: Colors.red,
              barWidth: 4,
              isStrokeCapRound: true,
              dotData: const FlDotData(show: false),
            ),
            LineChartBarData(
              spots: diastolicData,
              isCurved: true,
              color: Colors.blue,
              barWidth: 4,
              isStrokeCapRound: true,
              dotData: const FlDotData(show: false),
            ),
          ],
        ),
      ),
    );
  }
}
