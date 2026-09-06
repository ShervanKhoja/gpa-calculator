import 'package:flutter/material.dart';
import 'dart:math' as math;

class PercentCalculator extends StatefulWidget {
  const PercentCalculator({super.key});

  @override
  State<PercentCalculator> createState() => _PercentCalculatorState();
}

class _PercentCalculatorState extends State<PercentCalculator> {
  final _gradeCont = TextEditingController();
  final _hoursCont = TextEditingController();
  final _oldPercentCont = TextEditingController();
  final _oldHoursCont = TextEditingController();

  final _gradeFocus = FocusNode();
  final _hoursFocus = FocusNode();

  List<Map<String, dynamic>> courses = [];
  double result = 0.0;
  double cumulativeResult = 0.0;

  bool _isArabic(BuildContext context) {
    return Localizations.localeOf(context).languageCode == 'ar';
  }

  // دالة عرض رسائل الخطأ
  void _showError(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message), backgroundColor: Colors.red),
    );
  }

  // دالة الحذف الجماعي مع التأكيد
  void _deleteAllConfirmation() {
    if (courses.isEmpty) return;
    final bool ar = _isArabic(context);
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text(ar ? "حذف الكل" : "Delete All"),
        content: Text(ar ? "هل أنت متأكد من حذف جميع المواد؟" : "Are you sure you want to delete all courses?"),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx), child: Text(ar ? "إلغاء" : "Cancel")),
          TextButton(
            onPressed: () {
              setState(() { courses.clear(); _calc(); });
              Navigator.pop(ctx);
            },
            child: Text(ar ? "حذف الكل" : "Delete All", style: const TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
  }

  // دالة الحذف الفردي مع التأكيد
  void _deleteCourseConfirmation(int index) {
    final bool ar = _isArabic(context);
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text(ar ? "حذف المادة" : "Delete Course"),
        content: Text(ar ? "هل أنت متأكد من حذف هذه المادة؟" : "Are you sure you want to delete this course?"),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx), child: Text(ar ? "إلغاء" : "Cancel")),
          TextButton(
            onPressed: () {
              setState(() { courses.removeAt(index); _calc(); });
              Navigator.pop(ctx);
            },
            child: Text(ar ? "حذف" : "Delete", style: const TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
  }

  void _add() {
    final bool ar = _isArabic(context);
    double? g = double.tryParse(_gradeCont.text);
    double? h = double.tryParse(_hoursCont.text);

    // التحقق من صحة المدخلات
    if (g == null || h == null) {
      _showError(ar ? "يرجى تعبئة الحقول بأرقام صحيحة!" : "Please fill in the fields with valid numbers!");
    } else if (h <= 0) {
      _showError(ar ? "عدد الساعات يجب أن يكون أكبر من صفر!" : "Hours must be greater than zero!");
    } else if (g < 0 || g > 100) {
      _showError(ar ? "العلامة يجب أن تكون بين 0 و 100!" : "Grade must be between 0 and 100!");
    } else {
      setState(() {
        courses.add({"grade": g, "hours": h});
        _calc();
        _gradeCont.clear();
        _hoursCont.clear();
        FocusScope.of(context).requestFocus(_gradeFocus);
      });
    }
  }

  void _calc() {
    double totalW = 0, totalH = 0;
    for (var c in courses) {
      totalW += ((c["grade"] as num).toDouble() * (c["hours"] as num).toDouble());
      totalH += (c["hours"] as num).toDouble();
    }
    result = totalH == 0 ? 0 : totalW / totalH;
    double? oldP = double.tryParse(_oldPercentCont.text);
    double? oldH = double.tryParse(_oldHoursCont.text);
    cumulativeResult = (oldP != null && oldH != null && oldH > 0) ? ((oldP * oldH) + totalW) / (oldH + totalH) : result;
  }

  @override
  Widget build(BuildContext context) {
    final bool ar = _isArabic(context);

    return Scaffold(
      appBar: AppBar(
        title: Text(ar ? "نظام النسبة المئوية" : "Percentage System"),
        backgroundColor: Colors.teal,
        foregroundColor: Colors.white,
        actions: [
          IconButton(
            icon: const Icon(Icons.delete_sweep),
            onPressed: _deleteAllConfirmation,
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            ExpansionTile(
              title: Text(ar ? "حساب المعدل التراكمي (اختياري)" : "Cumulative GPA Calculation (Optional)"),
              onExpansionChanged: (_) => setState(() => _calc()),
              children: [
                _input(_oldPercentCont, ar ? "النسبة السابقة" : "Previous Percentage", FocusNode(), null, TextInputAction.next),
                _input(_oldHoursCont, ar ? "الساعات السابقة" : "Previous Hours", FocusNode(), null, TextInputAction.done),
              ],
            ),
            const SizedBox(height: 10),
            _input(_gradeCont, ar ? "العلامة من 100" : "Grade out of 100", _gradeFocus, _hoursFocus, TextInputAction.next),
            _input(_hoursCont, ar ? "عدد الساعات" : "Credit Hours", _hoursFocus, null, TextInputAction.done),

            SizedBox(
              width: double.infinity,
              child: ElevatedButton(onPressed: _add, child: Text(ar ? "إضافة مادة" : "Add Course")),
            ),
            const SizedBox(height: 20),

            Row(
              children: [
                Expanded(child: _buildGauge(ar ? "فصلي" : "Semester", result, Colors.teal)),
                Expanded(child: _buildGauge(ar ? "تراكمي" : "Cumulative", cumulativeResult, Colors.blueAccent)),
              ],
            ),
            const SizedBox(height: 10),

            ListView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: courses.length,
              itemBuilder: (context, i) => Card(
                child: ListTile(
                  title: Text(ar ? "العلامة: ${courses[i]["grade"]}%" : "Grade: ${courses[i]["grade"]}%"),
                  subtitle: Text(ar ? "الساعات: ${courses[i]["hours"]}" : "Hours: ${courses[i]["hours"]}"),
                  trailing: IconButton(
                    icon: const Icon(Icons.delete, color: Colors.red),
                    onPressed: () => _deleteCourseConfirmation(i),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildGauge(String title, double val, Color color) => Column(children: [
    SizedBox(height: 100, width: 160,
      child: TweenAnimationBuilder<double>(
        tween: Tween<double>(begin: 0, end: val),
        duration: const Duration(milliseconds: 800),
        curve: Curves.easeOutCubic,
        builder: (context, animatedVal, child) => CustomPaint(
          painter: SpeedometerPainter(value: animatedVal, color: color),
        ),
      ),
    ),
    Text(title, style: const TextStyle(fontWeight: FontWeight.bold)),
    Text("${val.toStringAsFixed(2)}%", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: color)),
  ]);

  Widget _input(TextEditingController c, String l, FocusNode currentFocus, FocusNode? nextFocus, TextInputAction action) =>
      Padding(
        padding: const EdgeInsets.only(bottom: 10),
        child: TextField(
            controller: c,
            focusNode: currentFocus,
            textInputAction: action,
            onChanged: (val) => setState(() => _calc()),
            onSubmitted: (_) {
              if (nextFocus != null) {
                FocusScope.of(context).requestFocus(nextFocus);
              } else {
                _add();
              }
            },
            decoration: InputDecoration(labelText: l, border: const OutlineInputBorder()),
            keyboardType: const TextInputType.numberWithOptions(decimal: true)
        ),
      );
}

class SpeedometerPainter extends CustomPainter {
  final double value; final Color color;
  SpeedometerPainter({required this.value, required this.color});

  @override
  void paint(Canvas canvas, Size size) {
    Offset center = Offset(size.width / 2, size.height);
    double radius = size.width / 2;
    double progress = (value / 100).clamp(0.0, 1.0);

    Paint backgroundPaint = Paint()..color = Colors.grey.shade300..strokeWidth = 15..style = PaintingStyle.stroke;
    canvas.drawArc(Rect.fromCircle(center: center, radius: radius), math.pi, math.pi, false, backgroundPaint);

    Paint progressPaint = Paint()..color = color..strokeWidth = 15..style = PaintingStyle.stroke..strokeCap = StrokeCap.round;
    canvas.drawArc(Rect.fromCircle(center: center, radius: radius), math.pi, progress * math.pi, false, progressPaint);

    double angle = math.pi + (progress * math.pi);
    Paint needlePaint = Paint()..color = Colors.black..strokeWidth = 4..strokeCap = StrokeCap.round;
    Offset needleEnd = Offset(center.dx + (radius - 10) * math.cos(angle), center.dy + (radius - 10) * math.sin(angle));

    canvas.drawLine(center, needleEnd, needlePaint);
    canvas.drawCircle(center, 5, Paint()..color = Colors.black);
  }

  @override
  bool shouldRepaint(covariant SpeedometerPainter oldDelegate) => oldDelegate.value != value;
}