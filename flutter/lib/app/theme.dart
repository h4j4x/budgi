import 'package:flex_color_scheme/flex_color_scheme.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

void initTheme() {
  GoogleFonts.config.allowRuntimeFetching = false;
}

// https://rydmike.com/flexcolorscheme/themesplayground-latest/
const scheme = FlexScheme.materialBaseline;

// https://pub.dev/packages/google_fonts
final fontFamily = GoogleFonts.openSans().fontFamily;

// https://mui.com/material-ui/customization/palette/
extension ColorSchemeExtension on ColorScheme {
  Color get success => brightness == Brightness.light
      ? const Color(0xFF2e7d32)
      : const Color(0xFF1b5e20);

  Color get warning => brightness == Brightness.light
      ? const Color(0xFFed6c02)
      : const Color(0xFFe65100);
}

final lightTheme = FlexThemeData.light(
  scheme: scheme,
  surfaceMode: FlexSurfaceMode.levelSurfacesLowScaffold,
  blendLevel: 7,
  subThemesData: const FlexSubThemesData(
    blendOnLevel: 10,
    blendOnColors: false,
    useTextTheme: true,
    useM2StyleDividerInM3: true,
    alignedDropdown: true,
    useInputDecoratorThemeInDialogs: true,
  ),
  visualDensity: FlexColorScheme.comfortablePlatformDensity,
  useMaterial3: true,
  swapLegacyOnMaterial3: true,
  fontFamily: fontFamily,
);

final darkTheme = FlexThemeData.dark(
  scheme: scheme,
  surfaceMode: FlexSurfaceMode.levelSurfacesLowScaffold,
  blendLevel: 13,
  subThemesData: const FlexSubThemesData(
    blendOnLevel: 20,
    useTextTheme: true,
    useM2StyleDividerInM3: true,
    alignedDropdown: true,
    useInputDecoratorThemeInDialogs: true,
  ),
  visualDensity: FlexColorScheme.comfortablePlatformDensity,
  useMaterial3: true,
  swapLegacyOnMaterial3: true,
  fontFamily: fontFamily,
);
