import 'package:flutter/material.dart';
import 'dart:math' as math;
import 'package:google_fonts/google_fonts.dart';
import 'dart:async';
// import 'package:flutter/scheduler.dart' show timeDilation;

// Global Theme Notifier
final ThemeNotifier themeNotifier = ThemeNotifier();

void main() {
  // timeDilation = 2.0; // Optional: Slow down animations
  runApp(
    ChangeNotifierProvider(
      create: (_) => themeNotifier,
      child: MyApp(),
    ),
  );
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Consumer<ThemeNotifier>(
      builder: (context, notifier, child) {
        return MaterialApp(
          title: 'سلامت یار نهایی',
          debugShowCheckedModeBanner: false,
          theme: AppTheme.lightTheme,
          darkTheme: AppTheme.darkTheme,
          themeMode: notifier.themeMode,
          home: HealthDashboardScreen(),
        );
      },
    );
  }
}

// --- Theme Management ---
class ThemeNotifier extends ChangeNotifier {
  ThemeMode _themeMode = ThemeMode.system; // Default to system theme

  ThemeMode get themeMode => _themeMode;

  void setThemeMode(ThemeMode mode) {
    _themeMode = mode;
    notifyListeners();
  }
}

class AppTheme {
  static final Color _lightPrimaryColor = Color(0xFF64B5F6); // Sky Blue
  static final Color _lightAccentColor = Color(0xFFFFB74D); // Orange Pastel
  static final Color _lightBackgroundColor = Color(0xFFF0F2F5); // Lighter Grey
  static final Color _lightCardColor = Colors.white;

  static final Color _darkPrimaryColor = Color(0xFF81C784); // Soft Green
  static final Color _darkAccentColor = Color(0xFFF06292); // Soft Pink
  static final Color _darkBackgroundColor = Color(0xFF1A1A1A); // Very Dark Grey
  static final Color _darkCardColor = Color(0xFF262626); // Darker Grey

  static final ThemeData lightTheme = ThemeData(
    brightness: Brightness.light,
    primaryColor: _lightPrimaryColor,
    scaffoldBackgroundColor: _lightBackgroundColor,
    colorScheme: ColorScheme.light(
      primary: _lightPrimaryColor,
      secondary: _lightAccentColor,
      background: _lightBackgroundColor,
      surface: _lightCardColor,
      onPrimary: Colors.white,
      onSecondary: Colors.black,
      onBackground: Colors.black87,
      onSurface: Colors.black87,
      error: Colors.redAccent,
    ),
    textTheme: GoogleFonts.vazirmatnTextTheme(
        ThemeData.light().textTheme.apply(bodyColor: Colors.black87, displayColor: Colors.black87)),
    appBarTheme: AppBarTheme(
      backgroundColor: _lightPrimaryColor,
      foregroundColor: Colors.white,
      elevation: 1.0,
      titleTextStyle: GoogleFonts.lalezar(fontSize: 28, color: Colors.white),
    ),
    cardTheme: CardThemeData(
      elevation: 3.0,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16.0)),
      margin: const EdgeInsets.symmetric(vertical: 8.0, horizontal: 4.0),
      color: _lightCardColor,
    ),
    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12.0)),
        padding: EdgeInsets.symmetric(horizontal: 20, vertical: 12),
      ),
    ),
    textButtonTheme: TextButtonThemeData(
      style: TextButton.styleFrom(foregroundColor: _lightPrimaryColor)
    ),
    iconTheme: IconThemeData(color: _lightPrimaryColor),
  );

  static final ThemeData darkTheme = ThemeData(
    brightness: Brightness.dark,
    primaryColor: _darkPrimaryColor,
    scaffoldBackgroundColor: _darkBackgroundColor,
    colorScheme: ColorScheme.dark(
      primary: _darkPrimaryColor,
      secondary: _darkAccentColor,
      background: _darkBackgroundColor,
      surface: _darkCardColor,
      onPrimary: Colors.black,
      onSecondary: Colors.white,
      onBackground: Colors.white.withOpacity(0.87),
      onSurface: Colors.white.withOpacity(0.87),
      error: Colors.red.shade300,
    ),
    textTheme: GoogleFonts.vazirmatnTextTheme(
        ThemeData.dark().textTheme.apply(bodyColor: Colors.white.withOpacity(0.87), displayColor: Colors.white.withOpacity(0.87))),
    appBarTheme: AppBarTheme(
      backgroundColor: _darkCardColor, // Darker AppBar for Dark Theme
      foregroundColor: _darkPrimaryColor,
      elevation: 1.0,
      titleTextStyle: GoogleFonts.lalezar(fontSize: 28, color: _darkPrimaryColor),
    ),
    cardTheme: CardThemeData(
      elevation: 2.0,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16.0)),
      margin: const EdgeInsets.symmetric(vertical: 8.0, horizontal: 4.0),
      color: _darkCardColor,
    ),
     elevatedButtonTheme: ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12.0)),
        padding: EdgeInsets.symmetric(horizontal: 20, vertical: 12),
      ),
    ),
    textButtonTheme: TextButtonThemeData(
      style: TextButton.styleFrom(foregroundColor: _darkPrimaryColor)
    ),
    iconTheme: IconThemeData(color: _darkPrimaryColor),
  );
}


// --- Enums & Data Models (similar to before, adapted for new theme) ---
enum Mood {
  elated('🥳', Color(0xFFFFD700), "سرخوش", Color(0xFFFFF9C4), Color(0xFF332E00)), // Dark BG tint
  happy('😄', Color(0xFF66BB6A), "خوشحال", Color(0xFFE8F5E9), Color(0xFF102411)),
  good('😊', Color(0xFF9CCC65), "خوب", Color(0xFFF1F8E9), Color(0xFF1A2D11)),
  neutral('😐', Color(0xFFFFCA28), "معمولی", Color(0xFFFFFDE7), Color(0xFF332A05)),
  sad('😟', Color(0xFF29B6F6), "ناراحت", Color(0xFFE1F5FE), Color(0xFF052533)),
  stressed('😫', Color(0xFFEF5350), "پراسترس", Color(0xFFFFEBEE), Color(0xFF30100F));

  const Mood(this.emoji, this.solidColor, this.label, this.lightThemeBgTint, this.darkThemeBgTint);
  final String emoji;
  final Color solidColor;
  final String label;
  final Color lightThemeBgTint;
  final Color darkThemeBgTint;

  Color getBgTint(Brightness brightness) => brightness == Brightness.light ? lightThemeBgTint : darkThemeBgTint;
}

enum AchievementId { waterWeek, mindfulMoments, calorieConqueror, consistentSleep }
class Achievement {
  final AchievementId id;
  final String name;
  final String description;
  final IconData icon;
  bool unlocked;
  final Color color; // This color might need to be adapted for dark/light themes or use a theme-aware color

