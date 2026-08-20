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
          onNavigationRequest: (NavigationRequest request) async {
            // إذا كان الرابط هو صفحة غيت هوب الخاصة بالإعلانات، اتركه يحمل طبيعياً داخل البانر
            if (request.url.contains('shervankhoja.github.io')) {
              return NavigationDecision.navigate;
            }

            // لأي رابط إعلان خارجي، قم بفتحه فوراً في متصفح الهاتف الخارجي
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

            // منع تحميل الرابط داخل مساحة البانر الضيقة
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
        height: 50, // مقاس البانر 320x50 بدقة
        width: double.infinity,
        child: WebViewWidget(controller: _controller),
      ),
    );
  }
}