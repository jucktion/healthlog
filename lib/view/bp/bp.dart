import 'package:flutter/material.dart';
import 'package:healthlog/model/bloodpressure.dart';
import 'package:healthlog/view/bp/add_bp.dart';
import 'package:healthlog/data/db.dart';
import 'package:healthlog/view/bp/bp_graph.dart';

class BPScreen extends StatefulWidget {
  final String userid;
  const BPScreen({super.key, required this.userid});

  @override
  State<BPScreen> createState() => _BPScreenState();
}

class _BPScreenState extends State<BPScreen> {
  late DatabaseHandler handler;
  late Future<List<BloodPressure>> _bp;
  bool _retrived = false;

  @override
  void initState() {
    super.initState();
    handler = DatabaseHandler();
    handler.initializeDB().whenComplete(() async {
      setState(() {
        _retrived = true;
        _bp = getList();
      });
    });
  }

  Future<List<BloodPressure>> getList() async {
    return await handler.bphistory(widget.userid);
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
        title: const Text('User Log'),
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
          Navigator.push(
            context,
            MaterialPageRoute(
                builder: (context) => AddBPScreen(
                      userid: widget.userid,
                    )),
          );
        },
        backgroundColor: Colors.deepOrange,
        child: const Icon(Icons.add),
      ),
      body: !_retrived
          ? const Text('Content is not loaded yet')
          : FutureBuilder<List<BloodPressure>>(
              future: _bp,
              builder: (BuildContext context,
                  AsyncSnapshot<List<BloodPressure>> snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(
                    child: CircularProgressIndicator(),
                  );
                } else if (snapshot.hasError) {
                  return Text('Error: ${snapshot.error}');
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
                              padding:
                                  const EdgeInsets.symmetric(horizontal: 10.0),
                              child: const Icon(Icons.delete_forever),
                            ),
                            key: ValueKey<int>(items[index].id),
                            onDismissed: (DismissDirection direction) async {
                              await handler.deleteBP(items[index].id);
                              setState(() {
                                items.remove(items[index]);
                              });
                            },
                            child: Card(
                                child: InkWell(
                              onTap: () => {
                                ScaffoldMessenger.of(context).showSnackBar(
                                    SnackBar(
                                        duration: const Duration(seconds: 1),
                                        content: Text(
                                            'Record id: ${items[index].id}')))
                              },
                              child: ListTile(
                                trailing: Text(
                                    '${DateTime.parse(items[index].date).year}-${DateTime.parse(items[index].date).month}-${DateTime.parse(items[index].date).day} ${DateTime.parse(items[index].date).hour}:${DateTime.parse(items[index].date).minute}'),
                                contentPadding: const EdgeInsets.all(8.0),
                                title: Text(
                                    '${items[index].content.systolic} ${items[index].content.diastolic}'),
                                subtitle:
                                    Text(items[index].content.arm.toString()),
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
    );
  }
}
