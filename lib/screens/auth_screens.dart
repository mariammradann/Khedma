import 'package:material_ui/material_ui.dart';

import '../main.dart';
import '../models.dart';
import '../state.dart';
import '../theme.dart';
import '../widgets.dart';

void _enterApp(BuildContext context, UserRole role) {
  Navigator.pushNamedAndRemoveUntil(
    context,
    role == UserRole.customer ? Routes.customer : Routes.worker,
    (_) => false,
  );
}

String? _required(String? v, String what) =>
    (v == null || v.trim().isEmpty) ? 'Enter $what' : null;

/// Login: email/phone + password, "Choose user" (customer / worker),
/// forgot password, terms and sign-up link.
class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _form = GlobalKey<FormState>();
  final _id = TextEditingController();
  final _pw = TextEditingController();
  UserRole? _role;
  bool _hide = true;

  @override
  void dispose() {
    _id.dispose();
    _pw.dispose();
    super.dispose();
  }

  void _submit() {
    if (!_form.currentState!.validate()) return;
    appState.login(identifier: _id.text.trim(), role: _role!);
    _enterApp(context, _role!);
  }

  void _forgot() {
    final email = TextEditingController(text: _id.text);
    showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      showDragHandle: true,
      builder: (ctx) => Padding(
        padding: EdgeInsets.fromLTRB(
            24, 8, 24, 24 + MediaQuery.of(ctx).viewInsets.bottom),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('Retrieve your password',
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.w700)),
            const SizedBox(height: 6),
            const Text("Enter your e-mail or phone and we'll send a reset code.",
                style: TextStyle(color: KColors.muted)),
            const SizedBox(height: 16),
            TextField(
              controller: email,
              decoration: const InputDecoration(hintText: 'Enter E-mail or Phone'),
            ),
            const SizedBox(height: 16),
            FilledButton(
              onPressed: () {
                Navigator.pop(ctx);
                showSnack(context, 'Reset code sent');
              },
              child: const Text('Send code'),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.fromLTRB(24, 32, 24, 24),
          child: Form(
            key: _form,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                const Center(child: KhedmaLogo(size: 64, showWordmark: false)),
                const SizedBox(height: 14),
                const Text('Khedma',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                        fontFamily: kSerif,
                        fontWeight: FontWeight.w700,
                        fontSize: 26)),
                const SizedBox(height: 4),
                const Text('Login',
                    textAlign: TextAlign.center,
                    style: TextStyle(fontWeight: FontWeight.w600)),
                const SizedBox(height: 32),
                TextFormField(
                  controller: _id,
                  keyboardType: TextInputType.emailAddress,
                  decoration: const InputDecoration(hintText: 'Enter E-mail or Phone'),
                  validator: (v) => _required(v, 'your e-mail or phone'),
                ),
                const SizedBox(height: 12),
                TextFormField(
                  controller: _pw,
                  obscureText: _hide,
                  decoration: InputDecoration(
                    hintText: 'Enter Password',
                    suffixIcon: IconButton(
                      icon: Icon(_hide ? Icons.visibility_off : Icons.visibility,
                          size: 20),
                      onPressed: () => setState(() => _hide = !_hide),
                    ),
                  ),
                  validator: (v) => (v == null || v.length < 6)
                      ? 'Password must be at least 6 characters'
                      : null,
                ),
                Align(
                  alignment: Alignment.centerLeft,
                  child: TextButton(
                    onPressed: _forgot,
                    style: TextButton.styleFrom(
                      foregroundColor: KColors.ink,
                      padding: const EdgeInsets.symmetric(horizontal: 2),
                      textStyle: const TextStyle(
                          fontSize: 12, fontWeight: FontWeight.w600),
                    ),
                    child: const Text('Forget password'),
                  ),
                ),
                const SizedBox(height: 4),
                DropdownButtonFormField<UserRole>(
                  value: _role, // ignore: deprecated_member_use
                  hint: const Text('Choose user'),
                  decoration: const InputDecoration(),
                  borderRadius: BorderRadius.circular(10),
                  items: [
                    for (final r in UserRole.values)
                      DropdownMenuItem(value: r, child: Text(r.name)),
                  ],
                  onChanged: (r) => setState(() => _role = r),
                  validator: (r) => r == null ? 'Choose customer or worker' : null,
                ),
                const SizedBox(height: 32),
                FilledButton(onPressed: _submit, child: const Text('Login')),
                const SizedBox(height: 16),
                const Text(
                  'By clicking continue, you agree to our Terms of Service and Privacy Policy',
                  textAlign: TextAlign.center,
                  style: TextStyle(fontSize: 10, color: KColors.muted),
                ),
                const SizedBox(height: 24),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Text("Don't have an account? "),
                    GestureDetector(
                      onTap: () => Navigator.pushNamed(context, Routes.signup),
                      child: const Text('Sign up',
                          style: TextStyle(
                              color: KColors.link, fontWeight: FontWeight.w600)),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

/// Create an account (customer requirement: "create an account").
class SignUpScreen extends StatefulWidget {
  const SignUpScreen({super.key});

  @override
  State<SignUpScreen> createState() => _SignUpScreenState();
}

class _SignUpScreenState extends State<SignUpScreen> {
  final _form = GlobalKey<FormState>();
  final _name = TextEditingController();
  final _email = TextEditingController();
  final _phone = TextEditingController();
  final _pw = TextEditingController();
  UserRole _role = UserRole.customer;

  @override
  void dispose() {
    _name.dispose();
    _email.dispose();
    _phone.dispose();
    _pw.dispose();
    super.dispose();
  }

  void _submit() {
    if (!_form.currentState!.validate()) return;
    appState.signUp(
      name: _name.text.trim(),
      email: _email.text.trim(),
      phone: _phone.text.trim(),
      role: _role,
    );
    _enterApp(context, _role);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Create account')),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.fromLTRB(24, 8, 24, 24),
          child: Form(
            key: _form,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                const Text('I want to join as',
                    style: TextStyle(fontWeight: FontWeight.w600)),
                const SizedBox(height: 10),
                SegmentedButton<UserRole>(
                  showSelectedIcon: false,
                  segments: const [
                    ButtonSegment(
                        value: UserRole.customer,
                        icon: Icon(Icons.person_outline),
                        label: Text('Customer')),
                    ButtonSegment(
                        value: UserRole.worker,
                        icon: Icon(Icons.handyman_outlined),
                        label: Text('Worker')),
                  ],
                  selected: {_role},
                  onSelectionChanged: (s) => setState(() => _role = s.first),
                  style: SegmentedButton.styleFrom(
                    selectedBackgroundColor: KColors.ink,
                    selectedForegroundColor: Colors.white,
                  ),
                ),
                const SizedBox(height: 20),
                TextFormField(
                  controller: _name,
                  textCapitalization: TextCapitalization.words,
                  decoration: const InputDecoration(hintText: 'Full name'),
                  validator: (v) => _required(v, 'your name'),
                ),
                const SizedBox(height: 12),
                TextFormField(
                  controller: _email,
                  keyboardType: TextInputType.emailAddress,
                  decoration: const InputDecoration(hintText: 'E-mail address'),
                  validator: (v) => (v == null || !v.contains('@'))
                      ? 'Enter a valid e-mail'
                      : null,
                ),
                const SizedBox(height: 12),
                TextFormField(
                  controller: _phone,
                  keyboardType: TextInputType.phone,
                  decoration: const InputDecoration(hintText: 'Mobile phone'),
                  validator: (v) => _required(v, 'your phone number'),
                ),
                const SizedBox(height: 12),
                TextFormField(
                  controller: _pw,
                  obscureText: true,
                  decoration: const InputDecoration(hintText: 'Password'),
                  validator: (v) => (v == null || v.length < 6)
                      ? 'Password must be at least 6 characters'
                      : null,
                ),
                const SizedBox(height: 28),
                FilledButton(onPressed: _submit, child: const Text('Create account')),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
