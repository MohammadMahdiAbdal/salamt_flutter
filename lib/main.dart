import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:intl/intl.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';
import 'package:animate_do/animate_do.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:flutter_slidable/flutter_slidable.dart';
import 'package:lottie/lottie.dart';
import 'package:flutter/services.dart'; // برای HapticFeedback
import 'package:flutter_staggered_animations/flutter_staggered_animations.dart'; // ایمپورت مهم

// --- مدل داده ---
class Reminder {
  String text;
  TimeOfDay time;
  bool isActive;

  Reminder({required this.text, required this.time, this.isActive = true});

  Map<String, dynamic> toJson() => {
    'text': text,
    'hour': time.hour,
    'minute': time.minute,
    'isActive': isActive,
  };

  factory Reminder.fromJson(Map<String, dynamic> json) => Reminder(
    text: json['text'],
    time: TimeOfDay(hour: json['hour'], minute: json['minute']),
    isActive: json['isActive'] ?? true,
  );
}

// --- کلیدهای SharedPreferences ---
const String _sleepKey =
    'salamati_app_v1_sleep_hours'; // اضافه کردن پیشوند برای جلوگیری از تداخل با نسخه های قبلی
const String _waterKey = 'salamati_app_v1_water_liters';
const String _remindersKey = 'salamati_app_v1_reminders_list';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await initializeDateFormatting('fa_IR', null);
  runApp(SalamatiApp());
}

// --- ویجت اصلی برنامه ---
class SalamatiApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    const Color primaryTeal = Color(0xFF00897B);
    const Color accentTeal = Color(0xFF00BFA5);
    const Color lightBackground = Color(0xFFF0FDFB);
    const Color darkText = Color(0xFF004D40);
    const Color cardSurface = Colors.white;
    final String? appFontFamily = null; // 'Tahoma' or null for system font

    return MaterialApp(
      title: 'سلامتی من',
      theme: ThemeData(
        useMaterial3: true,
        primaryColor: primaryTeal,
        scaffoldBackgroundColor: lightBackground,
        fontFamily: appFontFamily,
        colorScheme: ColorScheme.fromSeed(
          seedColor: primaryTeal,
          primary: primaryTeal,
          secondary: accentTeal,
          background: lightBackground,
          surface: cardSurface,
          onPrimary: Colors.white,
          onSecondary: Colors.black87,
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
            fontSize: 19,
            fontWeight: FontWeight.w600,
            fontFamily: appFontFamily,
            color: Colors.white,
            letterSpacing: 0.3,
          ),
        ),
        cardTheme: CardTheme(
          elevation: 2.5,
          margin: EdgeInsets.symmetric(vertical: 8.0, horizontal: 16.0),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16.0),
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
            fontFamily: appFontFamily,
            fontSize: 15,
          ),
          hintStyle: TextStyle(
            color: Colors.grey.shade500,
            fontFamily: appFontFamily,
            fontSize: 14.5,
          ),
          contentPadding: EdgeInsets.symmetric(horizontal: 20, vertical: 16),
          prefixIconColor: primaryTeal.withOpacity(0.7),
        ),
        elevatedButtonTheme: ElevatedButtonThemeData(
          style: ElevatedButton.styleFrom(
            backgroundColor: accentTeal,
            foregroundColor: Colors.white,
            padding: EdgeInsets.symmetric(horizontal: 28, vertical: 15),
            textStyle: TextStyle(
              fontSize: 15,
              fontWeight: FontWeight.w600,
              fontFamily: appFontFamily,
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
          backgroundColor: Colors.white,
          selectedItemColor: primaryTeal,
          unselectedItemColor: Colors.grey.shade500,
          selectedLabelStyle: TextStyle(
            fontWeight: FontWeight.w600,
            fontSize: 11.5,
            fontFamily: appFontFamily,
          ),
          unselectedLabelStyle: TextStyle(
            fontSize: 11,
            fontFamily: appFontFamily,
          ),
          type: BottomNavigationBarType.fixed,
          elevation: 5.0,
        ),
        listTileTheme: ListTileThemeData(
          iconColor: primaryTeal,
          titleTextStyle: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w500,
            color: darkText,
            fontFamily: appFontFamily,
          ),
          subtitleTextStyle: TextStyle(
            fontSize: 13.5,
            color: Colors.grey.shade700,
            fontFamily: appFontFamily,
          ),
          contentPadding: EdgeInsetsDirectional.symmetric(
            horizontal: 20.0,
            vertical: 6.0,
          ),
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
            fontFamily: appFontFamily,
          ),
          contentTextStyle: TextStyle(
            color: darkText.withOpacity(0.9),
            fontSize: 15,
            fontFamily: appFontFamily,
            height: 1.4,
          ),
        ),
        snackBarTheme: SnackBarThemeData(
          backgroundColor: darkText.withOpacity(0.9),
          contentTextStyle: TextStyle(
            color: Colors.white,
            fontFamily: appFontFamily,
          ),
          actionTextColor: accentTeal,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10),
          ),
          behavior: SnackBarBehavior.floating,
          elevation: 4,
          insetPadding: EdgeInsets.all(10),
        ),
        textTheme: TextTheme(
          bodyLarge: TextStyle(
            fontFamily: appFontFamily,
            fontSize: 16,
            color: darkText,
            height: 1.5,
          ),
          bodyMedium: TextStyle(
            fontFamily: appFontFamily,
            fontSize: 14,
            color: darkText.withOpacity(0.85),
            height: 1.4,
          ),
          labelLarge: TextStyle(
            fontFamily: appFontFamily,
            fontSize: 14,
            fontWeight: FontWeight.w600,
            color: primaryTeal,
          ),
          titleMedium: TextStyle(
            fontFamily: appFontFamily,
            fontSize: 16,
            fontWeight: FontWeight.w600,
            color: darkText,
          ),
          headlineSmall: TextStyle(
            fontFamily: appFontFamily,
            fontSize: 22,
            fontWeight: FontWeight.bold,
            color: primaryTeal,
          ),
        ),
      ),
      debugShowCheckedModeBanner: false,
      locale: const Locale('fa', 'IR'),
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

