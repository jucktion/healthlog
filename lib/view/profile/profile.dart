import 'package:flutter/material.dart';
import 'package:healthlog/view/theme/colors.dart';
import 'package:healthlog/data/db.dart';
import 'package:healthlog/model/data.dart';
import 'package:healthlog/view/bp/bp.dart';
import 'package:healthlog/view/bp/bp_helper.dart';
import 'package:healthlog/view/cholesterol/cholesterol.dart';
import 'package:healthlog/view/cholesterol/cholesterol_helper.dart';
import 'package:healthlog/view/notes/note.dart';
import 'package:healthlog/view/notes/note_helper.dart';
import 'package:healthlog/view/rft/rft.dart';
import 'package:healthlog/view/rft/rft_helper.dart';
import 'package:healthlog/view/sugar/sugar.dart';
import 'package:healthlog/view/sugar/sugar_helper.dart';
import 'package:healthlog/view/theme/globals.dart';
import 'package:shared_preferences/shared_preferences.dart';

class ProfileScreen extends StatefulWidget {
  final int userid;
  const ProfileScreen({super.key, required this.userid});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  late DatabaseHandler handler;
  SharedPreferences? _prefs;
  final GlobalKey<RefreshIndicatorState> _refreshIndicatorKey =
      GlobalKey<RefreshIndicatorState>();
  late Future<List<dynamic>> _data;
  late Future<String> _user;
  bool _retrived = false;
  bool _isFabOpen = false;
  bool _prefLoaded = false;

  @override
  void initState() {
    super.initState();
    _initPrefs();
    handler = DatabaseHandler.instance;
    handler.initializeDB().whenComplete(() async {
      setState(() {
        _retrived = true;
        _data = getList();
        _user = getName();
      });
    });
  }

  void _initPrefs() async {
    _prefs = await SharedPreferences.getInstance();
    setState(() {
      _prefLoaded = true;
    });
  }

  Future<List<Data>> getList() async {
    return await handler.allhistory(widget.userid);
  }

  Future<String> getName() async {
    return await handler.getUserName(widget.userid);
  }

