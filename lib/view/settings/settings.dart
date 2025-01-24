import 'package:flutter/material.dart';
import 'package:healthlog/data/db.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:url_launcher/url_launcher.dart';

class SettingScreen extends StatefulWidget {
  const SettingScreen({super.key});

  @override
  State<SettingScreen> createState() => _SettingScreenState();
}

class _SettingScreenState extends State<SettingScreen> {
  SharedPreferences? _prefs;
  bool _graphDots = false;
  bool _prefLoaded = false;
  bool _backupDB = false;
  double sugarMax = 200;
  RangeValues sugarBeforeRange = RangeValues(60, 110);
  RangeValues sugarAfterRange = RangeValues(70, 140);
  //Cholesterol
  double totalCholesterolHigh = 230;
  double totalCholesterolMax = 300;
  double tagHigh = 200;
  double tagMax = 700;
  double hdlMax = 100;
  RangeValues hdlRange = RangeValues(40, 60);
  double ldlHigh = 100;
  double ldlMax = 200;
  double nonHdlHigh = 130;
  double nonHdlMax = 200;

  //Renal Function Test
  RangeValues bunRange = RangeValues(4.6, 23.5);
  RangeValues ureaRange = RangeValues(10, 50);
  RangeValues creatinineRange = RangeValues(0.6, 1.2);
  RangeValues sodiumRange = RangeValues(135, 145);
  RangeValues potassiumRange = RangeValues(3.5, 5.0);
  double bunMax = 50;
  double ureaMax = 100;
  double creatinineMax = 5;
  double sodiumMax = 200;
  double potassiumMax = 10;

  @override
  void initState() {
    super.initState();
    _initPrefs();
  }

  void _initPrefs() async {
    _prefs = await SharedPreferences.getInstance();
    setState(() {
      _prefLoaded = true;
    });
  }

  Future<void> _launchUrl(String url) async {
    if (!await launchUrl(Uri.parse(url))) {
      throw Exception('Could not launch $url');
    }
  }

  @override
  Widget build(BuildContext context) {
    return !_prefLoaded
        ? const Center(child: CircularProgressIndicator())
        : Scaffold(
            appBar: AppBar(
              title: const Text('Settings'),
            ),
            body: SingleChildScrollView(
              child: Column(
                children: [
                  generalSettings(),
                  sugarSettings(),
                  cholesterolSettings(),
                  rftSettings(),
                  dataSettings(),
                  aboutSettings()
                ],
              ),
            ),
          );
  }

