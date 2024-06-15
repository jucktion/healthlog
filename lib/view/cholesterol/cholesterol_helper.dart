import 'package:flutter/material.dart';
import 'package:healthlog/data/db.dart';
import 'package:healthlog/model/cholesterol.dart';

class CHLSTRLHelper {
  static Future<void> statefulchlstrlBottomModal(BuildContext context,
      {required int userid,
      required Function callback,
      required GlobalKey<RefreshIndicatorState> refreshIndicatorKey}) async {
    final formKey = GlobalKey<FormState>();
    double total = 0.00;
    double tag = 0.00;
    double hdl = 0.00;
    double ldl = 0.00;
    // String fastingNormalReading = '60 - 110';
    // String afterFastingNormalReading = '70 - 140';
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
                    Padding(
                      padding: const EdgeInsets.only(left: 40, right: 40),
                      child: TextFormField(
                          keyboardType: TextInputType.number,
                          validator: (value) {
                            if (value == null || value.isEmpty) {
                              return 'Please enter total cholesterol result';
                            }
                            return null;
                          },
                          decoration: const InputDecoration(
                            hintText: '<Less than 200, no more than 240',
                            suffixText: 'mg/dL',
                            label: Text('Total Cholesterol'),
                          ),
                          onChanged: (String? value) {
                            setState(
                                () => total = double.parse(value.toString()));
                          }),
                    ),
                    Padding(
                      padding: const EdgeInsets.only(left: 40, right: 40),
                      child: TextFormField(
                          keyboardType: TextInputType.number,
                          validator: (value) {
                            if (value == null || value.isEmpty) {
                              return 'Please enter Triacyglycerol result';
                            }
                            return null;
                          },
                          decoration: const InputDecoration(
                            hintText:
                                '<Ideally less than 150, no more than 500',
                            suffixText: 'mg/dL',
                            label: Text('Triacyglycerol (TAG)'),
                          ),
                          onChanged: (String? value) {
                            setState(
                                () => tag = double.parse(value.toString()));
                          }),
                    ),
                    Padding(
                      padding: const EdgeInsets.only(left: 40, right: 40),
                      child: TextFormField(
                          keyboardType: TextInputType.number,
                          validator: (value) {
                            if (value == null || value.isEmpty) {
                              return 'Please enter HDL Cholesterol result';
                            }
                            return null;
                          },
                          decoration: const InputDecoration(
                            hintText: '40-60',
                            suffixText: 'mg/dL',
                            label: Text('HDL Cholesterol'),
                          ),
                          onChanged: (String? value) {
                            setState(
                                () => hdl = double.parse(value.toString()));
                          }),
                    ),
                    Padding(
                      padding: const EdgeInsets.only(left: 40, right: 40),
                      child: TextFormField(
                          keyboardType: TextInputType.number,
                          validator: (value) {
                            if (value == null || value.isEmpty) {
                              return 'Please enter HDL Cholesterol result';
                            }
                            return null;
                          },
                          decoration: const InputDecoration(
                            hintText: '100-129',
                            suffixText: 'mg/dL',
                            label: Text('LDL Cholesterol'),
                          ),
                          onChanged: (String? value) {
                            setState(
                                () => ldl = double.parse(value.toString()));
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
                          await DatabaseHandler.instance
                              .insertCh(Cholesterol(
                                  user: userid,
                                  type: 'chlstrl',
                                  content: CHLSTRL(
                                      total: total,
                                      tag: tag,
                                      hdl: hdl,
                                      ldl: ldl,
                                      unit: unit),
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
    late Future<List<Cholesterol>> ch;
    Future<List<Cholesterol>> getList() async {
      handler = DatabaseHandler.instance;
      return await handler.chlstrlEntry(entryid);
    }

    ch = getList();
    showDialog(
        context: context,
        builder: (BuildContext context) {
          return FutureBuilder<List<Cholesterol>>(
            future: ch,
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
                          child: Text('Record ID: $entryid'),
                        ),
                      ],
                    ),
                    content: Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                            children: [
                              const Text('Total:',
                                  style: TextStyle(
                                    fontSize: 20,
                                  )),
                              Text(
                                '${entry.first.content.total}',
                                style: TextStyle(
                                    fontSize: 20,
                                    color: (entry.first.content.total > 240)
                                        ? Colors.red
                                        : Colors.green),
                              ),
                            ],
                          ),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                            children: [
                              const Text('TAG:',
                                  style: TextStyle(
                                    fontSize: 20,
                                  )),
                              Text(
                                '${entry.first.content.tag}',
                                style: TextStyle(
                                    fontSize: 20,
                                    color: (entry.first.content.tag > 500)
                                        ? Colors.red
                                        : Colors.green),
                              ),
                            ],
                          ),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                            children: [
                              const Text('HDL:',
                                  style: TextStyle(
                                    fontSize: 20,
                                  )),
                              Text(
                                '${entry.first.content.hdl}',
                                style: TextStyle(
                                    fontSize: 20,
                                    color: (entry.first.content.hdl > 60)
                                        ? Colors.red
                                        : Colors.green),
                              ),
                            ],
                          ),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                            children: [
                              const Text('LDL:',
                                  style: TextStyle(
                                    fontSize: 20,
                                  )),
                              Text(
                                '${entry.first.content.ldl}',
                                style: TextStyle(
                                    fontSize: 20,
                                    color: (entry.first.content.ldl > 190)
                                        ? Colors.red
                                        : Colors.green),
                              ),
                            ],
                          ),
                          const Padding(
                            padding: EdgeInsets.only(top: 10.0),
                            child: SizedBox(
                              child: Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceAround,
                                crossAxisAlignment: CrossAxisAlignment.center,
                                children: [
                                  Text('TAG: (Tracyglyclerol)'),
                                ],
                              ),
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
