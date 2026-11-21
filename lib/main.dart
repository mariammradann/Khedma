import 'package:material_ui/material_ui.dart';
import 'package:flutter/services.dart';

import 'screens/auth_screens.dart';
import 'screens/customer_shell.dart';
import 'screens/receipt_screen.dart';
import 'screens/request_task_screen.dart';
import 'screens/tracking_screen.dart';
import 'screens/welcome_screen.dart';
import 'screens/worker_shell.dart';
import 'theme.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  SystemChrome.setPreferredOrientations([DeviceOrientation.portraitUp]);
  runApp(const KhedmaApp());
}

class Routes {
  static const welcome = '/';
  static const login = '/login';
  static const signup = '/signup';
  static const customer = '/customer';
  static const worker = '/worker';
  static const request = '/request';
  static const tracking = '/tracking';
  static const receipt = '/receipt';
}

class KhedmaApp extends StatelessWidget {
  const KhedmaApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Khedma',
      debugShowCheckedModeBanner: false,
      theme: buildTheme(),
      initialRoute: Routes.welcome,
      onGenerateRoute: (settings) {
        Widget page;
        switch (settings.name) {
          case Routes.welcome:
            page = const WelcomeScreen();
          case Routes.login:
            page = const LoginScreen();
          case Routes.signup:
            page = const SignUpScreen();
          case Routes.customer:
            page = const CustomerShell();
          case Routes.worker:
            page = const WorkerShell();
          case Routes.request:
            page = RequestTaskScreen(presetCategory: settings.arguments as String?);
          case Routes.tracking:
            page = TrackingScreen(taskId: settings.arguments! as String);
          case Routes.receipt:
            page = ReceiptScreen(taskId: settings.arguments! as String);
          default:
            page = const WelcomeScreen();
        }
        return MaterialPageRoute<void>(builder: (_) => page, settings: settings);
      },
    );
  }
}