  Achievement({
    required this.id,
    required this.name,
    required this.description,
    required this.icon,
    this.unlocked = false,
    required this.color,
  });
}


// --- Main Screen ---
class HealthDashboardScreen extends StatefulWidget {
  @override
  _HealthDashboardScreenState createState() => _HealthDashboardScreenState();
}

class _HealthDashboardScreenState extends State<HealthDashboardScreen> with TickerProviderStateMixin {
  //State variables (similar to previous)
    double _currentWaterIntake = 0.0;
    final double _waterGoal = 2.0;
    final double _cupSize = 0.25;
    bool _waterGoalCelebration = false;
    int _waterStreak = 0;

    int _currentTipIndex = 0;
    final List<String> _healthTips = [
      "هر روز برای دقایقی کوتاه حرکات کششی انجام دهید.",
      "نوشیدن یک لیوان آب ولرم با لیمو در اول صبح معجزه می‌کند.",
      "در پخت‌وپز از روغن‌های سالم مانند روغن زیتون استفاده کنید.",
      "برای سلامت روان خود، زمانی را به سرگرمی‌های مورد علاقه‌تان اختصاص دهید.",
      "مصرف فیبر کافی (میوه، سبزیجات، غلات کامل) برای گوارش ضروری است.",
      "لبخند بزنید! خنده باعث ترشح اندورفین و کاهش استرس می‌شود.",
      "ارتباط با طبیعت و گذراندن وقت در فضای باز، روحیه را تقویت می‌کند.",
      "برای بهبود تمرکز، تکنیک پومودورو را امتحان کنید (۲۵ دقیقه کار، ۵ دقیقه استراحت).",
      "روزانه حداقل ۱۵ دقیقه در معرض نور خورشید قرار بگیرید (با رعایت نکات ایمنی)."
    ];

    Mood _currentMood = Mood.neutral;
    late AnimationController _moodBgController;
    late Animation<Color?> _moodBgAnimation;
    Color _previousMoodBgColor = Mood.neutral.getBgTint(Brightness.light).withOpacity(0.5); // Initial

    // Calorie Tracker - Using TextEditingControllers for robust input
    final Map<String, TextEditingController> _calorieControllers = {
      'صبحانه': TextEditingController(),
      'ناهار': TextEditingController(),
      'شام': TextEditingController(),
      'میان‌وعده': TextEditingController(),
    };
    final Map<String, double> _calorieValues = {
      'صبحانه': 0.0, 'ناهار': 0.0, 'شام': 0.0, 'میان‌وعده': 0.0,
    };
    final double _calorieGoal = 2000;


    late AnimationController _breathingController;
    late Animation<double> _breathingAnimation; // For circle size
    late Animation<double> _breathingOpacityAnimation; // For pulsing opacity
    bool _isBreathing = false;
    String _breathingPhase = "شروع";
    Timer? _breathingTimer;
    int _breathingCycleCount = 0;


    TimeOfDay? _bedTime;
    TimeOfDay? _wakeTime;
    double? _sleepDuration;
    int _sleepStreak = 0;


    Map<AchievementId, Achievement> _achievements = {};


    List<AnimationController> _cardEntryControllers = [];
    final int _totalAnimatedCards = 6; // Number of cards to animate

  @override
  void initState() {
    super.initState();
    _initializeAchievements();
    _currentTipIndex = math.Random().nextInt(_healthTips.length);
    _currentMood = Mood.values[math.Random().nextInt(Mood.values.length)];
    
    // Initial mood background color based on current theme (won't update on theme change until mood changes)
    WidgetsBinding.instance.addPostFrameCallback((_) {
        final Brightness currentBrightness = Theme.of(context).brightness;
        _previousMoodBgColor = _currentMood.getBgTint(currentBrightness).withOpacity(0.5);
         _moodBgController = AnimationController(vsync: this, duration: const Duration(milliseconds: 1200));
        _updateMoodBackground(_currentMood, animate: false); // Set initial without animation from transparent
    });


    _breathingController = AnimationController(vsync: this, duration: const Duration(seconds: 4));
    _breathingAnimation = Tween<double>(begin: 0.65, end: 1.0).animate(
        CurvedAnimation(parent: _breathingController, curve: Curves.easeInOutCubicEmphasized));
    _breathingOpacityAnimation = TweenSequence<double>([
        TweenSequenceItem(tween: Tween(begin: 0.7, end: 1.0), weight: 50),
        TweenSequenceItem(tween: Tween(begin: 1.0, end: 0.7), weight: 50),
    ]).animate(CurvedAnimation(parent: _breathingController, curve: Curves.easeInOut));


    _cardEntryControllers = List.generate(
        _totalAnimatedCards,
        (index) => AnimationController(vsync: this, duration: Duration(milliseconds: 500 + (index * 50))));

    _startCardAnimations();

    // Load dummy streak for demo
    _waterStreak = 3;
    _sleepStreak = 2;
    _checkAchievements();
  }

  void _startCardAnimations() {
    for (int i = 0; i < _cardEntryControllers.length; i++) {
      Future.delayed(Duration(milliseconds: 100 * i), () {
        if (mounted) _cardEntryControllers[i].forward();
      });
    }
  }


  void _initializeAchievements() {
    _achievements = {
      AchievementId.waterWeek: Achievement(id: AchievementId.waterWeek, name: "قهرمان آبرسانی", description: "۷ روز متوالی هدف آب را کامل کردید!", icon: Icons.local_drink_rounded, color: Colors.blue.shade300),
      AchievementId.mindfulMoments: Achievement(id: AchievementId.mindfulMoments, name: "استاد ذهن آگاهی", description: "۵ جلسه تمرین تنفس انجام دادید.", icon: Icons.self_improvement_rounded, color: Colors.purple.shade300),
      AchievementId.calorieConqueror: Achievement(id: AchievementId.calorieConqueror, name: "فاتح کالری", description: "به هدف کالری روزانه رسیدی!", icon: Icons.restaurant_menu_rounded, color: Colors.orange.shade300),
      AchievementId.consistentSleep: Achievement(id: AchievementId.consistentSleep, name: "خواب منظم", description: "۳ شب متوالی ۷-۹ ساعت خوابیدی.", icon: Icons.bedtime_rounded, color: Colors.indigo.shade300),
    };
  }


  @override
  void dispose() {
    _moodBgController.dispose();
    _breathingController.dispose();
    _breathingTimer?.cancel();
    _cardEntryControllers.forEach((controller) => controller.dispose());
    _calorieControllers.forEach((_, controller) => controller.dispose());
    super.dispose();
  }

