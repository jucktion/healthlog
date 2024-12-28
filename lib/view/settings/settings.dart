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
  bool _theme = false;
  bool _graphDots = true;
  bool _prefLoaded = false;
  bool _backupDB = false;
  double sugarMax = 200;
  RangeValues sugarBeforeRange = RangeValues(60, 110);
  RangeValues sugarAfterRange = RangeValues(70, 140);
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
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              paddedText('Theme Design', 'Placeholder, does nothing for now'),
              Switch(
                  value: _theme,
                  onChanged: (value) {
                    setState(() {
                      _theme = value;
                    });
                  })
            ],
          ),
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
          heading('Blood Glucose Settings'),
          setUnit('sugarUnit'),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              headText('Glucose Range (fasting)'),
              setRange(sugarBeforeRange, 1, sugarMax, _prefs, 'sugarBeforeLow',
                  'sugarBeforeHigh'),
              headText('Glucose Range After Fasting (PP)'),
              setRange(sugarAfterRange, 1, sugarMax, _prefs, 'sugarAfterLow',
                  'sugarAfterHigh')
            ],
          )
        ],
      ),
    );
  }

  Widget cholesterolSettings() {
    return SizedBox(
      child: Column(
        children: [
          heading('Cholesterol Settings'),
          setUnit('chlstrlUnit'),
        ],
      ),
    );
  }

  Widget rftSettings() {
    return SizedBox(
      child: Column(
        children: [
          heading('Renal Function Settings'),
          setUnit('rftUnit'),
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
            children: [paddedText('Version', '0.1.5')],
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
      textAlign: TextAlign.left,
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

  Widget setRange(RangeValues range, double min, double max,
      SharedPreferences? prefs, String setLow, String setHigh) {
    print(int.parse(max.toStringAsFixed(0)));
    return StatefulBuilder(
      builder: (context, StateSetter setState) => Center(
        child: RangeSlider(
            values: range,
            labels: RangeLabels(
                range.start.toStringAsFixed(2), range.end.toStringAsFixed(2)),
            min: min,
            max: max,
            divisions: (int.parse(max.toStringAsFixed(0)) * 10) - 10,
            onChanged: (newValues) {
              setState(() {
                range = newValues;
                prefs?.setDouble(
                    setLow, double.parse(newValues.start.toStringAsFixed(2)));
                prefs?.setDouble(
                    setHigh, double.parse(newValues.end.toStringAsFixed(2)));
                // labels = RangeLabels(
                //     newValues.start.toString(), newValues.end.toString());
                //print('${newValues.start}, ${newValues.end}');
              });
            }),
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
