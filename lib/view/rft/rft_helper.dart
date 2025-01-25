import 'package:flutter/material.dart';
import 'package:healthlog/data/db.dart';
import 'package:healthlog/model/kidney.dart';
import 'package:healthlog/view/theme/globals.dart';
import 'package:shared_preferences/shared_preferences.dart';

class RFTHelper {
  static Future<void> statefulRftBottomModal(BuildContext context,
      {required int userid,
      required Function callback,
      required GlobalKey<RefreshIndicatorState> refreshIndicatorKey,
      SharedPreferences? prefs}) async {
    final formKey = GlobalKey<FormState>();
    double bun = 0.00;
    double urea = 0.00;
    double creatinine = 0.00;
    double sodium = 0.00;
    double potassium = 0.00;
    // String fastingNormalReading = '60 - 110';
    // String afterFastingNormalReading = '70 - 140';
    String unit = "mg/dL";
    String elunit = "mmol/L";
    String comment = "";

    //Get prefs
    double bunLow = prefs!.getDouble('bunLow') ?? 4.6;
    double bunHigh = prefs.getDouble('bunHigh') ?? 23.5;
    double ureaLow = prefs.getDouble('ureaLow') ?? 10;
    double ureaHigh = prefs.getDouble('ureaHigh') ?? 50;
    double creatinineLow = prefs.getDouble('creatinineLow') ?? 0.6;
    double creatinineHigh = prefs.getDouble('creatinineHigh') ?? 1.2;
    double sodiumLow = prefs.getDouble('sodiumLow') ?? 135;
    double sodiumHigh = prefs.getDouble('sodiumHigh') ?? 145;
    double potassiumLow = prefs.getDouble('potassiumLow') ?? 3.5;
    double potassiumHigh = prefs.getDouble('potassiumHigh') ?? 5.0;

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
              height: 550,
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
                          width: 165,
                          child: RadioListTile<String>(
                              title: const Text("mmol/L"),
                              value: "mmol/L",
                              groupValue: unit,
                              onChanged: (String? value) {
                                setState(() {
                                  unit = value.toString();
                                });
                              }),
                        ),
                        SizedBox(
                          width: 160,
                          child: RadioListTile<String>(
                            title: const Text("mg/dL"),
                            selected: true,
                            value: "mg/dL",
                            groupValue: unit,
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
                      padding: const EdgeInsets.only(left: 40, right: 40),
                      child: TextFormField(
                          keyboardType: TextInputType.number,
                          validator: (value) {
                            if (value == null ||
                                value.isEmpty ||
                                !GlobalMethods.isDouble(value)) {
                              return 'Please enter BUN reading';
                            }
                            return null;
                          },
                          decoration: InputDecoration(
                            hintText: '$bunLow - $bunHigh',
                            suffixText: unit,
                            label: const Text('BUN'),
                          ),
                          onChanged: (String? value) {
                            setState(
                                () => bun = double.parse(value.toString()));
                          }),
                    ),
                    Padding(
                      padding: const EdgeInsets.only(left: 40, right: 40),
                      child: TextFormField(
                          keyboardType: TextInputType.number,
                          validator: (value) {
                            if (value == null ||
                                value.isEmpty ||
                                !GlobalMethods.isDouble(value)) {
                              return 'Please enter Urea reading';
                            }
                            return null;
                          },
                          decoration: InputDecoration(
                            hintText: '$ureaLow - $ureaHigh',
                            suffixText: unit,
                            label: const Text('Urea'),
                          ),
                          onChanged: (String? value) {
                            setState(
                                () => urea = double.parse(value.toString()));
                          }),
                    ),
                    Padding(
                      padding: const EdgeInsets.only(left: 40, right: 40),
                      child: TextFormField(
                          keyboardType: TextInputType.number,
                          validator: (value) {
                            if (value == null ||
                                value.isEmpty ||
                                !GlobalMethods.isDouble(value)) {
                              return 'Please enter creatinine reading';
                            }
                            return null;
                          },
                          decoration: InputDecoration(
                            hintText: '$creatinineLow - $creatinineHigh',
                            suffixText: unit,
                            label: const Text('Creatinine'),
                          ),
                          onChanged: (String? value) {
                            setState(() =>
                                creatinine = double.parse(value.toString()));
                          }),
                    ),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        SizedBox(
                          width: 165,
                          child: RadioListTile<String>(
                              title: const Text("mmol/L"),
                              value: "mmol/L",
                              selected: true,
                              groupValue: elunit,
                              onChanged: (String? value) {
                                setState(() {
                                  elunit = value.toString();
                                });
                              }),
                        ),
                        SizedBox(
                          width: 160,
                          child: RadioListTile<String>(
                            title: const Text("mEq/L"),
                            value: "mEq/L",
                            groupValue: elunit,
                            onChanged: (String? value) {
                              setState(() {
                                elunit = value.toString();
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
                              return 'Please enter Sodium reading';
                            }
                            return null;
                          },
                          decoration: InputDecoration(
                            hintText: '$sodiumLow - $sodiumHigh',
                            suffixText: elunit,
                            label: const Text('Sodium'),
                          ),
                          onChanged: (String? value) {
                            setState(
                                () => sodium = double.parse(value.toString()));
                          }),
                    ),
                    Padding(
                      padding: const EdgeInsets.only(left: 40, right: 40),
                      child: TextFormField(
                          keyboardType: TextInputType.number,
                          validator: (value) {
                            if (value == null ||
                                value.isEmpty ||
                                !GlobalMethods.isDouble(value)) {
                              return 'Please enter Potassium reading';
                            }
                            return null;
                          },
                          decoration: InputDecoration(
                            hintText: '$potassiumLow - $potassiumHigh',
                            suffixText: elunit,
                            label: const Text('Potassium'),
                          ),
                          onChanged: (String? value) {
                            setState(() =>
                                potassium = double.parse(value.toString()));
                          }),
                    ),
                    Padding(
                      padding: const EdgeInsets.only(left: 40, right: 40),
                      child: TextFormField(
                          decoration: const InputDecoration(
                              hintText: 'Additional Context',
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
                                .insertRf(RenalFunction(
                                    user: userid,
                                    type: 'rft',
                                    content: RFT(
                                        bun: bun,
                                        urea: urea,
                                        creatinine: creatinine,
                                        elements: RFTel(
                                          unit: elunit,
                                          sodium: sodium,
                                          potassium: potassium,
                                        ),
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

  static Future<void> statefulRftUpdateModal(BuildContext context,
      {required int userid,
      required int entryid,
      required Function callback,
      required GlobalKey<RefreshIndicatorState> refreshIndicatorKey,
      required SharedPreferences? prefs}) async {
    final formKey = GlobalKey<FormState>();
    late DatabaseHandler handler;
    late Future<List<RenalFunction>> rf;
    Future<List<RenalFunction>> getList() async {
      handler = DatabaseHandler.instance;
      return await handler.rftEntry(entryid);
    }

    rf = getList();

    double bun = 0.00;
    double urea = 0.00;
    double creatinine = 0.00;
    double sodium = 0.00;
    double potassium = 0.00;
    // String fastingNormalReading = '60 - 110';
    // String afterFastingNormalReading = '70 - 140';
    String unit = "";
    String elunit = "mmol/L";
    String comment = "";

    double bunLow = prefs!.getDouble('bunLow') ?? 4.6;
    double bunHigh = prefs.getDouble('bunHigh') ?? 23.5;
    double ureaLow = prefs.getDouble('ureaLow') ?? 10;
    double ureaHigh = prefs.getDouble('ureaHigh') ?? 50;
    double creatinineLow = prefs.getDouble('creatinineLow') ?? 0.6;
    double creatinineHigh = prefs.getDouble('creatinineHigh') ?? 1.2;
    double sodiumLow = prefs.getDouble('sodiumLow') ?? 135;
    double sodiumHigh = prefs.getDouble('sodiumHigh') ?? 145;
    double potassiumLow = prefs.getDouble('potassiumLow') ?? 3.5;
    double potassiumHigh = prefs.getDouble('potassiumHigh') ?? 5.0;

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
              height: 550,
              width: MediaQuery.of(context).size.width / 1.25,
              child: FutureBuilder<List<RenalFunction>>(
                  future: rf,
                  builder: (context, snapshot) {
                    if (snapshot.connectionState == ConnectionState.done) {
                      if (snapshot.hasError) {
                        return Text('Error: ${snapshot.error}');
                      } else {
                        final entry = snapshot.data ?? [];
                        final rfd = entry.first.content;
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
                                    width: 160,
                                    child: RadioListTile<String>(
                                        title: const Text("mmol/L"),
                                        selected: rfd.unit == 'mmol/L',
                                        value: "mmol/L",
                                        groupValue:
                                            unit.isEmpty ? rfd.unit : unit,
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
                                      selected: rfd.unit == 'mg/dL',
                                      value: "mg/dL",
                                      groupValue:
                                          unit.isEmpty ? rfd.unit : unit,
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
                                    initialValue: rfd.bun.toString(),
                                    keyboardType: TextInputType.number,
                                    validator: (value) {
                                      if (value == null ||
                                          value.isEmpty ||
                                          !GlobalMethods.isDouble(value)) {
                                        return 'Please enter BUN reading';
                                      }
                                      return null;
                                    },
                                    decoration: InputDecoration(
                                      hintText: '$bunLow - $bunHigh',
                                      suffixText: unit,
                                      label: const Text('BUN'),
                                    ),
                                    onChanged: (String? value) {
                                      setState(() =>
                                          bun = double.parse(value.toString()));
                                    }),
                              ),
                              Padding(
                                padding:
                                    const EdgeInsets.only(left: 40, right: 40),
                                child: TextFormField(
                                    initialValue: rfd.urea.toString(),
                                    keyboardType: TextInputType.number,
                                    validator: (value) {
                                      if (value == null ||
                                          value.isEmpty ||
                                          !GlobalMethods.isDouble(value)) {
                                        return 'Please enter Urea reading';
                                      }
                                      return null;
                                    },
                                    decoration: InputDecoration(
                                      hintText: '$ureaLow - $ureaHigh',
                                      suffixText: unit,
                                      label: const Text('Urea'),
                                    ),
                                    onChanged: (String? value) {
                                      setState(() => urea =
                                          double.parse(value.toString()));
                                    }),
                              ),
                              Padding(
                                padding:
                                    const EdgeInsets.only(left: 40, right: 40),
                                child: TextFormField(
                                    initialValue: rfd.creatinine.toString(),
                                    keyboardType: TextInputType.number,
                                    validator: (value) {
                                      if (value == null ||
                                          value.isEmpty ||
                                          !GlobalMethods.isDouble(value)) {
                                        return 'Please enter Creatinine reading';
                                      }
                                      return null;
                                    },
                                    decoration: InputDecoration(
                                      hintText:
                                          '$creatinineLow - $creatinineHigh',
                                      suffixText: unit,
                                      label: const Text('Creatinine'),
                                    ),
                                    onChanged: (String? value) {
                                      setState(() => creatinine =
                                          double.parse(value.toString()));
                                    }),
                              ),
                              Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  SizedBox(
                                    width: 165,
                                    child: RadioListTile<String>(
                                        title: const Text("mmol/L"),
                                        value: "mmol/L",
                                        selected: true,
                                        groupValue: elunit.isEmpty
                                            ? rfd.elements.unit
                                            : elunit,
                                        onChanged: (String? value) {
                                          setState(() {
                                            elunit = value.toString();
                                          });
                                        }),
                                  ),
                                  SizedBox(
                                    width: 160,
                                    child: RadioListTile<String>(
                                      title: const Text("mEq/L"),
                                      value: "mEq/L",
                                      groupValue: elunit.isEmpty
                                          ? rfd.elements.unit
                                          : elunit,
                                      onChanged: (String? value) {
                                        setState(() {
                                          elunit = value.toString();
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
                                    initialValue:
                                        rfd.elements.sodium.toString(),
                                    keyboardType: TextInputType.number,
                                    validator: (value) {
                                      if (value == null ||
                                          value.isEmpty ||
                                          !GlobalMethods.isDouble(value)) {
                                        return 'Please enter Sodium reading';
                                      }
                                      return null;
                                    },
                                    decoration: InputDecoration(
                                      hintText: '$sodiumLow - $sodiumHigh',
                                      suffixText: unit,
                                      label: const Text('Sodium'),
                                    ),
                                    onChanged: (String? value) {
                                      setState(() => sodium =
                                          double.parse(value.toString()));
                                    }),
                              ),
                              Padding(
                                padding:
                                    const EdgeInsets.only(left: 40, right: 40),
                                child: TextFormField(
                                    initialValue:
                                        rfd.elements.potassium.toString(),
                                    keyboardType: TextInputType.number,
                                    validator: (value) {
                                      if (value == null ||
                                          value.isEmpty ||
                                          !GlobalMethods.isDouble(value)) {
                                        return 'Please enter Potassium reading';
                                      }
                                      return null;
                                    },
                                    decoration: InputDecoration(
                                      hintText:
                                          '$potassiumLow - $potassiumHigh',
                                      suffixText: unit,
                                      label: const Text('Potassium'),
                                    ),
                                    onChanged: (String? value) {
                                      setState(() => potassium =
                                          double.parse(value.toString()));
                                    }),
                              ),
                              Padding(
                                padding:
                                    const EdgeInsets.only(left: 40, right: 40),
                                child: TextFormField(
                                    initialValue: entry.first.comments,
                                    decoration: const InputDecoration(
                                        hintText: 'Additional Context',
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
                                          .updateRf(
                                              RenalFunction(
                                                  id: entry.first.id,
                                                  user: userid,
                                                  type: 'rft',
                                                  content: RFT(
                                                      bun: bun != 0.0 &&
                                                              bun != rfd.bun
                                                          ? bun
                                                          : rfd.bun,
                                                      urea: urea != 0.0 &&
                                                              urea != rfd.urea
                                                          ? urea
                                                          : rfd.urea,
                                                      creatinine: creatinine !=
                                                                  0.0 &&
                                                              creatinine !=
                                                                  rfd.creatinine
                                                          ? creatinine
                                                          : rfd.creatinine,
                                                      elements: RFTel(
                                                        unit: elunit.isNotEmpty
                                                            ? elunit
                                                            : rfd.elements.unit,
                                                        sodium: sodium != 0.0 &&
                                                                sodium !=
                                                                    rfd.elements
                                                                        .sodium
                                                            ? sodium
                                                            : rfd.elements
                                                                .sodium,
                                                        potassium: potassium !=
                                                                    0.0 &&
                                                                potassium !=
                                                                    rfd.elements
                                                                        .potassium
                                                            ? potassium
                                                            : rfd.elements
                                                                .potassium,
                                                      ),
                                                      unit: unit.isNotEmpty
                                                          ? unit
                                                          : rfd.unit),
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
    late Future<List<RenalFunction>> rf;

    Future<List<RenalFunction>> getList() async {
      handler = DatabaseHandler.instance;
      return await handler.rftEntry(entryid);
    }

    double bunLow = prefs!.getDouble('bunLow') ?? 4.6;
    double bunHigh = prefs.getDouble('bunHigh') ?? 23.5;
    double ureaLow = prefs.getDouble('ureaLow') ?? 10;
    double ureaHigh = prefs.getDouble('ureaHigh') ?? 50;
    double creatinineLow = prefs.getDouble('creatinineLow') ?? 0.6;
    double creatinineHigh = prefs.getDouble('creatinineHigh') ?? 1.2;
    double sodiumLow = prefs.getDouble('sodiumLow') ?? 135;
    double sodiumHigh = prefs.getDouble('sodiumHigh') ?? 145;
    double potassiumLow = prefs.getDouble('potassiumLow') ?? 3.5;
    double potassiumHigh = prefs.getDouble('potassiumHigh') ?? 5.0;

    rf = getList();
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return FutureBuilder<List<RenalFunction>>(
          future: rf,
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.done) {
              if (snapshot.hasError) {
                return Text('Error: ${snapshot.error}');
              } else {
                final entry = snapshot.data ?? [];
                final userid = entry.first.user;
                final rfd = entry.first.content;
                final fromUnit = entry.first.content.unit;

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
                          'Record ID: $entryid',
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
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                          children: [
                            const Text('BUN:',
                                style: TextStyle(
                                  fontSize: 20,
                                )),
                            Text(
                                GlobalMethods.convertUnit(
                                  fromUnit,
                                  rfd.bun,
                                  unit,
                                ).toStringAsFixed(2),
                                style: TextStyle(
                                    fontSize: 20,
                                    color: (GlobalMethods.convertUnit(
                                                    fromUnit, rfd.bun, unit) >
                                                GlobalMethods.convertUnit(
                                                    'mg/dL', bunHigh, unit) ||
                                            GlobalMethods.convertUnit(
                                                    fromUnit, rfd.bun, unit) <
                                                GlobalMethods.convertUnit(
                                                    'mg/dL', bunLow, unit))
                                        ? Colors.red
                                        : Colors.green)),
                          ],
                        ),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                          children: [
                            const Text('Urea:',
                                style: TextStyle(
                                  fontSize: 20,
                                )),
                            Text(
                              GlobalMethods.convertUnit(
                                fromUnit,
                                rfd.urea,
                                unit,
                              ).toStringAsFixed(2),
                              style: TextStyle(
                                  fontSize: 20,
                                  color: (GlobalMethods.convertUnit(
                                                  fromUnit, rfd.urea, unit) >
                                              GlobalMethods.convertUnit(
                                                  'mg/dL', ureaHigh, unit) ||
                                          GlobalMethods.convertUnit(
                                                  fromUnit, rfd.urea, unit) <
                                              GlobalMethods.convertUnit(
                                                  'mg/dL', ureaLow, unit))
                                      ? Colors.red
                                      : Colors.green),
                            ),
                          ],
                        ),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                          children: [
                            const Text('Creatinine:',
                                style: TextStyle(
                                  fontSize: 20,
                                )),
                            Text(
                              GlobalMethods.convertUnit(
                                fromUnit,
                                rfd.creatinine,
                                unit,
                              ).toStringAsFixed(2),
                              style: TextStyle(
                                  fontSize: 20,
                                  color: (GlobalMethods.convertUnit(fromUnit,
                                                  rfd.creatinine, unit) >
                                              GlobalMethods.convertUnit('mg/dL',
                                                  creatinineHigh, unit) ||
                                          GlobalMethods.convertUnit(fromUnit,
                                                  rfd.creatinine, unit) <
                                              GlobalMethods.convertUnit(
                                                  'mg/dL', creatinineLow, unit))
                                      ? Colors.red
                                      : Colors.green),
                            ),
                          ],
                        ),
                        Padding(
                          padding: EdgeInsets.only(top: 10.0, bottom: 5.0),
                          child: SizedBox(
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceAround,
                              crossAxisAlignment: CrossAxisAlignment.center,
                              children: [
                                Text('Unit: $unit'),
                              ],
                            ),
                          ),
                        ),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                          children: [
                            const Text('Sodium:',
                                style: TextStyle(
                                  fontSize: 20,
                                )),
                            Text(
                              '${rfd.elements.sodium}',
                              style: TextStyle(
                                  fontSize: 20,
                                  color: (rfd.elements.sodium > sodiumHigh ||
                                          rfd.elements.sodium < sodiumLow)
                                      ? Colors.red
                                      : Colors.green),
                            ),
                          ],
                        ),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                          children: [
                            const Text('Potassium:',
                                style: TextStyle(fontSize: 20)),
                            Text(
                              '${rfd.elements.potassium}',
                              style: TextStyle(
                                  fontSize: 20,
                                  color: (rfd.elements.potassium >
                                              potassiumHigh ||
                                          rfd.elements.potassium < potassiumLow)
                                      ? Colors.red
                                      : Colors.green),
                            ),
                          ],
                        ),
                        Padding(
                          padding: EdgeInsets.only(top: 10.0),
                          child: SizedBox(
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceAround,
                              crossAxisAlignment: CrossAxisAlignment.center,
                              children: [
                                Text('Unit: ${rfd.elements.unit}'),
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
                            statefulRftUpdateModal(context,
                                userid: userid,
                                entryid: entryid,
                                callback: () {},
                                refreshIndicatorKey: refresh,
                                prefs: prefs)
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

  static ListTile tileRFT(BuildContext context, RenalFunction items, unit) {
    String fromUnit = items.content.unit;
    String bun = GlobalMethods.convertUnit(
      fromUnit,
      items.content.bun,
      unit,
    ).toStringAsFixed(2);
    String urea = GlobalMethods.convertUnit(
      fromUnit,
      items.content.urea,
      unit,
    ).toStringAsFixed(2);
    String creatinine = GlobalMethods.convertUnit(
      fromUnit,
      items.content.creatinine,
      unit,
    ).toStringAsFixed(2);
    String sodium = items.content.elements.sodium.toStringAsFixed(2);
    String potassium = items.content.elements.potassium.toStringAsFixed(2);
    String elunit = items.content.elements.unit;
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
                text:
                    '\nBun/Urea/Creatinine:\n$bun/$urea/$creatinine $unit \nSodium/Potassium: \n$sodium/$potassium $elunit',
                style: TextStyle(fontWeight: FontWeight.bold)),
          ])),
      subtitle: Text('Note: ${items.comments.toString()}'),
    );
  }
}
