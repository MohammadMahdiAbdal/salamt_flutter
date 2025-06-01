import 'package:flutter/material.dart';
import 'dart:math' as math; // For random tip and initial mood
import 'package:google_fonts/google_fonts.dart'; // For custom font

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'سلامت یار',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        primarySwatch: Colors.teal,
        // Use Vazirmatn font from Google Fonts for a nice Persian UI
        textTheme: GoogleFonts.vazirmatnTextTheme(Theme.of(context).textTheme),
        brightness: Brightness.light, // Default to light theme
      ),
      home: HealthDashboardScreen(),
    );
  }
}

class HealthDashboardScreen extends StatefulWidget {
  @override
  _HealthDashboardScreenState createState() => _HealthDashboardScreenState();
}

class _HealthDashboardScreenState extends State<HealthDashboardScreen>
    with TickerProviderStateMixin {
  // Water Tracker State
  double _currentWaterIntake = 0.0; // Liters
  final double _waterGoal = 2.5; // Liters
  final double _cupSize = 0.25; // Liters (250ml)

  // Health Tip State
  int _currentTipIndex = 0;
  final List<String> _healthTips = [
    "هر روز حداقل ۸ لیوان آب بنوشید.",
    "روزانه ۳۰ دقیقه ورزش کنید.",
    "میوه و سبزیجات تازه مصرف کنید.",
    "خواب کافی (۷-۸ ساعت) داشته باشید.",
    "از مصرف زیاد قند و نمک بپرهیزید.",
    "برای کاهش استرس، مدیتیشن یا یوگا انجام دهید.",
    "صبحانه را هرگز حذف نکنید، پادشاه وعده‌هاست!",
    "هر ۲ ساعت یکبار از پشت میز بلند شوید و کمی قدم بزنید.",
  ];

  // Mood Tracker State
  Mood _currentMood = Mood.neutral;
  late AnimationController _moodColorController;
  late Animation<Color?> _moodBackgroundColorAnimation;

  // Animation controller for buttons
  late AnimationController _buttonPressController;
  late Animation<double> _buttonScaleAnimation;

  @override
  void initState() {
    super.initState();
    _currentTipIndex = math.Random().nextInt(_healthTips.length);
    _currentMood = Mood.values[math.Random().nextInt(Mood.values.length)];

    _moodColorController = AnimationController(
      duration: const Duration(milliseconds: 700),
      vsync: this,
    );

    _updateMoodColorAnimation(
      _currentMood.color.withOpacity(0.1),
    ); // Initial subtle color

    _buttonPressController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 150),
      reverseDuration: const Duration(milliseconds: 200),
    );
    _buttonScaleAnimation = Tween<double>(begin: 1.0, end: 0.90).animate(
      CurvedAnimation(parent: _buttonPressController, curve: Curves.easeInOut),
    );
  }

  void _updateMoodColorAnimation(Color targetColor, {bool animate = true}) {
    Color beginColor =
        (_moodBackgroundColorAnimation?.value ?? Colors.transparent);

    // Ensure the new animation starts from the current animated value
    if (_moodColorController.isAnimating) {
      beginColor =
          _moodBackgroundColorAnimation.value ??
          Theme.of(context).scaffoldBackgroundColor;
    } else {
      beginColor =
          _moodBackgroundColorAnimation.value ??
          Theme.of(
            context,
          ).scaffoldBackgroundColor.withOpacity(0); // Default if first time
    }

    _moodBackgroundColorAnimation = ColorTween(
      begin: beginColor,
      end: targetColor.withOpacity(0.15), // Subtle background tint
    ).animate(
      CurvedAnimation(parent: _moodColorController, curve: Curves.easeInOut),
    );

    if (animate) {
      _moodColorController.forward(from: 0.0);
    } else {
      _moodColorController.value = 1.0; // Jump to end state
    }
  }

  @override
  void dispose() {
    _moodColorController.dispose();
    _buttonPressController.dispose();
    super.dispose();
  }

  void _addWater() {
    _buttonPressController.forward().then(
      (_) => _buttonPressController.reverse(),
    );
    setState(() {
      if (_currentWaterIntake < _waterGoal) {
        _currentWaterIntake = (_currentWaterIntake + _cupSize).clamp(
          0.0,
          _waterGoal,
        );
      }
    });
  }

  void _resetWater() {
    _buttonPressController.forward().then(
      (_) => _buttonPressController.reverse(),
    );
    setState(() {
      _currentWaterIntake = 0.0;
    });
  }

  void _changeHealthTip() {
    _buttonPressController.forward().then(
      (_) => _buttonPressController.reverse(),
    );
    setState(() {
      _currentTipIndex = (_currentTipIndex + 1) % _healthTips.length;
    });
  }

  void _updateMood(Mood mood) {
    setState(() {
      _currentMood = mood;
      _updateMoodColorAnimation(_currentMood.color);
    });
  }

  Widget _buildAnimatedButton({
    required VoidCallback onPressed,
    required Widget child,
    Color? color,
  }) {
    return ScaleTransition(
      scale: _buttonScaleAnimation,
      child: ElevatedButton(
        onPressed: onPressed,
        style: ElevatedButton.styleFrom(
          backgroundColor: color ?? Theme.of(context).primaryColor,
          padding: EdgeInsets.symmetric(horizontal: 20, vertical: 12),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
        child: child,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    // Determine light or dark mode for text colors
    final bool isDarkMode = Theme.of(context).brightness == Brightness.dark;
    final Color textColor = isDarkMode ? Colors.white : Colors.black87;
    final Color subtleTextColor = isDarkMode ? Colors.white70 : Colors.black54;

    return AnimatedBuilder(
      animation: _moodBackgroundColorAnimation,
      builder: (context, child) {
        return Scaffold(
          backgroundColor: _moodBackgroundColorAnimation.value,
          appBar: AppBar(
            title: Text(
              'سلامت یار روزانه شما',
              style: GoogleFonts.vazirmatn(fontWeight: FontWeight.bold),
            ),
            centerTitle: true,
            elevation: 2.0,
            flexibleSpace: Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [
                    Theme.of(context).primaryColorDark,
                    Theme.of(context).primaryColorLight,
                  ],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
              ),
            ),
          ),
          body: SingleChildScrollView(
            padding: EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: <Widget>[
                _buildSectionTitle("💧 میزان آب مصرفی", textColor),
                _buildWaterTracker(textColor, subtleTextColor),
                SizedBox(height: 30),
                _buildSectionTitle("💡 نکته سلامتی امروز", textColor),
                _buildHealthTipCard(textColor, subtleTextColor),
                SizedBox(height: 30),
                _buildSectionTitle("😊 حس و حال شما چطور است؟", textColor),
                _buildMoodSelector(),
                SizedBox(height: 20),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildSectionTitle(String title, Color textColor) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12.0),
      child: Text(
        title,
        textAlign: TextAlign.center,
        style: GoogleFonts.vazirmatn(
          fontSize: 20,
          fontWeight: FontWeight.w600,
          color: textColor,
        ),
      ),
    );
  }

  Widget _buildWaterTracker(Color textColor, Color subtleTextColor) {
    double percentage = (_currentWaterIntake / _waterGoal).clamp(0.0, 1.0);
    return Card(
      elevation: 4.0,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15.0)),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            Text(
              '${_currentWaterIntake.toStringAsFixed(2)} / ${_waterGoal.toStringAsFixed(1)} لیتر',
              style: GoogleFonts.vazirmatn(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: textColor,
              ),
            ),
            SizedBox(height: 15),
            Container(
              height: 150,
              width: 100,
              decoration: BoxDecoration(
                border: Border.all(color: Colors.blueGrey.shade200, width: 2),
                borderRadius: BorderRadius.only(
                  topLeft: Radius.circular(15),
                  topRight: Radius.circular(15),
                  bottomLeft: Radius.circular(5),
                  bottomRight: Radius.circular(5),
                ),
              ),
              child: Stack(
                alignment: Alignment.bottomCenter,
                children: [
                  AnimatedContainer(
                    duration: Duration(milliseconds: 600),
                    curve: Curves.bounceOut, // Funky animation
                    height: percentage * 146, // 150 - 2*borderWidth
                    width: double.infinity,
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: [
                          Colors.lightBlueAccent.shade100,
                          Colors.blue.shade600,
                        ],
                        begin: Alignment.bottomCenter,
                        end: Alignment.topCenter,
                      ),
                      borderRadius: BorderRadius.only(
                        topLeft: Radius.circular(
                          percentage > 0.95 ? 13 : (percentage * 15),
                        ),
                        topRight: Radius.circular(
                          percentage > 0.95 ? 13 : (percentage * 15),
                        ),
                        bottomLeft: Radius.circular(3),
                        bottomRight: Radius.circular(3),
                      ),
                    ),
                  ),
                  // Bubbles animation (simple example)
                  if (percentage > 0.1 && percentage < 1.0)
                    ...List.generate(5, (index) {
                      return AnimatedPositioned(
                        duration: Duration(milliseconds: 800 + index * 200),
                        curve: Curves.easeOut,
                        bottom:
                            percentage *
                            140 *
                            (math.Random().nextDouble() * 0.5 +
                                0.5), // Random height within filled area
                        left:
                            math.Random().nextDouble() *
                            80, // Random horizontal position
                        child: CircleAvatar(
                          radius: math.Random().nextDouble() * 3 + 2,
                          backgroundColor: Colors.white.withOpacity(0.5),
                        ),
                      );
                    }),
                ],
              ),
            ),
            SizedBox(height: 20),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                _buildAnimatedButton(
                  onPressed: _addWater,
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(Icons.add_circle_outline, color: Colors.white),
                      SizedBox(width: 8),
                      Text(
                        'یک لیوان (${_cupSize} ل)',
                        style: GoogleFonts.vazirmatn(color: Colors.white),
                      ),
                    ],
                  ),
                ),
                _buildAnimatedButton(
                  onPressed: _resetWater,
                  color: Colors.orangeAccent,
                  child: Icon(Icons.refresh, color: Colors.white),
                ),
              ],
            ),
            if (_currentWaterIntake >= _waterGoal)
              Padding(
                padding: const EdgeInsets.only(top: 15.0),
                child: Text(
                  '🎉 تبریک! به هدف روزانه‌ات رسیدی!',
                  style: GoogleFonts.vazirmatn(
                    fontSize: 16,
                    color: Colors.green.shade700,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildHealthTipCard(Color textColor, Color subtleTextColor) {
    return Card(
      elevation: 4.0,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15.0)),
      color: Colors.teal.shade50,
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            Icon(
              Icons.lightbulb_outline,
              size: 30,
              color: Colors.amber.shade700,
            ),
            SizedBox(height: 10),
            AnimatedSwitcher(
              duration: Duration(milliseconds: 500),
              transitionBuilder: (Widget child, Animation<double> animation) {
                return FadeTransition(
                  opacity: animation,
                  child: SlideTransition(
                    position: Tween<Offset>(
                      begin: Offset(0.0, 0.5),
                      end: Offset.zero,
                    ).animate(animation),
                    child: child,
                  ),
                );
              },
              child: Text(
                _healthTips[_currentTipIndex],
                key: ValueKey<int>(
                  _currentTipIndex,
                ), // Important for AnimatedSwitcher
                textAlign: TextAlign.center,
                style: GoogleFonts.vazirmatn(
                  fontSize: 16,
                  color: Colors.teal.shade800,
                  height: 1.5,
                ),
              ),
            ),
            SizedBox(height: 15),
            _buildAnimatedButton(
              onPressed: _changeHealthTip,
              color: Colors.amber.shade600,
              child: Text(
                'نکته بعدی',
                style: GoogleFonts.vazirmatn(color: Colors.white),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildMoodSelector() {
    return Card(
      elevation: 4.0,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15.0)),
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 16.0, horizontal: 8.0),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children:
              Mood.values.map((mood) {
                bool isSelected = _currentMood == mood;
                return InkWell(
                  onTap: () => _updateMood(mood),
                  borderRadius: BorderRadius.circular(50),
                  child: AnimatedContainer(
                    duration: Duration(milliseconds: 300),
                    padding: EdgeInsets.all(isSelected ? 10 : 8),
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color:
                          isSelected
                              ? mood.color.withOpacity(0.3)
                              : Colors.transparent,
                      border: Border.all(
                        color: isSelected ? mood.color : Colors.grey.shade300,
                        width: isSelected ? 2.5 : 1.5,
                      ),
                    ),
                    child: Text(
                      mood.emoji,
                      style: TextStyle(fontSize: isSelected ? 30 : 26),
                    ),
                  ),
                );
              }).toList(),
        ),
      ),
    );
  }
}

// Enum for Moods
enum Mood {
  happy('😄', Colors.greenAccent),
  good('😊', Colors.lightGreen),
  neutral('😐', Colors.amber),
  sad('😟', Colors.lightBlue),
  stressed('😫', Colors.deepOrangeAccent);

  const Mood(this.emoji, this.color);
  final String emoji;
  final Color color;
}
