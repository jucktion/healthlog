import 'package:flutter/material.dart';
import 'package:healthlog/data/db.dart';
import 'package:healthlog/model/data.dart';
import 'package:healthlog/view/bp/bp.dart';
import 'package:healthlog/view/bp/bp_helper.dart';
import 'package:healthlog/view/sugar/sugar.dart';
import 'package:healthlog/view/sugar/sugar_helper.dart';
import 'package:healthlog/view/theme/globals.dart';

class ProfileScreen extends StatefulWidget {
  final int userid;
  const ProfileScreen({super.key, required this.userid});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  late DatabaseHandler handler;
  final GlobalKey<RefreshIndicatorState> _refreshIndicatorKey =
      GlobalKey<RefreshIndicatorState>();
  late Future<List<dynamic>> _data;
  late Future<String> _user;
  bool _retrived = false;
  bool _isFabOpen = false;

  @override
  void initState() {
    super.initState();
    handler = DatabaseHandler();
    handler.initializeDB().whenComplete(() async {
      setState(() {
        _retrived = true;
        _data = getList();
        _user = getName();
      });
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
              return {'BP', 'Sugar', 'Notes'}
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
          child: !_retrived
              ? const Text('Content is not loaded yet')
              : SizedBox(
                  height: MediaQuery.of(context).size.height / 1.25,
                  child: FutureBuilder(
                    future: _data,
                    builder: (BuildContext context, AsyncSnapshot snapshot) {
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
                                        'Delete user',
                                        'Do you really want to delete the record?',
                                        () async {
                                      await handler.deleteBP(items[index].id);
                                      setState(() {
                                        items.remove(items[index]);
                                      });
                                    });
                                    WidgetsBinding.instance
                                        .addPostFrameCallback((_) =>
                                            _refreshIndicatorKey.currentState
                                                ?.show());
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
                                      title:
                                          Text(items[index].type.toUpperCase()),
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

  Widget _buildFab(BuildContext context) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.end,
      crossAxisAlignment: CrossAxisAlignment.end,
      children: [
        if (_isFabOpen)
          _buildFabOption(
              icon: Icons.format_size, label: 'Notes', doOnPressed: () {}),
        if (_isFabOpen)
          _buildFabOption(
              icon: Icons.cake,
              label: 'Sugar',
              doOnPressed: () {
                SGHelper.statefulBpBottomModal(context,
                    userid: widget.userid,
                    callback: () {},
                    refreshIndicatorKey: _refreshIndicatorKey);
              }),
        if (_isFabOpen)
          _buildFabOption(
              icon: Icons.bloodtype,
              label: 'BP',
              doOnPressed: () {
                BPHelper.statefulBpBottomModal(context,
                    userid: widget.userid,
                    callback: () {},
                    refreshIndicatorKey: _refreshIndicatorKey);
              }),
        FloatingActionButton(
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
          Text(label),
          FloatingActionButton(
            mini: true,
            heroTag: label,
            onPressed: () {
              // Handle your on press here
              doOnPressed();
            },
            child: Icon(icon),
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
        DatabaseHandler().deleteDB();
        break;
      default:
      //print('Unknown');
    }
  }
}
