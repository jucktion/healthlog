import 'package:flutter/material.dart';
import 'package:healthlog/data/db.dart';
import 'package:healthlog/model/notes.dart';

class NoteHelper {
  static Future<void> statefulNoteBottomModal(BuildContext context,
      {required int userid,
      required Function callback,
      required GlobalKey<RefreshIndicatorState> refreshIndicatorKey}) async {
    final formKey = GlobalKey<FormState>();
    String note = "";
    String title = "";
    String? selectedValue = "Note";
    String comment = "";
    final List<String> items = ['Note', 'Phone', 'Medicine'];

    showModalBottomSheet(
      isScrollControlled: true,
      context: context,
      builder: ((context) {
        return StatefulBuilder(
            builder: (BuildContext context, StateSetter setState) {
          return Padding(
            padding: EdgeInsets.only(
                bottom: MediaQuery.of(context).viewInsets.bottom),
            child: SizedBox(
              height: 450,
              width: MediaQuery.of(context).size.width / 1.25,
              child: Form(
                key: formKey,
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.start,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: <Widget>[
                    Padding(
                      padding: const EdgeInsets.only(left: 40, right: 40),
                      child: TextFormField(
                          decoration: const InputDecoration(
                              hintText: 'Enter a Title', label: Text('Title')),
                          onChanged: (String? value) {
                            setState(() => title = value.toString());
                          }),
                    ),
                    Padding(
                      padding: const EdgeInsets.only(left: 40, right: 40),
                      child: TextFormField(
                          decoration: const InputDecoration(
                              hintText: 'Enter a note', label: Text('Note')),
                          onChanged: (String? value) {
                            setState(() => note = value.toString());
                          }),
                    ),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: [
                        const Text('Type:',
                            style: TextStyle(
                              fontSize: 17,
                            )),
                        DropdownButton<String>(
                          hint: Text('Select an option'), // Hint text
                          value: selectedValue, // Currently selected value
                          onChanged: (String? newValue) {
                            setState(() {
                              selectedValue =
                                  newValue; // Update the selected value
                            });
                          },
                          items: items
                              .map<DropdownMenuItem<String>>((String value) {
                            return DropdownMenuItem<String>(
                              value: value,
                              child: Text(value), // Display each item
                            );
                          }).toList(),
                        ),
                      ],
                    ),
                    Padding(
                      padding: const EdgeInsets.only(left: 40, right: 40),
                      child: TextFormField(
                          decoration: const InputDecoration(
                              hintText: 'Additional comment',
                              label: Text('Comments')),
                          onChanged: (String? value) {
                            setState(() => comment = value.toString());
                          }),
                    ),
                    ElevatedButton(
                      onPressed: () async {
                        if (formKey.currentState!.validate()) {
                          await DatabaseHandler.instance
                              .insertNote(Notes(
                                  user: userid,
                                  type: 'note',
                                  content: Note(
                                    title: title,
                                    note: note,
                                    notetype: selectedValue.toString(),
                                  ),
                                  date: DateTime.now().toIso8601String(),
                                  comments: comment))
                              .whenComplete(() {
                            if (context.mounted) {
                              Navigator.pop(context);
                            }
                            WidgetsBinding.instance.addPostFrameCallback((_) =>
                                refreshIndicatorKey.currentState?.show());
                          });
                        } else {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(content: Text('Processing Data')),
                          );
                        }
                      },
                      child: const Text(
                        'Add',
                        style: TextStyle(
                          fontSize: 20,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          );
        });
      }),
    );
  }

  static Future<void> showRecord(BuildContext context, int entryid) async {
    late DatabaseHandler handler;
    late Future<List<Notes>> bp;
    Future<List<Notes>> getList() async {
      handler = DatabaseHandler.instance;
      return await handler.noteEntry(entryid);
    }

    bp = getList();
    showDialog(
        context: context,
        builder: (BuildContext context) {
          return FutureBuilder<List<Notes>>(
            future: bp,
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.done) {
                if (snapshot.hasError) {
                  return Text('Error: ${snapshot.error}');
                } else {
                  final entry = snapshot.data ?? [];
                  return AlertDialog(
                    title: Row(
                      children: [
                        const Padding(
                          padding: EdgeInsets.all(8.0),
                          child: Icon(
                            Icons.receipt_rounded,
                            size: 25,
                            color: Colors.green,
                          ),
                        ),
                        Padding(
                          padding: const EdgeInsets.all(8.0),
                          child: Text('Note ID: $entryid'),
                        ),
                      ],
                    ),
                    content: Padding(
                      padding: const EdgeInsets.only(top: 8.0),
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Padding(
                            padding:
                                const EdgeInsets.only(top: 8.0, bottom: 10.0),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                              children: [
                                Text(entry.first.content.title,
                                    style: TextStyle(
                                        fontSize: 19,
                                        fontWeight: FontWeight.bold)),
                              ],
                            ),
                          ),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                            children: [
                              Text(entry.first.content.note,
                                  style: TextStyle(
                                    fontSize: 17,
                                  )),
                            ],
                          ),
                          Padding(
                            padding: const EdgeInsets.all(25.0),
                            child:
                                Text('Type: ${entry.first.content.notetype}'),
                          ),
                          Padding(
                            padding: const EdgeInsets.only(top: 5.0),
                            child: SizedBox(
                              child: Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceAround,
                                crossAxisAlignment: CrossAxisAlignment.center,
                                children: [
                                  Text(
                                      'Date: ${DateTime.parse(entry.first.date).year}-${DateTime.parse(entry.first.date).month}-${DateTime.parse(entry.first.date).day}'),
                                  Text(
                                      'Time: ${DateTime.parse(entry.first.date).hour}:${DateTime.parse(entry.first.date).minute}')
                                ],
                              ),
                            ),
                          )
                        ],
                      ),
                    ),
                    actions: [
                      TextButton(
                        onPressed: () => Navigator.pop(context),
                        child: const Text('OK'),
                      ),
                    ],
                  );
                }
              } else {
                return const CircularProgressIndicator(); // Or any loading indicator widget
              }
            },
          );
        });
  }
}
