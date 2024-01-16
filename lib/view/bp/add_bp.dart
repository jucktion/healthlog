import 'dart:math';
import 'package:flutter/material.dart';
import 'package:healthlog/model/bloodpressure.dart';
import 'package:healthlog/view/bp/bp.dart';
import 'package:healthlog/data/db.dart';

class AddBPScreen extends StatefulWidget {
  final String userid;
  const AddBPScreen({super.key, required this.userid});

  @override
  State<AddBPScreen> createState() => _AddBPScreenState();
}

class _AddBPScreenState extends State<AddBPScreen> {
  final _formKey = GlobalKey<FormState>();
  int _systolic = 120;
  int _diastolic = 80;
  int _heartrate = 70;
  String arm = "";

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Add BP'),
      ),
      body: Center(
        child: Form(
          key: _formKey,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: <Widget>[
              Padding(
                padding: const EdgeInsets.all(8.0),
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
                  onChanged: (value) {
                    setState(() {
                      _systolic = int.parse(value);
                    });
                  },
                ),
              ),
              Padding(
                padding: const EdgeInsets.all(8.0),
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
                  onChanged: (value) {
                    setState(() {
                      _diastolic = int.parse(value);
                    });
                  },
                ),
              ),
              Padding(
                padding: const EdgeInsets.all(8.0),
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
                  onChanged: (value) {
                    setState(() {
                      _heartrate = int.parse(value);
                    });
                  },
                ),
              ),
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: TextFormField(
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Select the arm';
                    }
                    return null;
                  },
                  decoration: const InputDecoration(
                      hintText: 'Left/Right', label: Text('Arm')),
                  onChanged: (value) {
                    setState(() {
                      arm = value;
                    });
                  },
                ),
              ),
              ElevatedButton(
                onPressed: () async {
                  if (_formKey.currentState!.validate()) {
                    await DatabaseHandler()
                        .insertBp(BloodPressure(
                            id: Random().nextInt(50),
                            user: int.parse(widget.userid),
                            type: 'bp',
                            content: BP(
                              systolic: _systolic,
                              diastolic: _diastolic,
                              heartrate: _heartrate,
                              arm: arm,
                            ),
                            date: DateTime.now().toIso8601String(),
                            comments: 'new'))
                        .whenComplete(() => Navigator.push(
                              context,
                              MaterialPageRoute(
                                  builder: (context) => BPScreen(
                                        userid: widget.userid,
                                      )),
                            ));
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
  }
}
