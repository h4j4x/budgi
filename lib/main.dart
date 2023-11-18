import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import 'di.dart';
import 'l10n/l10n.dart';
import 'router.dart';
import 'theme.dart';

void main() {
  LicenseRegistry.addLicense(() async* {
    final license = await rootBundle.loadString('fonts/Open_Sans/OFL.txt');
    yield LicenseEntryWithLineBreaks(['google_fonts'], license);
  });

  initTheme();
  DI().setup();
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp.router(
      onGenerateTitle: (context) => L10n.of(context).appTitle,
      theme: lightTheme,
      darkTheme: darkTheme,
      localizationsDelegates: L10n.localizationsDelegates,
      supportedLocales: L10n.supportedLocales,
      routerConfig: router,
    );
  }
}
