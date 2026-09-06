import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:webview_flutter/webview_flutter.dart';
import 'package:webview_flutter_android/webview_flutter_android.dart';

class AdBannerWidget extends StatefulWidget {
  const AdBannerWidget({super.key});

  @override
  State<AdBannerWidget> createState() => _AdBannerWidgetState();
}

class _AdBannerWidgetState extends State<AdBannerWidget> {
  late final WebViewController _controller;
  bool _isLoaded = false;
  int _navigationCount = 0; // عدّاد لمنع النقرات التلقائية والوهمية عند التشغيل

  @override
  void initState() {
    super.initState();

    _controller = WebViewController()
      ..setJavaScriptMode(JavaScriptMode.unrestricted)
      ..setBackgroundColor(const Color(0x00000000))
      ..setUserAgent("Mozilla/5.0 (Linux; Android 10) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/91.0.4472.120 Mobile Safari/537.36")
      ..setNavigationDelegate(
        NavigationDelegate(
          onHttpError: (HttpResponseError error) {},
          onWebResourceError: (WebResourceError error) {},
          onPageFinished: (String url) {
            setState(() {
              _isLoaded = true;
              _navigationCount = 0; // إعادة ضبط العدّاد عند اكتمال تحميل الصفحة
            });
          },
          onNavigationRequest: (NavigationRequest request) async {
            // السماح دائماً بتحميل صفحة الجيت هوب الأساسية داخل البانر
            if (request.url.contains('shervankhoja.github.io')) {
              return NavigationDecision.navigate;
            }

            // منع أي عملية توجيه أو فتح تلقائي أثناء التحميل الأولي
            if (!_isLoaded) {
              return NavigationDecision.prevent;
            }

            _navigationCount++;

            // تجاهل أي محاولة توجيه وهمية أو تلقائية يفرضها السكريبت عند التحميل
            if (_navigationCount <= 1) {
              return NavigationDecision.prevent;
            }

            // إذا قام المستخدم بالضغط الفعلي والمقصود على الإعلان
            final Uri uri = Uri.parse(request.url);
            try {
              if (await canLaunchUrl(uri)) {
                await launchUrl(uri, mode: LaunchMode.externalApplication);
              } else {
                await launchUrl(uri, mode: LaunchMode.externalApplication);
              }
            } catch (e) {
              // معالجة الخطأ بصمت
            }

            // منع تحميل رابط الإعلان داخل مساحة البانر الضيقة وفتحه في المتصفح الخارجي
            return NavigationDecision.prevent;
          },
        ),
      );

    final androidController = _controller.platform;
    if (androidController is AndroidWebViewController) {
      androidController.setMediaPlaybackRequiresUserGesture(false);
    }

    // تحميل رابط GitHub Pages الكامل والصحيح الخاص بالإعلان
    _controller.loadRequest(Uri.parse('https://shervankhoja.github.io/my-ads/'));
  }

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(12),
      child: SizedBox(
        height: 50, // مقاس البانر بدقة
        width: double.infinity,
        child: WebViewWidget(controller: _controller),
      ),
    );
  }
}