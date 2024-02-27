import 'dart:math';
import 'package:flutter/material.dart';
import 'package:healthlog/model/bloodpressure.dart';
import 'package:healthlog/data/db.dart';
import 'package:healthlog/view/bp/bp_graph.dart';
import 'package:healthlog/view/bp/bp_helper.dart';

class BPScreen extends StatefulWidget {
  final int userid;
  const BPScreen({super.key, required this.userid});

  @override
  State<BPScreen> createState() => _BPScreenState();
}

class _BPScreenState extends State<BPScreen> {
  late DatabaseHandler handler;
  late Future<List<BloodPressure>> _bp;
  late Future<String> _user;
  bool _retrived = false;

  final _formKey = GlobalKey<FormState>();
  int _systolic = 120;
  int _diastolic = 80;
  int _heartrate = 70;
  String _arm = "";
  String _comment = "";

  @override
  void initState() {
    super.initState();
    handler = DatabaseHandler();
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
                    return Text(snapshot.data ?? 'User Log');
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
          BPHelper.bpBottomModal(context,
              formKey: _formKey,
              userid: widget.userid, systolicChange: (value) {
            setState(() => _systolic = int.parse(value));
          }, diastolicChange: (value) {
            setState(() => _diastolic = int.parse(value));
          }, heartChange: (value) {
            setState(() => _heartrate = int.parse(value));
          }, armChange: (value) {
            setState(() => _arm = value);
          }, commentChange: (value) {
            setState(() => _comment = value);
          }, submitForm: () async {
            if (_formKey.currentState!.validate()) {
              await DatabaseHandler()
                  .insertBp(BloodPressure(
                      id: Random().nextInt(50),
                      user: widget.userid,
                      type: 'bp',
                      content: BP(
                          systolic: _systolic,
                          diastolic: _diastolic,
                          heartrate: _heartrate,
                          arm: _arm),
                      date: DateTime.now().toIso8601String(),
                      comments: _comment))
                  .whenComplete(() => Navigator.pop(context));
            } else {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Processing Data')),
              );
            }
          });
        },
        backgroundColor: Colors.deepOrange,
        child: const Icon(Icons.add),
      ),
      body: RefreshIndicator(
        onRefresh: _onRefresh,
        child: SingleChildScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          child: !_retrived
              ? const Text('Content is not loaded yet')
              : SizedBox(
                  height: MediaQuery.of(context).size.height / 1.25,
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
                                  key: ValueKey<int>(items[index].id),
                                  onDismissed:
                                      (DismissDirection direction) async {
                                    await handler.deleteBP(items[index].id);
                                    setState(() {
                                      items.remove(items[index]);
                                    });
                                  },
                                  child: Card(
                                      child: InkWell(
                                    onTap: () => {
                                      ScaffoldMessenger.of(context)
                                          .showSnackBar(SnackBar(
                                              duration:
                                                  const Duration(seconds: 1),
                                              content: Text(
                                                  'Record id: ${items[index].id}')))
                                    },
                                    child: ListTile(
                                      trailing: Text(
                                          '${DateTime.parse(items[index].date).year}-${DateTime.parse(items[index].date).month}-${DateTime.parse(items[index].date).day} ${DateTime.parse(items[index].date).hour}:${DateTime.parse(items[index].date).minute}'),
                                      contentPadding: const EdgeInsets.all(8.0),
                                      title: Text(
                                          '${items[index].content.systolic} ${items[index].content.diastolic}'),
                                      subtitle: Text(
                                          items[index].content.arm.toString()),
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
