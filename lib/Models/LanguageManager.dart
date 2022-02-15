
import 'package:dr_tech/Config/Globals.dart';
import 'package:dr_tech/Models/DatabaseManager.dart';
import 'package:flutter/cupertino.dart';

class LanguageManager {
  static var languages = {};
  static var languagesNames = {};
  static var selectedLanguage =
      DatabaseManager.getUserSettings("localization") ?? "";

  static String getCurrentLanguageName() {
    return languagesNames[selectedLanguage] ?? "";
  }

  static String getText(int index) {
    try {
      return LanguageManager.languages[selectedLanguage][index - 1] ??
          "NO_TEXT_FOUND";
    } catch (e) {
      return "NO_LANGUAGE_FOUND";
    }
  }

  static bool setLanguage(String key) {
    if (!languagesNames.keys.contains(key)) return false;
    DatabaseManager.setUserSettings("localization", key);
    selectedLanguage = DatabaseManager.getUserSettings("localization");
    return selectedLanguage == key;
  }

  static String getCustomText(int index) {
    var offset = Globals.getConfig("language_offset");
    offset = offset == "" ? 0 : (int.parse(offset) ?? 0);
    try {
      return LanguageManager.languages[selectedLanguage][index + offset] ??
          "NO_TEXT_FOUND";
    } catch (e) {
      return "NO_LANGUAGE_FOUND";
    }
  }

  static bool getDirection() {
    return LanguageManager.getLocal().toString().contains("ar");
  }

  static TextDirection getTextDirection() {
    if (getDirection())
      return TextDirection.rtl;
    else
      return TextDirection.ltr;
  }

  static TextDirection getReversTextDirection() {
    if (getDirection())
      return TextDirection.ltr;
    else
      return TextDirection.rtl;
  }

  static void init(data) {
    selectedLanguage = DatabaseManager.getUserSettings("localization");

    LanguageManager.languages = data['data'];
    LanguageManager.languagesNames = data['languages_names'];
    if (selectedLanguage.isEmpty ||
        LanguageManager.languages[selectedLanguage] == null) {
      selectedLanguage = data['default'];
      DatabaseManager.setUserSettings('localization', selectedLanguage);
    }
  }

  static String getLocalName() {
    String userSettingsLocal = DatabaseManager.getUserSettings("localization");
    userSettingsLocal = (userSettingsLocal != ""
        ? userSettingsLocal
        : Globals.getConfig("localization"));

    userSettingsLocal = userSettingsLocal != "" ? userSettingsLocal : "ar,SA";

    var appLocals = Globals.getConfig("locales");
    appLocals = appLocals == "" ? [] : appLocals;

    for (var item in appLocals) {
      if (item['code'] == userSettingsLocal) return item['text'];
    }

    return "";
  }

  static String getLocalStr() {
    String userSettingsLocal = DatabaseManager.getUserSettings("localization");
    userSettingsLocal = (userSettingsLocal != ""
        ? userSettingsLocal
        : Globals.getConfig("localization"));

    userSettingsLocal = userSettingsLocal != "" ? userSettingsLocal : "ar,SA";

    return userSettingsLocal.split(",")[0] ?? "ar";
  }

  static Locale getLocal() {
    // test
    // return Locale('en', 'US');

    String userSettingsLocal = DatabaseManager.getUserSettings("localization");
    userSettingsLocal = (userSettingsLocal != ""
        ? userSettingsLocal
        : Globals.getConfig("localization"));
    userSettingsLocal = userSettingsLocal != "" ? userSettingsLocal : "ar,SA";

    return Locale(
            userSettingsLocal.split(",")[0], userSettingsLocal.split(",")[1]) ??
        Locale('ar', 'SA');
  }

  static List<Locale> getSupportedLocales() {
    var appLocals = Globals.getConfig("locales");
    appLocals = appLocals == ""
        ? [
            {"code": "ar,SA"}
          ]
        : appLocals;
    List<Locale> locals = [];

    for (var item in appLocals)
      locals.add(Locale(item['code'].toString().split(",")[0],
          item['code'].toString().split(",")[1]));
    return locals;
  }
}
