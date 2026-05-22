import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:hijri/hijri_calendar.dart';
import 'package:hijri_picker/hijri_picker.dart';

void main() => runApp(const HijriPickerDemoApp());

class HijriPickerDemoApp extends StatefulWidget {
  const HijriPickerDemoApp({super.key});

  @override
  State<HijriPickerDemoApp> createState() => _HijriPickerDemoAppState();
}

class _HijriPickerDemoAppState extends State<HijriPickerDemoApp> {
  Locale _locale = const Locale('en', 'US');
  ThemeMode _themeMode = ThemeMode.system;

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Hijri Picker Demo',
      debugShowCheckedModeBanner: false,
      locale: _locale,
      themeMode: _themeMode,
      localizationsDelegates: const [
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],
      supportedLocales: const [
        Locale('en', 'US'),
        Locale('ar', 'SA'),
      ],
      theme: ThemeData(
        useMaterial3: true,
        colorScheme: ColorScheme.fromSeed(
          seedColor: Colors.amber,
          brightness: Brightness.light,
        ),
      ),
      darkTheme: ThemeData(
        useMaterial3: true,
        colorScheme: ColorScheme.fromSeed(
          seedColor: Colors.blue,
          brightness: Brightness.dark,
        ),
      ),
      home: HomePage(
        locale: _locale,
        themeMode: _themeMode,
        onLocaleChanged: (l) => setState(() => _locale = l),
        onThemeModeChanged: (m) => setState(() => _themeMode = m),
      ),
    );
  }
}

class HomePage extends StatefulWidget {
  const HomePage({
    super.key,
    required this.locale,
    required this.themeMode,
    required this.onLocaleChanged,
    required this.onThemeModeChanged,
  });

  final Locale locale;
  final ThemeMode themeMode;
  final ValueChanged<Locale> onLocaleChanged;
  final ValueChanged<ThemeMode> onThemeModeChanged;

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  HijriDateTime _dialogResult = HijriDateTime.now();
  HijriDateTime _inlineDate = HijriDateTime.now();
  HijriDateTime? _formFieldDate;

  String get _hijriLanguage => widget.locale.languageCode;

  HijriDateTime get _firstDate {
    final now = HijriDateTime.now();
    return HijriDateTime(now.year - 5, 1, 1);
  }

  HijriDateTime get _lastDate {
    final now = HijriDateTime.now();
    return HijriDateTime(now.year + 5, 12, 29);
  }

  // Demo predicate: disable Fridays.
  bool _allowDay(HijriDateTime d) =>
      d.toGregorian().weekday != DateTime.friday;

  /// Walks forward from [start] until the predicate accepts the day.
  /// Flutter asserts that initialDate satisfies selectableDayPredicate, so we
  /// have to skip today if today happens to be a Friday.
  HijriDateTime _firstAllowedDay(HijriDateTime start) {
    final delegate = HijriCalendarDelegate(language: _hijriLanguage);
    HijriDateTime d = start;
    while (!_allowDay(d)) {
      d = delegate.addDaysToDate(d, 1);
    }
    return d;
  }

  Future<void> _openBasicDialog() async {
    final HijriDateTime? picked = await showHijriDatePicker(
      context: context,
      initialDate: _dialogResult,
      firstDate: _firstDate,
      lastDate: _lastDate,
      hijriLanguage: _hijriLanguage,
    );
    if (picked != null) {
      setState(() => _dialogResult = picked);
    }
  }

  Future<void> _openFullDialog() async {
    final HijriDateTime? picked = await showHijriDatePicker(
      context: context,
      initialDate: _firstAllowedDay(_dialogResult),
      firstDate: _firstDate,
      lastDate: _lastDate,
      initialEntryMode: DatePickerEntryMode.calendar,
      initialDatePickerMode: DatePickerMode.day,
      helpText: 'SELECT HIJRI DATE',
      cancelText: 'CANCEL',
      confirmText: 'OK',
      errorFormatText: 'Invalid format.',
      errorInvalidText: 'Date out of range.',
      fieldHintText: 'dd/mm/yyyy',
      fieldLabelText: 'Hijri date',
      selectableDayPredicate: _allowDay,
      hijriLanguage: _hijriLanguage,
    );
    if (picked != null) {
      setState(() => _dialogResult = picked);
    }
  }

