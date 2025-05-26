// این کد را می توانید در یک فایل جداگانه مثل lib/main_screen_navigator.dart قرار دهید
// یا اگر ترجیح می دهید در انتهای main.dart باشد.
// من فرض می کنم در انتهای main.dart است.

const String _sleepKey = 'sleep_hours';
const String _waterKey = 'water_liters';
const String _remindersKey = 'reminders_list';

class MainScreen extends StatefulWidget {
  @override
  State<MainScreen> createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> with SingleTickerProviderStateMixin {
  int _selectedIndex = 0;
  late PageController _pageController;
  late AnimationController _fabAnimationController; // برای انیمیشن FAB

  // داده های برنامه
  double _sleepHours = 0.0;
  double _waterLiters = 0.0;
  List<Reminder> _reminders = [];
  bool _isLoading = true; // برای نمایش لودینگ اولیه

  @override
  void initState() {
    super.initState();
    _pageController = PageController(initialPage: _selectedIndex);
    _fabAnimationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 400),
    );
    _loadData(); // بارگذاری داده ها هنگام شروع برنامه
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
        final List<dynamic> remindersJson = jsonDecode(remindersString);
        _reminders = remindersJson.map((json) => Reminder.fromJson(json)).toList();
      }
      _isLoading = false; // پایان لودینگ
    });
  }

  Future<void> _saveSleepAndWater() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setDouble(_sleepKey, _sleepHours);
    await prefs.setDouble(_waterKey, _waterLiters);
  }

  Future<void> _saveReminders() async {
    final prefs = await SharedPreferences.getInstance();
    final String remindersString = jsonEncode(_reminders.map((r) => r.toJson()).toList());
    await prefs.setString(_remindersKey, remindersString);
  }

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
      _pageController.animateToPage(
        index,
        duration: const Duration(milliseconds: 350), // انیمیشن جابجایی صفحه
        curve: Curves.easeInOutQuart,
      );
    });
    // انیمیشن FAB بر اساس صفحه
    if (index == 2) { // صفحه یادآورها
      _fabAnimationController.forward();
    } else {
      _fabAnimationController.reverse();
    }
  }

  // توابع برای به روز رسانی داده ها از صفحات فرزند
  void updateDashboardData(double sleep, double water) {
    setState(() {
      _sleepHours = sleep;
      _waterLiters = water;
      _saveSleepAndWater(); // ذخیره داده ها
    });
  }

  void addReminder(Reminder newReminder) {
    setState(() {
      _reminders.add(newReminder);
      _reminders.sort((a, b) { // مرتب سازی بر اساس زمان
         final now = DateTime.now();
         final timeA = DateTime(now.year, now.month, now.day, a.time.hour, a.time.minute);
         final timeB = DateTime(now.year, now.month, now.day, b.time.hour, b.time.minute);
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
         final timeA = DateTime(now.year, now.month, now.day, a.time.hour, a.time.minute);
         final timeB = DateTime(now.year, now.month, now.day, b.time.hour, b.time.minute);
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


  @override
  Widget build(BuildContext context) {
    final List<Widget> _pages = [
      DashboardScreen(key: PageStorageKey('DashboardPage'), sleepHours: _sleepHours, waterLiters: _waterLiters),
      InputScreen(key: PageStorageKey('InputPage'), onSubmit: updateDashboardData),
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
          child: CircularProgressIndicator(color: Theme.of(context).primaryColor),
        ),
      );
    }

    return Directionality( // این Directionality اینجا هم لازم است اگر MaterialApp آن را مدیریت نکند
      textDirection: TextDirection.rtl,
      child: Scaffold(
        body: PageView( // استفاده از PageView برای انیمیشن بهتر بین صفحات
          controller: _pageController,
          onPageChanged: (index) {
            setState(() {
              _selectedIndex = index;
               if (index == 2) { _fabAnimationController.forward();}
               else { _fabAnimationController.reverse();}
            });
          },
          children: _pages,
        ),
        bottomNavigationBar: BottomNavigationBar(
          currentIndex: _selectedIndex,
          onTap: _onItemTapped,
          // استایل از theme گرفته می شود
          items: const [
            BottomNavigationBarItem(
                icon: Icon(Icons.space_dashboard_outlined), activeIcon: Icon(Icons.space_dashboard_rounded), label: 'داشبورد'),
            BottomNavigationBarItem(
                icon: Icon(Icons.edit_calendar_outlined), activeIcon: Icon(Icons.edit_calendar_rounded), label: 'ورود روزانه'),
            BottomNavigationBarItem(
                icon: Icon(Icons.notifications_active_outlined), activeIcon: Icon(Icons.notifications_active_rounded),label: 'یادآورها'),
            BottomNavigationBarItem(
                icon: Icon(Icons.settings_outlined), activeIcon: Icon(Icons.settings_rounded), label: 'تنظیمات'),
          ],
        ),
        floatingActionButton: _selectedIndex == 2 // فقط در صفحه یادآور FAB نمایش داده شود
            ? ScaleTransition( // انیمیشن برای FAB
                scale: _fabAnimationController,
                child: FloatingActionButton.extended(
                  onPressed: () {
                    // متد نمایش دیالوگ افزودن یادآور از صفحه ReminderScreen فراخوانی می شود
                    // این نیاز به یک GlobalKey برای ReminderScreen یا روش دیگری دارد
                    // برای سادگی فعلا اینجا یک placeholder می گذاریم
                    // در فایل ReminderScreen این را پیاده سازی می کنیم
                    // ReminderScreen.showAddReminderDialog(context, addReminder);
                     // این روش مستقیم کار نمیکنه، باید از طریق یک callback یا GlobalKey باشه
                     // فعلا یک کار موقت:
                     if (mounted && _pages[2] is ReminderScreen) {
                        // این روش برای دسترسی مستقیم به متد یک ویجت دیگر خوب نیست
                        // بهتر است showAddDialog در خود MainScreen باشد و به ReminderScreen پاس داده شود
                        // یا از یک Event Bus/Provider استفاده شود
                        // (_pages[2] as ReminderScreen).manuallyShowAddDialog(context); // این رو تغییر میدیم
                        // به جای اینکار، یک متد در MainScreen برای نمایش دیالوگ میسازیم
                        _showAddReminderDialogFromMainScreen();
                     }
                  },
                  icon: Icon(Icons.add_alarm_rounded),
                  label: Text("افزودن یادآور"),
                  // استایل از theme
                ),
              )
            : null,
        floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
      ),
    );
  }


  // این متد برای نمایش دیالوگ از MainScreen است،
  // چون FAB متعلق به MainScreen است وقتی صفحه ReminderScreen فعال است
  void _showAddReminderDialogFromMainScreen() {
    final _textController = TextEditingController();
    TimeOfDay selectedTime = TimeOfDay.now();
    final context = this.context; // گرفتن context از MainScreen

    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text('افزودن یادآور جدید', textAlign: TextAlign.right),
        contentPadding: EdgeInsets.fromLTRB(20, 20, 20, 10),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            TextField(
              controller: _textController,
              textAlign: TextAlign.right,
              decoration: InputDecoration(labelText: 'متن یادآور', hintText: "مثال: نوشیدن آب"),
              textInputAction: TextInputAction.done,
            ),
            SizedBox(height: 18),
            ElevatedButton.icon(
              icon: Icon(Icons.access_time_rounded, size: 20),
              label: Text('انتخاب ساعت یادآوری'),
              style: ElevatedButton.styleFrom(
                backgroundColor: Theme.of(context).primaryColor.withOpacity(0.1), // رنگ متفاوت
                foregroundColor: Theme.of(context).primaryColor,
                elevation: 0,
                padding: EdgeInsets.symmetric(vertical: 12)
              ),
              onPressed: () async {
                final pickedTime = await showTimePicker(
                  context: context,
                  initialTime: selectedTime,
                  helpText: "زمان یادآور را انتخاب کنید",
                  builder: (context, child) { // استایل TimePicker
                    return Theme(
                      data: Theme.of(context).copyWith(
                        colorScheme: Theme.of(context).colorScheme.copyWith(
                          primary: Theme.of(context).primaryColor, // رنگ هدر و دکمه ها
                          onPrimary: Colors.white,
                          surface: Colors.white,
                          onSurface: Theme.of(context).colorScheme.onSurface,
                        ),
                        timePickerTheme: TimePickerThemeData(
                          dialBackgroundColor: Colors.grey.shade100,
                          // ... سایر استایل ها
                        ),
                        textButtonTheme: TextButtonThemeData(
                          style: TextButton.styleFrom(
                            foregroundColor: Theme.of(context).primaryColor,
                          ),
                        ),
                      ),
                      child: Directionality( // اطمینان از RTL بودن TimePicker
                          textDirection: TextDirection.rtl,
                          child: child!,
                      ),
                    );
                  },
                );
                if (pickedTime != null) {
                  // چون showDialog یک context جدید میسازه، برای آپدیت UI داخلش باید از StatefulBuilder استفاده کرد
                  // یا زمان رو در یک متغیر موقت در _MainScreenState نگه داریم و بعد از pop آپدیت کنیم
                  // برای سادگی فعلا فقط مقدار رو میگیریم
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
            child: Text('انصراف', style: TextStyle(color: Colors.grey.shade700)),
          ),
          ElevatedButton(
            onPressed: () {
              if (_textController.text.trim().isNotEmpty) {
                addReminder(Reminder(text: _textController.text.trim(), time: selectedTime));
                Navigator.of(ctx).pop();
              } else {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text('لطفا متن یادآور را وارد کنید.', textAlign: TextAlign.right), backgroundColor: Colors.orangeAccent)
                );
              }
            },
            child: Text('افزودن'), // استایل از theme
          ),
        ],
      ),
    );
  }
}
```**تغییرات کلیدی در `MainScreen`:**
*   **مدیریت وضعیت مرکزی:** `MainScreen` حالا `StatefulWidget` است و داده‌های اصلی برنامه (ساعت خواب، آب، لیست یادآورها) را در خود نگه می‌دارد و بین صفحات جابجا می‌کند.
*   **`SharedPreferences`:** توابع `_loadData`, `_saveSleepAndWater`, `_saveReminders` برای بارگذاری و ذخیره داده‌ها اضافه شده‌اند.
*   **`PageController`:** برای انیمیشن نرم‌تر بین صفحات از `PageView` و `PageController` استفاده شده.
*   **انیمیشن FAB:** `AnimationController` برای کنترل نمایش و انیمیشن `FloatingActionButton` در صفحه یادآورها اضافه شده.
*   **توابع به‌روزرسانی:** توابع `updateDashboardData`, `addReminder`, `editReminder`, `deleteReminder`, `toggleReminderActive` برای اینکه صفحات فرزند بتوانند داده‌های `MainScreen` را تغییر دهند.
*   **دیالوگ افزودن یادآور:** منطق نمایش دیالوگ افزودن یادآور به `MainScreen` منتقل شده چون FAB مربوط به `MainScreen` است.

---

**مرحله ۴: ایجاد فایل‌ها و بازنویسی صفحات فرزند**

حالا فایل‌های زیر را در پوشه `lib/screens/` ایجاد کنید و کدهای مربوطه را در آن‌ها قرار دهید.

**فایل `lib/screens/dashboard_screen.dart`**

```dart
import 'package:flutter/material.dart';
import 'package:animate_do/animate_do.dart';
import 'package:fl_chart/fl_chart.dart'; // برای نمودار

