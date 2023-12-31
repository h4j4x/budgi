import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:month_year_picker/month_year_picker.dart';

import 'app/router.dart';
import 'app/theme.dart';
import 'di.dart';
import 'l10n/l10n.dart';

void main() async {
  await DI().setup();

  LicenseRegistry.addLicense(() async* {
    final license = await rootBundle.loadString('fonts/Open_Sans/OFL.txt');
    yield LicenseEntryWithLineBreaks(['google_fonts'], license);
  });

  initTheme();
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
      localizationsDelegates: const [
        ...L10n.localizationsDelegates,
        MonthYearPickerLocalizations.delegate,
      ],
      supportedLocales: L10n.supportedLocales,
      routerConfig: router,
    );
  }
}
