import 'package:flutter/material.dart';
import 'package:healthlog/data/colors.dart';
import 'package:healthlog/data/db.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:healthlog/model/bloodpressure.dart';
import 'package:healthlog/view/bp/bp_helper.dart';
import 'package:healthlog/view/theme/globals.dart';
import 'package:shared_preferences/shared_preferences.dart';

class BPGraph extends StatefulWidget {
  final int userid;
  const BPGraph({super.key, required this.userid});

  @override
  State<BPGraph> createState() => _BPGraphState();
}

class _BPGraphState extends State<BPGraph> {
  final GlobalKey<RefreshIndicatorState> _refreshIndicatorKey =
      GlobalKey<RefreshIndicatorState>();

  //List<FlSpot> normalSystolic = List.filled(11, FlSpot(for (int i = 1; i <= 11; i++) i,120.toDouble()));
  SharedPreferences? _prefs;
  List<FlSpot> dateData = [];

  late DatabaseHandler handler;
  late Future<List<BloodPressure>> _bp;
  bool _retrived = false;
  bool _prefLoaded = false;

  @override
  void initState() {
    super.initState();
    _initPrefs();
    handler = DatabaseHandler.instance;
    handler.initializeDB().whenComplete(() async {
      setState(() {
        _bp = getList();
        _retrived = true;
      });
    });
  }

  Future<List<BloodPressure>> getList() async {
    return await handler.bpHistoryGraph(widget.userid);
  }

