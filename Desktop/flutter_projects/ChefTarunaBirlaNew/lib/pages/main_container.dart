import 'dart:io';
import 'dart:typed_data';

import 'package:chef_taruna_birla/pages/blog/each_blog.dart';
import 'package:chef_taruna_birla/pages/live_integration/live_classes.dart';
import 'package:chef_taruna_birla/pages/main_pages/blog_page.dart';
import 'package:chef_taruna_birla/pages/main_pages/course_page.dart';
import 'package:chef_taruna_birla/pages/main_pages/home_page.dart';
import 'package:chef_taruna_birla/pages/main_pages/product_page.dart';
import 'package:chef_taruna_birla/pages/main_pages/profile_page.dart';
import 'package:chef_taruna_birla/pages/product/each_product.dart';
import 'package:chef_taruna_birla/viewmodels/course_page_viewmodel.dart';
import 'package:chef_taruna_birla/widgets/custom_app_bar.dart';
import 'package:chef_taruna_birla/widgets/image_placeholder.dart';
import 'package:chef_taruna_birla/widgets/custom_app_bar.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
// import 'package:ios_insecure_screen_detector/ios_insecure_screen_detector.dart';
import 'package:material_design_icons_flutter/material_design_icons_flutter.dart';
import 'package:path_provider/path_provider.dart';
import 'package:provider/provider.dart';
import 'package:share_plus/share_plus.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../config/config.dart';
import '../utils/utility.dart';
import '../viewmodels/deepLink.dart';
import '../viewmodels/main_container_viewmodel.dart';
import '../viewmodels/product_page_viewmodel.dart';
import 'book/each_book.dart';
import 'course/each_course.dart';
import 'notifications/notification_page.dart';

class MainContainer extends StatefulWidget {
  const MainContainer({Key? key}) : super(key: key);

  @override
  _MainContainerState createState() => _MainContainerState();
}

class _MainContainerState extends State<MainContainer> {
  List screens = [
    const HomePage(),
    const BlogScreen(),
    const CoursePage(),
    const ProductPage(),
    const ProfilePage()
  ];
  // final IosInsecureScreenDetector _insecureScreenDetector =
  //     IosInsecureScreenDetector();
  bool _isCaptured = false;
  bool isLoading = false;
  int index = 0;

  isCaptured() async {
    // _isCaptured = await _insecureScreenDetector.isCaptured();
    setState(() {});
  }

