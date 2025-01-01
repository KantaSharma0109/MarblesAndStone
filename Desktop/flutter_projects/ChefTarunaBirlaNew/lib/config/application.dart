part of config;

class Application {
  //Define Application variables
  static bool isDeepLink = false;
  static bool callAPI = false;
  static bool isShowPopup = false;
  static bool isShowAuthPopup = false;
  static bool isShowBlockedPopup = false;
  static bool isShowLogoutPopup = false;
  static bool isShowDatabasePopup = false;
  static String deepLinkUrl = '';
  static String appVersion = '';
  static String iosAppVersion = '';
  static String fcmToken = '';
  static String deviceToken = '';
  static String deviceId = '';
  static String userId = '';
  static String userName = '';
  static String address = '';
  static String pincode = '';
  static String languageId = '';
  static String phoneNumber = '';
  static String adminPhoneNumber = '';
  static String shareText = '';

  //index
  static int previousIndex = 0;
  static int currentIndex = 0;

  //Lists
  static List<CourseCategory> courseCategory = [];
  static List<ProductCategory> productCategory = [];
  static List<Course> featuredCourses = [];
  static List<Products> featuredProducts = [];
  static List<Course> userCourseSubscription = [];
  static List<Book> userBookSubscription = [];
  static List<AppSlider> appSlider = [];
  static List<Book> impBooks = [];
  static List<CartItem> userCart = [];
  static List<UserData> userData = [];
  static List<SocialLinks> socialLinks = [];

  //App initialisation
  static init() {
    Application.deviceToken = '';
  }

  static Future<File> createFileOfPdfUrl(String path) async {
    Completer<File> completer = Completer();
    Utility.printLog("Start download file from internet!");
    try {
      final url = path;
      final filename = url.substring(url.lastIndexOf("/") + 1);
      var request = await HttpClient().getUrl(Uri.parse(url));
      var response = await request.close();
      var bytes = await consolidateHttpClientResponseBytes(response);
      var dir = await getApplicationDocumentsDirectory();
      Utility.printLog("Download files");
      Utility.printLog("${dir.path}/$filename");
      File file = File("${dir.path}/$filename");

      await file.writeAsBytes(bytes, flush: true);
      completer.complete(file);
    } catch (e) {
      throw Exception('Error parsing asset file!');
    }

    return completer.future;
  }

  static void onShare(
      BuildContext context, String remotePDFpath, String shareText) async {
    final box = context.findRenderObject() as RenderBox?;
    // await Share.shareFiles(
    //   [remotePDFpath],
    //   text: shareText,
    //   sharePositionOrigin: box!.localToGlobal(Offset.zero) & box.size,
    // );
  }

  static openPdf(String path, BuildContext context) async {
    if (Platform.isIOS) {
      // for iOS phone only
      if (await canLaunchUrl(Uri.parse(path.replaceAll(' ', '%20')))) {
        await launchUrl(Uri.parse(path.replaceAll(' ', '%20')));
      } else {
        Utility.showSnacbar(context, "Not able to download");
      }
    } else {
      // android , web
      if (await canLaunchUrl(Uri.parse(path.replaceAll(' ', '%20')))) {
        await launchUrl(Uri.parse(path.replaceAll(' ', '%20')));
      } else {
        Utility.showSnacbar(context, "Not able to download");
      }
    }
    // }
  }
}
