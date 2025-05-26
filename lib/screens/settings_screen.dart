import 'package:flutter/material.dart';
import 'package:animate_do/animate_do.dart';
// import 'package:url_launcher/url_launcher.dart'; // اگر می خواهید لینک باز کنید

class SettingsScreen extends StatelessWidget {
  const SettingsScreen({Key? key}) : super(key: key);

  void _showAboutDialog(BuildContext context) {
    final theme = Theme.of(context);
    showDialog(
      context: context,
      builder:
          (ctx) => FadeIn(
            // انیمیشن برای دیالوگ
            duration: Duration(milliseconds: 300),
            child: AlertDialog(
              title: Row(
                // عنوان با آیکون
                mainAxisAlignment: MainAxisAlignment.end,
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
                      "نسخه برنامه: 1.0.0",
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        color: Colors.grey.shade500,
                        fontSize: 12,
                      ),
                    ),
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
      // انیمیشن برای هر آیتم تنظیمات
      delay: Duration(milliseconds: delay),
      duration: Duration(milliseconds: 400),
      child: Card(
        elevation: 1, // سایه کمتر برای آیتم های لیست
        margin: EdgeInsets.symmetric(horizontal: 16, vertical: 6),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        child: ListTile(
          leading: CircleAvatar(
            // آیکون در دایره
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
          onTap: onTap,
          contentPadding: EdgeInsetsDirectional.fromSTEB(
            16,
            8,
            12,
            8,
          ), // پدینگ دقیق تر
        ),
      ),
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
            subtitle: 'نحوه مدیریت داده‌های شما',
            onTap: () {
              // در اینجا می توانید یک لینک به صفحه سیاست حفظ حریم خصوصی باز کنید
              // یا یک دیالوگ دیگر نمایش دهید.
              // await launchUrl(Uri.parse('https://your-privacy-policy-url.com'));
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text(
                    'صفحه سیاست حفظ حریم خصوصی (نمونه)',
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
            title: 'به برنامه امتیاز دهید',
            subtitle: 'نظر شما برای ما ارزشمند است',
            onTap: () {
              // await launchUrl(Uri.parse('market://details?id=your.package.name')); // برای اندروید
              // await launchUrl(Uri.parse('itms-apps://itunes.apple.com/app/your-app-id')); // برای iOS
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text(
                    'باز کردن صفحه فروشگاه (نمونه)',
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
            title: 'معرفی برنامه به دوستان',
            subtitle: 'کمک به رشد جامعه سلامتی ما',
            onTap: () {
              // از پکیج share_plus استفاده کنید
              // Share.share('سلام! اپلیکیشن سلامتی من رو امتحان کن: [لینک برنامه]');
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text(
                    'قابلیت اشتراک گذاری (نمونه)',
                    textAlign: TextAlign.right,
                  ),
                ),
              );
            },
            delay: animationDelay += 100,
          ),
          // گزینه تم تاریک (در آینده)
          // _buildSettingsTile(
          //   context,
          //   icon: Icons.brightness_6_outlined,
          //   title: 'حالت نمایش',
          //   subtitle: 'تغییر بین حالت روشن و تاریک',
          //   onTap: () {
          //     // منطق تغییر تم
          //   },
          //   trailing: Switch(value: false, onChanged: (val){}, activeColor: theme.colorScheme.secondary),
          //   delay: animationDelay += 100,
          // ),
        ],
      ),
    );
  }
}