  Future<void> _openInputOnly() async {
    final HijriDateTime? picked = await showHijriDatePicker(
      context: context,
      initialDate: _dialogResult,
      firstDate: _firstDate,
      lastDate: _lastDate,
      initialEntryMode: DatePickerEntryMode.inputOnly,
      fieldHintText: 'dd/mm/yyyy',
      fieldLabelText: 'Hijri date',
      hijriLanguage: _hijriLanguage,
    );
    if (picked != null) {
      setState(() => _dialogResult = picked);
    }
  }

  @override
  Widget build(BuildContext context) {
    final HijriCalendarDelegate delegate =
        HijriCalendarDelegate(language: _hijriLanguage);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Hijri Picker Demo'),
        actions: [
          IconButton(
            tooltip: 'Toggle language',
            icon: Text(
              _hijriLanguage.toUpperCase(),
              style: const TextStyle(fontWeight: FontWeight.bold),
            ),
            onPressed: () {
              widget.onLocaleChanged(
                _hijriLanguage == 'en'
                    ? const Locale('ar', 'SA')
                    : const Locale('en', 'US'),
              );
            },
          ),
          IconButton(
            tooltip: 'Cycle theme',
            icon: Icon(switch (widget.themeMode) {
              ThemeMode.light => Icons.light_mode,
              ThemeMode.dark => Icons.dark_mode,
              ThemeMode.system => Icons.brightness_auto,
            }),
            onPressed: () {
              widget.onThemeModeChanged(switch (widget.themeMode) {
                ThemeMode.system => ThemeMode.light,
                ThemeMode.light => ThemeMode.dark,
                ThemeMode.dark => ThemeMode.system,
              });
            },
          ),
        ],
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          _SectionCard(
            title: '1. Dialog (showHijriDatePicker)',
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                _DateDisplay(
                  label: 'Selected',
                  value: _dialogResult,
                  hijriLanguage: _hijriLanguage,
                ),
                const SizedBox(height: 12),
                FilledButton.icon(
                  onPressed: _openBasicDialog,
                  icon: const Icon(Icons.event),
                  label: const Text('Open (basic)'),
                ),
                const SizedBox(height: 8),
                OutlinedButton.icon(
                  onPressed: _openFullDialog,
                  icon: const Icon(Icons.tune),
                  label: const Text('Open (all options, no Fridays)'),
                ),
                const SizedBox(height: 8),
                OutlinedButton.icon(
                  onPressed: _openInputOnly,
                  icon: const Icon(Icons.keyboard),
                  label: const Text('Open (input-only)'),
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),
          _SectionCard(
            title: '2. Embedded CalendarDatePicker',
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                _DateDisplay(
                  label: 'Selected',
                  value: _inlineDate,
                  hijriLanguage: _hijriLanguage,
                ),
                const SizedBox(height: 8),
                CalendarDatePicker(
                  initialDate: _inlineDate,
                  firstDate: _firstDate,
                  lastDate: _lastDate,
                  onDateChanged: (DateTime d) {
                    setState(() => _inlineDate = d as HijriDateTime);
                  },
                  calendarDelegate: delegate,
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),
          _SectionCard(
            title: '3. InputDatePickerFormField',
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                if (_formFieldDate != null)
                  _DateDisplay(
                    label: 'Submitted',
                    value: _formFieldDate!,
                    hijriLanguage: _hijriLanguage,
                  )
                else
                  Text(
                    'Type a Hijri date and press enter / Done.',
                    style: Theme.of(context).textTheme.bodyMedium,
                  ),
                const SizedBox(height: 12),
                InputDatePickerFormField(
                  initialDate: _formFieldDate ?? _dialogResult,
                  firstDate: _firstDate,
                  lastDate: _lastDate,
                  fieldHintText: 'dd/mm/yyyy',
                  fieldLabelText: 'Hijri date',
                  errorFormatText: 'Invalid format.',
                  errorInvalidText: 'Date out of range.',
                  onDateSubmitted: (DateTime d) {
                    setState(() => _formFieldDate = d as HijriDateTime);
                  },
                  onDateSaved: (DateTime d) {
                    setState(() => _formFieldDate = d as HijriDateTime);
                  },
                  calendarDelegate: delegate,
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),
          _SectionCard(
            title: '4. Embedded YearPicker',
            child: SizedBox(
              height: 220,
              child: YearPicker(
                firstDate: _firstDate,
                lastDate: _lastDate,
                selectedDate: _inlineDate,
                // Flutter's YearPicker defaults currentDate to DateTime.now()
                // (not calendarDelegate.now()), so pass it explicitly.
                currentDate: HijriDateTime.now(),
                onChanged: (DateTime d) {
                  setState(() => _inlineDate = d as HijriDateTime);
                },
                calendarDelegate: delegate,
              ),
            ),
          ),
          const SizedBox(height: 16),
          _LegendCard(language: _hijriLanguage),
        ],
      ),
    );
  }
}

