import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:lottie/lottie.dart';
import 'package:flutter_localizations/flutter_localizations.dart';

// الربط الآمن مع الملفات الثلاثة الخاصة بالإعلانات/الـ Webview
import 'webview_stub.dart'
if (dart.library.html) 'webview_web.dart'
if (dart.library.io) 'webview_mobile.dart';

import 'gpa_calculator.dart';
import 'percent_calculator.dart';

final ValueNotifier<ThemeMode> themeNotifier = ValueNotifier(ThemeMode.system);
final ValueNotifier<Locale> localeNotifier = ValueNotifier(const Locale('ar'));

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  SystemChrome.setSystemUIOverlayStyle(const SystemUiOverlayStyle(
    statusBarColor: Colors.transparent,
  ));
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<ThemeMode>(
      valueListenable: themeNotifier,
      builder: (_, ThemeMode currentMode, __) {
        return ValueListenableBuilder<Locale>(
          valueListenable: localeNotifier,
          builder: (context, currentLocale, child) {
            return MaterialApp(
              debugShowCheckedModeBanner: false,
              locale: currentLocale,
              supportedLocales: const [
                Locale('ar'),
                Locale('en'),
              ],
              localizationsDelegates: const [
                GlobalMaterialLocalizations.delegate,
                GlobalWidgetsLocalizations.delegate,
                GlobalCupertinoLocalizations.delegate,
              ],
              theme: ThemeData.light().copyWith(
                scaffoldBackgroundColor: Colors.white,
                appBarTheme: const AppBarTheme(
                  backgroundColor: Color(0xFF1B1B3A),
                  foregroundColor: Colors.white,
                  systemOverlayStyle: SystemUiOverlayStyle.light,
                ),
                textTheme: GoogleFonts.cairoTextTheme(ThemeData.light().textTheme),
              ),
              darkTheme: ThemeData.dark().copyWith(
                scaffoldBackgroundColor: const Color(0xFF121212),
                appBarTheme: const AppBarTheme(
                  backgroundColor: Color(0xFF1B1B3A),
                  foregroundColor: Colors.white,
                  systemOverlayStyle: SystemUiOverlayStyle.light,
                ),
                textTheme: GoogleFonts.cairoTextTheme(ThemeData.dark().textTheme),
              ),
              themeMode: currentMode,
              builder: (context, child) => Directionality(
                textDirection: currentLocale.languageCode == 'ar'
                    ? TextDirection.rtl
                    : TextDirection.ltr,
                child: child!,
              ),
              home: const SplashScreen(),
            );
          },
        );
      },
    );
  }
}

