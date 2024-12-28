import 'package:flutter/material.dart';
import 'package:healthlog/data/db.dart';
import 'package:healthlog/model/sugar.dart';
import 'package:healthlog/view/theme/globals.dart';
import 'package:shared_preferences/shared_preferences.dart';

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
    String unit = "mg/dL";
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
              height: 325,
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
                            if (value == null ||
                                value.isEmpty ||
                                !GlobalMethods.isDouble(value)) {
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
                            suffixText: unitGroup,
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
                    Padding(
                      padding: const EdgeInsets.all(10.0),
                      child: ElevatedButton(
                        onPressed: () async {
                          if (formKey.currentState!.validate()) {
                            await DatabaseHandler.instance
                                .insertSg(Sugar(
                                    user: userid,
                                    type: 'sugar',
                                    content: SG(
                                        reading: reading,
                                        beforeAfter: beforeAfter,
                                        unit: unit),
                                    date: DateTime.now().toIso8601String(),
                                    comments: comment))
                                .whenComplete(() {
                              if (context.mounted) {
                                Navigator.pop(context);
                              }
                              WidgetsBinding.instance.addPostFrameCallback(
                                  (_) =>
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

  static Future<void> statefulSgUpdateModal(BuildContext context,
      {required int userid,
      required int entryid,
      required Function callback,
      required GlobalKey<RefreshIndicatorState> refreshIndicatorKey}) async {
    late DatabaseHandler handler;
    late Future<List<Sugar>> sg;
    Future<List<Sugar>> getList() async {
      handler = DatabaseHandler.instance;
      return await handler.sugarEntry(entryid);
    }

    sg = getList();

    final formKey = GlobalKey<FormState>();

    double reading = 0.0;
    String beforeAfter = '';
    // String fastingNormalReading = '60 - 110';
    // String afterFastingNormalReading = '70 - 140';
    String fastGroup = '';
    String unit = '';
    String comment = '';

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
              height: 325,
              width: MediaQuery.of(context).size.width / 1.25,
              child: FutureBuilder<List<Sugar>>(
                  future: sg,
                  builder: (context, snapshot) {
                    if (snapshot.connectionState == ConnectionState.done) {
                      if (snapshot.hasError) {
                        return Text('Error: ${snapshot.error}');
                      } else {
                        final entry = snapshot.data ?? [];
                        final sgd = entry.first.content;

                        return Form(
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
                                        selected: sgd.beforeAfter == 'before',
                                        value: "before",
                                        groupValue: fastGroup.isEmpty
                                            ? sgd.beforeAfter
                                            : fastGroup,
                                        onChanged: (String? value) {
                                          setState(() {
                                            beforeAfter =
                                                fastGroup = value.toString();
                                          });
                                        }),
                                  ),
                                  SizedBox(
                                    width: 150,
                                    child: RadioListTile<String>(
                                      title: const Text("After"),
                                      selected: sgd.beforeAfter == 'after',
                                      value: "after",
                                      groupValue: fastGroup.isEmpty
                                          ? sgd.beforeAfter
                                          : fastGroup,
                                      onChanged: (String? value) {
                                        setState(() {
                                          beforeAfter =
                                              fastGroup = value.toString();
                                        });
                                      },
                                    ),
                                  ),
                                ],
                              ),
                              Padding(
                                padding:
                                    const EdgeInsets.only(left: 40, right: 40),
                                child: TextFormField(
                                    initialValue: sgd.reading.toString(),
                                    keyboardType: TextInputType.number,
                                    validator: (value) {
                                      if (value == null ||
                                          value.isEmpty ||
                                          !GlobalMethods.isDouble(value)) {
                                        return 'Please enter blood sugar reading';
                                      }
                                      return null;
                                    },
                                    decoration: InputDecoration(
                                      hintText: (unit == 'mg/dL' &&
                                              beforeAfter == 'before')
                                          ? '60-110'
                                          : (unit == 'mg/dL' &&
                                                  beforeAfter == 'after')
                                              ? '70-140'
                                              : (unit == 'mmol/L' &&
                                                      beforeAfter == 'before')
                                                  ? '3.33-6.11'
                                                  : (unit == 'mmol/L' &&
                                                          beforeAfter ==
                                                              'after')
                                                      ? '3.88-7.77'
                                                      : '',
                                      suffixText: unit,
                                      label: const Text('Blood Sugar'),
                                    ),
                                    onChanged: (String? value) {
                                      setState(() => reading =
                                          double.parse(value.toString()));
                                    }),
                              ),
                              Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  SizedBox(
                                    width: 160,
                                    child: RadioListTile<String>(
                                        title: const Text("mmol/L"),
                                        selected: sgd.unit == 'mmol/L',
                                        value: "mmol/L",
                                        groupValue:
                                            unit.isEmpty ? sgd.unit : unit,
                                        onChanged: (String? value) {
                                          setState(() {
                                            unit = value.toString();
                                          });
                                        }),
                                  ),
                                  SizedBox(
                                    width: 150,
                                    child: RadioListTile<String>(
                                      title: const Text("mg/dL"),
                                      selected: sgd.unit == 'mg/dL',
                                      value: "mg/dL",
                                      groupValue:
                                          unit.isEmpty ? sgd.unit : unit,
                                      onChanged: (String? value) {
                                        setState(() {
                                          unit = value.toString();
                                        });
                                      },
                                    ),
                                  ),
                                ],
                              ),
                              Padding(
                                padding:
                                    const EdgeInsets.only(left: 40, right: 40),
                                child: TextFormField(
                                    initialValue: entry.first.comments,
                                    decoration: const InputDecoration(
                                        hintText: 'Additional context',
                                        label: Text('Comments')),
                                    onChanged: (String? value) {
                                      setState(
                                          () => comment = value.toString());
                                    }),
                              ),
                              Padding(
                                padding: const EdgeInsets.all(10.0),
                                child: ElevatedButton(
                                  onPressed: () async {
                                    if (formKey.currentState!.validate()) {
                                      await DatabaseHandler.instance
                                          .updateSg(
                                              Sugar(
                                                  id: entry.first.id,
                                                  user: userid,
                                                  type: 'sugar',
                                                  content: SG(
                                                      reading: reading != 0.0 &&
                                                              reading !=
                                                                  sgd.reading
                                                          ? reading
                                                          : sgd.reading,
                                                      beforeAfter:
                                                          beforeAfter.isNotEmpty
                                                              ? beforeAfter
                                                              : sgd.beforeAfter,
                                                      unit: unit.isNotEmpty
                                                          ? unit
                                                          : sgd.unit),
                                                  date: entry.first.date,
                                                  comments: comment.isNotEmpty
                                                      ? comment
                                                      : entry.first.comments),
                                              userid,
                                              entryid)
                                          .whenComplete(() {
                                        if (context.mounted) {
                                          Navigator.pop(context);
                                        }
                                        WidgetsBinding.instance
                                            .addPostFrameCallback((_) =>
                                                refreshIndicatorKey.currentState
                                                    ?.show());
                                      });
                                    } else {
                                      ScaffoldMessenger.of(context)
                                          .showSnackBar(
                                        const SnackBar(
                                            content: Text('Processing Data')),
                                      );
                                    }
                                  },
                                  child: const Text(
                                    'Update',
                                    style: TextStyle(
                                      fontSize: 20,
                                    ),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        );
                      }
                    } else {
                      return const CircularProgressIndicator(); // Or any loading indicator widget
                    }
                  }),
            ),
          );
        });
      }),
    );
  }

  static Future<void> showRecord(
      BuildContext context,
      int entryid,
      String unit,
      GlobalKey<RefreshIndicatorState> refresh,
      SharedPreferences? prefs) async {
    late DatabaseHandler handler;
    late Future<List<Sugar>> sg;
    Future<List<Sugar>> getList() async {
      handler = DatabaseHandler.instance;
      return await handler.sugarEntry(entryid);
    }

    sg = getList();
    double sugarBeforeLow = prefs!.getDouble('sugarBeforeLow') ?? 60;
    double sugarBeforeHigh = prefs.getDouble('sugarBeforeHigh') ?? 110;
    double sugarAfterLow = prefs.getDouble('sugarAfterLow') ?? 60;
    double sugarAfterHigh = prefs.getDouble('sugarAfterHigh') ?? 140;
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
                final userid = entry.first.user;
                //Convert the units as required from settings
                String reading = GlobalMethods.convertUnit(
                  entry.first.content.unit,
                  entry.first.content.reading,
                  unit,
                ).toStringAsFixed(2);

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
                        child: Text(
                          'Sugar Record: $entryid',
                          style: TextStyle(
                            color: Theme.of(context).primaryColor,
                          ),
                        ),
                      ),
                    ],
                  ),
                  content: Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                          children: [
                            Text(
                                '${entry.first.content.beforeAfter.toUpperCase()}:',
                                style: const TextStyle(
                                  fontSize: 20,
                                )),
                            Text(
                              '$reading $unit',
                              //Color the readings based on range
                              style: TextStyle(
                                  fontSize: 20,
                                  color: (unit == 'mg/dL' &&
                                              entry.first.content.beforeAfter ==
                                                  'before' &&
                                              double.parse(reading) >
                                                  sugarBeforeHigh) ||
                                          (unit == 'mg/dL' &&
                                              entry.first.content.beforeAfter ==
                                                  'after' &&
                                              double.parse(reading) >
                                                  sugarAfterHigh)
                                      ? Colors.red
                                      : Colors.green),
                            ),
                          ],
                        ),
                        Padding(
                          padding: const EdgeInsets.only(top: 5.0),
                          child: SizedBox(
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.spaceAround,
                              crossAxisAlignment: CrossAxisAlignment.center,
                              children: [
                                unit == 'mg/dL'
                                    ? Text(
                                        'Fasting: $sugarBeforeLow-$sugarBeforeHigh mg/dL')
                                    : const Text('Fasting: 3.33-6.11 mmol/L'),
                                unit == 'mg/dL'
                                    ? Text(
                                        'After: $sugarAfterLow-$sugarAfterHigh mg/dL')
                                    : const Text('After: 3.88-7.77 mmol/L')
                              ],
                            ),
                          ),
                        ),
                        Padding(
                          padding: const EdgeInsets.only(top: 25.0),
                          child: SizedBox(
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceAround,
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
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        ElevatedButton(
                          onPressed: () => {
                            Navigator.pop(context),
                            statefulSgUpdateModal(context,
                                userid: userid,
                                entryid: entryid,
                                callback: () {},
                                refreshIndicatorKey: refresh)
                          },
                          child: const Text('Update'),
                        ),
                        ElevatedButton(
                          onPressed: () => Navigator.pop(context),
                          child: const Text('OK'),
                        ),
                      ],
                    ),
                  ],
                );
              }
            } else {
              return const CircularProgressIndicator(); // Or any loading indicator widget
            }
          },
        );
      },
    );
  }

  static ListTile tileSugar(BuildContext context, Sugar items, unit) {
    String reading = GlobalMethods.convertUnit(
      items.content.unit,
      items.content.reading,
      unit,
    ).toStringAsFixed(2);
    return ListTile(
      trailing: Text(
        '${DateTime.parse(items.date).year}-${DateTime.parse(items.date).month}-${DateTime.parse(items.date).day} ${DateTime.parse(items.date).hour}:${DateTime.parse(items.date).minute}',
      ),
      contentPadding: const EdgeInsets.all(8.0),
      title: RichText(
          text: TextSpan(
              style: TextStyle(
                color: Theme.of(context).textTheme.bodyMedium?.color,
                fontSize: 19,
              ),
              children: [
            TextSpan(
                text: '$reading $unit, ${items.content.beforeAfter}',
                style: TextStyle(fontWeight: FontWeight.bold)),
          ])),
      subtitle: Text('Note: ${items.comments.toString()}'),
    );
  }
}