  // --- State Update Methods ---
  void _updateMoodBackground(Mood newMood, {bool animate = true}) {
    if (!mounted || !_moodBgController.isInitialized) return;
    final Brightness currentBrightness = Theme.of(context).brightness;
    _previousMoodBgColor = _moodBgAnimation?.value ?? _currentMood.getBgTint(currentBrightness).withOpacity(0.0); // Start from transparent if no previous

    _moodBgAnimation = ColorTween(
            begin: _previousMoodBgColor,
            end: newMood.getBgTint(currentBrightness).withOpacity(0.65) // More intense tint
          )
        .animate(CurvedAnimation(parent: _moodBgController, curve: Curves.easeInOutQuart));
    
    if (animate) {
      _moodBgController.forward(from: 0.0);
    } else {
      _moodBgController.value = 1.0; // Jump to end
    }
  }
  
  void _addWater() {
    setState(() {
      bool wasGoalReached = _currentWaterIntake >= _waterGoal;
      if (_currentWaterIntake < _waterGoal) {
        _currentWaterIntake = (_currentWaterIntake + _cupSize).clamp(0.0, _waterGoal);
      }
      if (_currentWaterIntake >= _waterGoal && !wasGoalReached) {
        _waterGoalCelebration = true;
        _waterStreak++;
        _checkAchievements();
        Future.delayed(const Duration(seconds: 3), () {
          if (mounted) setState(() => _waterGoalCelebration = false);
        });
      }
    });
  }
  void _resetWater() => setState(() { _currentWaterIntake = 0.0; _waterGoalCelebration = false;});
  
  void _updateCurrentMood(Mood mood) { // Renamed to avoid conflict with argument name
    setState(() => _currentMood = mood);
    _updateMoodBackground(mood);
  }

  void _updateCalorieValue(String mealType, String value) {
    final double? parsedValue = double.tryParse(value);
    if (parsedValue != null) {
      setState(() {
        _calorieValues[mealType] = parsedValue.clamp(0, 5000);
        _checkAchievements();
      });
    } else if (value.isEmpty) {
         setState(() {
            _calorieValues[mealType] = 0.0;
             _checkAchievements();
         });
    }
  }
  double get _totalCalories => _calorieValues.values.fold(0.0, (sum, item) => sum + item);

  void _startStopBreathing() {
    setState(() {
      _isBreathing = !_isBreathing;
      if (_isBreathing) {
        _breathingCycleCount = 0;
        _breathingController.repeat(); // For continuous opacity pulse
        _runBreathingCycle();
      } else {
        _breathingController.stop(); // Stop opacity pulse
        _breathingController.reset(); // Reset size animation
        _breathingTimer?.cancel();
        _breathingPhase = "شروع";
      }
    });
  }

  void _runBreathingCycle() {
    if (!_isBreathing || !mounted) return;
    _breathingPhase = "دم (۴ ثانیه)";
    // Size animation for inhale
    _breathingController.duration = const Duration(seconds: 4); // This duration is for size change
    _breathingController.forward(from:0.0);

    _breathingTimer = Timer(const Duration(seconds: 4), () {
      if (!_isBreathing || !mounted) return;
      _breathingPhase = "نگهدار (۴ ثانیه)";
       if (mounted) setState((){});
      // Hold size, opacity continues pulsing via repeat()

      _breathingTimer = Timer(const Duration(seconds: 4), () {
        if (!_isBreathing || !mounted) return;
        _breathingPhase = "بازدم (۴ ثانیه)";
        // Size animation for exhale
         _breathingController.duration = const Duration(seconds: 4);
        _breathingController.reverse(from:1.0);
        
        _breathingTimer = Timer(const Duration(seconds: 4), () {
          if (!_isBreathing || !mounted) return;
          _breathingPhase = "نگهدار (۴ ثانیه)";
          if (mounted) setState((){});
          // Hold size

          _breathingTimer = Timer(const Duration(seconds: 4), () {
            if (!_isBreathing || !mounted) return;
             _breathingCycleCount++;
            _checkAchievements();
            _runBreathingCycle(); 
          });
        });
      });
    });
  }

  Future<void> _selectTime(BuildContext context, bool isBedTime) async {
    final theme = Theme.of(context);
    final TimeOfDay? picked = await showTimePicker(
      context: context,
      initialTime: isBedTime ? _bedTime ?? const TimeOfDay(hour: 22, minute: 0) : _wakeTime ?? const TimeOfDay(hour: 7, minute: 0),
      builder: (context, child){
        return Theme( // Apply theme colors to time picker
          data: theme.copyWith(
            timePickerTheme: theme.timePickerTheme.copyWith(
               backgroundColor: theme.colorScheme.surface,
               dialHandColor: theme.colorScheme.primary,
               hourMinuteTextColor: theme.colorScheme.onSurface,
               entryModeIconColor: theme.colorScheme.primary,
            ),
            textButtonTheme: TextButtonThemeData(
              style: TextButton.styleFrom(foregroundColor: theme.colorScheme.primary),
            ),
          ),
          child: child!,
        );
      }
    );
    if (picked != null) {
      setState(() {
        if (isBedTime) _bedTime = picked;
        else _wakeTime = picked;
        _calculateSleepDuration();
      });
    }
  }

  void _calculateSleepDuration() {
    if (_bedTime != null && _wakeTime != null) {
      final now = DateTime.now();
      DateTime bedDateTime = DateTime(now.year, now.month, now.day, _bedTime!.hour, _bedTime!.minute);
      DateTime wakeDateTime = DateTime(now.year, now.month, now.day, _wakeTime!.hour, _wakeTime!.minute);

      if (wakeDateTime.isBefore(bedDateTime) || wakeDateTime.isAtSameMomentAs(bedDateTime)) {
        wakeDateTime = wakeDateTime.add(const Duration(days: 1));
      }
      _sleepDuration = wakeDateTime.difference(bedDateTime).inMinutes / 60.0;
      if (_sleepDuration != null && _sleepDuration! >= 7 && _sleepDuration! <=9) {
        _sleepStreak++;
      } else {
        _sleepStreak = 0; // Reset streak if not within range
      }
    } else {
      _sleepDuration = null;
      _sleepStreak = 0;
    }
     _checkAchievements();
  }

