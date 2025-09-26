import 'dart:math';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:healthlog/data/db.dart';
import 'package:healthlog/model/cholesterol.dart';
import 'package:healthlog/model/user.dart';
import 'package:healthlog/view/theme/globals.dart';
import 'package:shared_preferences/shared_preferences.dart';

class UserHelper {
  static Future<void> statefulUserBottomModal(BuildContext context,
      {required Function callback,
      required GlobalKey<RefreshIndicatorState> refreshIndicatorKey,
      SharedPreferences? prefs}) async {
    final formKey = GlobalKey<FormState>();
    String firstName = "";
    String lastName = "";
    int age = 0;
    double weight = 0;
    double height = 0;

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
              height: 600,
              width: MediaQuery.of(context).size.width / 1.25,
              child: Form(
                key: formKey,
                child: ListView(
                  padding: const EdgeInsets.all(16.0),
                  children: <Widget>[
                    Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: TextFormField(
                        textCapitalization: TextCapitalization.words,
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Please enter some text';
                          }
                          return null;
                        },
                        decoration: const InputDecoration(
                          hintText: 'John',
                          label: Text('First Name'),
                        ),
                        onChanged: (value) {
                          setState(() {
                            firstName = value;
                          });
                        },
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: TextFormField(
                        textCapitalization: TextCapitalization.words,
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Please enter some text';
                          }
                          return null;
                        },
                        decoration: const InputDecoration(
                          hintText: 'Doe',
                          label: Text('Last Name'),
                        ),
                        onChanged: (value) {
                          setState(() {
                            lastName = value;
                          });
                        },
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: TextFormField(
                        keyboardType: TextInputType.number,
                        maxLengthEnforcement: MaxLengthEnforcement.enforced,
                        maxLength: 3,
                        validator: (value) {
                          if (GlobalMethods.isTextInt(value)) {
                            return 'Please enter your age';
                          }
                          return null;
                        },
                        decoration: const InputDecoration(
                            hintText: '21', label: Text('Age')),
                        onChanged: (value) {
                          setState(() {
                            if (!GlobalMethods.isTextInt(value)) {
                              age = int.parse(value);
                            }
                          });
                        },
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: TextFormField(
                        keyboardType: TextInputType.number,
                        maxLengthEnforcement: MaxLengthEnforcement.enforced,
                        maxLength: 5,
                        validator: (value) {
                          if (GlobalMethods.isTextDouble(value)) {
                            return 'Please enter your weight';
                          }
                          return null;
                        },
                        decoration: const InputDecoration(
                          hintText: '60',
                          label: Text('Weight'),
                          suffixText: 'kg',
                        ),
                        onChanged: (value) {
                          if (!GlobalMethods.isTextDouble(value)) {
                            setState(() {
                              weight = double.parse(value);
                            });
                          }
                        },
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: TextFormField(
                        keyboardType: TextInputType.number,
                        maxLengthEnforcement: MaxLengthEnforcement.enforced,
                        maxLength: 6,
                        validator: (value) {
                          if (GlobalMethods.isTextDouble(value)) {
                            return 'Please enter your height';
                          }
                          return null;
                        },
                        decoration: const InputDecoration(
                          suffixText: 'cm',
                          hintText: '160',
                          label: Text('Height'),
                        ),
                        onChanged: (value) {
                          if (!GlobalMethods.isTextDouble(value)) {
                            setState(() {
                              height = double.parse(value);
                            });
                          }
                        },
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.all(15.0),
                      child: ElevatedButton(
                        onPressed: () async {
                          if (formKey.currentState!.validate()) {
                            await DatabaseHandler.instance
                                .insertUser(User(
                                    firstName: firstName,
                                    lastName: lastName,
                                    age: age,
                                    weight: weight.toDouble(),
                                    height: height.toDouble(),
                                    id: Random().nextInt(50)))
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

  static Future<void> statefulUserUpdateModal(BuildContext context,
      {required int userid,
      required Function callback,
      required GlobalKey<RefreshIndicatorState> refreshIndicatorKey,
      required SharedPreferences? prefs}) async {
    final formKey = GlobalKey<FormState>();
    late DatabaseHandler handler;
    late Future<List<User>> ch;
    Future<List<User>> getList() async {
      handler = DatabaseHandler.instance;
      return await handler.userEntry(userid);
    }

    ch = getList();

    String firstName = "";
    String lastName = "";
    int age = 0;
    double weight = 0;
    double height = 0;

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
              height: 600,
              width: MediaQuery.of(context).size.width / 1.25,
              child: FutureBuilder<List<User>>(
                  future: ch,
                  builder: (context, snapshot) {
                    if (snapshot.connectionState == ConnectionState.done) {
                      if (snapshot.hasError) {
                        return Text('Error: ${snapshot.error}');
                      } else {
                        final entry = snapshot.data ?? [];
                        final uhd = entry.first;
                        return Form(
                          key: formKey,
                          child: ListView(
                            padding: const EdgeInsets.all(16.0),
                            children: <Widget>[
                              Padding(
                                padding: const EdgeInsets.all(8.0),
                                child: TextFormField(
                                  initialValue: uhd.firstName,
                                  textCapitalization: TextCapitalization.words,
                                  validator: (value) {
                                    if (value == null || value.isEmpty) {
                                      return 'Please check your text';
                                    }
                                    return null;
                                  },
                                  decoration: const InputDecoration(
                                    hintText: 'John',
                                    label: Text('First Name'),
                                  ),
                                  onChanged: (value) {
                                    setState(() {
                                      firstName = value;
                                    });
                                  },
                                ),
                              ),
                              Padding(
                                padding: const EdgeInsets.all(8.0),
                                child: TextFormField(
                                  initialValue: uhd.lastName,
                                  textCapitalization: TextCapitalization.words,
                                  validator: (value) {
                                    if (value == null || value.isEmpty) {
                                      return 'Please check the text';
                                    }
                                    return null;
                                  },
                                  decoration: const InputDecoration(
                                    hintText: 'Doe',
                                    label: Text('Last Name'),
                                  ),
                                  onChanged: (value) {
                                    setState(() {
                                      lastName = value;
                                    });
                                  },
                                ),
                              ),
                              Padding(
                                padding: const EdgeInsets.all(8.0),
                                child: TextFormField(
                                  initialValue: uhd.age.toString(),
                                  keyboardType: TextInputType.number,
                                  maxLengthEnforcement:
                                      MaxLengthEnforcement.enforced,
                                  maxLength: 3,
                                  validator: (value) {
                                    if (GlobalMethods.isTextInt(value)) {
                                      return 'Please enter your age';
                                    }
                                    return null;
                                  },
                                  decoration: const InputDecoration(
                                      hintText: '21', label: Text('Age')),
                                  onChanged: (value) {
                                    setState(() {
                                      if (!GlobalMethods.isTextInt(value)) {
                                        age = int.parse(value);
                                      }
                                    });
                                  },
                                ),
                              ),
                              Padding(
                                padding: const EdgeInsets.all(8.0),
                                child: TextFormField(
                                  initialValue: uhd.weight.toString(),
                                  keyboardType: TextInputType.number,
                                  maxLengthEnforcement:
                                      MaxLengthEnforcement.enforced,
                                  maxLength: 5,
                                  validator: (value) {
                                    if (GlobalMethods.isTextDouble(value)) {
                                      return 'Please check your weight';
                                    }
                                    return null;
                                  },
                                  decoration: const InputDecoration(
                                    hintText: '60',
                                    label: Text('Weight'),
                                    suffixText: 'kg',
                                  ),
                                  onChanged: (value) {
                                    if (!GlobalMethods.isTextDouble(value)) {
                                      setState(() {
                                        weight = double.parse(value);
                                      });
                                    }
                                  },
                                ),
                              ),
                              Padding(
                                padding: const EdgeInsets.all(8.0),
                                child: TextFormField(
                                  initialValue: uhd.height.toString(),
                                  keyboardType: TextInputType.number,
                                  maxLengthEnforcement:
                                      MaxLengthEnforcement.enforced,
                                  maxLength: 6,
                                  validator: (value) {
                                    if (GlobalMethods.isTextDouble(value)) {
                                      return 'Please enter your height';
                                    }
                                    return null;
                                  },
                                  decoration: const InputDecoration(
                                    suffixText: 'cm',
                                    hintText: '160',
                                    label: Text('Height'),
                                  ),
                                  onChanged: (value) {
                                    if (!GlobalMethods.isTextDouble(value)) {
                                      setState(() {
                                        height = double.parse(value);
                                      });
                                    }
                                  },
                                ),
                              ),
                              Padding(
                                padding: const EdgeInsets.all(15.0),
                                child: ElevatedButton(
                                  onPressed: () async {
                                    if (formKey.currentState!.validate()) {
                                      // print(
                                      //     '$firstName : ${uhd.firstName}, $lastName : ${uhd.lastName}, $age : ${uhd.age}, $weight : ${uhd.weight}, $height : ${uhd.height} ');
                                      await DatabaseHandler.instance
                                          .updateUs(
                                              User(
                                                  firstName:
                                                      firstName.isNotEmpty &&
                                                              firstName !=
                                                                  uhd.firstName
                                                          ? firstName
                                                          : uhd.firstName,
                                                  lastName: lastName.isNotEmpty &&
                                                          lastName !=
                                                              uhd.lastName
                                                      ? lastName
                                                      : uhd.lastName,
                                                  age:
                                                      age != 0 && age != uhd.age
                                                          ? age
                                                          : uhd.age,
                                                  weight: weight.toDouble() !=
                                                              0.0 &&
                                                          weight.toDouble() !=
                                                              uhd.weight
                                                      ? weight.toDouble()
                                                      : uhd.weight,
                                                  height: height.toDouble() !=
                                                              0.0 &&
                                                          height.toDouble() !=
                                                              uhd.height
                                                      ? height.toDouble()
                                                      : uhd.height,
                                                  id: uhd.id),
                                              uhd.id)
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

  static Future<void> showUser(
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
                            statefulUserUpdateModal(context,
                                userid: userid,
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
}
