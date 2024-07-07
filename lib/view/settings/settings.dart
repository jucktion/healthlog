import 'package:flutter/material.dart';
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
                children: [generalSettings()],
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
}
