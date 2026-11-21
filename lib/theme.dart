import 'package:material_ui/material_ui.dart';

/// Palette taken from the Khedma mockups: black on white, soft grey fields,
/// a green "Accept" and a red "Cancel".
class KColors {
  static const ink = Color(0xFF0A0A0A);
  static const paper = Colors.white;
  static const field = Color(0xFFF2F2F2);
  static const line = Color(0xFFE4E4E4);
  static const muted = Color(0xFF6B6B6B);
  static const accept = Color(0xFF22C55E);
  static const danger = Color(0xFFE5251B);
  static const link = Color(0xFF7AA7C7);
  static const star = Color(0xFFF5B301);
}

/// The wordmark in the mockups is a bold serif.
const String kSerif = 'Georgia';

ThemeData buildTheme() {
  final base = ColorScheme.fromSeed(
    seedColor: KColors.ink,
    brightness: Brightness.light,
  ).copyWith(
    primary: KColors.ink,
    onPrimary: Colors.white,
    surface: Colors.white,
    error: KColors.danger,
  );

  OutlineInputBorder border([Color c = Colors.transparent]) => OutlineInputBorder(
        borderRadius: BorderRadius.circular(10),
        borderSide: BorderSide(color: c, width: 1.2),
      );

  return ThemeData(
    useMaterial3: true,
    colorScheme: base,
    scaffoldBackgroundColor: Colors.white,
    appBarTheme: const AppBarTheme(
      backgroundColor: Colors.white,
      foregroundColor: KColors.ink,
      elevation: 0,
      scrolledUnderElevation: 0,
      centerTitle: false,
      titleTextStyle: TextStyle(
        color: KColors.ink,
        fontSize: 20,
        fontWeight: FontWeight.w700,
      ),
    ),
    inputDecorationTheme: InputDecorationTheme(
      filled: true,
      fillColor: KColors.field,
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
      hintStyle: const TextStyle(color: KColors.muted),
      border: border(),
      enabledBorder: border(),
      focusedBorder: border(KColors.ink),
      errorBorder: border(KColors.danger),
      focusedErrorBorder: border(KColors.danger),
    ),
    filledButtonTheme: FilledButtonThemeData(
      style: FilledButton.styleFrom(
        backgroundColor: KColors.ink,
        foregroundColor: Colors.white,
        minimumSize: const Size.fromHeight(52),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
        textStyle: const TextStyle(fontWeight: FontWeight.w600, fontSize: 15),
      ),
    ),
    navigationBarTheme: NavigationBarThemeData(
      backgroundColor: Colors.white,
      indicatorColor: KColors.ink,
      iconTheme: WidgetStateProperty.resolveWith((s) => IconThemeData(
            color: s.contains(WidgetState.selected) ? Colors.white : KColors.muted,
          )),
      labelTextStyle: WidgetStateProperty.resolveWith((s) => TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.w600,
            color: s.contains(WidgetState.selected) ? KColors.ink : KColors.muted,
          )),
    ),
    dividerColor: KColors.line,
  );
}