  Future<void> _onRefresh() async {
    setState(() {
      _data = getList();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        actions: [
          PopupMenuButton(
            //onOpened: () => {DatabaseHandler().getDbpath()},
            itemBuilder: (BuildContext context) {
              return {'BP', 'Sugar', 'Cholesterol', 'RFT', 'Notes'}
                  .toList()
                  .asMap()
                  .entries
                  .map((choice) {
                return PopupMenuItem<String>(
                  onTap: () => {handleMenuOptionClick(context, choice.key)},
                  value: choice.key.toString(),
                  child: Text(choice.value),
                );
              }).toList();
            },
            icon: const Icon(Icons.more_vert),
          ),
        ],
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
                    return Text("${snapshot.data}'s Data");
                  } else {
                    return const CircularProgressIndicator();
                  }
                },
              ),
      ),
      floatingActionButton: _buildFab(context),
      body: RefreshIndicator(
        key: _refreshIndicatorKey,
        onRefresh: _onRefresh,
        child: SingleChildScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          child: !_retrived || !_prefLoaded
              ? const Text('Content is not loaded yet')
              : SizedBox(
                  height: MediaQuery.of(context).size.height,
                  child: FutureBuilder(
                    future: _data,
                    builder: (BuildContext context, AsyncSnapshot snapshot) {
                      if (snapshot.connectionState == ConnectionState.waiting) {
                        //Check if the prefs are loading
                        // print(
                        //     'Before: ${_prefs!.getDouble('sugarBeforeLow').toString()}, ${_prefs!.getDouble('sugarBeforeHigh').toString()}\nAfter: ${_prefs!.getDouble('sugarAfterLow').toString()}, ${_prefs!.getDouble('sugarAfterHigh').toString()} ');
                        return const Center(
                          child: CircularProgressIndicator(),
                        );
                      } else if (snapshot.hasError) {
                        return Text('Error: ${snapshot.error}');
                      } else if (snapshot.data.toString() ==
                          List.empty().toString()) {
                        return const Center(
                          child: Text(
                            'Record a new data',
                            style: TextStyle(fontSize: 20),
                          ),
                        );
                      } else {
                        final items = snapshot.data ?? <List>[];
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
                                        'Delete entry',
                                        'Do you really want to delete the record?',
                                        () async {
                                      await handler
                                          .deleteRecord(items[index].id);
                                      setState(() {
                                        items.remove(items[index]);
                                        WidgetsBinding.instance
                                            .addPostFrameCallback((_) =>
                                                _refreshIndicatorKey
                                                    .currentState
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
                                    onTap: () {
                                      switch (items[index].type) {
                                        case 'rft':
                                          RFTHelper.showRecord(
                                              context,
                                              items[index].id,
                                              _prefs!
                                                  .getString('rftUnit')
                                                  .toString(),
                                              _refreshIndicatorKey,
                                              _prefs);
                                          break;
                                        case 'sugar':
                                          SGHelper.showRecord(
                                              context,
                                              items[index].id,
                                              _prefs!
                                                  .getString('sugarUnit')
                                                  .toString(),
                                              _refreshIndicatorKey,
                                              _prefs);
                                          break;
                                        case 'bp':
                                          BPHelper.showRecord(
                                              context,
                                              items[index].id,
                                              _refreshIndicatorKey);
                                          break;
                                        case 'chlstrl':
                                          CHLSTRLHelper.showRecord(
                                              context,
                                              items[index].id,
                                              _prefs!
                                                  .getString('chlstrlUnit')
                                                  .toString(),
                                              _refreshIndicatorKey,
                                              _prefs);
                                          break;
                                      }
                                      // ScaffoldMessenger.of(context)
                                      //     .showSnackBar(SnackBar(
                                      //         duration:
                                      //             const Duration(seconds: 1),
                                      //         content: Text(
                                      //             'Record id: ${items[index].id}')))
                                    },
                                    child: ListTile(
                                      trailing: Text(
                                          '${DateTime.parse(items[index].date).year}-${DateTime.parse(items[index].date).month}-${DateTime.parse(items[index].date).day} ${DateTime.parse(items[index].date).hour}:${DateTime.parse(items[index].date).minute}'),
                                      contentPadding: const EdgeInsets.all(8.0),
                                      title: titleText(
                                          items[index].type, items[index].id),
                                      subtitle: Text(
                                          'Note: ${items[index].comments.toString()}'),
                                    ),
                                  )),
                                );
                              },
                            ),
                          ),
                        );
                      }
                    },
                  ),
                ),
        ),
      ),
    );
  }

  Widget titleText(String type, int id) {
    switch (type) {
      case 'bp':
        Future<String> entrybp = handler.bpReading(id);
        return FutureBuilder(
            future: entrybp,
            builder: (BuildContext context, AsyncSnapshot snapshot) {
              return Text('BP: ${snapshot.data}',
                  style: TextStyle(fontSize: 19));
            });

      case 'rft':
        Future<String> entrybp =
            handler.rftReading(id, _prefs!.getString('rftUnit').toString());
        return FutureBuilder(
            future: entrybp,
            builder: (BuildContext context, AsyncSnapshot snapshot) {
              return Text('RFT: ${snapshot.data}',
                  style: TextStyle(fontSize: 19));
            });
      case 'sugar':
        Future<String> entrysg =
            handler.sgReading(id, _prefs!.getString('sugarUnit').toString());
        return FutureBuilder(
            future: entrysg,
            builder: (BuildContext context, AsyncSnapshot snapshot) {
              return Text('Sugar: ${snapshot.data}',
                  style: TextStyle(fontSize: 19));
            });
      case 'chlstrl':
        Future<String> entrych = handler.chlstrlReading(
            id, _prefs!.getString('chlstrlUnit').toString());
        return FutureBuilder(
            future: entrych,
            builder: (BuildContext context, AsyncSnapshot snapshot) {
              return Text('Cholesterol: ${snapshot.data}',
                  style: TextStyle(fontSize: 19));
            });
      default:
        return const Text('');
    }
  }

  Widget _buildFab(BuildContext context) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.end,
      crossAxisAlignment: CrossAxisAlignment.end,
      children: [
        if (_isFabOpen)
          _buildFabOption(
              icon: Icons.format_size,
              label: 'Note',
              doOnPressed: () {
                NoteHelper.statefulNoteBottomModal(context,
                    userid: widget.userid,
                    callback: () {},
                    refreshIndicatorKey: _refreshIndicatorKey);
              }),
        if (_isFabOpen)
          _buildFabOption(
              icon: Icons.filter_alt_sharp,
              label: 'RFT',
              doOnPressed: () {
                RFTHelper.statefulRftBottomModal(context,
                    userid: widget.userid,
                    callback: () {},
                    refreshIndicatorKey: _refreshIndicatorKey,
                    prefs: _prefs);
              }),
        if (_isFabOpen)
          _buildFabOption(
              icon: Icons.water_drop_sharp,
              label: 'Cholesterol',
              doOnPressed: () {
                CHLSTRLHelper.statefulchlstrlBottomModal(context,
                    userid: widget.userid,
                    callback: () {},
                    refreshIndicatorKey: _refreshIndicatorKey,
                    prefs: _prefs);
              }),
        if (_isFabOpen)
          _buildFabOption(
              icon: Icons.cake,
              label: 'Sugar',
              doOnPressed: () {
                SGHelper.statefulSgBottomModal(context,
                    userid: widget.userid,
                    callback: () {},
                    refreshIndicatorKey: _refreshIndicatorKey,
                    prefs: _prefs);
              }),
        if (_isFabOpen)
          _buildFabOption(
              icon: Icons.monitor_heart,
              label: 'BP',
              doOnPressed: () {
                BPHelper.statefulBpBottomModal(context,
                    userid: widget.userid,
                    callback: () {},
                    refreshIndicatorKey: _refreshIndicatorKey);
              }),
        FloatingActionButton(
          backgroundColor: AppColors.floatingButton,
          onPressed: () {
            setState(() {
              _isFabOpen = !_isFabOpen;
            });
          },
          child: Icon(_isFabOpen ? Icons.close : Icons.add),
        ),
      ],
    );
  }

  Widget _buildFabOption(
      {required IconData icon,
      required String label,
      required Function doOnPressed}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          DecoratedBox(
            decoration: BoxDecoration(
              color: Theme.of(context).splashColor,
              borderRadius: BorderRadius.all(
                Radius.circular(5),
              ),
              boxShadow: [
                BoxShadow(
                  color: Theme.of(context).primaryColor,
                  spreadRadius: 1,
                  blurRadius: 1,
                  offset: Offset(1.1, 1), // changes position of shadow
                ),
              ],
            ),
            child: Padding(
              padding: const EdgeInsets.all(8.0),
              child: Row(
                children: [
                  Text(
                    label,
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      color: Theme.of(context).primaryColor,
                    ),
                  ),
                ],
              ),
            ),
          ),
          FloatingActionButton(
            mini: true,
            heroTag: label,
            onPressed: () {
              // Handle your on press here
              doOnPressed();
            },
            backgroundColor: Theme.of(context).splashColor,
            child: Icon(
              icon,
              color: Theme.of(context).primaryColor,
            ),
          ),
          // Space between the icon and the label
        ],
      ),
    );
  }

  void handleMenuOptionClick(BuildContext context, int value) {
    switch (value) {
      case 0:
        //print('Backup selected');
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => BPScreen(
              userid: widget.userid,
            ),
          ),
        );
        break;
      case 1:
        // print('Restore selected');
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => SGScreen(
              userid: widget.userid,
            ),
          ),
        );
        break;
      case 2:
        // print('Reset selected');
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => CHLSTRLScreen(
              userid: widget.userid,
            ),
          ),
        );
        break;
      case 3:
        // print('Reset selected');
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => RFTScreen(
              userid: widget.userid,
            ),
          ),
        );
        break;
      case 4:
        // print('Reset selected');
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => NoteScreen(
              userid: widget.userid,
            ),
          ),
        );
        break;
      default:
      //print('Unknown');
    }
  }
}
