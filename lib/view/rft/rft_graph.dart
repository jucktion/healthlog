import 'package:flutter/material.dart';
import 'package:healthlog/view/theme/colors.dart';
import 'package:healthlog/data/db.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:healthlog/model/kidney.dart';
import 'package:healthlog/view/rft/rft_helper.dart';
import 'package:healthlog/view/theme/globals.dart';

class RFTGraph extends StatefulWidget {
  final int userid;
  final bool dots;
  final String unit;
  const RFTGraph(
      {super.key,
      required this.userid,
      required this.dots,
      required this.unit});

  @override
  State<RFTGraph> createState() => _RFTGraphState();
}

class _RFTGraphState extends State<RFTGraph> {
  final GlobalKey<RefreshIndicatorState> _refreshIndicatorKey =
      GlobalKey<RefreshIndicatorState>();

  //final int _range = 30;
  //List<FlSpot> normalSystolic = List.filled(11, FlSpot(for (int i = 1; i <= 11; i++) i,120.toDouble()));

  List<FlSpot> dateData = [];

  late DatabaseHandler handler;
  late Future<List<RenalFunction>> _rf;
  late Future<String> _user;
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
    _initPrefs();
    handler = DatabaseHandler.instance;
    handler.initializeDB().whenComplete(() async {
      setState(() {
        _rf = getList();

        _retrived = true;
        _user = getName();
      });
    });
  }

  Future<List<RenalFunction>> getList() async {
    return await handler.rftGraph(widget.userid);
  }

  Future<String> getName() async {
    return await handler.getUserName(widget.userid);
  }

  void _initPrefs() async {
    setState(() {
      _prefLoaded = true;
    });
  }

  Future<void> _onRefresh() async {
    setState(() {
      _rf = getList();
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
                      return Text("${snapshot.data}'s RFT Graph");
                    } else {
                      return const CircularProgressIndicator();
                    }
                  },
                ),
        ),
        floatingActionButton: FloatingActionButton(
          onPressed: () {
            RFTHelper.statefulRftBottomModal(context,
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
              child: !_retrived && _prefLoaded
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
                              child: FutureBuilder<List<RenalFunction>>(
                                future: _rf,
                                builder: (BuildContext context,
                                    AsyncSnapshot<List<RenalFunction>>
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
                                    final List<FlSpot> bunData = [];
                                    final List<FlSpot> ureaData = [];
                                    final List<FlSpot> creatinineData = [];
                                    final List<FlSpot> sodiumData = [];
                                    final List<FlSpot> potassiumData = [];
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
                                    final fromUnit = rawData[0].content.unit;
                                    for (int i = 0; i < rawData.length; i++) {
                                      // final content =
                                      //     jsonDecode(rawData[i].content.toString());
                                      //print(normalSystolic);

                                      final bun = double.parse(
                                          GlobalMethods.convertUnit(
                                        fromUnit,
                                        rawData[i].content.bun,
                                        widget.unit,
                                      ).toStringAsFixed(2));
                                      bunData.add(FlSpot(j.toDouble(), bun));

                                      final urea = double.parse(
                                          GlobalMethods.convertUnit(
                                        fromUnit,
                                        rawData[i].content.urea,
                                        widget.unit,
                                      ).toStringAsFixed(2));
                                      ureaData.add(FlSpot(j.toDouble(), urea));

                                      final creatinine = double.parse(
                                          GlobalMethods.convertUnit(
                                        fromUnit,
                                        rawData[i].content.creatinine,
                                        widget.unit,
                                      ).toStringAsFixed(2));
                                      creatinineData.add(
                                          FlSpot(j.toDouble(), creatinine));
                                      final sodium = double.parse(
                                          GlobalMethods.convertUnit(
                                        fromUnit,
                                        rawData[i].content.elements.sodium,
                                        widget.unit,
                                      ).toStringAsFixed(2));
                                      sodiumData
                                          .add(FlSpot(j.toDouble(), sodium));

                                      final potassium = double.parse(
                                          GlobalMethods.convertUnit(
                                        fromUnit,
                                        rawData[i].content.elements.potassium,
                                        widget.unit,
                                      ).toStringAsFixed(2));
                                      potassiumData
                                          .add(FlSpot(j.toDouble(), potassium));
                                      j++;
                                      dates =
                                          '${DateTime.parse((rawData[i].date)).month}-${DateTime.parse((rawData[i].date)).day}';

                                      dateData.add(dates);
                                    }
                                    //

                                    return LineChart(
                                      LineChartData(
                                        minX: 0,
                                        maxX: range.toDouble(),
                                        minY: 0,
                                        maxY: widget.unit == 'mg/dL' ? 200 : 15,
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
                                                            ? 50
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
                                            horizontalInterval: 50),
                                        //titlesData: const FlTitlesData(show: true),
                                        borderData: FlBorderData(
                                          show: true,
                                          border: Border.all(
                                              color: Colors.black, width: 0.25),
                                        ),
                                        lineBarsData: [
                                          LineChartBarData(
                                            spots: bunData,
                                            //isCurved: true,
                                            color: AppColors.bunRf,
                                            barWidth: 2,
                                            isStrokeCapRound: true,
                                            belowBarData: BarAreaData(
                                              applyCutOffY: true,
                                              show: true,
                                              cutOffY: 110,
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
                                            spots: ureaData,
                                            isCurved: true,
                                            color: AppColors.ureaRf,
                                            barWidth: 2,
                                            isStrokeCapRound: true,
                                            belowBarData: BarAreaData(
                                              applyCutOffY: true,
                                              show: true,
                                              cutOffY: 140,
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
                                            spots: creatinineData,
                                            isCurved: true,
                                            color: AppColors.creatinineRf,
                                            barWidth: 2,
                                            isStrokeCapRound: true,
                                            belowBarData: BarAreaData(
                                              applyCutOffY: true,
                                              show: true,
                                              cutOffY: 140,
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
                                            spots: sodiumData,
                                            isCurved: true,
                                            color: AppColors.sodiumRf,
                                            barWidth: 2,
                                            isStrokeCapRound: true,
                                            belowBarData: BarAreaData(
                                              applyCutOffY: true,
                                              show: true,
                                              cutOffY: 140,
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
                                            spots: potassiumData,
                                            isCurved: true,
                                            color: AppColors.potassiumRf,
                                            barWidth: 2,
                                            isStrokeCapRound: true,
                                            belowBarData: BarAreaData(
                                              applyCutOffY: true,
                                              show: true,
                                              cutOffY: 140,
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
                              width: 3,
                              legends: [
                                Legend('Bun', AppColors.totalChColor),
                                Legend('Urea', AppColors.tagColor),
                                Legend('Creatinine', AppColors.hdlColor),
                                Legend('Sodium', AppColors.ldlColor),
                                Legend('Potassium', AppColors.nonhdlColor),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ),
            )));
  }
}
