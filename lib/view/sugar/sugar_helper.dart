import 'dart:math';
import 'package:flutter/material.dart';
import 'package:healthlog/data/db.dart';
import 'package:healthlog/model/sugar.dart';

class SGHelper {
  static Future<void> statefulBpBottomModal(BuildContext context,
      {required int userid,
      required Function callback,
      required GlobalKey<RefreshIndicatorState> refreshIndicatorKey}) async {
    final formKey = GlobalKey<FormState>();
    double reading = 0.00;
    String beforeAfter = '';
    // String fastingNormalReading = '60 - 110';
    // String afterFastingNormalReading = '70 - 140';
    String fastGroup = "";
    String unit = "";
    String unitGroup = "mg/dL";
    String comment = "";

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
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        SizedBox(
                          width: 150,
                          child: RadioListTile<String>(
                              title: const Text("Before"),
                              value: "before",
                              groupValue: fastGroup,
                              onChanged: (String? value) {
                                setState(() {
                                  beforeAfter = fastGroup = value.toString();
                                });
                              }),
                        ),
                        SizedBox(
                          width: 150,
                          child: RadioListTile<String>(
                            title: const Text("After"),
                            value: "after",
                            groupValue: fastGroup,
                            onChanged: (String? value) {
                              setState(() {
                                beforeAfter = fastGroup = value.toString();
                              });
                            },
                          ),
                        ),
                      ],
                    ),
                    Padding(
                      padding: const EdgeInsets.only(left: 40, right: 40),
                      child: TextFormField(
                          keyboardType: TextInputType.number,
                          validator: (value) {
                            if (value == null || value.isEmpty) {
                              return 'Please enter blood sugar reading';
                            }
                            return null;
                          },
                          decoration: InputDecoration(
                            hintText: (unit == 'mg/dL' &&
                                    beforeAfter == 'before')
                                ? '60-110'
                                : (unit == 'mg/dL' && beforeAfter == 'after')
                                    ? '70-140'
                                    : (unitGroup == 'mmol/L' &&
                                            beforeAfter == 'before')
                                        ? '3.33-6.11'
                                        : (unitGroup == 'mmol/L' &&
                                                beforeAfter == 'after')
                                            ? '3.88-7.77'
                                            : '',
                            suffixText: 'mg/dL',
                            label: const Text('Blood Sugar'),
                          ),
                          onChanged: (String? value) {
                            setState(
                                () => reading = double.parse(value.toString()));
                          }),
                    ),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        SizedBox(
                          width: 160,
                          child: RadioListTile<String>(
                              title: const Text("mmol/L"),
                              value: "mmol/L",
                              groupValue: unitGroup,
                              onChanged: (String? value) {
                                setState(() {
                                  unit = unitGroup = value.toString();
                                });
                              }),
                        ),
                        SizedBox(
                          width: 150,
                          child: RadioListTile<String>(
                            title: const Text("mg/dL"),
                            selected: true,
                            value: "mg/dL",
                            groupValue: unitGroup,
                            onChanged: (String? value) {
                              setState(() {
                                unit = unitGroup = value.toString();
                              });
                            },
                          ),
                        ),
                      ],
                    ),
                    Padding(
                      padding: const EdgeInsets.only(left: 40, right: 40),
                      child: TextFormField(
                          decoration: const InputDecoration(
                              hintText: 'What did you eat',
                              label: Text('Comments')),
                          onChanged: (String? value) {
                            setState(() => comment = value.toString());
                          }
                          // (value) {
                          //   setState(() {
                          //     comment = value;
                          //   });
                          // },
                          ),
                    ),
                    ElevatedButton(
                      onPressed: () async {
                        if (formKey.currentState!.validate()) {
                          await DatabaseHandler()
                              .insertSg(Sugar(
                                  id: Random().nextInt(50),
                                  user: userid,
                                  type: 'sugar',
                                  content: SG(
                                      reading: unit == 'mg/dL'
                                          ? reading
                                          : reading * 18.0182,
                                      beforeAfter: beforeAfter,
                                      unit: 'mg/dL'),
                                  date: DateTime.now().toIso8601String(),
                                  comments: comment))
                              .whenComplete(() {
                            Navigator.pop(context);
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
    late Future<List<Sugar>> sg;
    Future<List<Sugar>> getList() async {
      handler = DatabaseHandler();
      return await handler.sugarEntry(entryid);
    }

    sg = getList();
    showDialog(
        context: context,
        builder: (BuildContext context) {
          return FutureBuilder<List<Sugar>>(
            future: sg,
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
                          child: Text('Sugar Record: $entryid'),
                        ),
                      ],
                    ),
                    content: Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.center,
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text(
                            '${entry.first.content.reading.toStringAsFixed(2)} ${entry.first.content.unit}',
                            style: const TextStyle(
                              fontSize: 20,
                            ),
                          ),
                          Padding(
                            padding: const EdgeInsets.only(top: 25.0),
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