// شاشة الشعار الترحيبية
class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  Timer? _timer;

  @override
  void initState() {
    super.initState();
    _timer = Timer(const Duration(seconds: 5), () {
      if (!mounted) return;
      Navigator.of(context).pushReplacement(
        MaterialPageRoute(builder: (context) => const WelcomePage()),
      );
    });
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final bool isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: isDark ? const Color(0xFF121212) : Colors.white,
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Image.asset(
              'assets/images/app_logo-removebg-preview.png',
              width: 250,
              height: 250,
              fit: BoxFit.contain,
            ),
            const SizedBox(height: 20),
            ColorFiltered(
              colorFilter: ColorFilter.mode(
                isDark ? Colors.white70 : const Color(0xFF1B2A47),
                BlendMode.srcATop,
              ),
              child: Lottie.asset(
                'assets/images/loading_graduation.json',
                width: 100,
                height: 100,
                fit: BoxFit.contain,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// الشاشة الرئيسية
class WelcomePage extends StatefulWidget {
  const WelcomePage({super.key});

  @override
  State<WelcomePage> createState() => _WelcomePageState();
}

class _WelcomePageState extends State<WelcomePage> {
  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<Locale>(
      valueListenable: localeNotifier,
      builder: (context, currentLocale, child) {
        final bool isArabic = currentLocale.languageCode == 'ar';

        return Scaffold(
          appBar: AppBar(
            title: Text(isArabic ? "حاسبة المعدل" : "GPA Calculator"),
            backgroundColor: const Color(0xFF1B1B3A),
            foregroundColor: Colors.white,
            actions: [
              IconButton(
                icon: const Icon(Icons.language),
                tooltip: isArabic ? 'Change to English' : 'التحويل إلى العربية',
                onPressed: () {
                  localeNotifier.value = isArabic
                      ? const Locale('en')
                      : const Locale('ar');
                },
              ),
              IconButton(
                icon: const Icon(Icons.info_outline),
                tooltip: isArabic ? 'عن التطبيق' : 'About App',
                onPressed: () {
                  Navigator.push(context, MaterialPageRoute(builder: (context) => const AboutPage()));
                },
              ),
              ValueListenableBuilder<ThemeMode>(
                valueListenable: themeNotifier,
                builder: (_, ThemeMode currentMode, __) {
                  final bool isDarkNow = Theme.of(context).brightness == Brightness.dark;
                  return IconButton(
                    icon: Icon(
                      isDarkNow ? Icons.nightlight_round : Icons.wb_sunny_rounded,
                      color: isDarkNow ? Colors.yellowAccent : Colors.white,
                    ),
                    tooltip: isDarkNow ? 'الوضع النهاري' : 'الوضع الليلي',
                    onPressed: () {
                      themeNotifier.value = isDarkNow ? ThemeMode.light : ThemeMode.dark;
                    },
                  );
                },
              ),
            ],
          ),
          body: Column(
            children: [
              Expanded(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.all(20.0),
                  child: Column(
                    children: [
                      const SizedBox(height: 10),
                      Opacity(
                        opacity: 0.9,
                        child: Image.asset(
                          'assets/images/app_logo-removebg-preview.png',
                          width: 150,
                          height: 150,
                          fit: BoxFit.contain,
                        ),
                      ),
                      const SizedBox(height: 15),
                      Text(
                        isArabic ? "اختر نظام الحساب المناسب:" : "Choose Calculation System:",
                        style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.grey),
                      ),
                      const SizedBox(height: 15),
                      _buildOption(
                        context,
                        isArabic ? "نظام 4.0" : "4.0 System",
                        Colors.blue,
                        4.0,
                      ),
                      _buildOption(
                        context,
                        isArabic ? "نظام 5.0" : "5.0 System",
                        Colors.orange,
                        5.0,
                      ),
                      _buildOption(
                        context,
                        isArabic ? "نظام النسبة المئوية" : "Percentage System",
                        Colors.teal,
                        100.0,
                      ),
                    ],
                  ),
                ),
              ),
              const Padding(
                padding: EdgeInsets.all(8.0),
                child: AdBannerWidget(),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildOption(BuildContext context, String text, Color color, double max) {
    return Card(
      margin: const EdgeInsets.symmetric(vertical: 8),
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
      child: ListTile(
        leading: Icon(Icons.school, color: color, size: 30),
        title: Text(text, style: const TextStyle(fontWeight: FontWeight.bold)),
        trailing: const Icon(Icons.arrow_forward_ios, size: 18),
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => max == 100.0
                  ? const PercentCalculator()
                  : GPACalculator(systemName: text, appBarColor: color, max: max),
            ),
          );
        },
      ),
    );
  }
}

// صفحة عن التطبيق
class AboutPage extends StatelessWidget {
  const AboutPage({super.key});

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<Locale>(
      valueListenable: localeNotifier,
      builder: (context, currentLocale, child) {
        final bool isArabic = currentLocale.languageCode == 'ar';

        return Scaffold(
          appBar: AppBar(
            title: Text(isArabic ? "عن التطبيق" : "About App"),
            backgroundColor: const Color(0xFF1B1B3A),
            foregroundColor: Colors.white,
          ),
          body: Padding(
            padding: const EdgeInsets.all(20.0),
            child: Center(
              child: SingleChildScrollView(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Image.asset(
                      'assets/images/app_logo-removebg-preview.png',
                      width: 100,
                      height: 100,
                    ),
                    const SizedBox(height: 20),
                    Text(
                      isArabic ? "حاسبة المعدل الجامعي" : "University GPA Calculator",
                      style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 10),
                    Text(
                      isArabic ? "الإصدار 1.0.2" : "Version 1.0.2",
                      style: const TextStyle(color: Colors.grey),
                    ),
                    const SizedBox(height: 30),
                    Card(
                      elevation: 2,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
                      child: Padding(
                        padding: const EdgeInsets.all(16.0),
                        child: Text(
                          isArabic
                              ? "تم تطوير هذا التطبيق بعناية لمساعدة الطلاب في حساب معدلاتهم بكل سهولة ودقة."
                              : "This application was carefully developed to help students calculate their GPA easily and accurately.",
                          textAlign: TextAlign.center,
                          style: const TextStyle(fontSize: 15),
                        ),
                      ),
                    ),
                    const SizedBox(height: 12),
                    Card(
                      elevation: 2,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
                      child: Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 14.0),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            const Icon(Icons.person, color: Color(0xFF1B1B3A), size: 20),
                            const SizedBox(width: 10),
                            Text(
                              isArabic ? "المطور: Shervan khoja" : "Developer: Shervan khoja",
                              style: const TextStyle(fontSize: 15, fontWeight: FontWeight.bold),
                            ),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(height: 12),
                    Card(
                      elevation: 2,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
                      child: Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 14.0),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            const Icon(Icons.business, color: Color(0xFF1B1B3A), size: 20),
                            const SizedBox(width: 10),
                            Text(
                              isArabic ? "استوديو: KSK" : "Studio: KSK",
                              style: const TextStyle(fontSize: 15, fontWeight: FontWeight.bold),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        );
      },
    );
  }
}