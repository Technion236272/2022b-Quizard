import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

const String LAGUAGE_CODE = 'languageCode';

//languages code
const String ENGLISH = 'en';
const String HEBREW = 'he';
const String ARABIC = 'ar';

Future<Locale> setLocale(String languageCode) async {
  SharedPreferences _prefs = await SharedPreferences.getInstance();
  await _prefs.setString(LAGUAGE_CODE, languageCode);
  return _locale(languageCode);
}

Future<Locale> getLocale() async {
  SharedPreferences _prefs = await SharedPreferences.getInstance();
  String languageCode = _prefs.getString(LAGUAGE_CODE) ?? ENGLISH;
  return _locale(languageCode);
}

Locale _locale(String languageCode) {
  switch (languageCode) {
    case ENGLISH:
      return const Locale(ENGLISH, '');
    case HEBREW:
      return const Locale(HEBREW, "");
    case ARABIC:
      return const Locale(ARABIC, "");
    default:
      return const Locale(ENGLISH, '');
  }
}

AppLocalizations translation(BuildContext context) {
  return AppLocalizations.of(context)!;
}

String getLocalizedFieldValue(String field, BuildContext context) {
  switch (field) {
    case "Change Language":
      return translation(context).changeLanguage;
    case "Change Avatar":
      return translation(context).changeAvatar;
    case "Change Username":
      return translation(context).changeUsername;
    case "Change Password":
      return translation(context).changePassword;
    case "Change Email":
      return translation(context).changeEmail;
    case "About":
      return translation(context).about;
    case "CHAT":
      return translation(context).chat;
    case "PIN CODE":
      return translation(context).pinCode;
    case "INVITE":
      return translation(context).invite;
    case "UNLOCKED":
      return translation(context).unlocked;
    case "LOCKED":
      return translation(context).locked;
  }

  return "";
}