  Widget generalSettings() {
    return SizedBox(
      child: Column(
        children: [
          heading('General'),
          // Row(
          //   mainAxisAlignment: MainAxisAlignment.spaceBetween,
          //   children: [
          //     paddedText('Theme Design', 'Placeholder, does nothing for now'),
          //     Switch(
          //         value: _theme,
          //         onChanged: (value) {
          //           setState(() {
          //             _theme = value;
          //           });
          //         })
          //   ],
          // ),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              paddedText(
                  'Save on each entry', 'Backup db to disk on every entry'),
              Switch(
                  value: _prefs?.getBool('alwaysbackupDB') ?? _backupDB,
                  onChanged: (value) {
                    _prefs?.setBool('alwaysbackupDB', value);
                    setState(() {
                      _backupDB = value;
                    });
                  })
            ],
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              paddedText(
                  'Show Dots on Graph', 'Graph should have dots for entries'),
              Switch(
                  value: _prefs?.getBool('graphDots') ?? _graphDots,
                  onChanged: (value) {
                    _prefs?.setBool('graphDots', value);
                    setState(() {
                      _graphDots = value;
                    });
                  })
            ],
          ),
        ],
      ),
    );
  }

  Widget sugarSettings() {
    return SizedBox(
      child: Column(
        children: [
          heading('Blood Glucose/Sugar'),
          setUnit('sugarUnit'),
          Padding(
            padding: const EdgeInsets.only(left: 15.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                setRange(
                    header: 'Glucose Range (fasting):',
                    range: sugarBeforeRange,
                    step: 1.0,
                    min: 1,
                    max: sugarMax,
                    setLow: 'sugarBeforeLow',
                    setHigh: 'sugarBeforeHigh'),
                setRange(
                    header: 'Glucose Range (PP):',
                    range: sugarAfterRange,
                    step: 1.0,
                    min: 1,
                    max: sugarMax,
                    setLow: 'sugarAfterLow',
                    setHigh: 'sugarAfterHigh')
              ],
            ),
          )
        ],
      ),
    );
  }

  Widget cholesterolSettings() {
    return SizedBox(
      child: Column(
        children: [
          heading('Cholesterol'),
          setUnit('chlstrlUnit'),
          Padding(
            padding: const EdgeInsets.only(left: 15.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                setHigh(
                  header: 'Total Cholesterol High Limit:',
                  high: totalCholesterolHigh,
                  step: 1.0,
                  min: 150,
                  max: totalCholesterolMax,
                  setHigh: 'totalCholesterolHigh',
                ),
                setHigh(
                    header: 'Triacyglycerol High Limit:',
                    high: tagHigh,
                    step: 1.0,
                    min: 100,
                    max: tagMax,
                    setHigh: 'tagHigh'),
                setRange(
                    header: 'HDL Range:',
                    range: hdlRange,
                    step: 1.0,
                    min: 1,
                    max: hdlMax,
                    setLow: 'hdlLow',
                    setHigh: 'hdlHigh'),
                setHigh(
                    header: 'LDL High Limit:',
                    high: ldlHigh,
                    step: 1.0,
                    min: 90,
                    max: ldlMax,
                    setHigh: 'ldlHigh'),
                setHigh(
                    header: 'Non-HDL High Limit:',
                    high: nonHdlHigh,
                    step: 1.0,
                    min: 100,
                    max: nonHdlMax,
                    setHigh: 'nonHdlHigh'),
              ],
            ),
          )
        ],
      ),
    );
  }

  Widget rftSettings() {
    return SizedBox(
      child: Column(
        children: [
          heading('Renal Function'),
          setUnit('rftUnit'),
          Padding(
            padding: const EdgeInsets.only(left: 15.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                setRange(
                    header: 'BUN:',
                    range: bunRange,
                    step: .1,
                    min: 1,
                    max: bunMax,
                    setLow: 'bunLow',
                    setHigh: 'bunHigh'),
                setRange(
                    header: 'Urea:',
                    range: ureaRange,
                    step: 1.0,
                    min: 1,
                    max: ureaMax,
                    setLow: 'ureaLow',
                    setHigh: 'ureaHigh'),
                setRange(
                    header: 'Creatinine:',
                    range: creatinineRange,
                    step: .1,
                    min: .1,
                    max: creatinineMax,
                    setLow: 'creatinineLow',
                    setHigh: 'creatinineHigh'),
                setRange(
                    header: 'Sodium (mmol/L or mEq/L):',
                    range: sodiumRange,
                    step: 1.0,
                    min: 75,
                    max: sodiumMax,
                    setLow: 'sodiumLow',
                    setHigh: 'sodiumHigh'),
                setRange(
                    header: 'Potassium (mmol/L or mEq/L):',
                    range: potassiumRange,
                    step: .1,
                    min: 1,
                    max: potassiumMax,
                    setLow: 'potassiumLow',
                    setHigh: 'potassiumHigh')
              ],
            ),
          )
        ],
      ),
    );
  }

  Widget dataSettings() {
    return SizedBox(
      child: Column(
        children: [
          const Text(
            'Data',
            style: TextStyle(
              fontSize: 25,
            ),
          ),
          const Divider(
            indent: 20,
            endIndent: 20,
            thickness: 1,
            height: 10,
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Padding(
                padding: const EdgeInsets.only(left: 18.0),
                child: InkWell(
                  onTap: () {
                    DatabaseHandler.instance.backupDB();
                  },
                  child: const Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Backup Data',
                        style: TextStyle(fontSize: 20),
                      ),
                      Text(
                        'A db file is saved to Stroage/Healthlog/healthlob.db',
                        style: TextStyle(fontSize: 10),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Padding(
                padding: const EdgeInsets.only(left: 18.0),
                child: InkWell(
                  onTap: () {
                    DatabaseHandler.instance.restoreDb();
                  },
                  child: const Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Restore Data',
                        style: TextStyle(fontSize: 20),
                      ),
                      Text(
                        'Stroage/Healthlog/healthlob.db must be available',
                        style: TextStyle(fontSize: 10),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Padding(
                padding: const EdgeInsets.only(left: 18.0),
                child: InkWell(
                  onTap: () {
                    DatabaseHandler.instance.deleteDB();
                  },
                  child: const Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Reset Data',
                        style: TextStyle(fontSize: 20),
                      ),
                      Text(
                        'All data is reset for a fresh start',
                        style: TextStyle(fontSize: 10),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  //Currently not used as the void function executes consecutively
  Widget dataSettingss() {
    return SizedBox(
      child: Column(
        children: [
          heading('Data'),
          dataRow(DatabaseHandler.instance.backupDB(), 'Backup Data',
              'A db file is saved to Stroage/Healthlog/healthlob.db'),
          dataRow(DatabaseHandler.instance.restoreDb(), 'Restore Data',
              'Stroage/Healthlog/healthlob.db must be available'),
          dataRow(DatabaseHandler.instance.deleteDB(), 'Reset Data',
              'All data is reset for a fresh start'),
        ],
      ),
    );
  }

  Widget aboutSettings() {
    String homeUrl = 'https://www.jucktion.com';
    String gitUrl = 'https://github.com/nirose/healthlog';
    return SizedBox(
      child: Column(
        children: [
          heading('About'),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [paddedText('Version', '0.33.0')],
          ),
          launchWeb(homeUrl, 'Website', 'https://www.jucktion.com/'),
          launchWeb(gitUrl, 'Issues/Discussion',
              'https://github.com/jucktion/healthlog'),
        ],
      ),
    );
  }

  Widget heading(String text) {
    return Column(
      children: [
        Text(
          text,
          style: TextStyle(fontSize: 25),
        ),
        const Divider(
          indent: 10,
          endIndent: 10,
          thickness: 1,
          height: 10,
        ),
      ],
    );
  }

  Widget headText(String text) {
    return Text(
      text,
      style: TextStyle(fontSize: 20),
      //textAlign: TextAlign.left,
    );
  }

  Widget head2Text(String text) {
    return Text(
      text,
      style: TextStyle(fontSize: 15),
      //textAlign: TextAlign.left,
    );
  }

  Widget subText(String text) {
    return Text(text, style: TextStyle(fontSize: 10));
  }

  //Currently not used as the void function executes consecutively
  Widget dataRow(void func, String head, String sub) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Padding(
          padding: const EdgeInsets.only(left: 18.0),
          child: InkWell(
            onTap: () {
              func;
            },
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                headText(head),
                subText(sub),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget launchWeb(String url, String head, String sub) {
    return InkWell(
      onTap: () => _launchUrl(url),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Padding(
            padding: EdgeInsets.only(left: 18.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                headText(head),
                subText(sub),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget setUnit(String unit) {
    const List<String> list = <String>['mg/dL', 'mmol/L'];
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Padding(
          padding: EdgeInsets.only(left: 18.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [headText('Preferred unit'), subText('mg/dL or mmol/L')],
          ),
        ),
        DropdownMenu<String>(
          initialSelection: _prefs?.getString(unit) ?? list.first,
          dropdownMenuEntries:
              list.map<DropdownMenuEntry<String>>((String value) {
            return DropdownMenuEntry<String>(
              value: value,
              label: value,
            );
          }).toList(),
          onSelected: (value) {
            _prefs?.setString(unit, value.toString());
            setState(
              () {
                value = value.toString();
              },
            );
          },
        ),
      ],
    );
  }

  Widget setRange(
      {required String header,
      required RangeValues range,
      required double step,
      required double min,
      required double max,
      required String setLow,
      required String setHigh}) {
    range = RangeValues(_prefs!.getDouble(setLow) ?? range.start,
        _prefs!.getDouble(setHigh) ?? range.end);
    double roundToStep(double value) {
      return (min + (step * ((value - min) / step))).clamp(min, max);
    }

    return StatefulBuilder(
      builder: (context, StateSetter setState) => Center(
        child: Center(
          child: Column(
            children: [
              Row(
                spacing: 5,
                children: [
                  head2Text(header),
                  Text(
                    textAlign: TextAlign.center,
                    '${range.start.toStringAsFixed(2)} - ${range.end.toStringAsFixed(2)}',
                    style: TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
              RangeSlider(
                values: range,
                labels: RangeLabels(range.start.toStringAsFixed(2),
                    range.end.toStringAsFixed(2)),
                min: min,
                max: max,
                //Change 0.1 with movement
                divisions: ((max - min) / step).toInt(),
                onChanged: (newValues) {
                  setState(
                    () {
                      range = RangeValues(roundToStep(newValues.start),
                          roundToStep(newValues.end));

                      _prefs?.setDouble(setLow,
                          double.parse(newValues.start.toStringAsFixed(2)));
                      _prefs?.setDouble(setHigh,
                          double.parse(newValues.end.toStringAsFixed(2)));
                      // labels = RangeLabels(
                      //     newValues.start.toString(), newValues.end.toString());
                      //print('${newValues.start}, ${newValues.end}');
                    },
                  );
                },
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget setHigh({
    required String header,
    required double high,
    required double step,
    required double min,
    required double max,
    required String setHigh,
  }) {
    return StatefulBuilder(
      builder: (context, StateSetter setState) => Center(
        child: Center(
          child: Column(
            children: [
              Row(
                spacing: 5,
                children: [
                  head2Text(header),
                  Text(
                    textAlign: TextAlign.center,
                    high.toStringAsFixed(2),
                    style: TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
              Slider(
                value: high,
                label: high.toStringAsFixed(2),
                min: min,
                max: max,
                //Change 0.1 with movement
                divisions: ((max - min) / step).toInt(),
                onChanged: (newValue) {
                  setState(
                    () {
                      high = newValue;

                      _prefs?.setDouble(
                          setHigh, double.parse(newValue.toStringAsFixed(2)));

                      // labels = RangeLabels(
                      //     newValues.start.toString(), newValues.end.toString());
                      //print('${newValues.start}, ${newValues.end}');
                    },
                  );
                },
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget paddedText(String head, String sub) {
    return Padding(
      padding: EdgeInsets.only(left: 18.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          headText(head),
          subText(sub),
        ],
      ),
    );
  }
}
