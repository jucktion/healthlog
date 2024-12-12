import 'package:flutter/material.dart';
import 'package:healthlog/data/colors.dart';
import 'package:healthlog/data/db.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:healthlog/model/sugar.dart';
import 'package:healthlog/view/sugar/sugar_helper.dart';
import 'package:healthlog/view/theme/globals.dart';

class SugarGraph extends StatefulWidget {
  final int userid;
  final String unit;
  final bool dots;
  const SugarGraph(
      {super.key,
      required this.userid,
      required this.unit,
      required this.dots});

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
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            SizedBox(
                              height: MediaQuery.of(context).size.height / 3,
                              width: MediaQuery.of(context).size.width / 1.05,
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
                                    //Reverse the list so graph appears left to right
                                    final rawData =
                                        snapshot.data!.reversed.toList();
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
                                      final String dataunit =
                                          rawData[i].content.unit;
                                      if (rawData[i].content.beforeAfter ==
                                          'before') {
                                        double beforeFast = double.parse(
                                            GlobalMethods.convertUnit(
                                                    widget.unit,
                                                    dataunit,
                                                    rawData[i].content.reading)
                                                .toStringAsFixed(2));
                                        beforeFastData.add(
                                            FlSpot(j.toDouble(), beforeFast));
                                      }
                                      //print(content['systolic'].toString());

                                      if (rawData[i].content.beforeAfter ==
                                          'after') {
                                        double afterFast = double.parse(
                                            GlobalMethods.convertUnit(
                                                    widget.unit,
                                                    dataunit,
                                                    rawData[i].content.reading)
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
                                        maxY: widget.unit == 'mg/dL' ? 350 : 20,
                                        titlesData: FlTitlesData(
                                            show: true,
                                            topTitles: const AxisTitles(
                                                sideTitles: SideTitles(
                                                    showTitles: false)),
                                            rightTitles: const AxisTitles(
                                                sideTitles: SideTitles(
                                                    showTitles: false)),
                                            leftTitles: AxisTitles(
                                                sideTitles: SideTitles(
                                                    interval:
                                                        widget.unit == 'mg/dL'
                                                            ? 20
                                                            : 1,
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
                                              color: Colors.black, width: 0.25),
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
                                              cutOffY: widget.unit == 'mg/dL'
                                                  ? 110
                                                  : 6.11,
                                              gradient: RadialGradient(
                                                colors: cautiongradientColors
                                                    .map((color) =>
                                                        color.withAlpha(77))
                                                    .toList(),
                                              ),
                                            ),
                                            dotData:
                                                FlDotData(show: widget.dots),
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
                                              cutOffY: widget.unit == 'mg/dL'
                                                  ? 140
                                                  : 7.77,
                                              gradient: RadialGradient(
                                                colors: cautiongradientColors
                                                    .map((color) =>
                                                        color.withAlpha(77))
                                                    .toList(),
                                              ),
                                            ),
                                            dotData:
                                                FlDotData(show: widget.dots),
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
                                Legend(
                                    widget.unit == 'mg/dL'
                                        ? 'Fasting (60-110)'
                                        : 'Fasting (3.33-6.11)',
                                    AppColors.beforeFastColor),
                                Legend(
                                    widget.unit == 'mg/dL'
                                        ? 'After (70-140)'
                                        : 'After(3.88-7.77)',
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
