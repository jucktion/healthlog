import 'package:flutter/material.dart';
import 'package:healthlog/view/theme/colors.dart';
import 'package:healthlog/model/bloodpressure.dart';
import 'package:healthlog/data/db.dart';
import 'package:healthlog/view/bp/bp_graph.dart';
import 'package:healthlog/view/bp/bp_helper.dart';
import 'package:healthlog/view/theme/globals.dart';

class BPScreen extends StatefulWidget {
  final int userid;
  const BPScreen({super.key, required this.userid});

  @override
  State<BPScreen> createState() => _BPScreenState();
}

class _BPScreenState extends State<BPScreen> {
  late DatabaseHandler handler;

  final GlobalKey<RefreshIndicatorState> _refreshIndicatorKey =
      GlobalKey<RefreshIndicatorState>();
  late Future<List<BloodPressure>> _bp;
  late Future<String> _user;
  bool _retrived = false;

  @override
  void initState() {
    super.initState();
    handler = DatabaseHandler.instance;
    handler.initializeDB().whenComplete(() async {
      setState(() {
        _retrived = true;
        _bp = getList();
        _user = getName();
      });
    });
  }

  Future<List<BloodPressure>> getList() async {
    return await handler.bphistory(widget.userid);
  }

  Future<String> getName() async {
    return await handler.getUserName(widget.userid);
  }

  Future<void> _onRefresh() async {
    setState(() {
      _bp = getList();
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
                    return Text("${snapshot.data}'s BP Data");
                  } else {
                    return const CircularProgressIndicator();
                  }
                },
              ),
        actions: [
          IconButton(
              onPressed: () => {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => BPGraph(
                          userid: widget.userid,
                        ),
                      ),
                    )
                  },
              icon: const Icon(Icons.auto_graph_sharp))
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          BPHelper.statefulBpBottomModal(context,
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
          child: !_retrived
              ? const Text('Content is not loaded yet')
              : SizedBox(
                  height: MediaQuery.of(context).size.height,
                  child: FutureBuilder<List<BloodPressure>>(
                    future: _bp,
                    builder: (BuildContext context,
                        AsyncSnapshot<List<BloodPressure>> snapshot) {
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
                        final items = snapshot.data ?? <BloodPressure>[];
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
                                              BPHelper.showRecord(
                                                  context,
                                                  items[index].id ?? 0,
                                                  _refreshIndicatorKey)
                                            },
                                        child: BPHelper.tileBP(
                                            context, items[index])),
                                  ),
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