  Future<void> extraData() async {
    Utility.printLog(context.read<DeepLink>().deepLinkUrl);

    if (context.read<DeepLink>().deepLinkUrl.contains('notifications')) {
      Utility.showSnacbar(
        context,
        'Notification available!!, click here to check',
        onClicked: () {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => const NotificationPage()),
          );
        },
        duration: 2,
      );
    } else if (context
        .read<DeepLink>()
        .deepLinkUrl
        .contains('new-notifications')) {
      Utility.showSnacbar(
        context,
        'Some new courses and products available , check your notification drawer!!',
        duration: 2,
      );
    }
    // if (Application.isShowPopup) {
    //   Utility.updateApplicationDialog(context);
    //   Application.isShowPopup = false;
    // }
    if (Application.isShowAuthPopup) {
      Utility.authErrorPopup(
          context,
          'Sorry for inconvenience. Their is some authentication problem regarding your account, contact support: ' +
              Application.adminPhoneNumber);
      Application.isShowAuthPopup = false;
    }
    if (Application.isShowBlockedPopup) {
      Utility.authErrorPopup(
          context,
          'Looks like you are blocked by admin so you have been logged out by the application please contact support: ' +
              Application.adminPhoneNumber);
      Application.isShowBlockedPopup = false;
    }
    if (Application.isShowDatabasePopup) {
      Utility.databaseErrorPopup(context);
      Application.isShowDatabasePopup = false;
    }
    if (Application.isShowLogoutPopup) {
      Utility.logout(context);
      Application.isShowLogoutPopup = false;
    }

    SharedPreferences prefs = await SharedPreferences.getInstance();
    String savedDate = prefs.getString('date') ?? '${DateTime.now()}';
    int savedCount = prefs.getInt('updatePopupCount') ?? 0;
    var date = DateTime.parse(savedDate);
    var today = DateTime.now();
    var diff = today.difference(date);
    if (diff.inDays == 7 && savedCount == 0) {
      Utility.rateApplicationDialog(context);
      prefs.setString('date', today.toString());
      prefs.setInt('updatePopupCount', savedCount + 1);
    } else {
      prefs.setInt('updatePopupCount', 0);
    }
  }

  Future<void> getAppData() async {
    // Provider.of<MainContainerViewModel>(context, listen: false)
    //     .initializeFlutterFire(context);
    // if (Provider.of<MainContainerViewModel>(context, listen: false).isLoading) {
    // await Future.delayed(const Duration(milliseconds: 1000));
    setState(() {
      isLoading = true;
    });

    try {
      final result = await InternetAddress.lookup(Constants.internetCheckUrl);
      if (result.isNotEmpty && result[0].rawAddress.isNotEmpty) {
        Utility.printLog('connected');
        if (Provider.of<MainContainerViewModel>(context, listen: false)
            .courseCategories
            .isNotEmpty) {
          Provider.of<CoursePageViewModel>(context, listen: false)
              .setSelectedCategory(
                  Provider.of<MainContainerViewModel>(context, listen: false)
                      .courseCategories[0]
                      .name);
        }
        if (Provider.of<MainContainerViewModel>(context, listen: false)
            .productCategories
            .isNotEmpty) {
          Provider.of<ProductPageViewModel>(context, listen: false)
              .setSelectedCategory(
                  Provider.of<MainContainerViewModel>(context, listen: false)
                      .productCategories[0]
                      .name);
        }
        Utility.showProgress(false);
        setState(() {
          isLoading = true;
        });
        extraData();
      }
    } on SocketException catch (_) {
      Utility.printLog('not connected');
      Utility.noInternetPopup(context);
      Utility.showProgress(false);
      setState(() {
        isLoading = true;
      });
    }
    // }
    // await Future.delayed(const Duration(milliseconds: 3000));
  }

  @override
  void initState() {
    super.initState();

    Utility.printLog(Application.appVersion);

    if (Platform.isIOS) {
      // _insecureScreenDetector.initialize();
      // _insecureScreenDetector.addListener(() {
      //   Utility.printLog('add event listener');
      //   Utility.forceLogoutUser(context);
      //   // Utility.forceLogout(context);
      // }, (isCaptured) {
      //   Utility.printLog('screen recording event listener');
      //   // Utility.forceLogoutUser(context);
      //   // Utility.forceLogout(context);
      //   setState(() {
      //     _isCaptured = isCaptured;
      //   });
      // });
    }

    Utility.showProgress(true);
    getAppData();
  }

  // //Sharing Function
  // void _onShare(BuildContext context) async {
  //   final ByteData bytes = await rootBundle.load('assets/images/splash1.jpeg');
  //   final Uint8List list = bytes.buffer.asUint8List();

  //   final tempDir = await getTemporaryDirectory();
  //   final file = await File('${tempDir.path}/image.jpg').create();
  //   file.writeAsBytesSync(list);
  //   final box = context.findRenderObject() as RenderBox?;
  //   await Share.shareFiles(
  //     [(file.path)],
  //     text: Application.shareText,
  //     sharePositionOrigin: box!.localToGlobal(Offset.zero) & box.size,
  //   );
  // }

  void _onShare(BuildContext context) async {
    // Load the image from assets
    final ByteData bytes = await rootBundle.load('assets/images/splash1.jpeg');
    final Uint8List list = bytes.buffer.asUint8List();

    // Create a temporary file to save the image
    final tempDir = await getTemporaryDirectory();
    final file = await File('${tempDir.path}/image.jpg').create();
    await file.writeAsBytes(list);

    // Convert the file path to XFile
    final xFile = XFile(file.path);

    // Get the box for sharing position
    final box = context.findRenderObject() as RenderBox?;

    // Share the file using Share.shareXFiles
    await Share.shareXFiles(
      [xFile],
      text:
          'To explore more products and courses click on the link given below\n\n👇https://play.google.com/store/apps/details?id=com.cheftarunbirla',
      sharePositionOrigin: box!.localToGlobal(Offset.zero) & box.size,
    );
  }

  @override
  Widget build(BuildContext context) {
    // return

    return !isLoading
        ? Column(
            children: [
              const Expanded(child: ImagePlaceholder()),
              const Expanded(
                child: Padding(
                  padding: EdgeInsets.all(8.0),
                  child: Center(
                    child: Text(
                      'Sorry for inconvenience. The servers are down due to some technical issue,Please visit after some time!!',
                      style: TextStyle(
                        fontFamily: 'EuclidCircularA Medium',
                        fontSize: 20.0,
                        color: Palette.black,
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ),
                ),
              ),
              const SizedBox(
                height: 5.0,
              ),
              GestureDetector(
                onTap: () {
                  if (Platform.isIOS) {
                    exit(0);
                  } else {
                    SystemNavigator.pop();
                  }
                },
                child: Container(
                  width: double.infinity,
                  decoration: const BoxDecoration(
                    color: Palette.secondaryColor,
                  ),
                  child: const Padding(
                    padding: EdgeInsets.only(top: 20.0, bottom: 20.0),
                    child: Center(
                      child: Text(
                        'Close the app',
                        style: TextStyle(
                          color: Palette.white,
                          fontSize: 16.0,
                          fontFamily: 'EuclidCircularA Medium',
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            ],
          )
        : context.watch<DeepLink>().deepLinkUrl.contains('course')
            ? EachCourse(
                id: context
                    .watch<DeepLink>()
                    .deepLinkUrl
                    .split('course_id=')[1]
                    .toString(),
              )
            : context.watch<DeepLink>().deepLinkUrl.contains('product')
                ? EachProduct(
                    id: context
                        .watch<DeepLink>()
                        .deepLinkUrl
                        .split('product_id=')[1]
                        .toString())
                : context.watch<DeepLink>().deepLinkUrl.contains('book')
                    ? EachBook(
                        id: context
                            .watch<DeepLink>()
                            .deepLinkUrl
                            .split('book_id=')[1]
                            .toString())
                    : context.watch<DeepLink>().deepLinkUrl.contains('blog')
                        ? EachBlog(
                            id: context
                                .watch<DeepLink>()
                                .deepLinkUrl
                                .split('book_id=')[1]
                                .toString(),
                            time: '',
                            title: '',
                            description: '',
                            share_url: '',
                          )
                        : context.watch<DeepLink>().deepLinkUrl.contains('live')
                            ? const LiveClasses()
                            : _isCaptured
                                ? const Center(
                                    child: Text(
                                      'You are not allowed to do screen recording',
                                      style: TextStyle(
                                        fontFamily: 'EuclidCircularA Regular',
                                        fontSize: 20.0,
                                        color: Palette.black,
                                      ),
                                      textAlign: TextAlign.center,
                                    ),
                                  )
                                : WillPopScope(
                                    onWillPop: () async {
                                      if (Provider.of<MainContainerViewModel>(
                                              context,
                                              listen: false)
                                          .navigationQueue
                                          .isEmpty) {
                                        Utility.exitApplicationPopup(context);
                                        return false;
                                      }

                                      Provider.of<MainContainerViewModel>(
                                              context,
                                              listen: false)
                                          .setIndex(Provider.of<
                                                      MainContainerViewModel>(
                                                  context,
                                                  listen: false)
                                              .navigationQueue
                                              .last);

                                      setState(() {
                                        index =
                                            Provider.of<MainContainerViewModel>(
                                                    context,
                                                    listen: false)
                                                .navigationQueue
                                                .last;
                                      });
                                      Provider.of<MainContainerViewModel>(
                                              context,
                                              listen: false)
                                          .navigationQueue
                                          .removeLast();
                                      return false;
                                    },
                                    child: Scaffold(
                                      appBar: CustomAppBar(
                                        preferredSize:
                                            const Size.fromHeight(60.0),
                                        bottom: PreferredSize(
                                          preferredSize:
                                              const Size.fromHeight(0.0),
                                          child: Container(),
                                        ),
                                        onshare: () {
                                          _onShare(context);
                                        },
                                      ),
                                      // body: const Center(
                                      //   child: Text(
                                      //     'Hello',
                                      //     style: TextStyle(
                                      //       fontSize: 24,
                                      //       fontWeight: FontWeight.bold,
                                      //     ),
                                      //   ),
                                      // ),
                                      body: screens[context
                                          .watch<MainContainerViewModel>()
                                          .current_index],
                                      floatingActionButton: Container(
                                        decoration: BoxDecoration(
                                          borderRadius:
                                              BorderRadius.circular(30),
                                          color: const Color(0xff25D366),
                                          border: Border.all(
                                              color: const Color(0xff25D366)),
                                          boxShadow: [
                                            BoxShadow(
                                              color: const Color(0xff000000)
                                                  .withOpacity(0.2),
                                              blurRadius:
                                                  10.0, // soften the shadow
                                              spreadRadius:
                                                  0.0, //extend the shadow
                                              offset: const Offset(
                                                0.0, // Move to right 10  horizontally
                                                0.0, // Move to bottom 10 Vertically
                                              ),
                                            ),
                                          ],
                                        ),
                                        child: FloatingActionButton(
                                          onPressed: () {
                                            Utility.openWhatsapp(context);
                                          },
                                          child: Icon(
                                            MdiIcons.whatsapp,
                                            size: 25.0,
                                            // color: Palette.secondaryColor,
                                          ),
                                          backgroundColor:
                                              const Color(0xff25D366),
                                          // focusColor: Palette.contrastColor,
                                          elevation: 0.0,
                                        ),
                                      ),
                                      bottomNavigationBar: Container(
                                        decoration: BoxDecoration(
                                          borderRadius:
                                              BorderRadius.circular(8),
                                          color: Colors.white,
                                          boxShadow: [
                                            BoxShadow(
                                              color: Palette.shadowColor
                                                  .withOpacity(0.06),
                                              blurRadius:
                                                  5.0, // soften the shadow
                                              spreadRadius:
                                                  0.0, //extend the shadow
                                              offset: const Offset(
                                                0.0, // Move to right 10  horizontally
                                                -0.0, // Move to bottom 10 Vertically
                                              ),
                                            ),
                                          ],
                                        ),
                                        child: BottomNavigationBar(
                                          currentIndex: Provider.of<
                                                      MainContainerViewModel>(
                                                  context,
                                                  listen: false)
                                              .current_index,
                                          onTap: (value) {
                                            Provider.of<MainContainerViewModel>(
                                                    context,
                                                    listen: false)
                                                .setIndex(value);
                                            Provider.of<MainContainerViewModel>(
                                                    context,
                                                    listen: false)
                                                .navigationQueue
                                                .addLast(index);
                                            setState(() => index = value);
                                          },
                                          items: [
                                            BottomNavigationBarItem(
                                              icon: Padding(
                                                padding: EdgeInsets.all(1.0),
                                                child: Icon(MdiIcons
                                                    .homeVariantOutline),
                                              ),
                                              label: 'Home',
                                            ),
                                            BottomNavigationBarItem(
                                              icon: Padding(
                                                padding: EdgeInsets.all(1.0),
                                                child: Icon(MdiIcons
                                                    .newspaperVariantOutline),
                                              ),
                                              label: 'Blogs',
                                            ),
                                            BottomNavigationBarItem(
                                              icon: Padding(
                                                padding: EdgeInsets.all(1.0),
                                                child: Icon(
                                                    MdiIcons.playCircleOutline),
                                              ),
                                              label: 'Courses',
                                            ),
                                            BottomNavigationBarItem(
                                              icon: Padding(
                                                padding: EdgeInsets.all(1.0),
                                                child:
                                                    Icon(MdiIcons.storeOutline),
                                              ),
                                              label: 'Shop',
                                            ),
                                            BottomNavigationBarItem(
                                              icon: Padding(
                                                padding: EdgeInsets.all(1.0),
                                                child: Icon(
                                                    MdiIcons.accountOutline),
                                              ),
                                              label: 'Profile',
                                            ),
                                          ],
                                          type: BottomNavigationBarType.fixed,
                                          selectedItemColor:
                                              Palette.contrastColor,
                                          backgroundColor:
                                              const Color(0xffffffff),
                                          unselectedItemColor:
                                              const Color(0xff8e8e8e),
                                          iconSize: 30,
                                          selectedFontSize: 10,
                                          unselectedFontSize: 10,
                                          showSelectedLabels: true,
                                          showUnselectedLabels: true,
                                          elevation: 20.0,
                                        ),
                                      ),
                                    ),
                                  );
  }
}
