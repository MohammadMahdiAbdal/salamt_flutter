import 'package:flutter/material.dart';
import 'package:animate_do/animate_do.dart';
import 'package:flutter/services.dart'; // برای HapticFeedback

class InputScreen extends StatefulWidget {
  final Function(double, double) onSubmit;

  const InputScreen({Key? key, required this.onSubmit}) : super(key: key);

  @override
  _InputScreenState createState() => _InputScreenState();
}

class _InputScreenState extends State<InputScreen> {
  final _sleepController = TextEditingController();
  final _waterController = TextEditingController();
  final _formKey = GlobalKey<FormState>(); // برای اعتبارسنجی

  void _submitData() {
    FocusScope.of(context).unfocus(); // بستن کیبورد
    if (_formKey.currentState!.validate()) {
      // اعتبارسنجی فرم
      final sleep = double.tryParse(_sleepController.text) ?? 0.0;
      final water = double.tryParse(_waterController.text) ?? 0.0;

      // محدودیت منطقی برای داده ها
      if (sleep > 24 || sleep < 0) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              'ساعت خواب وارد شده معتبر نیست.',
              textAlign: TextAlign.right,
            ),
            backgroundColor: Colors.orangeAccent,
          ),
        );
        return;
      }
      if (water > 10 || water < 0) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              'مقدار آب مصرفی وارد شده معتبر نیست.',
              textAlign: TextAlign.right,
            ),
            backgroundColor: Colors.orangeAccent,
          ),
        );
        return;
      }

      widget.onSubmit(sleep, water);
      HapticFeedback.mediumImpact(); // بازخورد لرزشی

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            'اطلاعات روزانه شما با موفقیت ثبت شد!',
            textAlign: TextAlign.right,
          ),
          // backgroundColor و سایر استایل ها از theme گرفته می شود
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
  }) {
    return FadeInUp(
      delay: Duration(milliseconds: delay),
      duration: Duration(milliseconds: 500),
      child: TextFormField(
        // استفاده از TextFormField برای اعتبارسنجی
        controller: controller,
        textAlign: TextAlign.right,
        decoration: InputDecoration(
          labelText: labelText,
          hintText: hintText,
          prefixIcon: Padding(
            padding: const EdgeInsetsDirectional.only(start: 12.0, end: 8.0),
            child: Icon(icon, size: 22),
          ),
          // استایل از theme
        ),
        keyboardType: TextInputType.numberWithOptions(
          decimal: true,
        ), // اجازه دادن به اعشار
        textInputAction: TextInputAction.next,
        validator: (value) {
          if (value == null || value.isEmpty) {
            return 'لطفا این فیلد را پر کنید';
          }
          if (double.tryParse(value) == null) {
            return 'لطفا یک عدد معتبر وارد کنید';
          }
          return null;
        },
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
          child: Text('ورود اطلاعات روزانه'),
        ),
      ),
      body: GestureDetector(
        onTap: () => FocusScope.of(context).unfocus(),
        child: SingleChildScrollView(
          // برای جلوگیری از overflow با کیبورد
          padding: const EdgeInsets.all(20.0), // پدینگ بیشتر
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch, // دکمه تمام عرض
              children: [
                SizedBox(height: 10),
                _buildTextFormField(
                  controller: _sleepController,
                  labelText: 'ساعت خواب شب گذشته',
                  hintText: "مثال: 7.5",
                  icon: Icons.bedtime_outlined,
                  delay: animationDelay,
                ),
                SizedBox(height: 22), // فاصله بیشتر
                _buildTextFormField(
                  controller: _waterController,
                  labelText: 'آب مصرفی امروز (به لیتر)',
                  hintText: "مثال: 2.5",
                  icon: Icons.local_drink_outlined,
                  delay: animationDelay += 150,
                ),
                SizedBox(height: 35), // فاصله خیلی بیشتر قبل از دکمه
                FadeInUp(
                  delay: Duration(milliseconds: animationDelay += 200),
                  duration: Duration(milliseconds: 500),
                  child: ElevatedButton.icon(
                    onPressed: _submitData,
                    icon: Icon(Icons.check_circle_outline_rounded, size: 22),
                    label: Text('ثبت و ذخیره اطلاعات'),
                    // استایل از theme
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
