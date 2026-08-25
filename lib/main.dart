import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'firebase_options.dart';
import 'login.dart';
import 'locale_controller.dart';
import 'l10n/app_localizations.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);

  // Enable persistent local cache for offline usage
  FirebaseFirestore.instance.settings = const Settings(
    persistenceEnabled: true,
    cacheSizeBytes: Settings.CACHE_SIZE_UNLIMITED,
  );

  await LocaleController.load();

  runApp(const myapp());
}

class myapp extends StatelessWidget {
  const myapp({super.key});

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<Locale>(
      valueListenable: LocaleController.notifier,
      builder: (context, locale, _) {
        return MaterialApp(
          debugShowCheckedModeBanner: false,
          locale: locale,
          supportedLocales: const [
            Locale('en'),
            Locale('ckb'), // Kurdish (Sorani)
          ],
          localizationsDelegates: const [
            AppLocalizations.delegate,
            GlobalMaterialLocalizations.delegate,
            GlobalWidgetsLocalizations.delegate,
            GlobalCupertinoLocalizations.delegate,
          ],
          // Kurdish (ckb) isn't recognized as RTL by the default bidi
          // detection, so force text direction explicitly here.
          builder: (context, child) {
            return Directionality(
              textDirection: locale.languageCode == 'ckb'
                  ? TextDirection.rtl
                  : TextDirection.ltr,
              child: child!,
            );
          },
          home: const LoginPage(),
        );
      },
    );
  }
}
