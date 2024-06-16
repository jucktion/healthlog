import 'package:flutter/material.dart';
import 'package:healthlog/data/colors.dart';
import 'package:healthlog/data/db.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:healthlog/model/sugar.dart';
import 'package:healthlog/view/sugar/sugar_helper.dart';
import 'package:healthlog/view/theme/globals.dart';

class SugarGraph extends StatefulWidget {
  final int userid;
  const SugarGraph({super.key, required this.userid});

  @override
  State<SugarGraph> createState() => _SugarGraphState();
}

class _SugarGraphState extends State<SugarGraph> {
  final GlobalKey<RefreshIndicatorState> _refreshIndicatorKey =
      GlobalKey<RefreshIndicatorState>();

  //final int _range = 30;
  //List<FlSpot> normalSystolic = List.filled(11, FlSpot(for (int i = 1; i <= 11; i++) i,120.toDouble()));

  List<FlSpot> dateData = [];

  late DatabaseHandler handler;
  late Future<List<Sugar>> _sg;
  bool _retrived = false;

  List<Color> normalgradientColors = [
    const Color(0xff23b6e6),
    const Color(0xff02d39a)
  ];
  List<Color> cautiongradientColors = [
    const Color.fromARGB(255, 240, 182, 107),
    const Color.fromARGB(255, 230, 74, 35)
  ];

  @override
  void initState() {
    super.initState();
    handler = DatabaseHandler.instance;
    handler.initializeDB().whenComplete(() async {
      setState(() {
        _sg = getList();
        _retrived = true;
      });
    });
  }

  Future<List<Sugar>> getList() async {
    return await handler.sgHistoryGraph(widget.userid);
  }

  Future<void> _onRefresh() async {
    setState(() {
      _sg = getList();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          title: const Text('Blood Glucose Graph'),
        ),
        floatingActionButton: FloatingActionButton(
          onPressed: () {
            SGHelper.statefulBpBottomModal(context,
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
              child: !_retrived
                  ? const Text('Content is not loaded yet')
                  : SizedBox(
                      height: MediaQuery.of(context).size.height / 1.25,
                      child: Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            SizedBox(
                              height: MediaQuery.of(context).size.height / 3,
                              width: MediaQuery.of(context).size.width,
                              child: FutureBuilder<List<Sugar>>(
                                future: _sg,
                                builder: (BuildContext context,
                                    AsyncSnapshot<List<Sugar>> snapshot) {
                                  if (snapshot.connectionState ==
                                      ConnectionState.waiting) {
                                    return const Center(
                                      child: CircularProgressIndicator(),
                                    );
                                  } else if (snapshot.hasError) {
                                    return Text('Error: ${snapshot.error}');
                                  } else {
                                    //final items = snapshot.data ?? <BloodPressure>[];
                                    final List<FlSpot> beforeFastData = [];
                                    final List<FlSpot> afterFastData = [];
                                    const int range = 30;
                                    final rawData = snapshot.data!;
                                    //List<dynamic> jsonList = jsonDecode(rawData);
                                    //print(rawData.toList().toString());
                                    Set<String> dateData = {};
                                    // List<FlSpot> normalBeforeData = [
                                    //   for (int i = 0; i <= _range; i++)
                                    //     FlSpot(i.toDouble(), 110.toDouble())
                                    // ];
                                    // List<FlSpot> normalAfterData = [
                                    //   for (int i = 0; i <= _range; i++)
                                    //     FlSpot(i.toDouble(), 140.toDouble())
                                    // ];
                                    String dates = '';
                                    int j = 0;
                                    for (int i = 0; i < rawData.length; i++) {
                                      // final content =
                                      //     jsonDecode(rawData[i].content.toString());
                                      //print(normalSystolic);

                                      if (rawData[i].content.beforeAfter ==
                                          'before') {
                                        final beforeFast = double.parse(
                                            rawData[i]
                                                .content
                                                .reading
                                                .toStringAsFixed(2));
                                        beforeFastData.add(
                                            FlSpot(j.toDouble(), beforeFast));
                                      }
                                      //print(content['systolic'].toString());
                                      if (rawData[i].content.beforeAfter ==
                                          'after') {
                                        final afterFast = double.parse(
                                            rawData[i]
                                                .content
                                                .reading
                                                .toStringAsFixed(2));
                                        if ('${DateTime.parse((rawData[i].date)).month}-${DateTime.parse((rawData[i].date)).day}' ==
                                            dates) {
                                          afterFastData.add(FlSpot(
                                              (j - 1).toDouble(), afterFast));
                                          j--;
                                        } else {
                                          afterFastData.add(FlSpot(
                                              (j).toDouble(), afterFast));
                                        }
                                      }
                                      j++;
                                      dates =
                                          '${DateTime.parse((rawData[i].date)).month}-${DateTime.parse((rawData[i].date)).day}';

                                      //print(content['diastolic'].toString());
                                      //final dates = item['date'].toString();

                                      //print(systolic + diastolic);

                                      //Assuming you want to plot points based on their order in the dataset

                                      //print(dates.toString());
                                      dateData.add(dates);
                                    }
                                    //

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
                                                          : Text(dateData
                                                                  .toList()[
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
                                              color: Colors.black, width: 1),
                                        ),
                                        lineBarsData: [
                                          LineChartBarData(
                                            spots: beforeFastData,
                                            //isCurved: true,
                                            color: AppColors.beforeFastColor,
                                            barWidth: 2,
                                            isStrokeCapRound: true,
                                            belowBarData: BarAreaData(
                                              applyCutOffY: true,
                                              show: true,
                                              cutOffY: 110,
                                              gradient: RadialGradient(
                                                colors: cautiongradientColors
                                                    .map((color) =>
                                                        color.withOpacity(0.3))
                                                    .toList(),
                                              ),
                                            ),
                                            //dotData: const FlDotData(show: false),
                                          ),
                                          LineChartBarData(
                                            spots: afterFastData,
                                            isCurved: true,
                                            color: AppColors.afterFastColor,
                                            barWidth: 2,
                                            isStrokeCapRound: true,
                                            belowBarData: BarAreaData(
                                              applyCutOffY: true,
                                              show: true,
                                              cutOffY: 140,
                                              gradient: RadialGradient(
                                                colors: cautiongradientColors
                                                    .map((color) =>
                                                        color.withOpacity(0.3))
                                                    .toList(),
                                              ),
                                            ),
                                            //dotData: const FlDotData(show: false),
                                          ),
                                        ],
                                      ),
                                    );
                                  }
                                },
                              ),
                            ),
                            LegendsListWidget(
                              width: 2,
                              legends: [
                                Legend('Fasting (60-110)',
                                    AppColors.beforeFastColor),
                                Legend('After Eating (70-140)',
                                    AppColors.afterFastColor),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ),
            )));
  }
}
