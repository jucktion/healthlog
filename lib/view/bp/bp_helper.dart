import 'package:flutter/material.dart';

class BPHelper {
  static Future<void> bpBottomModal(BuildContext context,
      {required GlobalKey<FormState> formKey,
      required int userid,
      required Function(dynamic value) systolicChange,
      required Function(dynamic value) diastolicChange,
      required Function(dynamic value) heartChange,
      required Function(dynamic value) armChange,
      required Function(dynamic value) commentChange,
      required Function() submitForm}) async {
    showModalBottomSheet(
      isScrollControlled: true,
      context: context,
      builder: ((context) {
        return Padding(
          padding:
              EdgeInsets.only(bottom: MediaQuery.of(context).viewInsets.bottom),
          child: SizedBox(
            height: 400,
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
                        onChanged: systolicChange),
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
                        onChanged: diastolicChange),
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
                        onChanged: heartChange),
                  ),
                  Padding(
                    padding: const EdgeInsets.only(left: 40, right: 40),
                    child: TextFormField(
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Select the arm';
                          }
                          return null;
                        },
                        decoration: const InputDecoration(
                            hintText: 'Left/Right', label: Text('Arm')),
                        onChanged: armChange),
                  ),
                  Padding(
                    padding: const EdgeInsets.only(left: 40, right: 40),
                    child: TextFormField(
                        decoration: const InputDecoration(
                            hintText: 'Before Breakfast/After Dinner',
                            label: Text('Comments')),
                        onChanged: commentChange
                        // (value) {
                        //   setState(() {
                        //     comment = value;
                        //   });
                        // },
                        ),
                  ),
                  ElevatedButton(
                    onPressed: submitForm,
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
      }),
    );
  }
}
