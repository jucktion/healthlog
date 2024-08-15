import 'package:flutter/material.dart';
import 'package:healthlog/data/colors.dart';
import 'package:healthlog/data/db.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:healthlog/model/cholesterol.dart';
import 'package:healthlog/view/cholesterol/cholesterol_helper.dart';
import 'package:healthlog/view/theme/globals.dart';

class CholesterolGraph extends StatefulWidget {
  final int userid;
  final bool dots;
  final String unit;
  const CholesterolGraph(
      {super.key,
      required this.userid,
      required this.dots,
      required this.unit});

  @override
  State<CholesterolGraph> createState() => _CholesterolGraphState();
}

class _CholesterolGraphState extends State<CholesterolGraph> {
  final GlobalKey<RefreshIndicatorState> _refreshIndicatorKey =
      GlobalKey<RefreshIndicatorState>();

  //final int _range = 30;
  //List<FlSpot> normalSystolic = List.filled(11, FlSpot(for (int i = 1; i <= 11; i++) i,120.toDouble()));

  List<FlSpot> dateData = [];

  late DatabaseHandler handler;
  late Future<List<Cholesterol>> _sg;
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
        _sg = getList();
        _retrived = true;
      });
    });
  }

  Future<List<Cholesterol>> getList() async {
    return await handler.chlstrlHistoryGraph(widget.userid);
  }

  void _initPrefs() async {
    setState(() {
      _prefLoaded = true;
    });
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
          title: const Text('Cholesterol Graph'),
        ),
        floatingActionButton: FloatingActionButton(
          onPressed: () {
            CHLSTRLHelper.statefulchlstrlBottomModal(context,
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
                              child: FutureBuilder<List<Cholesterol>>(
                                future: _sg,
                                builder: (BuildContext context,
                                    AsyncSnapshot<List<Cholesterol>> snapshot) {
                                  if (snapshot.connectionState ==
                                      ConnectionState.waiting) {
                                    return const Center(
                                      child: CircularProgressIndicator(),
                                    );
                                  } else if (snapshot.hasError) {
                                    return Text('Error: ${snapshot.error}');
                                  } else {
                                    //final items = snapshot.data ?? <BloodPressure>[];
                                    final List<FlSpot> totalData = [];
                                    final List<FlSpot> tagData = [];
                                    final List<FlSpot> hdlData = [];
                                    final List<FlSpot> ldlData = [];
                                    final List<FlSpot> nonhdlData = [];
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
                                    final fromUnit = rawData[0].content.unit;
                                    for (int i = 0; i < rawData.length; i++) {
                                      // final content =
                                      //     jsonDecode(rawData[i].content.toString());
                                      //print(normalSystolic);

                                      final total = double.parse(
                                          GlobalMethods.convertUnit(
                                                  widget.unit,
                                                  fromUnit,
                                                  rawData[i].content.total)
                                              .toStringAsFixed(2));
                                      totalData
                                          .add(FlSpot(j.toDouble(), total));

                                      final tag = double.parse(
                                          GlobalMethods.convertUnit(
                                                  widget.unit,
                                                  fromUnit,
                                                  rawData[i].content.tag)
                                              .toStringAsFixed(2));
                                      tagData.add(FlSpot(j.toDouble(), tag));

                                      final hdl = double.parse(
                                          GlobalMethods.convertUnit(
                                                  widget.unit,
                                                  fromUnit,
                                                  rawData[i].content.hdl)
                                              .toStringAsFixed(2));
                                      hdlData.add(FlSpot(j.toDouble(), hdl));
                                      final ldl = double.parse(
                                          GlobalMethods.convertUnit(
                                                  widget.unit,
                                                  fromUnit,
                                                  rawData[i].content.ldl)
                                              .toStringAsFixed(2));
                                      ldlData.add(FlSpot(j.toDouble(), ldl));

                                      final nonhdl = double.parse(
                                          GlobalMethods.convertUnit(
                                                  widget.unit,
                                                  fromUnit,
                                                  (rawData[i].content.total -
                                                      rawData[i].content.hdl))
                                              .toStringAsFixed(2));
                                      nonhdlData
                                          .add(FlSpot(j.toDouble(), nonhdl));

                                      //print(content['systolic'].toString());

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
                                        maxY: widget.unit == 'mg/dL' ? 500 : 15,
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
                                            spots: totalData,
                                            //isCurved: true,
                                            color: AppColors.totalChColor,
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
                                            dotData:
                                                FlDotData(show: widget.dots),
                                          ),
                                          LineChartBarData(
                                            spots: tagData,
                                            isCurved: true,
                                            color: AppColors.tagColor,
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
                                            dotData:
                                                FlDotData(show: widget.dots),
                                          ),
                                          LineChartBarData(
                                            spots: hdlData,
                                            isCurved: true,
                                            color: AppColors.hdlColor,
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
                                            dotData:
                                                FlDotData(show: widget.dots),
                                          ),
                                          LineChartBarData(
                                            spots: ldlData,
                                            isCurved: true,
                                            color: AppColors.ldlColor,
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
                                            dotData:
                                                FlDotData(show: widget.dots),
                                          ),
                                          LineChartBarData(
                                            spots: nonhdlData,
                                            isCurved: true,
                                            color: AppColors.nonhdlColor,
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
                                Legend('Total', AppColors.totalChColor),
                                Legend('TAG', AppColors.tagColor),
                                Legend('HDL', AppColors.hdlColor),
                                Legend('LDL', AppColors.ldlColor),
                                Legend('Non-HDL', AppColors.nonhdlColor),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ),
            )));
  }
}