  void _checkAchievements() {
    if (!mounted) return;
    // Water Streak
    if (_waterStreak >= 7 && !_achievements[AchievementId.waterWeek]!.unlocked) {
      setState(()  => _achievements[AchievementId.waterWeek]!.unlocked = true);
      _showAchievementSnackbar(_achievements[AchievementId.waterWeek]!);
    }
    // Mindful Moments
    if (_breathingCycleCount >= 5 && !_achievements[AchievementId.mindfulMoments]!.unlocked) {
       setState(() => _achievements[AchievementId.mindfulMoments]!.unlocked = true);
      _showAchievementSnackbar(_achievements[AchievementId.mindfulMoments]!);
    }
    // Calorie Conqueror
    if ((_totalCalories - _calorieGoal).abs() < _calorieGoal * 0.1 && _totalCalories > 0 && !_achievements[AchievementId.calorieConqueror]!.unlocked) {
        setState(() => _achievements[AchievementId.calorieConqueror]!.unlocked = true);
        _showAchievementSnackbar(_achievements[AchievementId.calorieConqueror]!);
    }
    // Consistent Sleep
    if (_sleepStreak >= 3 && !_achievements[AchievementId.consistentSleep]!.unlocked) {
        setState(() => _achievements[AchievementId.consistentSleep]!.unlocked = true);
        _showAchievementSnackbar(_achievements[AchievementId.consistentSleep]!);
    }
  }

