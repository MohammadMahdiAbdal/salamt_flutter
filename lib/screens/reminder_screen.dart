import 'package:flutter/material.dart';
import 'package:animate_do/animate_do.dart';
import 'package:flutter_slidable/flutter_slidable.dart'; // برای اکشن های کشویی
import 'package:intl/intl.dart'; // برای فرمت زمان فارسی
import '../models/reminder_model.dart'; // اطمینان از مسیر صحیح
import 'package:lottie/lottie.dart'; // برای انیمیشن صفحه خالی

class ReminderScreen extends StatefulWidget {
  // تبدیل به StatefulWidget برای مدیریت SlidableController
  final List<Reminder> reminders;
  final Function(Reminder) onAdd; // این از MainScreen می آید
  final Function(int, Reminder) onEdit;
  final Function(int) onDelete;
  final Function(int, bool) onToggleActive; // برای فعال/غیرفعال کردن

  const ReminderScreen({
    Key? key,
    required this.reminders,
    required this.onAdd, // این دیگر استفاده نمیشود چون دیالوگ در MainScreen است
    required this.onEdit,
    required this.onDelete,
    required this.onToggleActive,
  }) : super(key: key);

  @override
  State<ReminderScreen> createState() => _ReminderScreenState();
}

class _ReminderScreenState extends State<ReminderScreen> {
  final SlidableController _slidableController = SlidableController();

  // این متد دیگر لازم نیست چون دیالوگ از MainScreen کنترل می شود
  // void _showAddDialog(BuildContext context) { ... }

  void _showEditDialog(
    BuildContext context,
    int index,
    Reminder currentReminder,
  ) {
    final _editController = TextEditingController(text: currentReminder.text);
    TimeOfDay selectedTime = currentReminder.time;
    // برای آپدیت UI داخل دیالوگ بعد از انتخاب زمان
    TimeOfDay? tempPickedTime;

    showDialog(
      context: context,
      builder:
          (ctx) => StatefulBuilder(
            // برای آپدیت UI داخل دیالوگ
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
                          builder: (context, child) {
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
                              child: Directionality(
                                textDirection: TextDirection.rtl,
                                child: child!,
                              ),
                            );
                          },
                        );
                        if (picked != null) {
                          setDialogState(() {
                            // آپدیت UI داخل دیالوگ
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
    final DateFormat timeFormatter = DateFormat(
      'HH:mm',
      'fa_IR',
    ); // فرمت زمان فارسی

    return Scaffold(
      appBar: AppBar(
        title: FadeInDown(
          duration: Duration(milliseconds: 500),
          child: Text('یادآورهای روزانه شما'),
        ),
      ),
      // FAB به MainScreen منتقل شده است
      body:
          widget.reminders.isEmpty
              ? Center(
                child: FadeInUp(
                  duration: Duration(milliseconds: 600),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Lottie.asset(
                        // انیمیشن Lottie برای صفحه خالی
                        'assets/animations/empty_reminder.json', // این فایل را باید اضافه کنید
                        width: 220,
                        height: 220,
                        fit: BoxFit.contain,
                        repeat: true,
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
                // برای انیمیشن لیست
                child: ListView.builder(
                  padding: EdgeInsets.only(
                    top: 10,
                    bottom: 80,
                  ), // پدینگ برای FAB
                  itemCount: widget.reminders.length,
                  itemBuilder: (ctx, index) {
                    final reminder = widget.reminders[index];
                    return AnimationConfiguration.staggeredList(
                      position: index,
                      duration: const Duration(milliseconds: 450),
                      child: SlideAnimation(
                        verticalOffset: 50.0,
                        curve: Curves.easeOutQuint,
                        child: FadeInAnimation(
                          curve: Curves.easeInExpo,
                          child: Slidable(
                            key: ValueKey(
                              reminder.hashCode + reminder.time.hashCode,
                            ), // کلید منحصر به فرد
                            // controller: _slidableController, // اگر نیاز به کنترل دستی دارید
                            startActionPane: ActionPane(
                              // اکشن های سمت راست (در RTL)
                              motion: const StretchMotion(), // افکت کششی
                              extentRatio: 0.28, // عرض پنل
                              children: [
                                SlidableAction(
                                  onPressed:
                                      (context) => widget.onDelete(index),
                                  backgroundColor: theme.colorScheme.error
                                      .withOpacity(0.9),
                                  foregroundColor: Colors.white,
                                  icon: Icons.delete_forever_rounded,
                                  label: 'حذف',
                                  borderRadius: BorderRadius.horizontal(
                                    left: Radius.circular(16),
                                  ),
                                ),
                              ],
                            ),
                            endActionPane: ActionPane(
                              // اکشن های سمت چپ (در RTL)
                              motion: const BehindMotion(),
                              extentRatio: 0.28,
                              children: [
                                SlidableAction(
                                  onPressed:
                                      (context) => _showEditDialog(
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
                              // elevation و shape از theme
                              child: ListTile(
                                leading: Switch(
                                  // برای فعال/غیرفعال کردن یادآور
                                  value: reminder.isActive,
                                  onChanged: (bool value) {
                                    widget.onToggleActive(index, value);
                                  },
                                  activeColor:
                                      theme
                                          .colorScheme
                                          .secondary, // استفاده از رنگ تاکیدی
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
                                              ),
                                  textAlign: TextAlign.right,
                                  maxLines: 2,
                                  overflow: TextOverflow.ellipsis,
                                ),
                                subtitle: Text(
                                  'ساعت تنظیم شده: ${timeFormatter.format(DateTime(2000, 1, 1, reminder.time.hour, reminder.time.minute))}', // استفاده از Intl
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
                                              ),
                                  textAlign: TextAlign.right,
                                ),
                                trailing: Icon(
                                  Icons
                                      .drag_handle_rounded, // برای نشان دادن قابلیت کشیدن (اختیاری)
                                  color: Colors.grey.shade300,
                                  semanticLabel:
                                      "برای ویرایش یا حذف، به طرفین بکشید",
                                ),
                                // onTap: () => _showEditDialog(context, index, reminder), // یا با تپ کردن ویرایش شود
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
