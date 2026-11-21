import 'package:material_ui/material_ui.dart';

import '../main.dart';
import '../widgets.dart';

/// Splash / welcome: logo + "Lets get started".
class WelcomeScreen extends StatelessWidget {
  const WelcomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(24, 0, 24, 32),
          child: Column(
            children: [
              const Spacer(flex: 3),
              const KhedmaLogo(),
              const Spacer(flex: 4),
              FilledButton(
                onPressed: () =>
                    Navigator.pushReplacementNamed(context, Routes.login),
                child: const Text('Lets get started'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
