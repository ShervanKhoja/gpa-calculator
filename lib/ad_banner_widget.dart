import 'package:flutter/material.dart';
import 'package:webview_flutter/webview_flutter.dart';

class AdBannerWidget extends StatefulWidget {
  const AdBannerWidget({super.key});

  @override
  State<AdBannerWidget> createState() => _AdBannerWidgetState();
}

class _AdBannerWidgetState extends State<AdBannerWidget> {
  late final WebViewController _controller;

  @override
  void initState() {
    super.initState();

    // الطريقة الأولى والأسهل: تحميل صفحة غيت هوب التي جهزناها مسبقاً
    _controller = WebViewController()
      ..setJavaScriptMode(JavaScriptMode.unrestricted)
      ..setBackgroundColor(const Color(0x00000000))
      ..loadRequest(Uri.parse('https://shervankhoja.github.io'));
  }

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 50, // تم تعديل الارتفاع ليطابق مقاس إعلان البانر 320x50
      width: double.infinity,
      child: WebViewWidget(controller: _controller),
    );
  }
}