  void _showAchievementSnackbar(Achievement achievement) {
    if (!mounted) return;
    final theme = Theme.of(context);
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        backgroundColor: achievement.color.withOpacity(0.95),
        duration: const Duration(seconds: 4),
        content: Row(
          children: [
            Icon(achievement.icon, color: Colors.white, size: 30),
            const SizedBox(width: 15),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text("دستاورد جدید!", style: GoogleFonts.vazirmatn(fontWeight: FontWeight.bold, color: Colors.white, fontSize: 17)),
                  Text(achievement.name, style: GoogleFonts.vazirmatn(color: Colors.white.withOpacity(0.95), fontSize: 15)),
                ],
              ),
            ),
          ],
        ),
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        margin: const EdgeInsets.symmetric(horizontal: 12, vertical:20),
      )
    );
  }

  // --- UI Build Methods ---
  // Generic Animated Card Wrapper
  Widget _AnimatedFeatureCard({
    required Widget child,
    required AnimationController controller,
    double initialOffsetY = 40.0, // Reduced for smoother entry
    double initialScale = 0.95,  // Start slightly smaller
  }) {
    final animation = CurvedAnimation(parent: controller, curve: Curves.easeOutCubic); // Smoother curve
    return ScaleTransition(
      scale: Tween<double>(begin: initialScale, end: 1.0).animate(animation),
      child: FadeTransition(
        opacity: animation, // Fade in
        child: SlideTransition(
          position: Tween<Offset>(begin: Offset(0, initialOffsetY / MediaQuery.of(context).size.height), end: Offset.zero).animate(animation),
          child: child,
        ),
      ),
    );
  }

 // Animated Button
  Widget _AnimatedButton({
    required VoidCallback onPressed,
    required Widget child,
    required Color backgroundColor,
    required Color foregroundColor,
    double? elevation,
    EdgeInsets? padding,
  }) {
    return _AnimatedInteractiveContainer(
      onTap: onPressed,
      baseColor: backgroundColor,
      child: Padding(
        padding: padding ?? const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
        child: DefaultTextStyle(
          style: GoogleFonts.vazirmatn(color: foregroundColor, fontWeight: FontWeight.bold),
          child: child,
        ),
      ),
    );
  }

  // Helper for animated interactive container (used by buttons)
  Widget _AnimatedInteractiveContainer({
    required Widget child,
    required Color baseColor,
    VoidCallback? onTap,
    double borderRadius = 12.0,
  }) {
    return TweenAnimationBuilder<double>(
      tween: Tween<double>(begin: 0.0, end: 1.0), // Dummy tween, we control color internally
      duration: const Duration(milliseconds: 200),
      builder: (context, value, _) { // `value` is not directly used for color here
        return GestureDetector(
          onTapDown: (_) => setState(() {}), // Trigger rebuild for pressed state
          onTapUp: (_) => setState(() {}),   // Trigger rebuild for normal state
          onTapCancel: () => setState(() {}),// Trigger rebuild
          onTap: onTap,
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 150),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(borderRadius),
              gradient: LinearGradient( // Subtle gradient
                colors: [
                   HSLColor.fromColor(baseColor).withLightness((HSLColor.fromColor(baseColor).lightness * 0.95).clamp(0.0,1.0)).toColor(),
                   baseColor,
                ],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              boxShadow: [
                BoxShadow(
                  color: baseColor.withOpacity(0.3),
                  blurRadius: 5, // Softer shadow
                  offset: Offset(0, 2),
                )
              ],
            ),
            child: child,
          ),
        );
      },
    );
  }


  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDarkMode = theme.brightness == Brightness.dark;

    // Update mood background color if theme changes (and mood background controller is initialized)
    if (_moodBgController.isInitialized) {
        WidgetsBinding.instance.addPostFrameCallback((_) {
            if (mounted && (_moodBgAnimation == null || _moodBgAnimation!.value != _currentMood.getBgTint(theme.brightness).withOpacity(0.65))) {
                _updateMoodBackground(_currentMood, animate: true);
            }
        });
    }


    return Scaffold( // No AnimatedBuilder here as Scaffold BG is now theme-dependent
      appBar: AppBar(
        title: Text('سلامت یار نهایی'),
        centerTitle: true,
        actions: [
          IconButton(
            icon: Icon(isDarkMode ? Icons.light_mode_rounded : Icons.dark_mode_rounded, color: theme.appBarTheme.foregroundColor),
            tooltip: isDarkMode ? "تم روشن" : "تم تاریک",
            onPressed: () {
              themeNotifier.setThemeMode(isDarkMode ? ThemeMode.light : ThemeMode.dark);
            },
          )
        ],
      ),
      body: Container( // Animated background for mood
         decoration: BoxDecoration(
            gradient: LinearGradient(
                colors: [
                    theme.scaffoldBackgroundColor,
                    _moodBgAnimation?.value ?? theme.scaffoldBackgroundColor,
                ],
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                stops: [0.5, 1.0]
            )
         ),
        child: Stack(
          children: [
            ListView(
              padding: const EdgeInsets.fromLTRB(12.0, 12.0, 12.0, 90.0),
              children: <Widget>[
                _AnimatedFeatureCard(controller: _cardEntryControllers[0], child: _buildWaterTrackerCard(theme)),
                _AnimatedFeatureCard(controller: _cardEntryControllers[1], child: _buildHealthTipCard(theme)),
                _AnimatedFeatureCard(controller: _cardEntryControllers[2], child: _buildMoodSelectorCard(theme)),
                _AnimatedFeatureCard(controller: _cardEntryControllers[3], child: _buildCalorieTrackerCard(theme)),
                _AnimatedFeatureCard(controller: _cardEntryControllers[4], child: _buildBreathingExerciseCard(theme)),
                _AnimatedFeatureCard(controller: _cardEntryControllers[5], child: _buildSleepLogCard(theme)),
                _buildAchievementsSection(theme),
                const SizedBox(height: 30),
              ],
            ),
            if (_waterGoalCelebration) _buildConfettiOverlay(colors: [Colors.blue.shade300, Colors.lightBlue.shade200, Colors.teal.shade200]),
          ],
        ),
      ),
    );
  }

  Widget _buildCardTitle(String title, IconData icon, ThemeData theme) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12.0, top: 8.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(icon, color: theme.colorScheme.primary, size: 26), // Use colorScheme for consistency
          const SizedBox(width: 10),
          Text(
            title,
            style: GoogleFonts.vazirmatn(fontSize: 21, fontWeight: FontWeight.w600, color: theme.colorScheme.primary),
          ),
        ],
      ),
    );
  }

  Widget _buildWaterTrackerCard(ThemeData theme) {
    double percentage = (_currentWaterIntake / _waterGoal).clamp(0.0, 1.0);
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            _buildCardTitle("💧 ردیاب آب", Icons.opacity_rounded, theme),
            Text(
              '${(_currentWaterIntake * 1000).toStringAsFixed(0)} / ${(_waterGoal * 1000).toStringAsFixed(0)} میلی‌لیتر',
              style: GoogleFonts.titilliumWeb(fontSize: 18, fontWeight: FontWeight.bold, color: theme.colorScheme.onSurface.withOpacity(0.8)),
            ),
            const SizedBox(height: 18),
            SizedBox(
              height: 170, // Slightly larger
              width: 120,
              child: CustomPaint( // Assuming WaterGlassPainter is defined elsewhere and works
                painter: WaterGlassPainter(
                    percentage: percentage,
                    moodColor: _currentMood.solidColor, // Base color for water
                    animationValue: DateTime.now().millisecondsSinceEpoch / 1500.0, // Faster wave
                    themeBrightness: theme.brightness, // Pass theme brightness
                ),
                child: Center(
                  child: Text(
                    '${(percentage * 100).toStringAsFixed(0)}%',
                    style: GoogleFonts.orbitron(
                        fontSize: 28, // Larger percentage
                        fontWeight: FontWeight.bold,
                        color: percentage > 0.55 ? (_currentMood.solidColor.computeLuminance() > 0.5 ? Colors.black.withOpacity(0.7) : Colors.white.withOpacity(0.85)) : theme.colorScheme.primary,
                        shadows: [Shadow(color: Colors.black.withOpacity(0.2), blurRadius: 2, offset: Offset(1,1))]
                        ),
                  ),
                ),
              ),
            ),
            const SizedBox(height: 22),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                _AnimatedButton(
                  onPressed: _addWater,
                  backgroundColor: theme.colorScheme.primary.withOpacity(0.8),
                  foregroundColor: theme.colorScheme.onPrimary,
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Icon(Icons.add_circle_outline_rounded, size: 20),
                      const SizedBox(width: 8),
                      Text('یک لیوان (${(_cupSize * 1000).toStringAsFixed(0)}ml)', style: GoogleFonts.vazirmatn(fontSize: 13.5)),
                    ],
                  ),
                ),
                CircleAvatar( // Reset button with softer look
                  backgroundColor: theme.colorScheme.secondary.withOpacity(0.15),
                  child: IconButton(
                    icon: Icon(Icons.refresh_rounded, size: 26, color: theme.colorScheme.secondary),
                    onPressed: _resetWater,
                    tooltip: "تنظیم مجدد",
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildHealthTipCard(ThemeData theme) {
    return Card(
      color: theme.colorScheme.secondary.withOpacity(theme.brightness == Brightness.light ? 0.1 : 0.2), // Subtle background based on theme
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            _buildCardTitle("💡 نکته سلامتی", Icons.lightbulb_outline_rounded, theme),
            AnimatedSwitcher(
              duration: const Duration(milliseconds: 650), // Slightly longer for smoother feel
              transitionBuilder: (Widget child, Animation<double> animation) {
                final offsetAnimation = Tween<Offset>(begin: const Offset(0.0, 0.4), end: Offset.zero)
                    .animate(CurvedAnimation(parent: animation, curve: Curves.elasticOut. ХабаровскEaseInOutCubic)); // Smoother elastic curve
                final scaleAnimation = Tween<double>(begin: 0.95, end: 1.0).animate(CurvedAnimation(parent: animation, curve: Curves.easeOutCubic));
                return FadeTransition(opacity: animation, child: ScaleTransition(scale: scaleAnimation, child:SlideTransition(position: offsetAnimation, child: child)));
              },
              child: Text(
                _healthTips[_currentTipIndex],
                key: ValueKey<int>(_currentTipIndex),
                textAlign: TextAlign.center,
                style: GoogleFonts.vazirmatn(fontSize: 16.5, color: theme.colorScheme.onSurface.withOpacity(0.9), height: 1.65, fontWeight: FontWeight.w500),
              ),
            ),
            const SizedBox(height: 18),
            _AnimatedButton(
              onPressed: () => setState(() => _currentTipIndex = (_currentTipIndex + 1) % _healthTips.length),
              backgroundColor: theme.colorScheme.secondary,
              foregroundColor: theme.colorScheme.onSecondary,
              child: Text('نکته بعدی'),
            ),
          ],
        ),
      ),
    );
  }

    Widget _buildMoodSelectorCard(ThemeData theme) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            _buildCardTitle("😊 حس و حال", Icons.sentiment_very_satisfied_rounded, theme), // Changed icon
            Text(_currentMood.label, style: GoogleFonts.vazirmatn(
                fontSize: 18, // Larger
                color: _currentMood.solidColor.computeLuminance() > 0.5 && theme.brightness == Brightness.dark ?
                       HSLColor.fromColor(_currentMood.solidColor).withLightness(0.8).toColor() : // Lighter for dark bg if mood color is light
                       HSLColor.fromColor(_currentMood.solidColor).withLightness((HSLColor.fromColor(_currentMood.solidColor).lightness * (theme.brightness == Brightness.light ? 0.6 : 0.75)).clamp(0.0,1.0)).toColor(),
                fontWeight: FontWeight.bold)),
            const SizedBox(height: 15),
            Wrap(
              alignment: WrapAlignment.center,
              spacing: 12.0, // Increased spacing
              runSpacing: 12.0,
              children: Mood.values.map((mood) {
                bool isSelected = _currentMood == mood;
                return GestureDetector(
                  onTap: () => _updateCurrentMood(mood),
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 350), // Slightly longer animation
                    curve: Curves.elasticOut, // Funky curve
                    padding: EdgeInsets.all(isSelected ? 13 : 9), // Larger padding when selected
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: isSelected ? mood.solidColor.withOpacity(0.3) : theme.colorScheme.surfaceVariant.withOpacity(0.3),
                      border: Border.all(
                          color: isSelected ? mood.solidColor : theme.dividerColor,
                          width: isSelected ? 3.5 : 1.5), // Thicker border when selected
                      boxShadow: isSelected
                          ? [BoxShadow(color: mood.solidColor.withOpacity(0.5), blurRadius: 10.0, spreadRadius:1.0, offset: Offset(0,1))]
                          : [BoxShadow(color: theme.shadowColor.withOpacity(0.1), blurRadius: 3.0)],
                    ),
                    child: Text(mood.emoji, style: TextStyle(fontSize: isSelected ? 36 : 30)), // Larger emoji when selected
                  ),
                );
              }).toList(),
            ),
          ],
        ),
      ),
    );
  }


  Widget _buildCalorieTrackerCard(ThemeData theme) {
    double progress = _totalCalories / _calorieGoal;
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            _buildCardTitle("🔥 ردیاب کالری", Icons.local_fire_department_rounded, theme),
            const SizedBox(height: 12),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 10.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text("کل: ${_totalCalories.toStringAsFixed(0)} کالری", style: GoogleFonts.vazirmatn(fontSize: 16.5, fontWeight: FontWeight.bold, color: theme.colorScheme.onSurface)),
                  Text("هدف: ${_calorieGoal.toStringAsFixed(0)}", style: GoogleFonts.vazirmatn(fontSize: 14.5, color: theme.colorScheme.onSurface.withOpacity(0.7))),
                ],
              ),
            ),
            const SizedBox(height: 12),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 8.0),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(12), // More rounded
                child: LinearProgressIndicator(
                  value: progress.isNaN || progress.isInfinite ? 0 : progress.clamp(0.0,1.0),
                  minHeight: 20, // Thicker
                  backgroundColor: theme.colorScheme.primary.withOpacity(0.2),
                  valueColor: AlwaysStoppedAnimation<Color>(theme.colorScheme.primary),
                ),
              ),
            ),
            const SizedBox(height: 18),
            ..._calorieControllers.entries.map((entry) {
                final mealName = entry.key;
                final controller = entry.value;
                return _buildCalorieInputRow(mealName, controller, theme);
            }).toList(),
          ],
        ),
      ),
    );
  }

  Widget _buildCalorieInputRow(String mealName, TextEditingController controller, ThemeData theme) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 5.0),
      child: Row(
        children: [
          Expanded(flex:2, child: Text("$mealName:", style: GoogleFonts.vazirmatn(fontSize: 14.5, color: theme.colorScheme.onSurface.withOpacity(0.9)))),
          Expanded(
            flex: 3,
            child: TextField(
              controller: controller,
              keyboardType: TextInputType.numberWithOptions(decimal: false), // No decimals for calories usually
              textAlign: TextAlign.center,
              style: GoogleFonts.vazirmatn(fontSize: 15, color: theme.colorScheme.onSurface),
              decoration: InputDecoration(
                hintText: "0",
                hintStyle: TextStyle(color: theme.colorScheme.onSurface.withOpacity(0.4)),
                isDense: true,
                contentPadding: const EdgeInsets.symmetric(horizontal:10, vertical: 12),
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(10), borderSide: BorderSide(color: theme.dividerColor)),
                focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(10), borderSide: BorderSide(color: theme.colorScheme.primary, width: 2.0)),
                 filled: true,
                 fillColor: theme.colorScheme.surfaceVariant.withOpacity(0.2),
              ),
              onChanged: (value) => _updateCalorieValue(mealName, value), // Update on change for immediate feedback
              onTapOutside: (_) => FocusScope.of(context).unfocus(),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBreathingExerciseCard(ThemeData theme) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            _buildCardTitle("🧘 تمرین تنفس", Icons.self_improvement_rounded, theme),
            const SizedBox(height: 18),
            AnimatedBuilder( // Combine size and opacity animations
              animation: Listenable.merge([_breathingAnimation, _breathingOpacityAnimation]),
              builder: (context, child) {
                return Opacity(
                  opacity: _isBreathing ? _breathingOpacityAnimation.value : 0.7,
                  child: Container(
                    width: 100 + (30 * _breathingAnimation.value), // Dynamic size
                    height: 100 + (30 * _breathingAnimation.value),
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      gradient: RadialGradient( // More dynamic gradient
                        colors: [
                          theme.colorScheme.primary.withOpacity(0.4 + (0.3 * _breathingOpacityAnimation.value)),
                          theme.colorScheme.primary.withOpacity(0.7 + (0.2 * _breathingOpacityAnimation.value)),
                        ],
                       stops: const [0.2, 1.0],
                        center: Alignment.center,
                      ),
                      boxShadow: [
                        BoxShadow(
                          color: theme.colorScheme.primary.withOpacity(0.25 * _breathingOpacityAnimation.value),
                          blurRadius: 12 + (8 * _breathingAnimation.value), // Dynamic blur
                          spreadRadius: 1 + (1 * _breathingAnimation.value),
                        )
                      ]
                    ),
                  ),
                );
              },
            ),
            const SizedBox(height: 18),
            Text(_breathingPhase, style: GoogleFonts.vazirmatn(fontSize: 17, fontWeight: FontWeight.w600, color: theme.colorScheme.primary)),
            const SizedBox(height: 18),
             _AnimatedButton(
              onPressed: _startStopBreathing,
              backgroundColor: _isBreathing ? theme.colorScheme.secondary : theme.colorScheme.primary,
              foregroundColor: _isBreathing ? theme.colorScheme.onSecondary : theme.colorScheme.onPrimary,
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(_isBreathing ? Icons.stop_circle_outlined : Icons.play_circle_outline_rounded, size: 22),
                  SizedBox(width: 8),
                  Text(_isBreathing ? "توقف" : "شروع تمرین", style: GoogleFonts.vazirmatn(fontSize: 14.5)),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

Widget _buildSleepLogCard(ThemeData theme) {
    String bedTimeText = _bedTime != null ? "${_bedTime!.hour.toString().padLeft(2, '0')}:${_bedTime!.minute.toString().padLeft(2, '0')}" : "انتخاب نشده";
    String wakeTimeText = _wakeTime != null ? "${_wakeTime!.hour.toString().padLeft(2, '0')}:${_wakeTime!.minute.toString().padLeft(2, '0')}" : "انتخاب نشده";
    String durationText = _sleepDuration != null ? "${_sleepDuration!.toStringAsFixed(1)} ساعت" : "محاسبه نشده";

    bool isSleepDataAvailable = _bedTime != null && _wakeTime != null && _sleepDuration != null;

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            _buildCardTitle("😴 ثبت خواب", Icons.bedtime_outline_rounded, theme), // Changed icon
            const SizedBox(height: 12),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                _buildTimePickerButton("زمان خواب:", bedTimeText, () => _selectTime(context, true), theme),
                _buildTimePickerButton("زمان بیداری:", wakeTimeText, () => _selectTime(context, false), theme),
              ],
            ),
            const SizedBox(height: 15),
            AnimatedOpacity( // Animate visibility of duration text
              duration: const Duration(milliseconds: 400),
              opacity: isSleepDataAvailable ? 1.0 : 0.0,
              child: isSleepDataAvailable ? Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.timer_sand_empty_rounded, color: theme.colorScheme.secondary, size: 24),
                  const SizedBox(width: 8),
                  Text("مدت زمان خواب: $durationText", style: GoogleFonts.vazirmatn(fontSize: 16.5, fontWeight: FontWeight.bold, color: theme.colorScheme.secondary)),
                ],
              ) : SizedBox(height: 24), // Placeholder for height consistency
            ),
            const SizedBox(height: 8),
          ],
        ),
      ),
    );
  }

  Widget _buildTimePickerButton(String label, String valueText, VoidCallback onPressed, ThemeData theme) {
    return Column(
      children: [
        Text(label, style: GoogleFonts.vazirmatn(fontSize: 14.5, color: theme.colorScheme.onSurface.withOpacity(0.8))),
        TextButton(
          onPressed: onPressed,
          style: TextButton.styleFrom(
            padding: EdgeInsets.symmetric(horizontal: 12, vertical:8),
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
          ),
          child: Text(valueText, style: GoogleFonts.vazirmatn(fontSize: 18.5, fontWeight: FontWeight.bold, color: theme.colorScheme.primary)),
        ),
      ],
    );
  }

  Widget _buildAchievementsSection(ThemeData theme) {
    List<Achievement> unlocked = _achievements.values.where((a) => a.unlocked).toList();
    List<Achievement> locked = _achievements.values.where((a) => !a.unlocked).toList();
    
    return Padding( // Wrap section in padding
      padding: const EdgeInsets.only(top: 16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.only(left: 12.0, bottom: 12),
            child: Text("🏆 دستاوردها", style: GoogleFonts.vazirmatn(fontSize: 22, fontWeight: FontWeight.bold, color: theme.colorScheme.primary)),
          ),
          if (unlocked.isEmpty && locked.isEmpty)
            Center(child: Padding(
              padding: const EdgeInsets.symmetric(vertical: 20.0),
              child: Text("هنوز دستاوردی برای نمایش وجود ندارد.", style: GoogleFonts.vazirmatn(color: theme.colorScheme.onSurface.withOpacity(0.6), fontSize: 15)),
            )),
          if (unlocked.isNotEmpty)
            ...unlocked.map((ach) => _buildAchievementItem(ach, theme, isLocked: false)).toList(),
          if (locked.isNotEmpty)
            Padding(
              padding: const EdgeInsets.only(left: 12.0, top: 20, bottom: 8),
              child: Text("قفل شده:", style: GoogleFonts.vazirmatn(fontSize: 17, fontWeight: FontWeight.w600, color: theme.colorScheme.onSurface.withOpacity(0.7))),
            ),
          if (locked.isNotEmpty)
              ...locked.map((ach) => _buildAchievementItem(ach, theme, isLocked: true)).toList(),
        ],
      ),
    );
  }

  Widget _buildAchievementItem(Achievement achievement, ThemeData theme, {bool isLocked = false}) {
    Color itemColor = isLocked ? (theme.brightness == Brightness.light ? Colors.grey.shade300 : Colors.grey.shade700) : achievement.color;
    Color contentColor = isLocked ? theme.colorScheme.onSurface.withOpacity(0.6) : (itemColor.computeLuminance() > 0.5 ? Colors.black87 : Colors.white);
    Color cardBg = isLocked ? theme.cardTheme.color! : itemColor.withOpacity(theme.brightness == Brightness.light ? 0.15 : 0.25);


    return Card( // Achievements are now also cards for consistency
      elevation: isLocked ? 1 : 3,
      color: cardBg,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 12.0, vertical: 10.0),
        child: Row(
          children: [
            CircleAvatar(
              backgroundColor: itemColor.withOpacity(isLocked ? 0.5 : 1.0),
              radius: 24,
              child: Icon(achievement.icon, color: Colors.white.withOpacity(isLocked ? 0.7 : 1.0), size: 24),
            ),
            SizedBox(width: 15),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    achievement.name,
                    style: GoogleFonts.vazirmatn(fontWeight: FontWeight.bold, fontSize: 15.5, color: theme.colorScheme.onSurface),
                  ),
                  SizedBox(height: 3),
                  Text(
                    achievement.description,
                    style: GoogleFonts.vazirmatn(fontSize: 12.5, color: theme.colorScheme.onSurface.withOpacity(0.7)),
                  ),
                ],
              ),
            ),
            SizedBox(width: 10),
            isLocked
                ? Icon(Icons.lock_outline_rounded, color: theme.colorScheme.onSurface.withOpacity(0.5), size:26)
                : Icon(Icons.check_circle_rounded, color: itemColor, size: 28),
          ],
        ),
      ),
    );
  }


  Widget _buildConfettiOverlay({required List<Color> colors}) {
    return IgnorePointer( 
      child: Stack(
        children: List.generate(60, (index) { // More confetti
          final random = math.Random(index + DateTime.now().millisecond); 
          final duration = Duration(milliseconds: 3000 + random.nextInt(3000)); 
          final size = 9.0 + random.nextDouble() * 13.0;
          final color = colors[random.nextInt(colors.length)].withOpacity(0.7 + random.nextDouble() * 0.3);
          
          final beginX = (random.nextDouble() -0.2) * (MediaQuery.of(context).size.width * 1.4); 
          final endYFactor = 0.3 + random.nextDouble() * 0.7; 
          final driftX = (random.nextDouble() - 0.5) * 400; // Wider drift

          return AnimatedPositioned(
            duration: duration,
            curve: Curves.easeOutSine, // Softer falling curve
            top: _waterGoalCelebration ? MediaQuery.of(context).size.height * endYFactor : -size - 40, 
            left: _waterGoalCelebration? beginX + driftX : beginX,
            child: AnimatedOpacity(
              duration: duration, 
              opacity: _waterGoalCelebration ? 1.0 : 0.0, 
              child: Transform.rotate(
                angle: random.nextDouble() * 6 * math.pi, // More rotation
                child: Container(
                  width: size,
                  height: size,
                  decoration: BoxDecoration(
                    color: color,
                    // Mix shapes
                    shape: index % 3 == 0 ? BoxShape.rectangle : BoxShape.circle,
                     borderRadius: index % 3 == 0 ? BorderRadius.circular(size/4) : null, 
                  ),
                ),
              ),
            ),
          );
        }),
      ),
    );
  }
}


