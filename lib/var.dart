import 'package:flutter/widgets.dart';
import 'package:flutter_i18n/flutter_i18n.dart';
import 'package:flutter_mediator_lite/mediator.dart';
import 'package:shared_preferences/shared_preferences.dart';

//* Login token from the REST server.
var loginToken = '';

//* Declare a global scope SharedPreferences.
late SharedPreferences prefs;

//* Step1B: Declare the persistent watched variable with `late Rx<Type>`
late Rx<String> locale;
const DefaultLocale = 'en';

//* Step1B: Declare the persistent watched variable with `late Rx<Type>`
late Rx<int> themeIdx;
const DefaultThemeIdx = 1;

/// initialize the persistent watched variables
/// whose value is stored by SharedPreferences.
Future<void>? initVars() async {
  // To make sure SharedPreferences works.
  WidgetsFlutterBinding.ensureInitialized();

  prefs = await SharedPreferences.getInstance();
  locale = globalWatch(prefs.getString('locale') ?? DefaultLocale);
  themeIdx = globalWatch(prefs.getInt('themeIdx') ?? DefaultThemeIdx);
}

/// Change the locale, by `String`[countryCode]
/// and store the setting with SharedPreferences.
Future<void> changeLocale(BuildContext context, String countryCode) async {
  final loc = Locale(countryCode);
  await FlutterI18n.refresh(context, loc);
  //* Step4: Make an update to the watched variable.
  locale.value = countryCode;

  await prefs.setString('locale', countryCode);
}

/// Change the theme, by ThememData `int` [idx]
/// and store the setting with SharedPreferences.
Future<void> changeTheme(int idx) async {
  idx = idx.clamp(0, 1);
  if (idx != themeIdx.value) {
    themeIdx.value = idx;

    await prefs.setInt('themeIdx', idx);
  }
}

extension StringI18n on String {
  /// String extension for i18n.
  String i18n(BuildContext context) {
    return FlutterI18n.translate(context, this);
  }

  /// String extension for i18n and `locale.consume` the widget.
  Widget ci18n(BuildContext context, {TextStyle? style}) {
    return locale.consume(
      () => Text(FlutterI18n.translate(context, this), style: style),
    );
  }
}

/// Get the screen width
double getScreenWidth(BuildContext context) =>
    MediaQuery.of(context).size.width;

/// Get the screen height
double getScreenHeight(BuildContext context) =>
    MediaQuery.of(context).size.height;
