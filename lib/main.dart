import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import 'controller/auth_controller.dart';
import 'controller/locale_controller.dart';
import 'controller/theme_controller.dart';
import 'core/constant/app_router.dart';
import 'core/database/local_database_bootstrap.dart';
import 'l10n/app_localizations.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  GoRouter.optionURLReflectsImperativeAPIs = true;
  await SystemChrome.setPreferredOrientations([DeviceOrientation.portraitUp, DeviceOrientation.portraitDown]);
  await LocaleController.instance.load();
  await ThemeController.instance.load();
  await AuthController.restoreGlobals();
  await LocalDatabaseBootstrap.ensureReady();
  runApp(const ProviderScope(child: MyApp()));
}

class MyApp extends ConsumerWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) => AnimatedBuilder(
    animation: Listenable.merge([LocaleController.instance, ThemeController.instance]),
    builder: (context, _) => MaterialApp.router(
      debugShowCheckedModeBanner: false,
      onGenerateTitle: (context) => AppLocalizations.of(context)!.appTitle,
      theme: ThemeController.instance.theme,
      routerConfig: ref.watch(goRouterProvider),
      locale: LocaleController.instance.locale,
      supportedLocales: AppLocalizations.supportedLocales,
      localizationsDelegates: const [
        AppLocalizations.delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],
    ),
  );
}
