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
    String beforeAfter = '60 - 110';
    String fastingNormalReading = '60 - 110';
    String afterFastingNormalReading = '70 - 140';
    String fastGroup = "";
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
                              return 'Please enter blood sugar reading';
                            }
                            return null;
                          },
                          decoration: const InputDecoration(
                            hintText: '70',
                            label: Text('Blood Sugar'),
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
                                      reading: reading,
                                      beforeAfter: beforeAfter,
                                      unit: 'mg/dl'),
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
