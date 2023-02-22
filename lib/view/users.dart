import 'package:flutter/material.dart';
import 'package:healthlog/view/add_user.dart';
import 'package:healthlog/data/db.dart';
import 'package:healthlog/model/user.dart';

class UserScreen extends StatefulWidget {
  const UserScreen({super.key});

  @override
  State<UserScreen> createState() => _UserScreenState();
}

class _UserScreenState extends State<UserScreen> {
  late DatabaseHandler handler;
  late Future<List<User>> _user;
  bool _retrived = false;

  @override
  void initState() {
    super.initState();
    handler = DatabaseHandler();
    handler.initializeDB().whenComplete(() async {
      setState(() {
        _retrived = true;
        _user = getList();
      });
    });
  }

  Future<List<User>> getList() async {
    return await handler.users();
  }

  Future<void> _onRefresh() async {
    setState(() {
      _user = getList();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Sqlite todos'),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => const AddScreen()),
          );
        },
        backgroundColor: Colors.deepOrange,
        child: const Icon(Icons.add),
      ),
      body: !_retrived
          ? const Text('Content is not loaded yet')
          : FutureBuilder<List<User>>(
              future: _user,
              builder:
                  (BuildContext context, AsyncSnapshot<List<User>> snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(
                    child: CircularProgressIndicator(),
                  );
                } else if (snapshot.hasError) {
                  return Text('Error: ${snapshot.error}');
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
                              padding:
                                  const EdgeInsets.symmetric(horizontal: 10.0),
                              child: const Icon(Icons.delete_forever),
                            ),
                            key: ValueKey<int>(items[index].id),
                            onDismissed: (DismissDirection direction) async {
                              await handler.deleteUser(items[index].id);
                              setState(() {
                                items.remove(items[index]);
                              });
                            },
                            child: Card(
                                child: ListTile(
                              contentPadding: const EdgeInsets.all(8.0),
                              title: Text(
                                  '${items[index].firstName} ${items[index].lastName}'),
                              subtitle: Text(items[index].age.toString()),
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
