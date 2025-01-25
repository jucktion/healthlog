import 'package:flutter/material.dart';
import 'package:healthlog/data/db.dart';
import 'package:healthlog/model/cholesterol.dart';
import 'package:healthlog/view/theme/globals.dart';
import 'package:shared_preferences/shared_preferences.dart';

class CHLSTRLHelper {
  static Future<void> statefulchlstrlBottomModal(BuildContext context,
      {required int userid,
      required Function callback,
      required GlobalKey<RefreshIndicatorState> refreshIndicatorKey,
      SharedPreferences? prefs}) async {
    final formKey = GlobalKey<FormState>();
    double total = 0.00;
    double tag = 0.00;
    double hdl = 0.00;
    double ldl = 0.00;
    // String fastingNormalReading = '60 - 110';
    // String afterFastingNormalReading = '70 - 140';
    String unit = "mg/dL";
    String comment = "";

    double totalCholesterolHigh =
        prefs!.getDouble('totalCholesterolHigh') ?? 240;
    double tagHigh = prefs.getDouble('tagHigh') ?? 110;
    double hdlLow = prefs.getDouble('hdlLow') ?? 40;
    double hdlHigh = prefs.getDouble('hdlHigh') ?? 60;
    double ldlHigh = prefs.getDouble('ldlHigh') ?? 140;
    //double nonHdlHighHigh = prefs.getDouble('nonHdlHighHigh') ?? 140;

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
                              return 'Please enter total cholesterol result';
                            }
                            return null;
                          },
                          decoration: InputDecoration(
                            hintText: (unit == 'mg/dL')
                                ? 'Less than ${GlobalMethods.convertUnit(unit, totalCholesterolHigh).toStringAsFixed(2)}'
                                : (unit == 'mmol/L')
                                    ? 'Less than ${GlobalMethods.convertUnit('mg/dL', totalCholesterolHigh, unit).toStringAsFixed(2)}'
                                    : '',
                            suffixText: unit,
                            label: const Text('Total Cholesterol'),
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
                            if (value == null ||
                                value.isEmpty ||
                                !GlobalMethods.isDouble(value)) {
                              return 'Please enter Triacyglycerol result';
                            }
                            return null;
                          },
                          decoration: InputDecoration(
                            hintText: (unit == 'mg/dL')
                                ? 'Less than ${GlobalMethods.convertUnit(unit, tagHigh).toStringAsFixed(2)}'
                                : (unit == 'mmol/L')
                                    ? 'Less than ${GlobalMethods.convertUnit('mg/dL', tagHigh, unit).toStringAsFixed(2)}'
                                    : '',
                            suffixText: unit,
                            label: const Text('Triacyglycerol (TAG)'),
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
                            if (value == null ||
                                value.isEmpty ||
                                !GlobalMethods.isDouble(value)) {
                              return 'Please enter HDL Cholesterol result';
                            }
                            return null;
                          },
                          decoration: InputDecoration(
                            hintText: (unit == 'mg/dL')
                                ? '${GlobalMethods.convertUnit(unit, hdlLow).toStringAsFixed(2)} - ${GlobalMethods.convertUnit(unit, hdlHigh).toStringAsFixed(2)}'
                                : (unit == 'mmol/L')
                                    ? '${GlobalMethods.convertUnit('mg/dL', hdlLow, unit).toStringAsFixed(2)} - ${GlobalMethods.convertUnit('mg/dL', hdlHigh, unit).toStringAsFixed(2)}'
                                    : '',
                            suffixText: unit,
                            label: const Text('HDL Cholesterol'),
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
                            if (value == null ||
                                value.isEmpty ||
                                !GlobalMethods.isDouble(value)) {
                              return 'Please enter LDL Cholesterol result';
                            }
                            return null;
                          },
                          decoration: InputDecoration(
                            hintText: (unit == 'mg/dL')
                                ? 'Less than ${GlobalMethods.convertUnit(unit, ldlHigh).toStringAsFixed(2)}'
                                : (unit == 'mmol/L')
                                    ? 'Less than ${GlobalMethods.convertUnit('mg/dL', ldlHigh, unit).toStringAsFixed(2)}'
                                    : '',
                            suffixText: unit,
                            label: const Text('LDL Cholesterol'),
                          ),
                          onChanged: (String? value) {
                            setState(
                                () => ldl = double.parse(value.toString()));
                          }),
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

  static Future<void> statefulChlstrlUpdateModal(BuildContext context,
      {required int userid,
      required int entryid,
      required Function callback,
      required GlobalKey<RefreshIndicatorState> refreshIndicatorKey,
      required SharedPreferences? prefs}) async {
    final formKey = GlobalKey<FormState>();
    late DatabaseHandler handler;
    late Future<List<Cholesterol>> ch;
    Future<List<Cholesterol>> getList() async {
      handler = DatabaseHandler.instance;
      return await handler.chlstrlEntry(entryid);
    }

    ch = getList();

    double total = 0.00;
    double tag = 0.00;
    double hdl = 0.00;
    double ldl = 0.00;
    // String fastingNormalReading = '60 - 110';
    // String afterFastingNormalReading = '70 - 140';
    String unit = "";
    String comment = "";

    double totalCholesterolHigh =
        prefs!.getDouble('totalCholesterolHigh') ?? 240;
    double tagHigh = prefs.getDouble('tagHigh') ?? 110;
    double hdlLow = prefs.getDouble('hdlLow') ?? 40;
    double hdlHigh = prefs.getDouble('hdlHigh') ?? 60;
    double ldlHigh = prefs.getDouble('ldlHigh') ?? 140;

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
              child: FutureBuilder<List<Cholesterol>>(
                  future: ch,
                  builder: (context, snapshot) {
                    if (snapshot.connectionState == ConnectionState.done) {
                      if (snapshot.hasError) {
                        return Text('Error: ${snapshot.error}');
                      } else {
                        final entry = snapshot.data ?? [];
                        final chd = entry.first.content;
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
                                    width: 165,
                                    child: RadioListTile<String>(
                                        title: const Text("mmol/L"),
                                        selected: chd.unit == 'mmol/L',
                                        value: "mmol/L",
                                        groupValue:
                                            unit.isEmpty ? chd.unit : unit,
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
                                      selected: chd.unit == 'mg/dL',
                                      value: "mg/dL",
                                      groupValue:
                                          unit.isEmpty ? chd.unit : unit,
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
                                    initialValue: chd.total.toString(),
                                    keyboardType: TextInputType.number,
                                    validator: (value) {
                                      if (value == null ||
                                          value.isEmpty ||
                                          !GlobalMethods.isDouble(value)) {
                                        return 'Please enter total cholesterol result';
                                      }
                                      return null;
                                    },
                                    decoration: InputDecoration(
                                      hintText: (unit == 'mg/dL')
                                          ? 'Less than ${GlobalMethods.convertUnit(unit, totalCholesterolHigh).toStringAsFixed(2)}'
                                          : (unit == 'mmol/L')
                                              ? 'Less than ${GlobalMethods.convertUnit('mg/dL', totalCholesterolHigh, unit).toStringAsFixed(2)}'
                                              : '',
                                      suffixText: unit,
                                      label: const Text('Total Cholesterol'),
                                    ),
                                    onChanged: (String? value) {
                                      setState(() => total =
                                          double.parse(value.toString()));
                                    }),
                              ),
                              Padding(
                                padding:
                                    const EdgeInsets.only(left: 40, right: 40),
                                child: TextFormField(
                                    initialValue: chd.tag.toString(),
                                    keyboardType: TextInputType.number,
                                    validator: (value) {
                                      if (value == null ||
                                          value.isEmpty ||
                                          !GlobalMethods.isDouble(value)) {
                                        return 'Please enter Triacyglycerol result';
                                      }
                                      return null;
                                    },
                                    decoration: InputDecoration(
                                      hintText: (unit == 'mg/dL')
                                          ? 'Less than ${GlobalMethods.convertUnit(unit, tagHigh).toStringAsFixed(2)}'
                                          : (unit == 'mmol/L')
                                              ? 'Less than ${GlobalMethods.convertUnit('mg/dL', tagHigh, unit).toStringAsFixed(2)}'
                                              : '',
                                      suffixText: unit,
                                      label: const Text('Triacyglycerol (TAG)'),
                                    ),
                                    onChanged: (String? value) {
                                      setState(() =>
                                          tag = double.parse(value.toString()));
                                    }),
                              ),
                              Padding(
                                padding:
                                    const EdgeInsets.only(left: 40, right: 40),
                                child: TextFormField(
                                    initialValue: chd.hdl.toString(),
                                    keyboardType: TextInputType.number,
                                    validator: (value) {
                                      if (value == null ||
                                          value.isEmpty ||
                                          !GlobalMethods.isDouble(value)) {
                                        return 'Please enter HDL Cholesterol result';
                                      }
                                      return null;
                                    },
                                    decoration: InputDecoration(
                                      hintText: (unit == 'mg/dL')
                                          ? '${GlobalMethods.convertUnit(unit, hdlLow).toStringAsFixed(2)} - ${GlobalMethods.convertUnit(unit, hdlHigh).toStringAsFixed(2)}'
                                          : (unit == 'mmol/L')
                                              ? '${GlobalMethods.convertUnit('mg/dL', hdlLow, unit).toStringAsFixed(2)} - ${GlobalMethods.convertUnit('mg/dL', hdlHigh, unit).toStringAsFixed(2)}'
                                              : '',
                                      suffixText: unit,
                                      label: const Text('HDL Cholesterol'),
                                    ),
                                    onChanged: (String? value) {
                                      setState(() =>
                                          hdl = double.parse(value.toString()));
                                    }),
                              ),
                              Padding(
                                padding:
                                    const EdgeInsets.only(left: 40, right: 40),
                                child: TextFormField(
                                    initialValue: chd.ldl.toString(),
                                    keyboardType: TextInputType.number,
                                    validator: (value) {
                                      if (value == null ||
                                          value.isEmpty ||
                                          !GlobalMethods.isDouble(value)) {
                                        return 'Please enter LDL Cholesterol result';
                                      }
                                      return null;
                                    },
                                    decoration: InputDecoration(
                                      hintText: (unit == 'mg/dL')
                                          ? 'Less than ${GlobalMethods.convertUnit(unit, ldlHigh).toStringAsFixed(2)}'
                                          : (unit == 'mmol/L')
                                              ? 'Less than ${GlobalMethods.convertUnit('mg/dL', ldlHigh, unit).toStringAsFixed(2)}'
                                              : '',
                                      suffixText: unit,
                                      label: const Text('LDL Cholesterol'),
                                    ),
                                    onChanged: (String? value) {
                                      setState(() =>
                                          ldl = double.parse(value.toString()));
                                    }),
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
                                          .updateCh(
                                              Cholesterol(
                                                  id: entry.first.id,
                                                  user: userid,
                                                  type: 'chlstrl',
                                                  content: CHLSTRL(
                                                      total: total != 0.0 &&
                                                              total != chd.total
                                                          ? total
                                                          : chd.total,
                                                      tag: tag != 0.0 &&
                                                              tag != chd.tag
                                                          ? tag
                                                          : chd.tag,
                                                      hdl: hdl != 0.0 &&
                                                              hdl != chd.hdl
                                                          ? hdl
                                                          : chd.hdl,
                                                      ldl: ldl != 0.0 &&
                                                              ldl != chd.ldl
                                                          ? ldl
                                                          : chd.ldl,
                                                      unit: unit.isNotEmpty
                                                          ? unit
                                                          : chd.unit),
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
    late Future<List<Cholesterol>> ch;
    Future<List<Cholesterol>> getList() async {
      handler = DatabaseHandler.instance;
      return await handler.chlstrlEntry(entryid);
    }

    ch = getList();

    double totalCholesterolHigh =
        prefs!.getDouble('totalCholesterolHigh') ?? 240;
    double tagHigh = prefs.getDouble('tagHigh') ?? 110;
    double hdlLow = prefs.getDouble('hdlLow') ?? 40;
    double hdlHigh = prefs.getDouble('hdlHigh') ?? 60;
    double ldlHigh = prefs.getDouble('ldlHigh') ?? 140;
    double nonHdlHigh = prefs.getDouble('nonHdlHighHigh') ?? 140;

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
                final userid = entry.first.user;
                final chd = entry.first.content;
                final fromUnit = entry.first.content.unit;
                final double nonhdl = GlobalMethods.convertUnit(
                  fromUnit,
                  (entry.first.content.total - entry.first.content.hdl),
                  unit,
                );
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
                            const Text('Total:',
                                style: TextStyle(
                                  fontSize: 20,
                                )),
                            Text(
                                GlobalMethods.convertUnit(
                                        fromUnit, chd.total, unit)
                                    .toStringAsFixed(2),
                                style: TextStyle(
                                    fontSize: 20,
                                    color: (GlobalMethods.convertUnit(
                                                fromUnit, chd.total, unit) >
                                            GlobalMethods.convertUnit(fromUnit,
                                                totalCholesterolHigh, unit))
                                        ? Colors.red
                                        : Colors.green)),
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
                              GlobalMethods.convertUnit(fromUnit, chd.tag, unit)
                                  .toStringAsFixed(2),
                              style: TextStyle(
                                  fontSize: 20,
                                  color: (GlobalMethods.convertUnit(
                                              fromUnit, chd.tag, unit) >
                                          GlobalMethods.convertUnit(
                                              fromUnit, tagHigh, unit))
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
                              GlobalMethods.convertUnit(
                                fromUnit,
                                chd.hdl,
                                unit,
                              ).toStringAsFixed(2),
                              style: TextStyle(
                                fontSize: 20,
                                color: (GlobalMethods.convertUnit(
                                              fromUnit,
                                              chd.hdl,
                                              unit,
                                            ) >
                                            GlobalMethods.convertUnit(
                                              fromUnit,
                                              hdlHigh,
                                              unit,
                                            ) ||
                                        GlobalMethods.convertUnit(
                                              fromUnit,
                                              chd.hdl,
                                              unit,
                                            ) <
                                            GlobalMethods.convertUnit(
                                              fromUnit,
                                              hdlLow,
                                              unit,
                                            ))
                                    ? Colors.red
                                    : (GlobalMethods.convertUnit(
                                                  fromUnit,
                                                  chd.hdl,
                                                  unit,
                                                ) >
                                                GlobalMethods.convertUnit(
                                                  fromUnit,
                                                  hdlLow,
                                                  unit,
                                                ) &&
                                            GlobalMethods.convertUnit(
                                                  fromUnit,
                                                  chd.hdl,
                                                  unit,
                                                ) <
                                                GlobalMethods.convertUnit(
                                                  fromUnit,
                                                  hdlHigh,
                                                  unit,
                                                ) &&
                                            unit == 'mg/dL')
                                        ? Colors.green
                                        : Colors.blue,
                              ),
                            )
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
                              GlobalMethods.convertUnit(fromUnit, chd.ldl, unit)
                                  .toStringAsFixed(2),
                              style: TextStyle(
                                  fontSize: 20,
                                  color: (GlobalMethods.convertUnit(
                                              fromUnit, chd.ldl, unit) >
                                          GlobalMethods.convertUnit(
                                              fromUnit, ldlHigh, unit))
                                      ? Colors.red
                                      : Colors.green),
                            ),
                          ],
                        ),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                          children: [
                            const Text('Non-HDL:',
                                style: TextStyle(fontSize: 20)),
                            Text(
                              nonhdl.toStringAsFixed(2),
                              style: TextStyle(
                                  fontSize: 20,
                                  color: (GlobalMethods.convertUnit(
                                            fromUnit,
                                            nonhdl,
                                            unit,
                                          ) >
                                          GlobalMethods.convertUnit(
                                            fromUnit,
                                            nonHdlHigh,
                                            unit,
                                          ))
                                      ? Colors.red
                                      : Colors.green),
                            ),
                          ],
                        ),
                        Padding(
                          padding: EdgeInsets.only(top: 10.0),
                          child: SizedBox(
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.spaceAround,
                              crossAxisAlignment: CrossAxisAlignment.center,
                              children: [
                                Text('Unit: $unit'),
                                Text('TAG: (Tracyglyclerol)'),
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
                            statefulChlstrlUpdateModal(context,
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

  static ListTile tileCHLSTRL(BuildContext context, Cholesterol items, unit) {
    String fromUnit = items.content.unit;
    String total = GlobalMethods.convertUnit(
      fromUnit,
      items.content.total,
      unit,
    ).toStringAsFixed(2);
    String hdl = GlobalMethods.convertUnit(
      fromUnit,
      items.content.hdl,
      unit,
    ).toStringAsFixed(2);
    String ldl = GlobalMethods.convertUnit(
      fromUnit,
      items.content.ldl,
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
                text: '\nTotal/HDL/LDL:\n$total/$hdl/$ldl $unit',
                style: TextStyle(fontWeight: FontWeight.bold)),
          ])),
      subtitle: Text('Note: ${items.comments.toString()}'),
    );
  }
}