// --- Custom Painter for Water Glass (adapted for theme) ---
class WaterGlassPainter extends CustomPainter {
  final double percentage; 
  final Color moodColor; // This is the base color for water, can be mood-specific
  final double animationValue; 
  final Brightness themeBrightness;

  WaterGlassPainter({
    required this.percentage, 
    required this.moodColor, 
    required this.animationValue,
    required this.themeBrightness
  });

  @override
  void paint(Canvas canvas, Size size) {
    final glassWidth = size.width * 0.88; 
    final glassHeight = size.height;
    final glassTopY = 0.0;
    final glassBottomY = glassHeight;
    final taperAmount = size.width * 0.12; 

    final glassPath = Path()
      ..moveTo(size.width * 0.06, glassTopY) 
      ..lineTo(size.width * 0.94, glassTopY) 
      ..lineTo(size.width * 0.94 - taperAmount, glassBottomY) 
      ..lineTo(size.width * 0.06 + taperAmount, glassBottomY) 
      ..close();

    final glassPaint = Paint()
      ..color = (themeBrightness == Brightness.light ? Colors.blueGrey.shade50 : Colors.grey.shade800).withOpacity(0.4) 
      ..style = PaintingStyle.fill;
    canvas.drawPath(glassPath, glassPaint);

    final glassBorderPaint = Paint()
      ..color = (themeBrightness == Brightness.light ? Colors.blueGrey.shade200 : Colors.grey.shade600).withOpacity(0.7)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 3.0; 
    canvas.drawPath(glassPath, glassBorderPaint);

    if (percentage > 0) {
      final waterHeight = glassHeight * percentage;
      final waterY = glassBottomY - waterHeight;

      final waterPath = Path();
      waterPath.moveTo(size.width * 0.06 + taperAmount * (1-percentage) , waterY); 

      for (double x = size.width * 0.06 + taperAmount * (1-percentage) ; x <= size.width * 0.94 - taperAmount * (1-percentage); x++) {
        final waveAmplitude = 4.5 * percentage * (1 + math.sin(animationValue * 1.2) * 0.18); // Subtler wave
        final waveFrequency = (x / (glassWidth * 0.20)) + (animationValue * 1.05); // Adjusted frequency
        final waveOffset = math.sin(waveFrequency * math.pi) * waveAmplitude;
        waterPath.lineTo(x, waterY + waveOffset);
      }
      
      waterPath.lineTo(size.width * 0.94 - taperAmount * (1-percentage), waterY);
      waterPath.lineTo(size.width * 0.94 - taperAmount, glassBottomY);
      waterPath.lineTo(size.width * 0.06 + taperAmount, glassBottomY);
      waterPath.close();

      // Water color adapts to mood color and theme
      Color waterBaseColor = HSLColor.fromColor(moodColor)
                                .withSaturation((HSLColor.fromColor(moodColor).saturation * 0.8).clamp(0.0,1.0))
                                .withLightness((HSLColor.fromColor(moodColor).lightness * (themeBrightness == Brightness.light ? 0.7 : 0.5)).clamp(0.0,1.0))
                                .toColor();

      final waterPaint = Paint()
        ..shader = LinearGradient(
          colors: [waterBaseColor.withOpacity(0.65), waterBaseColor.withOpacity(0.95)],
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
        ).createShader(Rect.fromLTWH(0, waterY, size.width, waterHeight));
      
      canvas.save();
      canvas.clipPath(glassPath);
      canvas.drawPath(waterPath, waterPaint);
      canvas.restore();

      // Shine effect
      if (percentage > 0.1) {
        final shinePaint = Paint()..color = Colors.white.withOpacity(themeBrightness == Brightness.light ? 0.20 : 0.15);
        final shinePath = Path()
          ..moveTo(size.width * 0.35, waterY + 7 + (percentage*3))
          ..quadraticBezierTo(size.width * 0.4, waterY + 2 + (percentage*2), size.width * 0.5 - (glassWidth*0.1), waterY + 6 + (percentage*3))
          ..quadraticBezierTo(size.width * 0.6 + (glassWidth*0.1) , waterY + 10 + (percentage*4), size.width * 0.65, waterY + 7 + (percentage*3))
           ..quadraticBezierTo(size.width * 0.5, waterY + 12 + (percentage*5), size.width * 0.35, waterY + 7 + (percentage*3))
          ..close();
        canvas.drawPath(shinePath, shinePaint);
      }
    }
  }