class _SectionCard extends StatelessWidget {
  const _SectionCard({required this.title, required this.child});

  final String title;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    final ColorScheme cs = Theme.of(context).colorScheme;
    return Card(
      elevation: 0,
      color: cs.surfaceContainerHigh,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              title,
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    color: cs.onSurface,
                    fontWeight: FontWeight.bold,
                  ),
            ),
            const SizedBox(height: 12),
            child,
          ],
        ),
      ),
    );
  }
}

class _DateDisplay extends StatelessWidget {
  const _DateDisplay({
    required this.label,
    required this.value,
    required this.hijriLanguage,
  });

  final String label;
  final HijriDateTime value;
  final String hijriLanguage;

  @override
  Widget build(BuildContext context) {
    try {
      HijriCalendar.setLocal(hijriLanguage);
    } on ArgumentError {
      // Locale not registered with the hijri package; keep current.
    }
    final String hijriFormatted =
        value.toHijriCalendar().toFormat('DDDD, dd MMMM yyyy');
    final DateTime gregorian = value.toGregorian();
    final String gregorianFormatted =
        '${gregorian.year}-${gregorian.month.toString().padLeft(2, '0')}-${gregorian.day.toString().padLeft(2, '0')}';

    final ColorScheme cs = Theme.of(context).colorScheme;
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: cs.surfaceContainerLow,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label.toUpperCase(),
            style: Theme.of(context).textTheme.labelSmall?.copyWith(
                  color: cs.onSurfaceVariant,
                ),
          ),
          const SizedBox(height: 4),
          Text(
            hijriFormatted,
            style: Theme.of(context).textTheme.titleSmall,
          ),
          const SizedBox(height: 2),
          Text(
            'Gregorian: $gregorianFormatted',
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  color: cs.onSurfaceVariant,
                ),
          ),
        ],
      ),
    );
  }
}

class _LegendCard extends StatelessWidget {
  const _LegendCard({required this.language});

  final String language;

  @override
  Widget build(BuildContext context) {
    final ColorScheme cs = Theme.of(context).colorScheme;
    final bool isDark = Theme.of(context).brightness == Brightness.dark;
    return Card(
      elevation: 0,
      color: cs.surfaceContainerLowest,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Theming',
              style: Theme.of(context).textTheme.titleSmall,
            ),
            const SizedBox(height: 8),
            Text(
              isDark
                  ? 'Dark theme seeded with Colors.blue.'
                  : 'Light theme seeded with Colors.amber.',
              style: Theme.of(context).textTheme.bodySmall,
            ),
            const SizedBox(height: 4),
            Text(
              'Hijri language: $language',
              style: Theme.of(context).textTheme.bodySmall,
            ),
            const SizedBox(height: 4),
            Text(
              'Toggle theme and language from the AppBar actions.',
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: cs.onSurfaceVariant,
                  ),
            ),
          ],
        ),
      ),
    );
  }
}
