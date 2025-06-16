import 'package:flutter/material.dart';
import 'package:healthlog/view/theme/colors.dart';
import 'package:healthlog/data/db.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:healthlog/model/sugar.dart';
import 'package:healthlog/view/sugar/sugar_helper.dart';
import 'package:healthlog/view/theme/globals.dart';
import 'package:shared_preferences/shared_preferences.dart';

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
  late Future<String> _user;
  SharedPreferences? _prefs;
  bool _retrived = false;
  bool _prefLoaded = false;

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
      _sg = getList();
      setState(() {
        _retrived = true;
        _user = getName();
      });
    });
    _initPrefs();
  }

  Future<String> getName() async {
    return await handler.getUserName(widget.userid);
  }

  void _initPrefs() async {
    _prefs = await SharedPreferences.getInstance();
    setState(() {
      _prefLoaded = true;
    });
  }

  Future<List<Sugar>> getList() async {
    return await handler.sgHistoryGraph(widget.userid);
  }

  Future<void> _onRefresh() async {
    _sg = getList();
    setState(() {
      _retrived = true;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          title: !_retrived
              ? const Text('User log')
              : FutureBuilder<String>(
                  future: _user,
                  builder:
                      (BuildContext context, AsyncSnapshot<String> snapshot) {
                    if (snapshot.connectionState == ConnectionState.done) {
                      // Check if an error occurred.
                      if (snapshot.hasError) {
                        return const Text('Error');
                      }
                      // Return the retrieved title.
                      return Text("${snapshot.data}'s Sugar Graph");
                    } else {
                      return const CircularProgressIndicator();
                    }
                  },
                ),
        ),
        floatingActionButton: FloatingActionButton(
          onPressed: () {
            SGHelper.statefulSgBottomModal(context,
                userid: widget.userid,
                callback: () {},
                refreshIndicatorKey: _refreshIndicatorKey,
                prefs: _prefs);
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
                                    double sugarBeforeHigh =
                                        _prefs!.getDouble('sugarBeforeHigh') ??
                                            110;
                                    double sugarAfterHigh =
                                        _prefs!.getDouble('sugarAfterHigh') ??
                                            140;

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
                                          dataunit,
                                          rawData[i].content.reading,
                                          widget.unit,
                                        ).toStringAsFixed(2));
                                        beforeFastData.add(
                                            FlSpot(j.toDouble(), beforeFast));
                                      }
                                      //print(content['systolic'].toString());

                                      if (rawData[i].content.beforeAfter ==
                                          'after') {
                                        double afterFast = double.parse(
                                            GlobalMethods.convertUnit(
                                          dataunit,
                                          rawData[i].content.reading,
                                          widget.unit,
                                        ).toStringAsFixed(2));

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
                                                    meta: TitleMeta(
                                                        min: 0,
                                                        max: 1,
                                                        parentAxisSize: 1,
                                                        axisPosition: 1,
                                                        appliedInterval: 1,
                                                        sideTitles: SideTitles(
                                                            showTitles: true),
                                                        formattedValue: '',
                                                        axisSide:
                                                            AxisSide.bottom,
                                                        rotationQuarterTurns:
                                                            3),
                                                    child: Text((value >=
                                                            dateData.length)
                                                        ? ''
                                                        : dateData
                                                            .toList()[
                                                                value.toInt()]
                                                            .toString()),
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
                                              cutOffY:
                                                  GlobalMethods.convertUnit(
                                                      'mg/dL',
                                                      sugarBeforeHigh,
                                                      widget.unit),
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
                                              cutOffY:
                                                  GlobalMethods.convertUnit(
                                                      'mg/dL',
                                                      sugarAfterHigh,
                                                      widget.unit),
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
                                        : 'After (3.88-7.77)',
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
