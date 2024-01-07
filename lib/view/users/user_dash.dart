import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:healthlog/view/bp/add_bp.dart';
import 'package:healthlog/data/db.dart';
import 'package:fl_chart/fl_chart.dart';

class UserDash extends StatefulWidget {
  final String userid;
  const UserDash({super.key, required this.userid});

  @override
  State<UserDash> createState() => _UserDashState();
}

class _UserDashState extends State<UserDash> {
  List<FlSpot> systolicData = [];
  List<FlSpot> diastolicData = [];
  //List<FlSpot> normalSystolic = List.filled(11, FlSpot(for (int i = 1; i <= 11; i++) i,120.toDouble()));

  List<FlSpot> normalSystolic = [
    for (int i = 0; i <= 11; i++) FlSpot(i.toDouble(), 120.toDouble())
  ];
  List<FlSpot> normalDiastolic = [
    for (int i = 0; i <= 11; i++) FlSpot(i.toDouble(), 80.toDouble())
  ];
  List<FlSpot> dateData = [];

  late DatabaseHandler handler;
  late Future<List<Map<String, dynamic>>> _bp;
  bool _retrived = false;

  List<Color> gradientColors = [
    const Color(0xff23b6e6),
    const Color(0xff02d39a)
  ];

  @override
  void initState() {
    super.initState();
    handler = DatabaseHandler();
    handler.initializeDB().whenComplete(() async {
      setState(() {
        _retrived = true;
        _bp = getList();
      });
    });
  }

  void parseBloodPressureData(Future<List<Map<String, dynamic>>> data) {
    final List<Map<String, dynamic>> rawData =
        data as List<Map<String, dynamic>>;
    //List<dynamic> jsonList = jsonDecode(rawData);

    int index = 0;
    for (var item in rawData) {
      final content = item['content'];
      final systolic = content['systolic'].toDouble();
      final diastolic = content['diastolic'].toDouble();
      //final dates = item['date'].toString();

      //print(systolic + diastolic);

      // Assuming you want to plot points based on their order in the dataset
      systolicData.add(FlSpot(index.toDouble(), systolic));
      diastolicData.add(FlSpot(index.toDouble(), diastolic));

      index++;
    }
  }

  Future<List<Map<String, dynamic>>> getList() async {
    return await handler.bpdata(widget.userid);
  }

  Future<void> _onRefresh() async {
    setState(() {
      _bp = getList();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('User Dashboard'),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(
                builder: (context) => AddBPScreen(
                      userid: widget.userid,
                    )),
          );
        },
        backgroundColor: Colors.deepOrange,
        child: const Icon(Icons.add),
      ),
      body: !_retrived
          ? const Text('Content is not loaded yet')
          : FutureBuilder<List<Map<String, dynamic>>>(
              future: _bp,
              builder: (BuildContext context,
                  AsyncSnapshot<List<Map<String, dynamic>>> snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(
                    child: CircularProgressIndicator(),
                  );
                } else if (snapshot.hasError) {
                  return Text('Error: ${snapshot.error}');
                } else {
                  //final items = snapshot.data ?? <BloodPressure>[];
                  final rawData = snapshot.data!;
                  //List<dynamic> jsonList = jsonDecode(rawData);
                  //print(rawData);

                  for (int i = 0; i < rawData.length; i++) {
                    final content = jsonDecode(rawData[i]['content']);
                    //print(normalSystolic);
                    final systolic = content['systolic'].toDouble();
                    //print(content['systolic'].toString());

                    final diastolic = content['diastolic'].toDouble();
                    //print(content['diastolic'].toString());
                    //final dates = item['date'].toString();

                    //print(systolic + diastolic);

                    //Assuming you want to plot points based on their order in the dataset
                    systolicData.add(FlSpot(i.toDouble(), systolic));
                    diastolicData.add(FlSpot(i.toDouble(), diastolic));
                  }
                  //print(systolicData);
                  return RefreshIndicator(
                    onRefresh: _onRefresh,
                    child: LineChart(
                      LineChartData(
                        minX: 0,
                        maxX: 11,
                        minY: 0,
                        maxY: 200,
                        gridData: const FlGridData(show: true),
                        titlesData: const FlTitlesData(show: false),
                        borderData: FlBorderData(
                          show: true,
                          border: Border.all(color: Colors.black, width: 1),
                        ),
                        lineBarsData: [
                          LineChartBarData(
                            spots: normalSystolic,
                            isCurved: true,
                            color: Colors.green,
                            barWidth: 1,
                            isStrokeCapRound: true,
                            dotData: const FlDotData(show: false),
                            belowBarData: BarAreaData(
                              applyCutOffY: true,
                              show: true,
                              cutOffY: 80,
                              gradient: RadialGradient(
                                colors: gradientColors
                                    .map((color) => color.withOpacity(0.6))
                                    .toList(),
                              ),
                            ),
                          ),
                          LineChartBarData(
                            spots: systolicData,
                            isCurved: true,
                            color: Colors.red,
                            barWidth: 5,
                            isStrokeCapRound: true,
                            dotData: const FlDotData(show: false),
                          ),
                          LineChartBarData(
                            spots: diastolicData,
                            isCurved: true,
                            color: Colors.red,
                            barWidth: 5,
                            isStrokeCapRound: true,
                            dotData: const FlDotData(show: false),
                          ),
                        ],
                      ),
                    ),
                  );
                }
              },
            ),
    );
  }
}
