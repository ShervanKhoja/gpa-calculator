import 'package:flutter/material.dart';
import 'dart:math' as math;

class GPACalculator extends StatefulWidget {
  final String systemName;
  final Color appBarColor;
  final double max;

  const GPACalculator({super.key, required this.systemName, required this.appBarColor, required this.max});

  @override
  State<GPACalculator> createState() => _GPACalculatorState();
}

class _GPACalculatorState extends State<GPACalculator> {
  final _pointsCont = TextEditingController();
  final _hoursCont = TextEditingController();
  final _oldGpaCont = TextEditingController();
  final _oldHoursCont = TextEditingController();

  final _pointsNode = FocusNode();
  final _hoursNode = FocusNode();

  List<Map<String, dynamic>> courses = [];
  double result = 0.0;
  double cumulativeResult = 0.0;

  void _showError(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message), backgroundColor: Colors.red),
    );
  }

  void _add() {
    double? p = double.tryParse(_pointsCont.text);
    double? h = double.tryParse(_hoursCont.text);

    if (p == null || h == null) {
      _showError("يرجى إدخال النقاط وعدد الساعات!");
      return;
    }

    if (h <= 0) {
      _showError("الساعات يجب أن تكون أكبر من 0!");
      return;
    }

    if (p < 0 || p > widget.max) {
      _showError("النقاط يجب أن تكون بين 0 و ${widget.max}!");
      return;
    }

    setState(() {
      courses.add({"points": p, "hours": h});
      _calc();
      _pointsCont.clear();
      _hoursCont.clear();
      FocusScope.of(context).requestFocus(_pointsNode);
    });
  }

  void _calc() {
    double sumPointsTimesHours = 0;
    double totalHours = 0;

    for (var c in courses) {
      double p = (c["points"] as num).toDouble();
      double h = (c["hours"] as num).toDouble();

      sumPointsTimesHours += (p * h);
      totalHours += h;
    }

    result = totalHours == 0 ? 0 : sumPointsTimesHours / totalHours;

    double? og = double.tryParse(_oldGpaCont.text);
    double? oh = double.tryParse(_oldHoursCont.text);

    cumulativeResult = (og != null && oh != null && oh > 0)
        ? ((og * oh) + sumPointsTimesHours) / (oh + totalHours)
        : result;
  }

  void _deleteAllConfirmation() {
    if (courses.isEmpty) return;
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text("حذف الكل"),
        content: const Text("هل أنت متأكد من حذف جميع المواد؟"),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx), child: const Text("إلغاء")),
          TextButton(
            onPressed: () {
              setState(() { courses.clear(); _calc(); });
              Navigator.pop(ctx);
            },
            child: const Text("حذف الكل", style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
  }

  void _deleteCourse(int index) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text("حذف مادة"),
        content: const Text("هل أنت متأكد من حذف هذه المادة؟"),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx), child: const Text("إلغاء")),
          TextButton(
            onPressed: () {
              setState(() { courses.removeAt(index); _calc(); });
              Navigator.pop(ctx);
            },
            child: const Text("حذف", style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.systemName),
        backgroundColor: widget.appBarColor,
        foregroundColor: Colors.white,
        actions: [
          IconButton(icon: const Icon(Icons.delete_sweep), onPressed: _deleteAllConfirmation),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            ExpansionTile(
              title: const Text("المعدل التراكمي السابق (اختياري)"),
              children: [
                _input(_oldGpaCont, "المعدل السابق", null, null, TextInputAction.next),
                _input(_oldHoursCont, "الساعات السابقة", null, null, TextInputAction.done),
              ],
            ),
            const SizedBox(height: 10),
            _input(_pointsCont, "النقاط (من ${widget.max})", _pointsNode, _hoursNode, TextInputAction.next),
            _input(_hoursCont, "عدد الساعات", _hoursNode, null, TextInputAction.done),

            const SizedBox(height: 15),
            SizedBox(
              width: double.infinity,
              height: 50,
              child: ElevatedButton.icon(
                onPressed: _add,
                icon: const Icon(Icons.add),
                label: const Text("إضافة مادة"),
              ),
            ),

            const SizedBox(height: 20),
            Row(
              children: [
                Expanded(child: _buildGauge("الفصلي", result, Colors.blue)),
                Expanded(child: _buildGauge("التراكمي", cumulativeResult, Colors.indigo)),
              ],
            ),

            const Divider(height: 40),
            ListView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: courses.length,
              itemBuilder: (context, i) => Card(
                child: ListTile(
                  title: Text("النقاط: ${courses[i]["points"]} | الساعات: ${courses[i]["hours"]}"),
                  trailing: IconButton(
                    icon: const Icon(Icons.delete, color: Colors.red),
                    onPressed: () => _deleteCourse(i),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _input(TextEditingController c, String l, FocusNode? cur, FocusNode? next, TextInputAction act) => Padding(
    padding: const EdgeInsets.only(bottom: 8),
    child: TextField(
      controller: c,
      focusNode: cur,
      textInputAction: act,
      onSubmitted: (_) {
        if (next != null) {
          FocusScope.of(context).requestFocus(next);
        } else {
          _add();
        }
      },
      decoration: InputDecoration(labelText: l, border: const OutlineInputBorder()),
      keyboardType: const TextInputType.numberWithOptions(decimal: true),
    ),
  );

  Widget _buildGauge(String title, double val, Color color) => Column(
    children: [
      SizedBox(
        height: 100,
        width: 160,
        child: TweenAnimationBuilder<double>(
          tween: Tween<double>(begin: 0, end: val),
          duration: const Duration(milliseconds: 800),
          curve: Curves.easeOutCubic,
          builder: (context, animatedVal, child) => CustomPaint(
            painter: SpeedometerPainter(value: animatedVal, max: widget.max, color: color),
          ),
        ),
      ),
      Text(title, style: const TextStyle(fontWeight: FontWeight.bold)),
      Text(val.toStringAsFixed(3), style: TextStyle(color: color, fontWeight: FontWeight.bold, fontSize: 18)),
    ],
  );
}

class SpeedometerPainter extends CustomPainter {
  final double value, max;
  final Color color;
  SpeedometerPainter({required this.value, required this.max, required this.color});

  @override
  void paint(Canvas canvas, Size size) {
    Offset center = Offset(size.width / 2, size.height);
    double radius = size.width / 2;
    double progress = (value / max).clamp(0.0, 1.0);

    Paint backgroundPaint = Paint()
      ..color = Colors.grey.shade300
      ..strokeWidth = 15
      ..style = PaintingStyle.stroke;
    canvas.drawArc(Rect.fromCircle(center: center, radius: radius), math.pi, math.pi, false, backgroundPaint);

    Paint progressPaint = Paint()
      ..color = color
      ..strokeWidth = 15
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round;
    canvas.drawArc(Rect.fromCircle(center: center, radius: radius), math.pi, progress * math.pi, false, progressPaint);

    double angle = math.pi + (progress * math.pi);
    Paint needlePaint = Paint()
      ..color = Colors.black
      ..strokeWidth = 4
      ..strokeCap = StrokeCap.round;
    Offset needleEnd = Offset(center.dx + (radius - 10) * math.cos(angle), center.dy + (radius - 10) * math.sin(angle));

    canvas.drawLine(center, needleEnd, needlePaint);
    canvas.drawCircle(center, 5, Paint()..color = Colors.black);
  }

  @override
  bool shouldRepaint(covariant SpeedometerPainter oldDelegate) => oldDelegate.value != value;
}