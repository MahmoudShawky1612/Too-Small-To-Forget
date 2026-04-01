// lib/main.dart
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:toosmalltoforget/screens/home_screen.dart';
import 'package:toosmalltoforget/services/database_helper.dart';
import 'package:toosmalltoforget/services/notification_service.dart';
import 'package:toosmalltoforget/theme/app_colors.dart';
import 'package:toosmalltoforget/theme/app_theme.dart';


Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await _initializeApp();

  runApp(const MyApp());
}

Future<void> _initializeApp() async {
  final notificationService = NotificationService();

  await notificationService.init((payload) {
    // Handle notification tap here if needed.
  });

  await notificationService.requestPermissions();
  await _rescheduleReminders(notificationService);

  SystemChrome.setSystemUIOverlayStyle(
    const SystemUiOverlayStyle(
      statusBarColor: Colors.transparent,
      statusBarIconBrightness: Brightness.light,
      systemNavigationBarColor: AppColors.background,
      systemNavigationBarIconBrightness: Brightness.light,
    ),
  );
}

Future<void> _rescheduleReminders(
    NotificationService notificationService,
    ) async {
  final database = DatabaseHelper();
  final reminders = await database.getFutureReminders();

  for (final memory in reminders) {
    final reminderDate = memory.reminder;
    final memoryId = memory.id;

    if (reminderDate == null || memoryId == null) continue;

    await notificationService.scheduleNotification(
      id: memoryId,
      title: 'Reminder: ${memory.title}',
      body: memory.details.isNotEmpty
          ? memory.details
          : 'Tap to view memory',
      scheduledDate: reminderDate,
    );
  }
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return ScreenUtilInit(
      designSize: const Size(375, 812),
      minTextAdapt: true,
      splitScreenMode: true,
      builder: (_, __) {
        return MaterialApp(
          title: 'Too Small To Forget',
          debugShowCheckedModeBanner: false,
          theme: AppTheme.dark,
          home: const HomeScreen(),
        );
      },
    );
  }
}
