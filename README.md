# Flutter logins to a REST server example

A Flutter boilerplate example which logins to a REST server with i18n, theming, persistence and state management.

## Packages

- State management by <a href="https://github.com/rob333/flutter_mediator_persistence">Flutter Mediator Persistence</a>
  <a href="https://pub.dev/packages/flutter_mediator_persistence"><img src="https://img.shields.io/pub/v/flutter_mediator_persistence.svg" alt="pub.dev"></a> , a super easy state management package with built in persistence capability by using [shared_preferences](https://github.com/flutter/plugins/tree/master/packages/shared_preferences)[![Pub Package](https://img.shields.io/pub/v/shared_preferences.svg)](https://pub.dev/packages/shared_preferences).

- i18n by [Flutter_i18n](https://github.com/ilteoood/flutter_i18n)
  [![Pub Package](https://img.shields.io/pub/v/flutter_i18n.svg)](https://pub.dev/packages/flutter_i18n)

- REST api by [http](https://github.com/dart-lang/http)[![Pub Package](https://img.shields.io/pub/v/http.svg)](https://pub.dev/packages/http), a composable, Future-based library for making HTTP requests.

- REST server at [reqres.in](https://reqres.in/), login with account: `eve.holt@reqres.in`, password is `cityslicka` .

## Setting up

### Step 1. Add the following dependency to pubspec.yaml of your flutter project:

```yaml
dependencies:
  flutter_i18n: ^0.22.3
  flutter_mediator_persistence: ^1.0.0
  http:

  # ...
flutter:
  # ...
  assets:
    - assets/flutter_i18n/
```

### Step 2. Import these packages in [main.dart][]

```dart
import 'package:flutter/material.dart';
import 'package:flutter_i18n/flutter_i18n.dart';
import 'package:flutter_i18n/loaders/decoders/json_decode_strategy.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_mediator_persistence/mediator.dart';
```

### Step 3. Initial the state management in `main()`

```dart
Future<void> main() async {
  await initGlobalPersist();

  runApp(
    globalHost(child: MyApp()),
  );
}
```

### Step 4. Import [var.dart][] in the pages (with show/hide)

```dart
import '/var.dart' show locale;
```

```dart
import '/var.dart' hide locale;
```

<br>

## Theming

### Step 1. Declare the persistent watched variable in [var.dart][]

```dart
//* Declare the persistent watched variable with `defaultVal.globalPersist('key')`
final themeIdx = 1.globalPersist('themeIdx');
```

### Step 2. Prepare the `themeData` in [theme.dart][]

### Step 3. Register the widget in [main.dart][]

```dart
class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    //* Create a widget with `globalConsume` or `watchedVar.consume`
    //* to register the watched variable to the host to rebuild it when updating.
    //* `watchedVar.consume()` is a helper function to
    //* `touch()` itself first and then `globalConsume`.
    return themeIdx.consume( // register the widget
      () => MaterialApp(
        // ...
        theme: themeData(themeIdx.value), // set the themeData
```

### Step 4. Implement a update function (in [var.dart][])

```dart
/// Change the theme, by ThememData `int` [idx]
void changeTheme(int idx) {
  idx = idx.clamp(0, 1);
  if (idx != themeIdx.value) {
    themeIdx.value = idx; // will rebuild the registered widget automatically
  }
}
```

<br>

## i18n

### Step 1-1. Declare the persistent watched variable in [var.dart][]

```dart
const DefaultLocale = 'en';
//* Declare the persistent watched variable with `defaultVal.globalPersist('key')`
final locale = DefaultLocale.globalPersist('locale');
```

### Step 1-2 (optional). Write a String extension for i18n (in [var.dart][]).

```dart
extension StringI18n on String {
  /// String extension for i18n.
  String i18n(BuildContext context) {
    return FlutterI18n.translate(context, this);
  }

  /// String extension for i18n and `locale.consume` the widget
  /// to register the widget for the state management.
  Widget ci18n(BuildContext context, {TextStyle? style}) {
    return locale.consume(
      () => Text(FlutterI18n.translate(context, this), style: style),
    );
  }
}
```

### Step 2. Prepare the locale files in [assets/flutter_i18n/][]

### Step 3. Register the widget that needs to do i18n (in [lib/pages/locale_page.dart][]).

```dart
locale.consume(() => Text('${'app.hello'.i18n(context)} ')),
```

Or use the `ci18n` extension (in [lib/pages/login_page.dart][]).

```dart
'login.title'.ci18n(
  context,
  style: Theme.of(context).textTheme.headline2,
),
```

### Step 4. Implement a update function (in [var.dart][])

```dart
/// Change the locale, by `String`[countryCode]
Future<void> changeLocale(BuildContext context, String countryCode) async {
  if (countryCode != locale.value) {
    final loc = Locale(countryCode);
    await FlutterI18n.refresh(context, loc);
    //* Step4: Make an update to the watched variable.
    //* The persistent watched variable will update the persistent value automatically.
    locale.value = countryCode; // will rebuild the registered widget
  }
}
```

<br>

## ScrollOffset effect

[lib/pages/scroll_page.dart]

### Step 1. Declare the persistent watched variable

```dart
//* Declare the persistent watched variable with `defaultVal.globalPersist('key')`
final scrollOffset = 0.0.globalPersist('ScrollOffsetDemo');
```

### Step 2. Initial the `scrollController` with the persistent watched variable

```dart
class _ScrollPageState extends State<ScrollPage> {
  //* Initialize the scroll offset with the persistent value.
  final _scrollController =
      ScrollController(initialScrollOffset: scrollOffset.value);

  @override
  void initState() {
    _scrollController.addListener(() {
      //* Make an update to the watched variable.
      scrollOffset.value = _scrollController.offset;
    });
    super.initState();
  }
```

### Step 3. Register the widget

```dart
class CustomAppBar extends StatelessWidget {
  const CustomAppBar({required this.header, Key? key}) : super(key: key);
  final Widget header;

  @override
  Widget build(BuildContext context) {
    //* Step3: Create a widget with `globalConsume` or `watchedVar.consume`
    //* to register the watched variable to the host to rebuild it when updating.
    return globalConsume(
      () => Container(
        padding: const EdgeInsets.symmetric(
          vertical: 10.0,
          horizontal: 24.0,
        ),
        color: Colors.black
            .withOpacity((scrollOffset.value / 350).clamp(0, 1).toDouble()),
        child: header,
      ),
    );
  }
}
```

[assets/flutter_i18n/]: https://github.com/rob333/Flutter-logins-to-a-REST-server-with-i18n-theming-persistence-and-state-management/tree/main/assets/flutter_i18n
[main.dart]: https://github.com/rob333/Flutter-logins-to-a-REST-server-with-i18n-theming-persistence-and-state-management/blob/main/lib/main.dart
[var.dart]: https://github.com/rob333/Flutter-logins-to-a-REST-server-with-i18n-theming-persistence-and-state-management/blob/main/lib/var.dart
[theme.dart]: https://github.com/rob333/Flutter-logins-to-a-REST-server-with-i18n-theming-persistence-and-state-management/blob/main/lib/theme.dart
[lib/pages/login_page.dart]: https://github.com/rob333/Flutter-logins-to-a-REST-server-with-i18n-theming-persistence-and-state-management/blob/main/lib/pages/login_page.dart
[lib/pages/home_page.dart]: https://github.com/rob333/Flutter-logins-to-a-REST-server-with-i18n-theming-persistence-and-state-management/blob/main/lib/pages/home_page.dart
[lib/pages/locale_page.dart]: https://github.com/rob333/Flutter-logins-to-a-REST-server-with-i18n-theming-persistence-and-state-management/blob/main/lib/pages/locale_page.dart
[lib/pages/scroll_page.dart]: https://github.com/rob333/Flutter-logins-to-a-REST-server-with-i18n-theming-persistence-and-state-management/blob/main/lib/pages/scroll_page.dart
