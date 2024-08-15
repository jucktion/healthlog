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
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: const Text('Cancel'),
              ),
              TextButton(
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

  static double convertUnit(String unit, String fromUnit, double reading) {
    if (unit == 'mmol/L' && fromUnit == 'mg/dL') {
      return (reading / 18.0182);
    } else if (unit == 'mg/dL' && fromUnit == 'mmol/L') {
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
