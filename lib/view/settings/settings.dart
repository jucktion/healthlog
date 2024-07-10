import 'package:flutter/material.dart';
import 'package:healthlog/data/db.dart';
import 'package:shared_preferences/shared_preferences.dart';

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

  // void _setPrefs() async {
  //   _prefs?.setString('first', 'value');
  // }

  // void _getPrefs() async {
  //   setState(() {
  //     _data = _prefs?.getString('first') ?? '';
  //   });
  // }

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
                children: [generalSettings(), dataSettings(), aboutSettings()],
              ),
            ),
          );
  }

  Widget generalSettings() {
    return SizedBox(
      child: Column(
        children: [
          const Text(
            'General',
            style: TextStyle(
              fontSize: 25,
            ),
          ),
          const Divider(
            indent: 20,
            endIndent: 20,
            color: Colors.black45,
            thickness: 1,
            height: 10,
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Padding(
                padding: EdgeInsets.only(left: 18.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Theme Design',
                      style: TextStyle(fontSize: 20),
                    ),
                    Text(
                      'Choose the design of the app',
                      style: TextStyle(fontSize: 15),
                    ),
                  ],
                ),
              ),
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
              const Padding(
                padding: EdgeInsets.only(left: 18.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Show Dots on Graph',
                      style: TextStyle(fontSize: 20),
                    ),
                    Text(
                      'Graph should have dots',
                      style: TextStyle(fontSize: 15),
                    ),
                  ],
                ),
              ),
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
            color: Colors.black45,
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
                        style: TextStyle(fontSize: 15),
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
                        style: TextStyle(fontSize: 15),
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
                        style: TextStyle(fontSize: 15),
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

  Widget aboutSettings() {
    return const SizedBox(
      child: Column(
        children: [
          Text(
            'About',
            style: TextStyle(
              fontSize: 25,
            ),
          ),
          Divider(
            indent: 20,
            endIndent: 20,
            color: Colors.black45,
            thickness: 1,
            height: 10,
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Padding(
                padding: EdgeInsets.only(left: 18.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Version',
                      style: TextStyle(fontSize: 20),
                    ),
                    Text(
                      '0.1.5',
                      style: TextStyle(fontSize: 15),
                    ),
                  ],
                ),
              ),
            ],
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Padding(
                padding: EdgeInsets.only(left: 18.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Website',
                      style: TextStyle(fontSize: 20),
                    ),
                    Text(
                      'https://www.jucktion.com/',
                      style: TextStyle(fontSize: 15),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
