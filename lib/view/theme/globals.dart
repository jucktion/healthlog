import 'package:flutter/material.dart';

class GlobalMethods {
  Future<void> showDialogs(BuildContext context, String title, String subtitle,
      Function func) async {
    showDialog(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            title: Row(
              children: [
                const Padding(
                  padding: EdgeInsets.all(8.0),
                  child: Icon(
                    Icons.warning,
                    size: 25,
                    color: Colors.red,
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Text(title),
                ),
              ],
            ),
            content: Padding(
              padding: const EdgeInsets.all(8.0),
              child: Text(subtitle),
            ),
            actions: [
              ElevatedButton(
                onPressed: () => Navigator.pop(context),
                child: const Text('Cancel'),
              ),
              ElevatedButton(
                onPressed: () {
                  func();
                  Navigator.pop(context);
                },
                child: const Text('OK'),
              ),
            ],
          );
        });
  }

  static bool isInt(String input) {
    return int.tryParse(input) != null;
  }

  static bool isDouble(String input) {
    return double.tryParse(input) != null;
  }

  static bool isTextInt(String? input) {
    return (input!.isEmpty || int.tryParse(input) == null);
  }

  static bool isTextDouble(String? input) {
    return (input!.isEmpty || double.tryParse(input) == null);
  }

  static double convertUnit(String from, double reading,
      [String to = 'mg/dL']) {
    if (to == 'mmol/L' && from == 'mg/dL') {
      return (reading / 18.0182);
    } else if (to == 'mg/dL' && from == 'mmol/L') {
      return (reading * 18.0182);
    } else {
      return reading;
    }
  }
}

class LegendWidget extends StatelessWidget {
  const LegendWidget({
    super.key,
    required this.name,
    required this.color,
  });
  final String name;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Container(
          width: 15,
          height: 15,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: color,
          ),
        ),
        const SizedBox(width: 6),
        Text(
          name,
          style: const TextStyle(
            color: Color(0xff757391),
            fontSize: 15,
          ),
        ),
      ],
    );
  }
}

class LegendsListWidget extends StatelessWidget {
  const LegendsListWidget({
    super.key,
    required this.legends,
    required this.width,
  });
  final List<Legend> legends;
  final int width;

  @override
  Widget build(BuildContext context) {
    return Row(children: [
      const Expanded(child: SizedBox()),
      SizedBox(
          width: MediaQuery.of(context).size.width / width,
          child: Column(
              mainAxisSize: MainAxisSize.min,
              children: legends
                  .map(
                    (e) => LegendWidget(name: e.name, color: e.color),
                  )
                  .toList()))
    ]);
    // Wrap(
    //   spacing: 16,
    //   children: legends
    //       .map(
    //         (e) => LegendWidget(name: e.name, color: e.color),
    //       )
    //       .toList(),
    // );
  }
}

class Legend {
  Legend(this.name, this.color);
  final String name;
  final Color color;
}