// --- صفحه اصلی با ناوبری ---
class MainScreen extends StatefulWidget {
  @override
  State<MainScreen> createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen>
    with SingleTickerProviderStateMixin {
  int _selectedIndex = 0;
  late PageController _pageController;
  late AnimationController _fabAnimationController;

  double _sleepHours = 0.0;
  double _waterLiters = 0.0;
  List<Reminder> _reminders = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _pageController = PageController(initialPage: _selectedIndex);
    _fabAnimationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 400),
    );
    _loadData();
  }

  @override
  void dispose() {
    _pageController.dispose();
    _fabAnimationController.dispose();
    super.dispose();
  }

  Future<void> _loadData() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      _sleepHours = prefs.getDouble(_sleepKey) ?? 0.0;
      _waterLiters = prefs.getDouble(_waterKey) ?? 0.0;
      final String? remindersString = prefs.getString(_remindersKey);
      if (remindersString != null && remindersString.isNotEmpty) {
        try {
          final List<dynamic> remindersJson = jsonDecode(remindersString);
          _reminders =
              remindersJson
                  .map(
                    (jsonMap) =>
                        Reminder.fromJson(jsonMap as Map<String, dynamic>),
                  )
                  .toList();
        } catch (e) {
          print("Error decoding reminders from SharedPreferences: $e");
          _reminders = [];
        }
      }
      _isLoading = false;
    });
  }

  Future<void> _saveSleepAndWater() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setDouble(_sleepKey, _sleepHours);
    await prefs.setDouble(_waterKey, _waterLiters);
  }

  Future<void> _saveReminders() async {
    final prefs = await SharedPreferences.getInstance();
    final String remindersString = jsonEncode(
      _reminders.map((r) => r.toJson()).toList(),
    );
    await prefs.setString(_remindersKey, remindersString);
  }

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
      _pageController.animateToPage(
        index,
        duration: const Duration(milliseconds: 350),
        curve: Curves.easeInOutQuart,
      );
    });
    if (index == 2) {
      // ReminderScreen index
      _fabAnimationController.forward();
    } else {
      _fabAnimationController.reverse();
    }
  }

  void updateDashboardData(double sleep, double water) {
    setState(() {
      _sleepHours = sleep;
      _waterLiters = water;
      _saveSleepAndWater();
    });
  }

  void addReminder(Reminder newReminder) {
    setState(() {
      _reminders.add(newReminder);
      _reminders.sort((a, b) {
        final now = DateTime.now();
        final timeA = DateTime(
          now.year,
          now.month,
          now.day,
          a.time.hour,
          a.time.minute,
        );
        final timeB = DateTime(
          now.year,
          now.month,
          now.day,
          b.time.hour,
          b.time.minute,
        );
        return timeA.compareTo(timeB);
      });
      _saveReminders();
    });
  }

  void editReminder(int index, Reminder updatedReminder) {
    setState(() {
      _reminders[index] = updatedReminder;
      _reminders.sort((a, b) {
        final now = DateTime.now();
        final timeA = DateTime(
          now.year,
          now.month,
          now.day,
          a.time.hour,
          a.time.minute,
        );
        final timeB = DateTime(
          now.year,
          now.month,
          now.day,
          b.time.hour,
          b.time.minute,
        );
        return timeA.compareTo(timeB);
      });
      _saveReminders();
    });
  }

  void deleteReminder(int index) {
    setState(() {
      _reminders.removeAt(index);
      _saveReminders();
    });
  }

  void toggleReminderActive(int index, bool isActive) {
    setState(() {
      _reminders[index].isActive = isActive;
      _saveReminders();
    });
  }

  void _showAddReminderDialogFromMainScreen() {
    final _textController = TextEditingController();
    TimeOfDay selectedTime = TimeOfDay.now();
    final currentContext = this.context; // Capture context

    showDialog(
      context: currentContext,
      builder:
          (ctx) => AlertDialog(
            title: Text('افزودن یادآور جدید', textAlign: TextAlign.right),
            contentPadding: EdgeInsets.fromLTRB(20, 20, 20, 10),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                TextField(
                  controller: _textController,
                  textAlign: TextAlign.right,
                  decoration: InputDecoration(
                    labelText: 'متن یادآور',
                    hintText: "مثال: نوشیدن آب",
                  ),
                  textInputAction: TextInputAction.done,
                ),
                SizedBox(height: 18),
                ElevatedButton.icon(
                  icon: Icon(Icons.access_time_rounded, size: 20),
                  label: Text('انتخاب ساعت یادآوری'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Theme.of(
                      currentContext,
                    ).primaryColor.withOpacity(0.1),
                    foregroundColor: Theme.of(currentContext).primaryColor,
                    elevation: 0,
                    padding: EdgeInsets.symmetric(vertical: 12),
                  ),
                  onPressed: () async {
                    final pickedTime = await showTimePicker(
                      context: currentContext, // Use captured context
                      initialTime: selectedTime,
                      helpText: "زمان یادآور را انتخاب کنید",
                      builder: (pickerContext, child) {
                        return Theme(
                          data: Theme.of(currentContext).copyWith(
                            // Use captured context
                            colorScheme: Theme.of(
                              currentContext,
                            ).colorScheme.copyWith(
                              // Use captured context
                              primary:
                                  Theme.of(
                                    currentContext,
                                  ).primaryColor, // Use captured context
                              onPrimary: Colors.white,
                              surface: Colors.white,
                              onSurface:
                                  Theme.of(currentContext)
                                      .colorScheme
                                      .onSurface, // Use captured context
                            ),
                            timePickerTheme: TimePickerThemeData(
                              dialBackgroundColor: Colors.grey.shade100,
                            ),
                            textButtonTheme: TextButtonThemeData(
                              style: TextButton.styleFrom(
                                foregroundColor:
                                    Theme.of(currentContext).primaryColor,
                              ),
                            ), // Use captured context
                          ),
                          // اطمینان از Directionality برای TimePicker
                          child: Directionality(
                            textDirection:
                                TextDirection.rtl, // این باید درست باشه
                            child: child!,
                          ),
                        );
                      },
                    );
                    if (pickedTime != null) {
                      selectedTime = pickedTime;
                    }
                  },
                ),
              ],
            ),
            actionsAlignment: MainAxisAlignment.spaceBetween,
            actionsPadding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            actions: [
              TextButton(
                onPressed: () => Navigator.of(ctx).pop(),
                child: Text(
                  'انصراف',
                  style: TextStyle(color: Colors.grey.shade700),
                ),
              ),
              ElevatedButton(
                onPressed: () {
                  if (_textController.text.trim().isNotEmpty) {
                    addReminder(
                      Reminder(
                        text: _textController.text.trim(),
                        time: selectedTime,
                      ),
                    );
                    Navigator.of(ctx).pop();
                  } else {
                    ScaffoldMessenger.of(currentContext).showSnackBar(
                      // Use captured context
                      SnackBar(
                        content: Text(
                          'لطفا متن یادآور را وارد کنید.',
                          textAlign: TextAlign.right,
                        ),
                        backgroundColor: Colors.orangeAccent,
                      ),
                    );
                  }
                },
                child: Text('افزودن'),
              ),
            ],
          ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final List<Widget> _pages = [
      DashboardScreen(
        key: PageStorageKey('DashboardPage'),
        sleepHours: _sleepHours,
        waterLiters: _waterLiters,
      ),
      InputScreen(
        key: PageStorageKey('InputPage'),
        onSubmit: updateDashboardData,
      ),
      ReminderScreen(
        key: PageStorageKey('ReminderPage'),
        reminders: _reminders,
        onAdd: addReminder,
        onEdit: editReminder,
        onDelete: deleteReminder,
        onToggleActive: toggleReminderActive,
      ),
      SettingsScreen(key: PageStorageKey('SettingsPage')),
    ];

    if (_isLoading) {
      return Scaffold(
        body: Center(
          child: CircularProgressIndicator(
            color: Theme.of(context).primaryColor,
          ),
        ),
      );
    }

    return Directionality(
      textDirection: TextDirection.rtl, // این مهم است
      child: Scaffold(
        body: PageView(
          controller: _pageController,
          onPageChanged: (index) {
            setState(() {
              _selectedIndex = index;
              if (index == 2) {
                _fabAnimationController.forward();
              } else {
                _fabAnimationController.reverse();
              }
            });
          },
          children: _pages,
        ),
        bottomNavigationBar: BottomNavigationBar(
          currentIndex: _selectedIndex,
          onTap: _onItemTapped,
          items: const [
            BottomNavigationBarItem(
              icon: Icon(Icons.space_dashboard_outlined),
              activeIcon: Icon(Icons.space_dashboard_rounded),
              label: 'داشبورد',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.edit_calendar_outlined),
              activeIcon: Icon(Icons.edit_calendar_rounded),
              label: 'ورود روزانه',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.notifications_active_outlined),
              activeIcon: Icon(Icons.notifications_active_rounded),
              label: 'یادآورها',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.settings_outlined),
              activeIcon: Icon(Icons.settings_rounded),
              label: 'تنظیمات',
            ),
          ],
        ),
        floatingActionButton:
            _selectedIndex == 2
                ? ScaleTransition(
                  scale: _fabAnimationController,
                  child: FloatingActionButton.extended(
                    onPressed: _showAddReminderDialogFromMainScreen,
                    icon: Icon(Icons.add_alarm_rounded),
                    label: Text("افزودن یادآور"),
                  ),
                )
                : null,
        floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
      ),
    );
  }
}

