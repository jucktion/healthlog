import 'package:flutter/material.dart';
import 'package:healthlog/view/theme/colors.dart';
import 'package:healthlog/data/db.dart';
import 'package:healthlog/model/sugar.dart';
import 'package:healthlog/view/sugar/sugar_graph.dart';
import 'package:healthlog/view/sugar/sugar_helper.dart';
import 'package:healthlog/view/theme/globals.dart';
import 'package:shared_preferences/shared_preferences.dart';

class SGScreen extends StatefulWidget {
  final int userid;
  const SGScreen({super.key, required this.userid});

  @override
  State<SGScreen> createState() => _SGScreenState();
}

class _SGScreenState extends State<SGScreen> {
  late DatabaseHandler handler;
  SharedPreferences? _prefs;
  final GlobalKey<RefreshIndicatorState> _refreshIndicatorKey =
      GlobalKey<RefreshIndicatorState>();
  late Future<List<Sugar>> _sg;
  late Future<String> _user;
  bool _retrived = false;
  bool _prefLoaded = false;

  @override
  void initState() {
    super.initState();
    handler = DatabaseHandler.instance;
    handler.initializeDB().whenComplete(() async {
      setState(() {
        _retrived = true;
        _sg = getList();
        _user = getName();
        _initPrefs();
      });
    });
  }

  void _initPrefs() async {
    _prefs = await SharedPreferences.getInstance();
    setState(() {
      _prefLoaded = true;
    });
  }

  Future<List<Sugar>> getList() async {
    return await handler.sugarhistory(widget.userid);
  }

  Future<String> getName() async {
    return await handler.getUserName(widget.userid);
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
                    return Text("${snapshot.data}'s Sugar Data");
                  } else {
                    return const CircularProgressIndicator();
                  }
                },
              ),
        actions: [
          IconButton(
              onPressed: () => {
                    // print(_prefs!.getBool('graphDots')),
                    // print(_prefs!.getString('sugarUnit').toString()),
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => SugarGraph(
                          userid: widget.userid,
                          unit: _prefs!.getString('sugarUnit').toString(),
                          dots: _prefs!.getBool('graphDots') ?? false,
                        ),
                      ),
                    )
                  },
              icon: const Icon(Icons.auto_graph_sharp))
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          SGHelper.statefulBpBottomModal(context,
              userid: widget.userid,
              callback: () {},
              refreshIndicatorKey: _refreshIndicatorKey);
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
                  height: MediaQuery.of(context).size.height,
                  child: FutureBuilder<List<Sugar>>(
                    future: _sg,
                    builder: (BuildContext context,
                        AsyncSnapshot<List<Sugar>> snapshot) {
                      if (snapshot.connectionState == ConnectionState.waiting) {
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
                        final items = snapshot.data ?? <Sugar>[];

                        return Scrollbar(
                          child: RefreshIndicator(
                            onRefresh: _onRefresh,
                            child: ListView.builder(
                              itemCount: items.length,
                              itemBuilder: (BuildContext context, int index) {
                                String unit =
                                    _prefs!.getString('sugarUnit').toString();
                                return Dismissible(
                                  direction: DismissDirection.startToEnd,
                                  background: Container(
                                    color: Colors.red,
                                    alignment: Alignment.centerRight,
                                    padding: const EdgeInsets.symmetric(
                                        horizontal: 10.0),
                                    child: const Icon(Icons.delete_forever),
                                  ),
                                  key: ValueKey<int>(items[index].id ?? 0),
                                  onDismissed: (DismissDirection direction) {
                                    GlobalMethods().showDialogs(
                                        context,
                                        'Delete record',
                                        'Do you really want to delete the record?',
                                        () async {
                                      await handler
                                          .deleteRecord(items[index].id ?? 0);
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
                                          onTap: () => {
                                                SGHelper.showRecord(
                                                    context,
                                                    items[index].id ?? 0,
                                                    _prefs!
                                                        .getString('sugarUnit')
                                                        .toString(),
                                                    _refreshIndicatorKey)
                                              },
                                          child: SGHelper.tileSugar(
                                              context, items[index], unit))),
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
}