class DashboardScreen extends StatelessWidget {
  final double sleepHours;
  final double waterLiters;

  const DashboardScreen({Key? key, required this.sleepHours, required this.waterLiters}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    int animationDelay = 200; // تاخیر اولیه برای انیمیشن

    return Scaffold(
      // backgroundColor: theme.scaffoldBackgroundColor, // از theme گرفته می شود
      appBar: AppBar(
        title: FadeInDown(duration: Duration(milliseconds: 500), child: Text('داشبورد سلامتی شما')),
        // elevation از theme
      ),
      body: ListView(
        padding: const EdgeInsets.all(16.0),
        children: [
          // کارت خوش آمدگویی (اختیاری)
          FadeInDown(
            delay: Duration(milliseconds: animationDelay),
            duration: Duration(milliseconds: 500),
            child: Card(
              elevation: 0.5,
              color: theme.primaryColor.withOpacity(0.05), // رنگ خیلی ملایم
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 22),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      "سلام!", // یا "سلام [نام کاربر]" اگر نام کاربر را دارید
                      style: theme.textTheme.headlineSmall?.copyWith(color: theme.primaryColor, fontSize: 23),
                      textAlign: TextAlign.right,
                    ),
                    SizedBox(height: 6),
                    Text(
                      "نگاهی به وضعیت امروزت بنداز:",
                      style: theme.textTheme.bodyMedium?.copyWith(color: theme.colorScheme.onSurface.withOpacity(0.7)),
                      textAlign: TextAlign.right,
                    ),
                  ],
                ),
              ),
            ),
          ),
          SizedBox(height: 12),

          // کارت های اطلاعاتی
          _buildInfoCard(
            context,
            icon: Icons.king_bed_outlined, // آیکون مرتبط تر
            title: 'میزان خواب شب گذشته',
            value: '${sleepHours.toStringAsFixed(1)} ساعت',
            color: theme.primaryColor, // رنگ اصلی
            delay: animationDelay += 150,
          ),
          _buildInfoCard(
            context,
            icon: Icons.opacity_outlined, // آیکون مرتبط تر
            title: 'میزان آب مصرفی امروز',
            value: '${waterLiters.toStringAsFixed(1)} لیتر',
            color: Colors.blue.shade600, // رنگ متفاوت
            delay: animationDelay += 150,
          ),
          _buildInfoCard(
            context,
            icon: Icons.favorite_border_rounded,
            title: 'ضربان قلب (مثال)',
            value: '۷۲ bpm', // این داده ثابت است، می توانید آن را از ورودی بگیرید
            color: Colors.pink.shade400,
            delay: animationDelay += 150,
          ),
          SizedBox(height: 24),

          // بخش نمودارها (مثال برای نمودار خواب و آب)
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
                    style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold, color: theme.colorScheme.onBackground.withOpacity(0.8)),
                    textAlign: TextAlign.right,
                  ),
                ),
                Container(
                  height: 200, // ارتفاع نمودار
                  padding: EdgeInsets.symmetric(vertical: 10),
                  child: BarChart( // استفاده از BarChart به عنوان نمونه
                    BarChartData(
                      alignment: BarChartAlignment.spaceAround,
                      barTouchData: BarTouchData(enabled: true),
                      titlesData: FlTitlesData(
                        show: true,
                        bottomTitles: AxisTitles(
                          sideTitles: SideTitles(
                            showTitles: true,
                            reservedSize: 30,
                            getTitlesWidget: (double value, TitleMeta meta) {
                              final days = ['شنبه', '۱ش', '۲ش', '۳ش', '۴ش', '۵ش', 'جمعه'];
                              return SideTitleWidget(axisSide: meta.axisSide, space: 4, child: Text(days[value.toInt() % days.length], style: TextStyle(color: Colors.grey.shade600, fontSize: 10)));
                            },
                          ),
                        ),
                        leftTitles: AxisTitles(sideTitles: SideTitles(showTitles: true, reservedSize: 28, interval: sleepHours > 2 ? sleepHours/2 : 2)),
                        topTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
                        rightTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
                      ),
                      borderData: FlBorderData(show: false),
                      barGroups: _buildSampleBarGroups(context, sleepHours, waterLiters),
                      gridData: FlGridData(show: true, drawVerticalLine: false, horizontalInterval: 2,getDrawingHorizontalLine: (value) => FlLine(color: Colors.grey.shade200, strokeWidth: 0.5)),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildInfoCard(BuildContext context, {required IconData icon, required String title, required String value, required Color color, required int delay}) {
    final theme = Theme.of(context);
    return FadeInUp(
      delay: Duration(milliseconds: delay),
      duration: Duration(milliseconds: 500),
      child: Card(
        // elevation و shape از theme
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 20), // پدینگ داخلی
          child: Row(
            children: [
              CircleAvatar( // آیکون در دایره
                radius: 24,
                backgroundColor: color.withOpacity(0.12),
                child: Icon(icon, color: color, size: 26),
              ),
              SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(title, style: theme.textTheme.bodyMedium?.copyWith(color: theme.colorScheme.onSurface.withOpacity(0.85)), textAlign: TextAlign.right),
                    SizedBox(height: 5),
                    Text(value, style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold, fontSize: 18, color: color), textAlign: TextAlign.right),
                  ],
                ),
              ),
              Icon(Icons.arrow_forward_ios_rounded, size: 16, color: Colors.grey.shade400) // فلش نشانگر
            ],
          ),
        ),
      ),
    );
  }

  // تابع نمونه برای ایجاد داده های نمودار میله ای
  List<BarChartGroupData> _buildSampleBarGroups(BuildContext context, double currentSleep, double currentWater) {
    final theme = Theme.of(context);
    final List<double> sleepData = [6.5, 7, currentSleep > 0 ? currentSleep : 7.5, 6, 8, 7.2, 7.8]; // داده های نمونه خواب
    final List<double> waterData = [1.5, 2, currentWater > 0 ? currentWater : 2.2, 1.8, 2.5, 2.1, 2.3]; // داده های نمونه آب

    return List.generate(7, (index) {
      return BarChartGroupData(
        x: index,
        barRods: [
          BarChartRodData(
            toY: sleepData[index],
            color: theme.primaryColor.withOpacity(0.8),
            width: 10, // عرض میله ها
            borderRadius: BorderRadius.circular(4),
          ),
          BarChartRodData(
            toY: waterData[index],
            color: Colors.blue.shade300.withOpacity(0.8),
            width: 10,
            borderRadius: BorderRadius.circular(4),
          ),
        ],
        showingTooltipIndicators: [0,1] // نمایش تولتیپ برای هر دو میله
      );
    });
  }
}