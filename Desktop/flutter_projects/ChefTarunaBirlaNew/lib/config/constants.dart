part of config;

class Constants {
  // Make true for Development otherwise false
  static bool isDevelopment = false;

  //Backendurls
  static String BaseUrl = 'http://192.168.75.201:8080/taruna_birla_api/';
  static String devBackendUrl = 'http://192.168.0.108:3000';
  static String prodBackendUrl = 'https://dashboard.cheftarunabirla.com';
  static String imgBackendUrl = 'https://dashboard.cheftarunabirla.com';
  static String internetCheckUrl = 'dashboard.cheftarunabirla.com';
  static String finalUrl = isDevelopment ? devBackendUrl : prodBackendUrl;

  //App defaults
  static String iosAppStoreId = '1604566141';
  static String androidPlayStoreId = 'com.cheftarunbirla';
  static String iosBundleId = 'com.technotwist.tarunaBirla';

  //Firebase Dynamic Links
  static const firebaseLinkDomain = 'https://cheftarunabirla.page.link';
  static const firebaseReferLink = 'https://';
}

class Palette {
  static const Color primaryColor = Color(0xffFFFAF0);
  static const Color secondaryColor = Color(0xff344756);
  // static const Color appBarColor = Color(0xff294F38);
  // static const Color contrastColor = Color(0xff294F38);
  // static const Color appBarColor = Color(0xff832b8b);
  // static const Color contrastColor = Color(0xff832b8b);
  static const Color contrastColor = Color(0xFFD68D54);
  // static const Color appBarColor = Color(0xff21ad5a);
  static const Color appBarColor = Color(0xffffffff);

  // static const Color contrastColor = Color(0xff21ad5a);
  static const Color scaffoldColor = Color(0xfff8f8f8);
  static const Color appBarIconsColor = Color(0xff000000);
  static const Color white = Color(0xffffffff);
  // static const Color shadowColor = Color(0xff000000);
  static const Color shadowColor = Color(0xff000000);
  static const Color black = Color(0xff000000);
  static const Color shadowColorTwo = Color(0xffFFE9B9);
  static const Color grey = Color(0xff808080);
  // static const Color discount = Color(0xff44ac00);
  static const Color discount = Color(0xFFD68D54);
  static const Color textGrey = Colors.black54;
}
