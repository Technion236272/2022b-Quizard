import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import '../../consts.dart';
import '../custom_router.dart';
import 'language_constants.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:quizard/localization/custom_router.dart';
import 'package:quizard/localization/classes/language_constants.dart';


class Language {
  final int id;
  final String flag;
  final String name;
  final String languageCode;

  Language(this.id, this.flag, this.name, this.languageCode);
  
  static List<Language> languageList() {
    return <Language>[
      Language(2, "", "English", "en"),
      Language(4, "", "עברית", "he"),
      Language(3, "", "اَلْعَرَبِيَّةُ", "ar"),
    ];
  }
}


class Localization extends StatefulWidget {
  const Localization({Key? key}) : super(key: key);

  @override
  State<Localization> createState() => _LocalizationState();

  static void setLocale(BuildContext context, Locale newLocale) {
    _LocalizationState? state = context.findAncestorStateOfType<
        _LocalizationState>();
    state?.setLocale(newLocale);
  }

  static String getLocale(BuildContext context) {
    _LocalizationState? state = context.findAncestorStateOfType<_LocalizationState>();
    if(state?._locale?.languageCode == "he") {
      return "עברית";
    }
    if(state?._locale?.languageCode == "ar") {
      return "اَلْعَرَبِيَّةُ";
    }
    return "English";
  }

}


class _LocalizationState extends State<Localization> {
  Locale? _locale;

  setLocale(Locale locale) {
    setState(() {
      _locale = locale;
    });
  }

  @override
  void didChangeDependencies() {
    getLocale().then((locale) => {setLocale(locale)});
    super.didChangeDependencies();
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
        localizationsDelegates: const [
          AppLocalizations.delegate,
          GlobalMaterialLocalizations.delegate,
          GlobalWidgetsLocalizations.delegate,
          GlobalCupertinoLocalizations.delegate,
        ],
        supportedLocales: AppLocalizations.supportedLocales,
        onGenerateRoute: CustomRouter.generatedRoute,
        initialRoute: FirebaseAuth.instance.currentUser != null ? loadHomePageRoute : welcomePageRoute,
        locale: _locale,
        theme: Theme.of(context).copyWith(
          colorScheme:
          Theme.of(context).colorScheme.copyWith(primary: defaultColor),
          scaffoldBackgroundColor: backgroundColor,
        )
    );
  }
}

