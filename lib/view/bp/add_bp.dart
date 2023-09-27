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
  String systolic = "";
  String diastolic = "";
  int heartrate = 0;
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
              TextFormField(
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter systolic value';
                  }
                  return null;
                },
                decoration: const InputDecoration(
                  hintText: 'Systolic',
                ),
                onChanged: (value) {
                  setState(() {
                    systolic = value;
                  });
                },
              ),
              TextFormField(
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter diastolic value';
                  }
                  return null;
                },
                decoration: const InputDecoration(
                  hintText: 'Diastolic',
                ),
                onChanged: (value) {
                  setState(() {
                    diastolic = value;
                  });
                },
              ),
              TextFormField(
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter your heartrate';
                  }
                  return null;
                },
                decoration: const InputDecoration(
                  hintText: 'Heartrate',
                ),
                onChanged: (value) {
                  setState(() {
                    heartrate = int.parse(value);
                  });
                },
              ),
              TextFormField(
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Select the arm';
                  }
                  return null;
                },
                decoration: const InputDecoration(
                  hintText: 'Arm',
                ),
                onChanged: (value) {
                  setState(() {
                    arm = value;
                  });
                },
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
                              systolic: int.parse(systolic),
                              diastolic: int.parse(diastolic),
                              heartrate: heartrate,
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
