import 'package:flutter/material.dart';

class GPACalculator extends StatefulWidget {
  final String systemName;
  const GPACalculator({super.key, required this.systemName});
  @override
  State<GPACalculator> createState() => _GPACalculatorState();
}

class _GPACalculatorState extends State<GPACalculator> {
  final _gradeCont = TextEditingController();
  final _pointsCont = TextEditingController();
  final _hoursCont = TextEditingController();
  List<Map<String, dynamic>> courses = [];
  double result = 0.0;

  void _add() {
    double? p = double.tryParse(_pointsCont.text);
    double? h = double.tryParse(_hoursCont.text);
    if (p != null && h != null) {
      setState(() {
        courses.add({"grade": _gradeCont.text, "points": p, "hours": h});
        _calc();
      });
    }
  }

  void _calc() {
    double totalP = 0, totalH = 0;
    for (var c in courses) {
      totalP += (c["points"] * c["hours"]);
      totalH += c["hours"];
    }
    result = totalH == 0 ? 0 : totalP / totalH;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(widget.systemName)),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            TextField(controller: _gradeCont, decoration: const InputDecoration(labelText: "العلامة")),
            TextField(controller: _pointsCont, decoration: const InputDecoration(labelText: "النقاط")),
            TextField(controller: _hoursCont, decoration: const InputDecoration(labelText: "الساعات")),
            ElevatedButton(onPressed: _add, child: const Text("إضافة")),
            Text("المعدل: ${result.toStringAsFixed(2)}"),
            Expanded(child: ListView.builder(itemCount: courses.length, itemBuilder: (context, i) =>
                ListTile(title: Text("المادة: ${courses[i]["grade"]} | النقاط: ${courses[i]["points"]}")))),
          ],
        ),
      ),
    );
  }
}