// --- صفحه داشبورد ---
class DashboardScreen extends StatelessWidget {
  final double sleepHours;
  final double waterLiters;

  const DashboardScreen({
    Key? key,
    required this.sleepHours,
    required this.waterLiters,
  }) : super(key: key);

  Widget _buildInfoCard(
    BuildContext context, {
    required IconData icon,
    required String title,
    required String value,
    required Color color,
    required int delay,
  }) {
    final theme = Theme.of(context);
    return FadeInUp(
      delay: Duration(milliseconds: delay),
      duration: Duration(milliseconds: 500),
      child: Card(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 20),
          child: Row(
            children: [
              CircleAvatar(
                radius: 24,
                backgroundColor: color.withOpacity(0.12),
                child: Icon(icon, color: color, size: 26),
              ),
              SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: theme.textTheme.bodyMedium?.copyWith(
                        color: theme.colorScheme.onSurface.withOpacity(0.85),
                      ),
                      textAlign: TextAlign.right,
                    ),
                    SizedBox(height: 5),
                    Text(
                      value,
                      style: theme.textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                        fontSize: 18,
                        color: color,
                      ),
                      textAlign: TextAlign.right,
                    ),
                  ],
                ),
              ),
              Icon(
                Icons.arrow_forward_ios_rounded,
                size: 16,
                color: Colors.grey.shade400,
              ),
            ],
          ),
        ),
      ),
    );
  }

  // اصلاح شده برای fl_chart: ^1.0.0
  List<BarChartGroupData> _buildSampleBarGroups(
    BuildContext context,
    double currentSleep,
    double currentWater,
  ) {
    final theme = Theme.of(context);
    final List<double> sleepData = [
      6.5,
      7,
      currentSleep > 0 ? currentSleep : 7.5,
      6,
      8,
      7.2,
      7.8,
    ];
    final List<double> waterData = [
      1.5,
      2,
      currentWater > 0 ? currentWater : 2.2,
      1.8,
      2.5,
      2.1,
      2.3,
    ];

    return List.generate(7, (index) {
      return BarChartGroupData(
        x: index,
        barRods: [
          BarChartRodData(
            toY: sleepData[index],
            color: theme.primaryColor.withOpacity(0.8),
            width: 10,
            borderRadius: BorderRadius.circular(4),
          ),
          BarChartRodData(
            toY: waterData[index],
            color: Colors.blue.shade300.withOpacity(0.8),
            width: 10,
            borderRadius: BorderRadius.circular(4),
          ),
        ],
      );
    });
  }

  // اصلاح شده برای fl_chart: ^1.0.0
  Widget _getTitlesWidget(double value, TitleMeta meta, List<String> labels) {
    final style = TextStyle(
      color: Colors.grey.shade600,
      fontSize: 11,
      fontWeight: FontWeight.w500,
    );
    String text = '';
    if (value.toInt() >= 0 && value.toInt() < labels.length) {
      text = labels[value.toInt()];
    }
    return SideTitleWidget(
      axisSide: meta.axisSide, // این باید درست باشه برای نسخه 1.0.0
      space: 4,
      child: Text(text, style: style),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    int animationDelay = 200;

    return Scaffold(
      appBar: AppBar(
        title: FadeInDown(
          duration: Duration(milliseconds: 500),
          child: Text('داشبورد سلامتی شما'),
        ),
      ),
      body: ListView(
        padding: const EdgeInsets.all(16.0),
        children: [
          FadeInDown(
            delay: Duration(milliseconds: animationDelay),
            duration: Duration(milliseconds: 500),
            child: Card(
              elevation: 0.5,
              color: theme.primaryColor.withOpacity(0.05),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(14),
              ),
              child: Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: 20,
                  vertical: 22,
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      "سلام!",
                      style: theme.textTheme.headlineSmall?.copyWith(
                        color: theme.primaryColor,
                        fontSize: 23,
                      ),
                      textAlign: TextAlign.right,
                    ),
                    SizedBox(height: 6),
                    Text(
                      "نگاهی به وضعیت امروزت بنداز:",
                      style: theme.textTheme.bodyMedium?.copyWith(
                        color: theme.colorScheme.onSurface.withOpacity(0.7),
                      ),
                      textAlign: TextAlign.right,
                    ),
                  ],
                ),
              ),
            ),
          ),
          SizedBox(height: 12),
          _buildInfoCard(
            context,
            icon: Icons.king_bed_outlined,
            title: 'میزان خواب شب گذشته',
            value: '${sleepHours.toStringAsFixed(1)} ساعت',
            color: theme.primaryColor,
            delay: animationDelay += 150,
          ),
          _buildInfoCard(
            context,
            icon: Icons.opacity_outlined,
            title: 'میزان آب مصرفی امروز',
            value: '${waterLiters.toStringAsFixed(1)} لیتر',
            color: Colors.blue.shade600,
            delay: animationDelay += 150,
          ),
          _buildInfoCard(
            context,
            icon: Icons.favorite_border_rounded,
            title: 'ضربان قلب (مثال)',
            value: '۷۲ bpm',
            color: Colors.pink.shade400,
            delay: animationDelay += 150,
          ),
          SizedBox(height: 24),
          FadeInUp(
            delay: Duration(milliseconds: animationDelay += 150),
            duration: Duration(milliseconds: 600),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Padding(
                  padding: const EdgeInsets.only(right: 8.0, bottom: 12.0),
                  child: Text(
                    "روند هفتگی (نمونه)",
                    style: theme.textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                      color: theme.colorScheme.onBackground.withOpacity(0.8),
                    ),
                    textAlign: TextAlign.right,
                  ),
                ),
                Container(
                  height: 200,
                  padding: EdgeInsets.symmetric(vertical: 10),
                  child: BarChart(
                    BarChartData(
                      alignment: BarChartAlignment.spaceAround,
                      // اصلاح شده برای fl_chart: ^1.0.0
                      barTouchData: BarTouchData(
                        enabled: true,
                        touchTooltipData: BarTouchTooltipData(
                          tooltipRoundedRadius: 8,
                          getTooltipColor:
                              (_) => Colors.grey.shade200, // اصلاح شده
                          getTooltipItem: (group, groupIndex, rod, rodIndex) {
                            String weekDay;
                            final daysFull = [
                              'شنبه',
                              'یکشنبه',
                              'دوشنبه',
                              'سه‌شنبه',
                              'چهارشنبه',
                              'پنجشنبه',
                              'جمعه',
                            ];
                            weekDay = daysFull[group.x.toInt()];
                            return BarTooltipItem(
                              '$weekDay\n',
                              TextStyle(
                                color: Colors.black87,
                                fontWeight: FontWeight.bold,
                                fontSize: 13,
                              ),
                              children: <TextSpan>[
                                TextSpan(
                                  text: (rod.toY).toStringAsFixed(
                                    1,
                                  ), // اصلاح شده
                                  style: TextStyle(
                                    color:
                                        rod.color?.withOpacity(0.9) ??
                                        Colors.blue,
                                    fontSize: 14,
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                                TextSpan(
                                  text:
                                      rodIndex == 0 ? ' ساعت خواب' : ' لیتر آب',
                                  style: TextStyle(
                                    color: Colors.grey.shade700,
                                    fontSize: 12,
                                  ),
                                ),
                              ],
                            );
                          },
                        ),
                      ),
                      titlesData: FlTitlesData(
                        show: true,
                        bottomTitles: AxisTitles(
                          sideTitles: SideTitles(
                            showTitles: true,
                            reservedSize: 30,
                            getTitlesWidget:
                                (value, meta) => _getTitlesWidget(value, meta, [
                                  'ش',
                                  'ی',
                                  'د',
                                  'س',
                                  'چ',
                                  'پ',
                                  'ج',
                                ]),
                          ),
                        ),
                        leftTitles: AxisTitles(
                          sideTitles: SideTitles(
                            showTitles: true,
                            reservedSize: 30,
                            interval: 2,
                            getTitlesWidget:
                                (value, meta) => _getTitlesWidget(
                                  value,
                                  meta,
                                  List.generate(13, (i) => (i * 2).toString()),
                                ), // اصلاح برای نمایش اعداد
                          ),
                        ),
                        topTitles: AxisTitles(
                          sideTitles: SideTitles(showTitles: false),
                        ),
                        rightTitles: AxisTitles(
                          sideTitles: SideTitles(showTitles: false),
                        ),
                      ),
                      borderData: FlBorderData(show: false),
                      barGroups: _buildSampleBarGroups(
                        context,
                        sleepHours,
                        waterLiters,
                      ),
                      gridData: FlGridData(
                        show: true,
                        drawVerticalLine: false,
                        horizontalInterval: 2,
                        getDrawingHorizontalLine:
                            (value) => FlLine(
                              color: Colors.grey.shade200,
                              strokeWidth: 0.5,
                            ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
          SizedBox(height: 20),
        ],
      ),
    );
  }
}

// --- صفحه ورود اطلاعات ---
class InputScreen extends StatefulWidget {
  final Function(double, double) onSubmit;

  const InputScreen({Key? key, required this.onSubmit}) : super(key: key);

  @override
  _InputScreenState createState() => _InputScreenState();
}

class _InputScreenState extends State<InputScreen> {
  final _sleepController = TextEditingController();
  final _waterController = TextEditingController();
  final _formKey = GlobalKey<FormState>();

  void _submitData() {
    FocusScope.of(context).unfocus();
    if (_formKey.currentState!.validate()) {
      final sleep = double.tryParse(_sleepController.text) ?? 0.0;
      final water = double.tryParse(_waterController.text) ?? 0.0;

      if (sleep > 24 || sleep < 0) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              'ساعت خواب وارد شده معتبر نیست (0-24).',
              textAlign: TextAlign.right,
            ),
            backgroundColor: Colors.orangeAccent,
          ),
        );
        return;
      }
      if (water > 15 || water < 0) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              'مقدار آب مصرفی وارد شده معتبر نیست (0-15).',
              textAlign: TextAlign.right,
            ),
            backgroundColor: Colors.orangeAccent,
          ),
        );
        return;
      }

      widget.onSubmit(sleep, water);
      HapticFeedback.mediumImpact();

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            'اطلاعات روزانه شما با موفقیت ثبت شد!',
            textAlign: TextAlign.right,
          ),
        ),
      );

      _sleepController.clear();
      _waterController.clear();
    } else {
      HapticFeedback.heavyImpact();
    }
  }

  @override
  void dispose() {
    _sleepController.dispose();
    _waterController.dispose();
    super.dispose();
  }

  Widget _buildTextFormField({
    required TextEditingController controller,
    required String labelText,
    required IconData icon,
    required int delay,
    String? hintText,
    FocusNode? focusNode,
    Function(String)? onFieldSubmitted,
  }) {
    return FadeInUp(
      delay: Duration(milliseconds: delay),
      duration: Duration(milliseconds: 500),
      child: TextFormField(
        controller: controller,
        textAlign: TextAlign.right,
        focusNode: focusNode,
        decoration: InputDecoration(
          labelText: labelText,
          hintText: hintText,
          prefixIcon: Padding(
            padding: const EdgeInsetsDirectional.only(start: 12.0, end: 8.0),
            child: Icon(icon, size: 22),
          ),
        ),
        keyboardType: TextInputType.numberWithOptions(decimal: true),
        textInputAction:
            onFieldSubmitted == null
                ? TextInputAction.done
                : TextInputAction.next,
        validator: (value) {
          if (value == null || value.isEmpty) {
            return 'لطفا این فیلد را پر کنید';
          }
          if (double.tryParse(value) == null) {
            return 'لطفا یک عدد معتبر وارد کنید (مثال: 7.5)';
          }
          return null;
        },
        onFieldSubmitted: onFieldSubmitted,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    int animationDelay = 200;
    FocusNode sleepNode = FocusNode();
    FocusNode waterNode = FocusNode();

    return Scaffold(
      appBar: AppBar(
        title: FadeInDown(
          duration: Duration(milliseconds: 500),
          child: Text('ورود اطلاعات روزانه'),
        ),
      ),
      body: GestureDetector(
        onTap: () => FocusScope.of(context).unfocus(),
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(20.0),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                SizedBox(height: 10),
                _buildTextFormField(
                  controller: _sleepController,
                  labelText: 'ساعت خواب شب گذشته',
                  hintText: "مثال: 7.5 یا 8",
                  icon: Icons.bedtime_outlined,
                  delay: animationDelay,
                  focusNode: sleepNode,
                  onFieldSubmitted:
                      (_) => FocusScope.of(context).requestFocus(waterNode),
                ),
                SizedBox(height: 22),
                _buildTextFormField(
                  controller: _waterController,
                  labelText: 'آب مصرفی امروز (به لیتر)',
                  hintText: "مثال: 2 یا 2.5",
                  icon: Icons.local_drink_outlined,
                  delay: animationDelay += 150,
                  focusNode: waterNode,
                  onFieldSubmitted: (_) => _submitData(),
                ),
                SizedBox(height: 35),
                FadeInUp(
                  delay: Duration(milliseconds: animationDelay += 200),
                  duration: Duration(milliseconds: 500),
                  child: ElevatedButton.icon(
                    onPressed: _submitData,
                    icon: Icon(Icons.check_circle_outline_rounded, size: 22),
                    label: Text('ثبت و ذخیره اطلاعات'),
                  ),
                ),
                SizedBox(height: 20),
                FadeInUp(
                  delay: Duration(milliseconds: animationDelay += 100),
                  duration: Duration(milliseconds: 500),
                  child: Text(
                    "توجه: اطلاعات وارد شده برای نمایش در داشبورد و محاسبات آینده استفاده خواهد شد.",
                    textAlign: TextAlign.center,
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: Colors.grey.shade600,
                      fontSize: 12.5,
                      height: 1.5,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

// --- صفحه یادآورها ---
class ReminderScreen extends StatefulWidget {
  final List<Reminder> reminders;
  final Function(Reminder) onAdd;
  final Function(int, Reminder) onEdit;
  final Function(int) onDelete;
  final Function(int, bool) onToggleActive;

  const ReminderScreen({
    Key? key,
    required this.reminders,
    required this.onAdd,
    required this.onEdit,
    required this.onDelete,
    required this.onToggleActive,
  }) : super(key: key);

  @override
  State<ReminderScreen> createState() => _ReminderScreenState();
}

class _ReminderScreenState extends State<ReminderScreen> {
  void _showEditDialog(
    BuildContext context,
    int index,
    Reminder currentReminder,
  ) {
    final _editController = TextEditingController(text: currentReminder.text);
    TimeOfDay selectedTime = currentReminder.time;

    showDialog(
      context: context,
      builder:
          (ctx) => StatefulBuilder(
            builder: (dialogContext, setDialogState) {
              return AlertDialog(
                title: Text('ویرایش یادآور', textAlign: TextAlign.right),
                contentPadding: EdgeInsets.fromLTRB(20, 20, 20, 10),
                content: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    TextField(
                      controller: _editController,
                      textAlign: TextAlign.right,
                      decoration: InputDecoration(labelText: 'متن جدید یادآور'),
                      textInputAction: TextInputAction.done,
                    ),
                    SizedBox(height: 18),
                    Text(
                      "زمان فعلی: ${selectedTime.format(context)}",
                      textAlign: TextAlign.right,
                      style: TextStyle(fontSize: 14),
                    ),
                    SizedBox(height: 8),
                    ElevatedButton.icon(
                      icon: Icon(Icons.edit_calendar_outlined, size: 20),
                      label: Text('تغییر ساعت یادآوری'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Theme.of(
                          context,
                        ).primaryColor.withOpacity(0.1),
                        foregroundColor: Theme.of(context).primaryColor,
                        elevation: 0,
                        padding: EdgeInsets.symmetric(vertical: 12),
                      ),
                      onPressed: () async {
                        final picked = await showTimePicker(
                          context: context,
                          initialTime: selectedTime,
                          helpText: "زمان جدید را انتخاب کنید",
                          builder: (pickerContext, child) {
                            return Theme(
                              data: Theme.of(context).copyWith(
                                colorScheme: Theme.of(
                                  context,
                                ).colorScheme.copyWith(
                                  primary: Theme.of(context).primaryColor,
                                  onPrimary: Colors.white,
                                  surface: Colors.white,
                                  onSurface:
                                      Theme.of(context).colorScheme.onSurface,
                                ),
                                timePickerTheme: TimePickerThemeData(
                                  dialBackgroundColor: Colors.grey.shade100,
                                ),
                                textButtonTheme: TextButtonThemeData(
                                  style: TextButton.styleFrom(
                                    foregroundColor:
                                        Theme.of(context).primaryColor,
                                  ),
                                ),
                              ),
                              // اطمینان از Directionality برای TimePicker
                              child: Directionality(
                                textDirection: TextDirection.rtl,
                                child: child!,
                              ),
                            );
                          },
                        );
                        if (picked != null) {
                          setDialogState(() {
                            selectedTime = picked;
                          });
                        }
                      },
                    ),
                  ],
                ),
                actionsAlignment: MainAxisAlignment.spaceBetween,
                actionsPadding: EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 8,
                ),
                actions: [
                  TextButton(
                    onPressed: () => Navigator.of(ctx).pop(),
                    child: Text(
                      'انصراف',
                      style: TextStyle(color: Colors.grey.shade700),
                    ),
                  ),
                  ElevatedButton(
                    onPressed: () {
                      if (_editController.text.trim().isNotEmpty) {
                        widget.onEdit(
                          index,
                          Reminder(
                            text: _editController.text.trim(),
                            time: selectedTime,
                            isActive: currentReminder.isActive,
                          ),
                        );
                        Navigator.of(ctx).pop();
                      } else {
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text(
                              'متن یادآور نمی‌تواند خالی باشد.',
                              textAlign: TextAlign.right,
                            ),
                            backgroundColor: Colors.orangeAccent,
                          ),
                        );
                      }
                    },
                    child: Text('ذخیره تغییرات'),
                  ),
                ],
              );
            },
          ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final DateFormat timeFormatter = DateFormat('HH:mm', 'fa_IR');

    return Scaffold(
      appBar: AppBar(
        title: FadeInDown(
          duration: Duration(milliseconds: 500),
          child: Text('یادآورهای روزانه شما'),
        ),
      ),
      body:
          widget.reminders.isEmpty
              ? Center(
                child: FadeInUp(
                  duration: Duration(milliseconds: 600),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Lottie.asset(
                        // این فایل را باید در assets/animations/ قرار دهید
                        'assets/animations/empty_reminder.json',
                        width: 220,
                        height: 220,
                        fit: BoxFit.contain,
                      ),
                      SizedBox(height: 20),
                      Text(
                        "هنوز یادآوری تنظیم نکرده‌اید!",
                        style: theme.textTheme.titleMedium?.copyWith(
                          color: Colors.grey[600],
                        ),
                        textAlign: TextAlign.center,
                      ),
                      SizedBox(height: 10),
                      Text(
                        "برای افزودن، دکمه + پایین صفحه را لمس کنید.",
                        style: theme.textTheme.bodyMedium?.copyWith(
                          color: Colors.grey[500],
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ],
                  ),
                ),
              )
              : AnimationLimiter(
                // ویجت اصلی برای انیمیشن لیست
                child: ListView.builder(
                  padding: EdgeInsets.only(top: 10, bottom: 90),
                  itemCount: widget.reminders.length,
                  itemBuilder: (ctx, index) {
                    final reminder = widget.reminders[index];
                    return AnimationConfiguration.staggeredList(
                      // برای انیمیشن پلکانی
                      position: index,
                      duration: const Duration(milliseconds: 450),
                      child: SlideAnimation(
                        // انیمیشن سر خوردن
                        verticalOffset: 50.0,
                        curve: Curves.easeOutQuint,
                        child: FadeInAnimation(
                          // انیمیشن محو شدن
                          curve: Curves.easeInExpo,
                          child: Slidable(
                            key: ValueKey(
                              reminder.hashCode +
                                  reminder.time.hour +
                                  reminder.time.minute +
                                  index +
                                  reminder.isActive.hashCode,
                            ), // کلید پیچیده تر برای بازسازی
                            startActionPane: ActionPane(
                              motion: const StretchMotion(),
                              extentRatio: 0.28,
                              children: [
                                SlidableAction(
                                  onPressed: (contextSlidable) {
                                    HapticFeedback.mediumImpact();
                                    widget.onDelete(index);
                                  },
                                  backgroundColor: theme.colorScheme.error
                                      .withOpacity(0.9),
                                  foregroundColor: Colors.white,
                                  icon: Icons.delete_sweep_outlined,
                                  label: 'حذف',
                                  borderRadius: BorderRadius.horizontal(
                                    left: Radius.circular(16),
                                  ),
                                ),
                              ],
                            ),
                            endActionPane: ActionPane(
                              motion: const BehindMotion(),
                              extentRatio: 0.28,
                              children: [
                                SlidableAction(
                                  onPressed:
                                      (contextSlidable) => _showEditDialog(
                                        context,
                                        index,
                                        reminder,
                                      ),
                                  backgroundColor: Colors.blue.shade600,
                                  foregroundColor: Colors.white,
                                  icon: Icons.edit_note_rounded,
                                  label: 'ویرایش',
                                  borderRadius: BorderRadius.horizontal(
                                    right: Radius.circular(16),
                                  ),
                                ),
                              ],
                            ),
                            child: Card(
                              child: ListTile(
                                contentPadding: EdgeInsetsDirectional.fromSTEB(
                                  12,
                                  8,
                                  16,
                                  8,
                                ),
                                leading: Switch(
                                  value: reminder.isActive,
                                  onChanged: (bool value) {
                                    widget.onToggleActive(index, value);
                                  },
                                  activeColor: theme.colorScheme.secondary,
                                  inactiveThumbColor: Colors.grey.shade400,
                                  inactiveTrackColor: Colors.grey.shade200,
                                ),
                                title: Text(
                                  reminder.text,
                                  style:
                                      reminder.isActive
                                          ? theme.listTileTheme.titleTextStyle
                                          : theme.listTileTheme.titleTextStyle
                                              ?.copyWith(
                                                color: Colors.grey.shade500,
                                                decoration:
                                                    TextDecoration.lineThrough,
                                                decorationColor:
                                                    Colors.grey.shade500,
                                              ),
                                  textAlign: TextAlign.right,
                                  maxLines: 2,
                                  overflow: TextOverflow.ellipsis,
                                ),
                                subtitle: Text(
                                  'ساعت تنظیم: ${timeFormatter.format(DateTime(2000, 1, 1, reminder.time.hour, reminder.time.minute))}',
                                  style:
                                      reminder.isActive
                                          ? theme
                                              .listTileTheme
                                              .subtitleTextStyle
                                          : theme
                                              .listTileTheme
                                              .subtitleTextStyle
                                              ?.copyWith(
                                                color: Colors.grey.shade400,
                                                decoration:
                                                    TextDecoration.lineThrough,
                                                decorationColor:
                                                    Colors.grey.shade400,
                                              ),
                                  textAlign: TextAlign.right,
                                ),
                                trailing: Icon(
                                  Icons.drag_indicator_rounded,
                                  color: Colors.grey.shade300,
                                  semanticLabel:
                                      "برای ویرایش یا حذف، به طرفین بکشید",
                                ),
                              ),
                            ),
                          ),
                        ),
                      ),
                    );
                  },
                ),
              ),
    );
  }
}

// --- صفحه تنظیمات ---
class SettingsScreen extends StatelessWidget {
  const SettingsScreen({Key? key}) : super(key: key);

  void _showAboutDialog(BuildContext context) {
    final theme = Theme.of(context);
    showDialog(
      context: context,
      builder:
          (ctx) => FadeIn(
            duration: Duration(milliseconds: 300),
            child: AlertDialog(
              title: Row(
                mainAxisAlignment: MainAxisAlignment.end, // راست چین کردن عنوان
                children: [
                  Text('درباره برنامه "سلامتی من"'),
                  SizedBox(width: 10),
                  Icon(
                    Icons.health_and_safety_outlined,
                    color: theme.primaryColor,
                  ),
                ],
              ),
              content: SingleChildScrollView(
                child: ListBody(
                  children: <Widget>[
                    Text(
                      'این برنامه با هدف کمک به شما برای پیگیری و بهبود عادات سلامتی روزانه طراحی شده است.',
                      textAlign: TextAlign.justify,
                      style: theme.dialogTheme.contentTextStyle,
                    ),
                    SizedBox(height: 16),
                    Text(
                      'توسعه دهندگان:',
                      style: theme.textTheme.titleSmall?.copyWith(
                        fontWeight: FontWeight.bold,
                        color: theme.colorScheme.secondary,
                      ),
                      textAlign: TextAlign.right,
                    ),
                    SizedBox(height: 6),
                    Text(
                      '• علی اصغر راستگو\n• عرفان قاسمی\n• ابوالفضل داوری\n• صادق پریزادان\n• مهدی حبیبی',
                      textAlign: TextAlign.right,
                      style: theme.dialogTheme.contentTextStyle?.copyWith(
                        height: 1.7,
                        fontSize: 14.5,
                      ),
                    ),
                    SizedBox(height: 20),
                    Text(
                      "نسخه برنامه: 1.0.1",
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        color: Colors.grey.shade500,
                        fontSize: 12,
                      ),
                    ), // نسخه را آپدیت کنید
                  ],
                ),
              ),
              actionsAlignment: MainAxisAlignment.center,
              actions: [
                ElevatedButton.icon(
                  icon: Icon(Icons.close_rounded, size: 18),
                  label: Text('فهمیدم، متشکرم!'),
                  onPressed: () => Navigator.of(ctx).pop(),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: theme.primaryColor.withOpacity(0.1),
                    foregroundColor: theme.primaryColor,
                    elevation: 0,
                  ),
                ),
              ],
            ),
          ),
    );
  }

  Widget _buildSettingsTile(
    BuildContext context, {
    required IconData icon,
    required String title,
    String? subtitle,
    required VoidCallback onTap,
    required int delay,
    Widget? trailing,
  }) {
    final theme = Theme.of(context);
    return FadeInRight(
      delay: Duration(milliseconds: delay),
      duration: Duration(milliseconds: 400),
      child: Card(
        elevation: 1,
        margin: EdgeInsets.symmetric(horizontal: 16, vertical: 6),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        child: ListTile(
          leading: CircleAvatar(
            radius: 20,
            backgroundColor: theme.primaryColor.withOpacity(0.08),
            child: Icon(icon, color: theme.primaryColor, size: 21),
          ),
          title: Text(
            title,
            textAlign: TextAlign.right,
            style: theme.textTheme.titleMedium?.copyWith(fontSize: 15.5),
          ),
          subtitle:
              subtitle != null
                  ? Text(
                    subtitle,
                    textAlign: TextAlign.right,
                    style: theme.textTheme.bodySmall?.copyWith(
                      fontSize: 12.5,
                      color: Colors.grey.shade600,
                    ),
                  )
                  : null,
          trailing:
              trailing ??
              Icon(
                Icons.arrow_forward_ios_rounded,
                size: 16,
                color: Colors.grey.shade400,
              ),
          onTap: () {
            HapticFeedback.lightImpact();
            onTap();
          },
          contentPadding: EdgeInsetsDirectional.fromSTEB(16, 8, 12, 8),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    int animationDelay = 200;
    return Scaffold(
      appBar: AppBar(
        title: FadeInDown(
          duration: Duration(milliseconds: 500),
          child: Text('تنظیمات و بیشتر'),
        ),
      ),
      body: ListView(
        padding: EdgeInsets.only(top: 12),
        children: [
          _buildSettingsTile(
            context,
            icon: Icons.info_outline_rounded,
            title: 'درباره برنامه و تیم توسعه',
            subtitle: 'اطلاعات بیشتر در مورد این اپلیکیشن',
            onTap: () => _showAboutDialog(context),
            delay: animationDelay,
          ),
          _buildSettingsTile(
            context,
            icon: Icons.shield_outlined,
            title: 'سیاست حفظ حریم خصوصی',
            subtitle: 'نحوه مدیریت داده‌های شما (نمونه)',
            onTap: () {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text(
                    'صفحه سیاست حفظ حریم خصوصی باز می‌شود.',
                    textAlign: TextAlign.right,
                  ),
                ),
              );
            },
            delay: animationDelay += 100,
          ),
          _buildSettingsTile(
            context,
            icon: Icons.star_border_rounded,
            title: 'به برنامه امتیاز دهید (نمونه)',
            subtitle: 'نظر شما برای ما ارزشمند است',
            onTap: () {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text(
                    'صفحه فروشگاه برای امتیازدهی باز می‌شود.',
                    textAlign: TextAlign.right,
                  ),
                ),
              );
            },
            delay: animationDelay += 100,
          ),
          _buildSettingsTile(
            context,
            icon: Icons.share_outlined,
            title: 'معرفی برنامه به دوستان (نمونه)',
            subtitle: 'کمک به رشد جامعه سلامتی ما',
            onTap: () {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text(
                    'قابلیت اشتراک گذاری فعال می‌شود.',
                    textAlign: TextAlign.right,
                  ),
                ),
              );
            },
            delay: animationDelay += 100,
          ),
        ],
      ),
    );
  }
}
