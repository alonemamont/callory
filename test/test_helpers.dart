import 'package:flutter/material.dart';
import 'package:callory/l10n/app_localizations.dart';

Widget wrapWithLocalizations(Widget child) {
  return MaterialApp(
    localizationsDelegates: AppLocalizations.localizationsDelegates,
    supportedLocales: AppLocalizations.supportedLocales,
    home: child,
  );
}