  void _initPrefs() async {
    _prefs = await SharedPreferences.getInstance();
    setState(() {
      _prefLoaded = true;
    });
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
          title: const Text('BloodPressure Graph'),
        ),
        floatingActionButton: FloatingActionButton(
          onPressed: () {
            BPHelper.statefulBpBottomModal(context,
                userid: widget.userid,
                callback: () {},
                refreshIndicatorKey: _refreshIndicatorKey);
          },
          backgroundColor: Colors.deepOrange,
          child: const Icon(Icons.add),
        ),
        body: RefreshIndicator(
            key: _refreshIndicatorKey,
            onRefresh: _onRefresh,
            child: SingleChildScrollView(
              physics: const AlwaysScrollableScrollPhysics(),
              child: !_retrived && !_prefLoaded
                  ? const Text('Content is not loaded yet')
                  : SizedBox(
                      height: MediaQuery.of(context).size.height / 1.25,
                      child: Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            SizedBox(
                              height: MediaQuery.of(context).size.height / 3,
                              width: MediaQuery.of(context).size.width / 1.05,
                              child: FutureBuilder<List<BloodPressure>>(
                                future: _bp,
                                builder: (BuildContext context,
                                    AsyncSnapshot<List<BloodPressure>>
                                        snapshot) {
                                  if (snapshot.connectionState ==
                                      ConnectionState.waiting) {
                                    return const Center(
                                      child: CircularProgressIndicator(),
                                    );
                                  } else if (snapshot.hasError) {
                                    return Text('Error: ${snapshot.error}');
                                  } else {
                                    //final items = snapshot.data ?? <BloodPressure>[];
                                    final List<FlSpot> systolicData = [];
                                    final List<FlSpot> diastolicData = [];
                                    const int range = 30;
                                    //Reverse the list so graph appears left to right
                                    final rawData =
                                        snapshot.data!.reversed.toList();
                                    //List<dynamic> jsonList = jsonDecode(rawData);
                                    //print(rawData.toList().toString());
                                    List<String> dateData = [];
                                    List<FlSpot> normalSystolic = [
                                      for (int i = 0; i <= range; i++)
                                        FlSpot(i.toDouble(), 120.toDouble())
                                    ];
                                    List<FlSpot> normalDiastolic = [
                                      for (int i = 0; i <= range; i++)
                                        FlSpot(i.toDouble(), 80.toDouble())
                                    ];
                                    for (int i = 0; i < rawData.length; i++) {
                                      // final content =
                                      //     jsonDecode(rawData[i].content.toString());
                                      //print(normalSystolic);
                                      final systolic = rawData[i]
                                          .content
                                          .systolic
                                          .toDouble();
                                      //print(content['systolic'].toString());
                                      final diastolic = rawData[i]
                                          .content
                                          .diastolic
                                          .toDouble();
                                      final dates =
                                          '${DateTime.parse((rawData[i].date)).month}-${DateTime.parse((rawData[i].date)).day}';
                                      //print(content['diastolic'].toString());
                                      //final dates = item['date'].toString();

                                      //print(systolic + diastolic);

                                      //Assuming you want to plot points based on their order in the dataset
                                      systolicData
                                          .add(FlSpot(i.toDouble(), systolic));
                                      diastolicData
                                          .add(FlSpot(i.toDouble(), diastolic));
                                      //print(dates.toString());
                                      dateData.add(dates.toString());
                                    }
                                    //print(systolicData);
                                    return LineChart(
                                      LineChartData(
                                        minX: 0,
                                        maxX: range.toDouble(),
                                        minY: 0,
                                        maxY: 200,
                                        titlesData: FlTitlesData(
                                            show: true,
                                            topTitles: const AxisTitles(
                                                sideTitles: SideTitles(
                                                    showTitles: false)),
                                            rightTitles: const AxisTitles(
                                                sideTitles: SideTitles(
                                                    showTitles: false)),
                                            leftTitles: const AxisTitles(
                                                sideTitles: SideTitles(
                                                    interval: 10,
                                                    showTitles: true,
                                                    reservedSize: 35)),
                                            bottomTitles: AxisTitles(
                                              sideTitles: SideTitles(
                                                interval: 1,
                                                reservedSize: 50,
                                                showTitles: true,
                                                getTitlesWidget:
                                                    ((value, meta) {
                                                  return SideTitleWidget(
                                                    axisSide: meta.axisSide,
                                                    child: RotatedBox(
                                                      quarterTurns: 3,
                                                      child: (value >=
                                                              dateData.length)
                                                          ? const Text('')
                                                          : Text(dateData[
                                                              value.toInt()]),
                                                    ),
                                                  );
                                                }),
                                              ),
                                            )),
                                        gridData: FlGridData(
                                            show: true,
                                            drawHorizontalLine: true,
                                            getDrawingHorizontalLine: (value) {
                                              return const FlLine(
                                                  color: Color.fromARGB(
                                                      255, 30, 255, 0),
                                                  strokeWidth: .25);
                                            },
                                            getDrawingVerticalLine: (value) {
                                              return const FlLine(
                                                  color: Color.fromARGB(
                                                      255, 30, 255, 0),
                                                  strokeWidth: .25);
                                            },
                                            drawVerticalLine: true,
                                            verticalInterval: 1,
                                            horizontalInterval: 10),
                                        //titlesData: const FlTitlesData(show: true),
                                        borderData: FlBorderData(
                                          show: true,
                                          border: Border.all(
                                              color: Colors.black, width: 0.25),
                                        ),
                                        lineBarsData: [
                                          LineChartBarData(
                                            spots: normalSystolic,
                                            color: Colors.green,
                                            barWidth: 1,
                                            isStrokeCapRound: true,
                                            dotData:
                                                const FlDotData(show: false),
                                            belowBarData: BarAreaData(
                                              applyCutOffY: true,
                                              show: true,
                                              cutOffY: 80,
                                              gradient: RadialGradient(
                                                colors: AppColors
                                                    .safegradientColors
                                                    .map((color) =>
                                                        color.withOpacity(0.6))
                                                    .toList(),
                                              ),
                                            ),
                                          ),
                                          LineChartBarData(
                                            spots: systolicData,
                                            isCurved: true,
                                            color: AppColors.systolicGraph,
                                            barWidth: 2,
                                            isStrokeCapRound: true,
                                            dotData: FlDotData(
                                                show: _prefs?.getBool(
                                                        'graphDots') ??
                                                    true),
                                            belowBarData: BarAreaData(
                                              applyCutOffY: true,
                                              show: true,
                                              cutOffY: 130,
                                              gradient: RadialGradient(
                                                colors: AppColors
                                                    .cautiongradientColors
                                                    .map((color) =>
                                                        color.withOpacity(0.6))
                                                    .toList(),
                                              ),
                                            ),
                                          ),
                                          LineChartBarData(
                                            spots: normalDiastolic,
                                            color: Colors.green,
                                            barWidth: 1,
                                            isStrokeCapRound: true,
                                            dotData:
                                                const FlDotData(show: false),
                                          ),
                                          LineChartBarData(
                                            spots: diastolicData,
                                            isCurved: true,
                                            color: AppColors.diastolicGraph,
                                            barWidth: 2,
                                            isStrokeCapRound: true,
                                            dotData: FlDotData(
                                                show: _prefs?.getBool(
                                                        'graphDots') ??
                                                    true),
                                            belowBarData: BarAreaData(
                                              applyCutOffY: true,
                                              show: true,
                                              cutOffY: 90,
                                              gradient: RadialGradient(
                                                colors: AppColors
                                                    .cautiongradientColors
                                                    .map((color) =>
                                                        color.withOpacity(0.6))
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
                            LegendsListWidget(
                              width: 3,
                              legends: [
                                Legend('Systolic', AppColors.systolicGraph),
                                Legend('Diastolic', AppColors.diastolicGraph),
                                Legend(
                                    'Normal Range', AppColors.saferangeColor),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ),
            )));
  }
}
