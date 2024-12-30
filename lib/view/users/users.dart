import 'package:flutter/material.dart';
import 'package:healthlog/view/theme/colors.dart';
import 'package:healthlog/view/profile/profile.dart';
import 'package:healthlog/view/settings/settings.dart';
import 'package:healthlog/view/theme/globals.dart';
import 'package:healthlog/view/users/add_user.dart';
import 'package:healthlog/data/db.dart';
import 'package:healthlog/model/user.dart';
import 'package:shared_preferences/shared_preferences.dart';

class UserScreen extends StatefulWidget {
  const UserScreen({super.key});

  @override
  State<UserScreen> createState() => _UserScreenState();
}

class _UserScreenState extends State<UserScreen> {
  late DatabaseHandler handler;
  late Future<List<User>> _user;
  final GlobalKey<RefreshIndicatorState> _refreshIndicatorKey =
      GlobalKey<RefreshIndicatorState>();
  bool _retrived = false;
  bool _prefLoaded = false;

  SharedPreferences? _prefs;
  @override
  void initState() {
    super.initState();
    _initPrefs();
    _checkFirstRun();
    handler = DatabaseHandler.instance;
    handler.initializeDB().whenComplete(() async {
      setState(() {
        _retrived = true;
        _user = getList();
        _onRefresh();
      });
    });
  }

  void _initPrefs() async {
    _prefs = await SharedPreferences.getInstance();
    setState(() {
      _prefLoaded = true;
    });
    // print('Removing firstRun');
    // _prefs?.remove('firstRun');
  }

  //Run this to set default preferences, so some UI elements aren't messed up
  void _checkFirstRun() async {
    final String standardUnit = 'mg/dL';
    const List<String> unitList = <String>[
      'rftUnit',
      'sugarUnit',
      'chlstrlUnit'
    ];
    //Runs only if firstRun pref is not found
    if (_prefs?.containsKey('firstRun') == false) {
      unitList
          .map(
            (unit) => _prefs?.setString(unit, standardUnit),
          )
          .toList();
      _prefs?.setBool('alwaysbackupDB', false);

      // Sugar defaults
      _prefs?.setDouble('sugarBeforeLow', 60.0);
      _prefs?.setDouble('sugarBeforeHigh', 110.0);
      _prefs?.setDouble('sugarAfterLow', 70.0);
      _prefs?.setDouble('sugarAfterHigh', 140.0);

      _prefs?.setBool('firstRun', true);
    }
  }

  Future<List<User>> getList() async {
    return await handler.users();
  }

  Future<void> _onRefresh() async {
    setState(() {
      _user = getList();
    });
  }

  void handleMenuOptionClick(BuildContext context, int value) {
    switch (value) {
      case 0:
        //print('Backup selected');
        DatabaseHandler.instance.backupDB();
        break;
      case 1:
        // print('Restore selected');
        DatabaseHandler.instance.restoreDb();
        break;
      case 2:
        // print('Reset selected');
        DatabaseHandler.instance.deleteDB();
        break;
      case 3:
        // print('Reset selected');
        Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => const SettingScreen()),
        );
        break;
      default:
      //print('Unknown');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Health Log'),
        actions: [
          IconButton(
            icon: const Icon(Icons.settings),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const SettingScreen()),
              );
            },
          )
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => const AddScreen()),
          );
        },
        backgroundColor: AppColors.floatingButton,
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
                  child: FutureBuilder<List<User>>(
                    future: _user,
                    builder: (BuildContext context,
                        AsyncSnapshot<List<User>> snapshot) {
                      if (snapshot.connectionState == ConnectionState.waiting) {
                        return const Center(
                          child: CircularProgressIndicator(),
                        );
                      } else if (snapshot.hasError) {
                        return Text('Error: ${snapshot.error}');
                      } else if (snapshot.data.toString() ==
                          List.empty().toString()) {
                        //print('${snapshot.data}');
                        return const Center(
                          child: Text(
                            'Add a User',
                            style: TextStyle(fontSize: 20),
                          ),
                        );
                      } else {
                        final items = snapshot.data ?? <User>[];
                        return Scrollbar(
                            child: RefreshIndicator(
                          onRefresh: _onRefresh,
                          child: ListView.builder(
                            itemCount: items.length,
                            itemBuilder: (BuildContext context, int index) {
                              return Dismissible(
                                direction: DismissDirection.startToEnd,
                                background: Container(
                                  color: Colors.red,
                                  alignment: Alignment.centerRight,
                                  padding: const EdgeInsets.symmetric(
                                      horizontal: 10.0),
                                  child: const Icon(Icons.delete_forever),
                                ),
                                key: ValueKey<int>(items[index].id),
                                onDismissed: (DismissDirection direction) {
                                  GlobalMethods().showDialogs(
                                      context,
                                      'Delete user',
                                      'Do you really want to delete the user?',
                                      () async {
                                    await handler.deleteUser(items[index].id);
                                    setState(() {
                                      items.remove(items[index]);

                                      WidgetsBinding.instance
                                          .addPostFrameCallback((_) =>
                                              _refreshIndicatorKey.currentState
                                                  ?.show());
                                    });
                                  }).then((value) => {
                                        WidgetsBinding.instance
                                            .addPostFrameCallback((_) =>
                                                _refreshIndicatorKey
                                                    .currentState
                                                    ?.show())
                                      });
                                },
                                child: Card(
                                    child: InkWell(
                                  onTap: () => {
                                    // ScaffoldMessenger.of(context).showSnackBar(
                                    //   SnackBar(
                                    //     duration: const Duration(seconds: 1),
                                    //     content: Text(
                                    //         'You tapped user ${items[index].id}'),
                                    //   ),
                                    // ),
                                    Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                        builder: (context) => ProfileScreen(
                                          userid: items[index].id,
                                        ),
                                      ),
                                    )
                                  },
                                  child: ListTile(
                                    contentPadding: const EdgeInsets.all(8.0),
                                    title: Text(
                                      '${items[index].firstName} ${items[index].lastName}',
                                      style: const TextStyle(
                                        fontWeight: FontWeight.w400,
                                        fontSize: 19,
                                      ),
                                    ),
                                    subtitle: Text(
                                      'Age: ${items[index].age.toString()}',
                                      style: const TextStyle(
                                        fontWeight: FontWeight.w500,
                                        fontSize: 15,
                                      ),
                                    ),
                                  ),
                                )),
                              );
                            },
                          ),
                        ));
                      }
                    },
                  ),
                ),
        ),
      ),
    );
  }
}
