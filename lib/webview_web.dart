import 'package:flutter/material.dart';
import 'dart:html' as html;
import 'dart:ui_web' as ui_web;

class AdBannerWidget extends StatelessWidget {
  const AdBannerWidget({super.key});

  @override
  Widget build(BuildContext context) {
    const String viewType = 'adsterra-github-view';

    // ignore: undefined_prefixed_name
    ui_web.platformViewRegistry.registerViewFactory(viewType, (int viewId) {
      final html.IFrameElement iframe = html.IFrameElement()
        ..src = 'https://shervankhoja.github.io/my-ads/' // الرابط الصحيح والكامل لصفحة غيت هوب
        ..style.border = 'none'
        ..style.width = '100%'
        ..style.height = '100%';
      return iframe;
    });

    return ClipRRect(
      borderRadius: BorderRadius.circular(12),
      child: const SizedBox(
        height: 50, // ارتفاع البانر ليطابق مقاس 320x50 بدقة
        width: double.infinity,
        child: HtmlElementView(viewType: viewType),
      ),
    );
  }
}