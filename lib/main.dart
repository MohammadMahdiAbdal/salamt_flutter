import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:intl/date_symbol_data_local.dart'; // برای فرمت تاریخ فارسی
import 'package:shared_preferences/shared_preferences.dart'; // برای ذخیره سازی
import 'dart:convert'; // برای تبدیل Reminder به JSON و برعکس
import 'package:animate_do/animate_do.dart'; // برای انیمیشن ها

// صفحات برنامه (بعدا ایجاد می شوند)
import 'screens/dashboard_screen.dart';
import 'screens/input_screen.dart';
import 'screens/reminder_screen.dart';
import 'screens/settings_screen.dart';

// مدل داده
import 'models/reminder_model.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await initializeDateFormatting('fa_IR', null); // مهم برای فرمت تاریخ فارسی
  runApp(SalamatiApp());
}

class SalamatiApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    // تعریف پالت رنگی مدرن بر پایه Teal
    const Color primaryTeal = Color(
      0xFF00897B,
    ); // کمی تیره‌تر و جذاب‌تر از Colors.teal
    const Color accentTeal = Color(0xFF00BFA5); // یک Teal روشن‌تر برای تاکید
    const Color lightBackground = Color(
      0xFFF0FDFB,
    ); // پس‌زمینه خیلی روشن و تمیز
    const Color darkText = Color(0xFF004D40); // رنگ متن تیره برای خوانایی
    const Color cardSurface = Colors.white;

    return MaterialApp(
      title: 'سلامتی من',
      theme: ThemeData(
        useMaterial3: true, // فعال کردن Material 3
        primaryColor: primaryTeal,
        scaffoldBackgroundColor: lightBackground,
        fontFamily:
            'Tahoma', // یا هر فونت فارسی دیگری که دارید یا null برای فونت سیستم

        colorScheme: ColorScheme.fromSeed(
          seedColor: primaryTeal,
          primary: primaryTeal,
          secondary: accentTeal,
          background: lightBackground,
          surface: cardSurface,
          onPrimary: Colors.white,
          onSecondary: Colors.black87, // متن روی accentTeal
          onBackground: darkText,
          onSurface: darkText,
          error: Color(0xFFB00020),
          brightness: Brightness.light,
        ),

        appBarTheme: AppBarTheme(
          backgroundColor: primaryTeal,
          foregroundColor: Colors.white,
          elevation: 1.5,
          centerTitle: true,
          titleTextStyle: TextStyle(
            fontSize: 19, // کمی کوچکتر و مدرن‌تر
            fontWeight: FontWeight.w600,
            fontFamily: 'Tahoma', // فونت شما
            color: Colors.white,
            letterSpacing: 0.3,
          ),
        ),

        cardTheme: CardTheme(
          elevation: 2.5, // سایه نرم
          margin: EdgeInsets.symmetric(vertical: 8.0, horizontal: 16.0),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16.0), // گردی بیشتر
          ),
          color: cardSurface,
          shadowColor: Colors.black.withOpacity(0.08),
        ),

        inputDecorationTheme: InputDecorationTheme(
          filled: true,
          fillColor: Colors.white.withOpacity(0.8),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12.0),
            borderSide: BorderSide(color: Colors.grey.shade300, width: 0.8),
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12.0),
            borderSide: BorderSide(color: Colors.grey.shade300, width: 0.8),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12.0),
            borderSide: BorderSide(color: primaryTeal, width: 1.8),
          ),
          labelStyle: TextStyle(
            color: darkText.withOpacity(0.8),
            fontFamily: 'Tahoma',
            fontSize: 15,
          ),
          hintStyle: TextStyle(
            color: Colors.grey.shade500,
            fontFamily: 'Tahoma',
            fontSize: 14.5,
          ),
          contentPadding: EdgeInsets.symmetric(horizontal: 20, vertical: 16),
          prefixIconColor: primaryTeal.withOpacity(0.7),
        ),

        elevatedButtonTheme: ElevatedButtonThemeData(
          style: ElevatedButton.styleFrom(
            backgroundColor: accentTeal, // استفاده از رنگ تاکیدی
            foregroundColor: Colors.white,
            padding: EdgeInsets.symmetric(horizontal: 28, vertical: 15),
            textStyle: TextStyle(
              fontSize: 15,
              fontWeight: FontWeight.w600,
              fontFamily: 'Tahoma',
              letterSpacing: 0.4,
            ),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12.0),
            ),
            elevation: 2.0,
          ),
        ),

        floatingActionButtonTheme: FloatingActionButtonThemeData(
          backgroundColor: accentTeal,
          foregroundColor: Colors.white,
          elevation: 4.0,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16.0),
          ),
        ),

        bottomNavigationBarTheme: BottomNavigationBarThemeData(
          backgroundColor: Colors.white, // پس زمینه سفید
          selectedItemColor: primaryTeal, // رنگ آیتم فعال
          unselectedItemColor: Colors.grey.shade500, // رنگ آیتم غیرفعال
          selectedLabelStyle: TextStyle(
            fontWeight: FontWeight.w600,
            fontSize: 11.5,
            fontFamily: 'Tahoma',
          ),
          unselectedLabelStyle: TextStyle(fontSize: 11, fontFamily: 'Tahoma'),
          type: BottomNavigationBarType.fixed, // برای نمایش همه لیبل ها
          elevation: 5.0, // سایه برای جدا شدن از محتوا
        ),

        listTileTheme: ListTileThemeData(
          iconColor: primaryTeal,
          titleTextStyle: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w500,
            color: darkText,
            fontFamily: 'Tahoma',
          ),
          subtitleTextStyle: TextStyle(
            fontSize: 13.5,
            color: Colors.grey.shade700,
            fontFamily: 'Tahoma',
          ),
          contentPadding: EdgeInsetsDirectional.symmetric(
            horizontal: 20.0,
            vertical: 6.0,
          ), // پدینگ جهتی
        ),

        dialogTheme: DialogTheme(
          backgroundColor: Colors.white,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16.0),
          ),
          titleTextStyle: TextStyle(
            color: darkText,
            fontSize: 18,
            fontWeight: FontWeight.w600,
            fontFamily: 'Tahoma',
          ),
          contentTextStyle: TextStyle(
            color: darkText.withOpacity(0.9),
            fontSize: 15,
            fontFamily: 'Tahoma',
            height: 1.4,
          ),
        ),

        snackBarTheme: SnackBarThemeData(
          backgroundColor: darkText.withOpacity(0.9),
          contentTextStyle: TextStyle(
            color: Colors.white,
            fontFamily: 'Tahoma',
          ),
          actionTextColor: accentTeal,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10),
          ),
          behavior: SnackBarBehavior.floating, // اسنک بار شناور
          elevation: 4,
          insetPadding: EdgeInsets.all(10), // فاصله از لبه ها
        ),

        textTheme: TextTheme(
          bodyLarge: TextStyle(
            fontFamily: 'Tahoma',
            fontSize: 16,
            color: darkText,
            height: 1.5,
          ),
          bodyMedium: TextStyle(
            fontFamily: 'Tahoma',
            fontSize: 14,
            color: darkText.withOpacity(0.85),
            height: 1.4,
          ),
          labelLarge: TextStyle(
            fontFamily: 'Tahoma',
            fontSize: 14,
            fontWeight: FontWeight.w600,
            color: primaryTeal,
          ),
          titleMedium: TextStyle(
            fontFamily: 'Tahoma',
            fontSize: 16,
            fontWeight: FontWeight.w600,
            color: darkText,
          ),
          headlineSmall: TextStyle(
            fontFamily: 'Tahoma',
            fontSize: 22,
            fontWeight: FontWeight.bold,
            color: primaryTeal,
          ), // برای عناوین اصلی صفحات
        ),
      ),
      debugShowCheckedModeBanner: false,
      locale: const Locale('fa', 'IR'), // لوکال کامل فارسی
      supportedLocales: const [Locale('fa', 'IR')],
      localizationsDelegates: const [
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],
      home: MainScreen(),
    );
  }
}
