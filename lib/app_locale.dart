class AppLocalizations {
  static const Map<String, Map<String, String>> _localizedValues = {
    'en': {
      'hello': 'Hello',
      'welcome': 'Welcome to our app!',
    },
    'fa': {
      'hello': 'سلام',
      'welcome': 'به برنامه ما خوش آمدید!',
    },
  };

  static String? translate(String key, String locale) {
    return _localizedValues[locale]![key];
  }
}
