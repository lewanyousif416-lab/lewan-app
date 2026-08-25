import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// Global controller that holds the currently selected app locale.
/// main.dart listens to this and rebuilds MaterialApp when it changes.
/// Any page can call LocaleController.setLocale(...) to switch language
/// (e.g. from a language icon in the AppBar or the dashboard drawer).
class LocaleController {
  LocaleController._();

  static final ValueNotifier<Locale> notifier =
      ValueNotifier<Locale>(const Locale('en'));

  static const _prefKey = 'app_locale_code';

  static Future<void> load() async {
    final prefs = await SharedPreferences.getInstance();
    final code = prefs.getString(_prefKey);
    if (code != null) {
      notifier.value = Locale(code);
    }
  }

  static Future<void> setLocale(Locale locale) async {
    notifier.value = locale;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_prefKey, locale.languageCode);
  }

  static bool get isKurdish => notifier.value.languageCode == 'ckb';
}

/// A reusable language-switcher icon button you can drop into any AppBar's
/// `actions: []` list to let the user toggle between English and Kurdish.
class LanguageSwitcherAction extends StatelessWidget {
  const LanguageSwitcherAction({super.key});

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<Locale>(
      valueListenable: LocaleController.notifier,
      builder: (context, locale, _) {
        return PopupMenuButton<String>(
          icon: const Icon(Icons.language),
          tooltip: 'Language / زمان',
          onSelected: (code) => LocaleController.setLocale(Locale(code)),
          itemBuilder: (context) => [
            CheckedPopupMenuItem(
              value: 'en',
              checked: locale.languageCode == 'en',
              child: const Text('English'),
            ),
            CheckedPopupMenuItem(
              value: 'ckb',
              checked: locale.languageCode == 'ckb',
              child: const Text('کوردی'),
            ),
          ],
        );
      },
    );
  }
}