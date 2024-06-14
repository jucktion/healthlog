import 'package:flutter/material.dart';
import 'package:healthlog/data/db.dart';
import 'package:healthlog/model/cholesterol.dart';
import 'package:healthlog/view/cholesterol/cholesterol_graph.dart';
import 'package:healthlog/view/cholesterol/cholesterol_helper.dart';
import 'package:healthlog/view/theme/globals.dart';

class CHLSTRLScreen extends StatefulWidget {
  final int userid;
  const CHLSTRLScreen({super.key, required this.userid});

  @override
  State<CHLSTRLScreen> createState() => _CHLSTRLScreenState();
}

class _CHLSTRLScreenState extends State<CHLSTRLScreen> {
  late DatabaseHandler handler;
  final GlobalKey<RefreshIndicatorState> _refreshIndicatorKey =
      GlobalKey<RefreshIndicatorState>();
  late Future<List<Cholesterol>> _chlstrl;
  late Future<String> _user;
  bool _retrived = false;

  @override
  void initState() {
    super.initState();
    handler = DatabaseHandler();
    handler.initializeDB().whenComplete(() async {
      setState(() {
        _retrived = true;
        _chlstrl = getList();
        _user = getName();
      });
    });
  }

  Future<List<Cholesterol>> getList() async {
    return await handler.chlstrlHistory(widget.userid);
  }

  Future<String> getName() async {
    return await handler.getUserName(widget.userid);
  }

  Future<void> _onRefresh() async {
    setState(() {
      _chlstrl = getList();
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
                    return Text("${snapshot.data}'s Cholesterol Data");
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
                        builder: (context) => CholesterolGraph(
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
          child: !_retrived
              ? const Text('Content is not loaded yet')
              : SizedBox(
                  height: MediaQuery.of(context).size.height,
                  child: FutureBuilder<List<Cholesterol>>(
                    future: _chlstrl,
                    builder: (BuildContext context,
                        AsyncSnapshot<List<Cholesterol>> snapshot) {
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
                        final items = snapshot.data ?? <Cholesterol>[];
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
                                        'Delete record',
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
                                    onTap: () => {
                                      CHLSTRLHelper.showRecord(
                                          context, items[index].id)
                                    },
                                    child: ListTile(
                                      trailing: Text(
                                          '${DateTime.parse(items[index].date).year}-${DateTime.parse(items[index].date).month}-${DateTime.parse(items[index].date).day} ${DateTime.parse(items[index].date).hour}:${DateTime.parse(items[index].date).minute}'),
                                      contentPadding: const EdgeInsets.all(8.0),
                                      title: Text(
                                          '${items[index].type.toUpperCase()}: Total/HDL/LDL \n${items[index].content.total.toStringAsFixed(2)}/${items[index].content.hdl.toStringAsFixed(2)}/${items[index].content.ldl.toStringAsFixed(2)}'),
                                      subtitle: Text(
                                          'Comment: ${items[index].comments.toString()}'),
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
}
