import 'dart:math';

import 'package:flutter/material.dart';
import 'package:healthlog/data/db.dart';
import 'package:healthlog/model/bloodpressure.dart';

class BPHelper {
  static Future<void> statefulBpBottomModal(BuildContext context,
      {required int userid,
      required Function callback,
      required GlobalKey<RefreshIndicatorState> refreshIndicatorKey}) async {
    final formKey = GlobalKey<FormState>();
    int systolic = 120;
    int diastolic = 80;
    int heartrate = 70;
    String arm = "";
    String armGroup = "";
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
                              return 'Please enter systolic value';
                            }
                            return null;
                          },
                          decoration: const InputDecoration(
                            hintText: '120',
                            label: Text('Systolic'),
                          ),
                          onChanged: (String? value) {
                            setState(
                                () => systolic = int.parse(value.toString()));
                          }),
                    ),
                    Padding(
                      padding: const EdgeInsets.only(left: 40, right: 40),
                      child: TextFormField(
                          keyboardType: TextInputType.number,
                          validator: (value) {
                            if (value == null || value.isEmpty) {
                              return 'Please enter diastolic value';
                            }
                            return null;
                          },
                          decoration: const InputDecoration(
                            hintText: '80',
                            label: Text('Diastolic'),
                          ),
                          onChanged: (String? value) {
                            setState(
                                () => diastolic = int.parse(value.toString()));
                          }),
                    ),
                    Padding(
                      padding: const EdgeInsets.only(left: 40, right: 40),
                      child: TextFormField(
                          keyboardType: TextInputType.number,
                          validator: (value) {
                            if (value == null || value.isEmpty) {
                              return 'Please enter your heartrate';
                            }
                            return null;
                          },
                          decoration: const InputDecoration(
                            hintText: '70',
                            label: Text('Heartrate'),
                          ),
                          onChanged: (String? value) {
                            setState(
                                () => heartrate = int.parse(value.toString()));
                          }),
                    ),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        SizedBox(
                          width: 150,
                          child: RadioListTile<String>(
                              title: const Text("Left"),
                              value: "left",
                              groupValue: armGroup,
                              onChanged: (String? value) {
                                setState(() {
                                  arm = armGroup = value.toString();
                                });
                              }),
                        ),
                        SizedBox(
                          width: 150,
                          child: RadioListTile<String>(
                            title: const Text("Right"),
                            value: "right",
                            groupValue: armGroup,
                            onChanged: (String? value) {
                              setState(() {
                                arm = armGroup = value.toString();
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
                              hintText: 'Before Breakfast/After Dinner',
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
                              .insertBp(BloodPressure(
                                  id: Random().nextInt(50),
                                  user: userid,
                                  type: 'bp',
                                  content: BP(
                                      systolic: systolic,
                                      diastolic: diastolic,
                                      heartrate: heartrate,
                                      arm: arm),
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
}
