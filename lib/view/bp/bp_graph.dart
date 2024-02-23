import 'dart:convert';
import 'dart:math';
import 'package:flutter/material.dart';
import 'package:healthlog/model/bloodpressure.dart';
import 'package:healthlog/data/db.dart';
import 'package:fl_chart/fl_chart.dart';

class BPGraph extends StatefulWidget {
  final int userid;
  const BPGraph({super.key, required this.userid});

  @override
  State<BPGraph> createState() => _BPGraphState();
}

class _BPGraphState extends State<BPGraph> {
  final List<FlSpot> _systolicData = [];
  final List<FlSpot> _diastolicData = [];
  final int _range = 30;
  //List<FlSpot> normalSystolic = List.filled(11, FlSpot(for (int i = 1; i <= 11; i++) i,120.toDouble()));

  final _formKey = GlobalKey<FormState>();
  int _systolic = 120;
  int _diastolic = 80;
  int _heartrate = 70;
  String arm = "";
  String comment = "";

  List<FlSpot> dateData = [];

  late DatabaseHandler handler;
  late Future<List<Map<String, dynamic>>> _bp;
  bool _retrived = false;

  List<Color> safegradientColors = [
    const Color(0xff23b6e6),
    const Color(0xff02d39a)
  ];
  List<Color> cautiongradientColors = [
    const Color.fromARGB(255, 230, 74, 35),
    const Color.fromARGB(255, 240, 182, 107)
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
      _systolicData.add(FlSpot(index.toDouble(), systolic));
      _diastolicData.add(FlSpot(index.toDouble(), diastolic));

      index++;
    }
  }

  Future<List<Map<String, dynamic>>> getList() async {
    return await handler.bpdata(widget.userid);
  }

  // Future<void> _onRefresh() async {
  //   setState(() {
  //     _bp = getList();
  //   });
  // }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('BloodPressure Graph'),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          showModalBottomSheet(
              isScrollControlled: true,
              context: context,
              builder: ((context) {
                return Padding(
                  padding: EdgeInsets.only(
                      bottom: MediaQuery.of(context).viewInsets.bottom),
                  child: SizedBox(
                    height: 450,
                    child: Form(
                      key: _formKey,
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.start,
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: <Widget>[
                          Padding(
                            padding: const EdgeInsets.all(2.0),
                            child: TextFormField(
                              keyboardType: TextInputType.number,
                              validator: (value) {
                                if (value == null || value.isEmpty) {
                                  return 'Please enter systolic value';
                                }
                                return null;
                              },
                              decoration: const InputDecoration(
                                hintText: '120',
                                label: Text('Systolic'),
                              ),
                              onChanged: (value) {
                                setState(() {
                                  _systolic = int.parse(value);
                                });
                              },
                            ),
                          ),
                          Padding(
                            padding: const EdgeInsets.all(2.0),
                            child: TextFormField(
                              keyboardType: TextInputType.number,
                              validator: (value) {
                                if (value == null || value.isEmpty) {
                                  return 'Please enter diastolic value';
                                }
                                return null;
                              },
                              decoration: const InputDecoration(
                                hintText: '80',
                                label: Text('Diastolic'),
                              ),
                              onChanged: (value) {
                                setState(() {
                                  _diastolic = int.parse(value);
                                });
                              },
                            ),
                          ),
                          Padding(
                            padding: const EdgeInsets.all(2.0),
                            child: TextFormField(
                              keyboardType: TextInputType.number,
                              validator: (value) {
                                if (value == null || value.isEmpty) {
                                  return 'Please enter your heartrate';
                                }
                                return null;
                              },
                              decoration: const InputDecoration(
                                hintText: '70',
                                label: Text('Heartrate'),
                              ),
                              onChanged: (value) {
                                setState(() {
                                  _heartrate = int.parse(value);
                                });
                              },
                            ),
                          ),
                          Padding(
                            padding: const EdgeInsets.all(2.0),
                            child: TextFormField(
                              validator: (value) {
                                if (value == null || value.isEmpty) {
                                  return 'Select the arm';
                                }
                                return null;
                              },
                              decoration: const InputDecoration(
                                  hintText: 'Left/Right', label: Text('Arm')),
                              onChanged: (value) {
                                setState(() {
                                  arm = value;
                                });
                              },
                            ),
                          ),
                          Padding(
                            padding: const EdgeInsets.all(2.0),
                            child: TextFormField(
                              decoration: const InputDecoration(
                                  hintText: 'Before Breakfast/After Dinner',
                                  label: Text('Comments')),
                              onChanged: (value) {
                                setState(() {
                                  comment = value;
                                });
                              },
                            ),
                          ),
                          ElevatedButton(
                            onPressed: () async {
                              if (_formKey.currentState!.validate()) {
                                await DatabaseHandler()
                                    .insertBp(BloodPressure(
                                        id: Random().nextInt(50),
                                        user: widget.userid,
                                        type: 'bp',
                                        content: BP(
                                            systolic: _systolic,
                                            diastolic: _diastolic,
                                            heartrate: _heartrate,
                                            arm: arm),
                                        date: DateTime.now().toIso8601String(),
                                        comments: comment))
                                    .whenComplete(() => Navigator.pop(context));
                              } else {
                                ScaffoldMessenger.of(context).showSnackBar(
                                  const SnackBar(
                                      content: Text('Processing Data')),
                                );
                              }
                            },
                            child: const Text(
                              'Add',
                              style: TextStyle(
                                fontSize: 20,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                );
              }));
        },
        backgroundColor: Colors.deepOrange,
        child: const Icon(Icons.add),
      ),
      body: !_retrived
          ? const Text('Content is not loaded yet')
          : Center(
              child: SizedBox(
                height: MediaQuery.of(context).size.height / 2,
                child: FutureBuilder<List<Map<String, dynamic>>>(
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
                      List<FlSpot> normalSystolic = [
                        for (int i = 0; i <= _range; i++)
                          FlSpot(i.toDouble(), 120.toDouble())
                      ];
                      List<FlSpot> normalDiastolic = [
                        for (int i = 0; i <= _range; i++)
                          FlSpot(i.toDouble(), 80.toDouble())
                      ];
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
                        _systolicData.add(FlSpot(i.toDouble(), systolic));
                        _diastolicData.add(FlSpot(i.toDouble(), diastolic));
                      }
                      //print(systolicData);
                      return LineChart(
                        LineChartData(
                          minX: 0,
                          maxX: 30,
                          minY: 0,
                          maxY: 200,
                          gridData: FlGridData(
                              show: true,
                              drawHorizontalLine: false,
                              getDrawingVerticalLine: (value) {
                                return const FlLine(
                                    color: Color.fromARGB(255, 30, 255, 0),
                                    strokeWidth: 5);
                              },
                              drawVerticalLine: true,
                              verticalInterval: 1),
                          titlesData: const FlTitlesData(show: false),
                          borderData: FlBorderData(
                            show: true,
                            border: Border.all(color: Colors.black, width: 1),
                          ),
                          lineBarsData: [
                            LineChartBarData(
                              spots: normalSystolic,
                              color: Colors.green,
                              barWidth: 1,
                              isStrokeCapRound: true,
                              dotData: const FlDotData(show: false),
                              belowBarData: BarAreaData(
                                applyCutOffY: true,
                                show: true,
                                cutOffY: 80,
                                gradient: RadialGradient(
                                  colors: safegradientColors
                                      .map((color) => color.withOpacity(0.6))
                                      .toList(),
                                ),
                              ),
                            ),
                            LineChartBarData(
                              spots: _systolicData,
                              isCurved: true,
                              color: Colors.red,
                              barWidth: 2,
                              isStrokeCapRound: true,
                              dotData: const FlDotData(show: false),
                              belowBarData: BarAreaData(
                                applyCutOffY: true,
                                show: true,
                                cutOffY: 130,
                                gradient: RadialGradient(
                                  colors: cautiongradientColors
                                      .map((color) => color.withOpacity(0.6))
                                      .toList(),
                                ),
                              ),
                            ),
                            LineChartBarData(
                              spots: normalDiastolic,
                              color: Colors.green,
                              barWidth: 1,
                              isStrokeCapRound: true,
                              dotData: const FlDotData(show: false),
                            ),
                            LineChartBarData(
                              spots: _diastolicData,
                              isCurved: true,
                              color: Colors.red,
                              barWidth: 2,
                              isStrokeCapRound: true,
                              dotData: const FlDotData(show: false),
                              belowBarData: BarAreaData(
                                applyCutOffY: true,
                                show: true,
                                cutOffY: 90,
                                gradient: RadialGradient(
                                  colors: cautiongradientColors
                                      .map((color) => color.withOpacity(0.6))
                                      .toList(),
                                ),
                              ),
                            ),
                          ],
                        ),
                      );
                    }
                  },
                ),
              ),
            ),
    );
  }
}