  @override
  bool shouldRepaint(covariant WaterGlassPainter oldDelegate) {
    return oldDelegate.percentage != percentage || 
           oldDelegate.moodColor != moodColor || 
           oldDelegate.animationValue != animationValue ||
           oldDelegate.themeBrightness != themeBrightness;
  }
}


// --- ChangeNotifier and Provider (Simple implementations for single file) ---
// (Normally these would be in separate files and potentially use a package like provider)
class ChangeNotifierProvider<T extends ChangeNotifier> extends StatefulWidget {
  final T Function(BuildContext context) create;
  final Widget child;

  ChangeNotifierProvider({required this.create, required this.child});

  static T of<T extends ChangeNotifier>(BuildContext context) {
    final _InheritedChangeNotifier<T>? result = context.dependOnInheritedWidgetOfExactType<_InheritedChangeNotifier<T>>();
    assert(result != null, 'No ChangeNotifierProvider<$T> found in context');
    return result!.notifier;
  }

  @override
  _ChangeNotifierProviderState<T> createState() => _ChangeNotifierProviderState<T>();
}

class _ChangeNotifierProviderState<T extends ChangeNotifier> extends State<ChangeNotifierProvider<T>> {
  late T notifier;

  @override
  void initState() {
    super.initState();
    notifier = widget.create(context);
  }

  @override
  void dispose() {
    notifier.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return _InheritedChangeNotifier<T>(
      notifier: notifier,
      child: widget.child,
    );
  }
}

class _InheritedChangeNotifier<T extends ChangeNotifier> extends InheritedWidget {
  final T notifier;

  _InheritedChangeNotifier({required this.notifier, required Widget child}) : super(child: child);

  @override
  bool updateShouldNotify(_InheritedChangeNotifier<T> oldWidget) {
    return notifier != oldWidget.notifier; // Or more specific checks if needed
  }
}

class Consumer<T extends ChangeNotifier> extends StatelessWidget {
  final Widget Function(BuildContext context, T notifier, Widget? child) builder;
  final Widget? child;

  Consumer({required this.builder, this.child});

  @override
  Widget build(BuildContext context) {
    final notifier = ChangeNotifierProvider.of<T>(context);
    // This is a simplified consumer, a real one would listen to notifier.addListener
    // For simplicity here, we rely on an AncestorWidget (like MaterialApp for theme) to rebuild.
    // For more granular updates, a StatefulWidget listening to the notifier would be better.
    return AnimatedBuilder(
      animation: notifier,
      builder: (context, _) => builder(context, notifier, child),
      child: child,
    );
  }
}