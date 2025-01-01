import 'dart:io';

import 'package:chef_taruna_birla/pages/common/webview_page.dart';
import 'package:chef_taruna_birla/pages/startup/splash.dart';

import 'package:chef_taruna_birla/utils/utility.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:material_design_icons_flutter/material_design_icons_flutter.dart';
import 'package:rate_my_app/rate_my_app.dart';

import '../../config/config.dart';

import '../profile/my_books.dart';
import '../profile/my_courses.dart';
import '../profile/my_orders.dart';
import '../profile/user_account.dart';
import '../wallet/wallet_page.dart';

class ProfilePage extends StatefulWidget {
  const ProfilePage({Key? key}) : super(key: key);

  @override
  _ProfilePageState createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  String phoneNumber = '';
  bool isLoading = false;
  RateMyApp? ratemyapp = RateMyApp();
  static const playstoreId = 'com.cheftarunbirla';
  static const appstoreId = 'com.technotwist.tarunaBirla';
  late Widget Function(RateMyApp) builder;
  late final RateMyAppInitializedCallback onInitialized;
  // late final WidgetBuilder builder;

  Future<RateMyAppBuilder> rateMyApp(BuildContext context) async {
    return RateMyAppBuilder(
      onInitialized: (context, ratemyapp) {
        setState(() {
          this.ratemyapp = ratemyapp;
        });
      },
      builder: (context) => ratemyapp == null
          ? const Center(
              child: CircularProgressIndicator(),
            )
          : builder(ratemyapp!),
      rateMyApp: RateMyApp(
        preferencesPrefix: 'rateMyApp_',
        minDays: 7,
        minLaunches: 10,
        remindDays: 7,
        remindLaunches: 10,
        googlePlayIdentifier: 'com.cheftarunbirla',
        appStoreIdentifier: 'com.technotwist.tarunaBirla',
      ),
    );
  }

  void openRateDialog(BuildContext context) {
    ratemyapp?.showRateDialog(context);
  }

  _filterRetriever() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    final String phonenumber = prefs.getString('phonenumber') ?? '';
    // print();
    setState(() {
      phoneNumber = phonenumber;
    });

    if (phoneNumber.isNotEmpty) {
      initRateMyApp();
    }
  }

  @override
  void initState() {
    _filterRetriever();
    super.initState();
  }

  Future<void> initRateMyApp() async {
    await ratemyapp?.init();

    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) {
        onInitialized(context, ratemyapp!);
      }
    });
  }

  @override
  void dispose() {
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      scrollDirection: Axis.vertical,
      child:
          //  phoneNumber.isEmpty
          //     ? const LoginPage()
          //     :
          Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SizedBox(
            height: 20.0,
          ),
          Padding(
            padding: const EdgeInsets.symmetric(
              vertical: 5.0,
              horizontal: 24.0,
            ),
            child: GestureDetector(
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => const UserAccount(),
                  ),
                );
              },
              child: Container(
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(10.0),
                  color: Palette.white,
                  boxShadow: [
                    BoxShadow(
                      color: Palette.shadowColor.withOpacity(0.1),
                      blurRadius: 5.0, // soften the shadow
                      spreadRadius: 0.0, //extend the shadow
                      offset: const Offset(
                        0.0, // Move to right 10  horizontally
                        0.0, // Move to bottom 10 Vertically
                      ),
                    ),
                  ],
                ),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Expanded(
                      flex: 2,
                      child: Padding(
                        padding: EdgeInsets.symmetric(
                            vertical: 10.0, horizontal: 0.0),
                        child: CircleAvatar(
                          backgroundColor: Palette.secondaryColor,
                          radius: 25.0,
                          child: Icon(
                            MdiIcons.accountOutline,
                            color: Palette.white,
                          ),
                        ),
                      ),
                    ),
                    Expanded(
                      flex: 5,
                      child: Padding(
                        padding: EdgeInsets.symmetric(
                            vertical: 0.0, horizontal: 5.0),
                        child: Text(
                          'Account',
                          style: TextStyle(
                              color: Colors.black,
                              fontSize: 16.0,
                              fontFamily: 'EuclidCircularA Medium'),
                        ),
                      ),
                    ),
                    Expanded(
                      flex: 1,
                      child: Padding(
                        padding: const EdgeInsets.all(5.0),
                        child: Icon(
                          Icons.arrow_forward_ios,
                          size: 18.0,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
          Platform.isIOS
              ? Padding(
                  padding: EdgeInsets.symmetric(
                    vertical: Platform.isIOS ? 5.0 : 0.0,
                    horizontal: 24.0,
                  ),
                  child: !Platform.isIOS
                      ? Container()
                      : GestureDetector(
                          onTap: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => const WalletPage(),
                              ),
                            );
                          },
                          child: Container(
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(10.0),
                              color: Palette.white,
                              boxShadow: [
                                BoxShadow(
                                  color: Palette.shadowColor.withOpacity(0.1),
                                  blurRadius: 5.0, // soften the shadow
                                  spreadRadius: 0.0, //extend the shadow
                                  offset: const Offset(
                                    0.0, // Move to right 10  horizontally
                                    0.0, // Move to bottom 10 Vertically
                                  ),
                                ),
                              ],
                            ),
                            child: Row(
                              crossAxisAlignment: CrossAxisAlignment.center,
                              children: [
                                Expanded(
                                  flex: 2,
                                  child: Padding(
                                    padding: EdgeInsets.symmetric(
                                        vertical: 10.0, horizontal: 0.0),
                                    child: CircleAvatar(
                                      backgroundColor: Palette.secondaryColor,
                                      // backgroundImage: AssetImage('assets/images/blog.jpeg'),
                                      radius: 25.0,
                                      child: Icon(
                                        MdiIcons.currencyInr,
                                        color: Palette.white,
                                      ),
                                    ),
                                  ),
                                ),
                                Expanded(
                                  flex: 5,
                                  child: Padding(
                                    padding: EdgeInsets.symmetric(
                                        vertical: 0.0, horizontal: 5.0),
                                    child: Text(
                                      'Wallet',
                                      style: TextStyle(
                                          color: Colors.black,
                                          fontSize: 16.0,
                                          fontFamily: 'EuclidCircularA Medium'),
                                    ),
                                  ),
                                ),
                                Expanded(
                                  flex: 1,
                                  child: Padding(
                                    padding: const EdgeInsets.all(5.0),
                                    child: Icon(
                                      Icons.arrow_forward_ios,
                                      size: 18.0,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                )
              : Container(),
          Padding(
            padding: const EdgeInsets.symmetric(
              vertical: 5.0,
              horizontal: 24.0,
            ),
            child: GestureDetector(
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => const MyOrders(),
                  ),
                );
              },
              child: Container(
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(10.0),
                  color: Palette.white,
                  boxShadow: [
                    BoxShadow(
                      color: Palette.shadowColor.withOpacity(0.1),
                      blurRadius: 5.0, // soften the shadow
                      spreadRadius: 0.0, //extend the shadow
                      offset: const Offset(
                        0.0, // Move to right 10  horizontally
                        0.0, // Move to bottom 10 Vertically
                      ),
                    ),
                  ],
                ),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Expanded(
                      flex: 2,
                      child: Padding(
                        padding: EdgeInsets.symmetric(
                            vertical: 10.0, horizontal: 0.0),
                        child: CircleAvatar(
                          backgroundColor: Palette.secondaryColor,
                          // backgroundImage: AssetImage('assets/images/blog.jpeg'),
                          radius: 25.0,
                          child: Icon(
                            MdiIcons.cartOutline,
                            color: Palette.white,
                          ),
                        ),
                      ),
                    ),
                    Expanded(
                      flex: 5,
                      child: Padding(
                        padding: const EdgeInsets.symmetric(
                            vertical: 0.0, horizontal: 5.0),
                        child: Row(
                          children: const [
                            Text(
                              'My Orders',
                              style: TextStyle(
                                  color: Colors.black,
                                  fontSize: 16.0,
                                  fontFamily: 'EuclidCircularA Medium'),
                            ),
                          ],
                        ),
                      ),
                    ),
                    const Expanded(
                      flex: 1,
                      child: Padding(
                        padding: EdgeInsets.all(5.0),
                        child: Icon(
                          Icons.arrow_forward_ios,
                          size: 18.0,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(
              vertical: 5.0,
              horizontal: 24.0,
            ),
            child: GestureDetector(
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => const MyCourses(),
                  ),
                );
              },
              child: Container(
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(10.0),
                  color: Palette.white,
                  boxShadow: [
                    BoxShadow(
                      color: Palette.shadowColor.withOpacity(0.1),
                      blurRadius: 5.0, // soften the shadow
                      spreadRadius: 0.0, //extend the shadow
                      offset: const Offset(
                        0.0, // Move to right 10  horizontally
                        0.0, // Move to bottom 10 Vertically
                      ),
                    ),
                  ],
                ),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Expanded(
                      flex: 2,
                      child: Padding(
                        padding: EdgeInsets.symmetric(
                            vertical: 10.0, horizontal: 0.0),
                        child: CircleAvatar(
                          backgroundColor: Palette.secondaryColor,
                          // backgroundImage: AssetImage('assets/images/blog.jpeg'),
                          radius: 25.0,
                          child: Icon(
                            MdiIcons.playCircleOutline,
                            color: Palette.white,
                          ),
                        ),
                      ),
                    ),
                    Expanded(
                      flex: 5,
                      child: Padding(
                        padding: const EdgeInsets.symmetric(
                            vertical: 0.0, horizontal: 5.0),
                        child: Row(
                          children: const [
                            Text(
                              'My Courses',
                              style: TextStyle(
                                  color: Colors.black,
                                  fontSize: 16.0,
                                  fontFamily: 'EuclidCircularA Medium'),
                            ),
                          ],
                        ),
                      ),
                    ),
                    const Expanded(
                      flex: 1,
                      child: Padding(
                        padding: EdgeInsets.all(5.0),
                        child: Icon(
                          Icons.arrow_forward_ios,
                          size: 18.0,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(
              vertical: 5.0,
              horizontal: 24.0,
            ),
            child: GestureDetector(
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => const MyBooks(),
                  ),
                );
              },
              child: Container(
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(10.0),
                  color: Palette.white,
                  boxShadow: [
                    BoxShadow(
                      color: Palette.shadowColor.withOpacity(0.1),
                      blurRadius: 5.0, // soften the shadow
                      spreadRadius: 0.0, //extend the shadow
                      offset: const Offset(
                        0.0, // Move to right 10  horizontally
                        0.0, // Move to bottom 10 Vertically
                      ),
                    ),
                  ],
                ),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Expanded(
                      flex: 2,
                      child: Padding(
                        padding: EdgeInsets.symmetric(
                            vertical: 10.0, horizontal: 0.0),
                        child: CircleAvatar(
                          backgroundColor: Palette.secondaryColor,
                          // backgroundImage: AssetImage('assets/images/blog.jpeg'),
                          radius: 25.0,
                          child: Icon(
                            MdiIcons.bookOutline,
                            color: Palette.white,
                          ),
                        ),
                      ),
                    ),
                    Expanded(
                      flex: 5,
                      child: Padding(
                        padding: const EdgeInsets.symmetric(
                            vertical: 0.0, horizontal: 5.0),
                        child: Row(
                          children: const [
                            Text(
                              'My Books',
                              style: TextStyle(
                                  color: Colors.black,
                                  fontSize: 16.0,
                                  fontFamily: 'EuclidCircularA Medium'),
                            ),
                          ],
                        ),
                      ),
                    ),
                    const Expanded(
                      flex: 1,
                      child: Padding(
                        padding: EdgeInsets.all(5.0),
                        child: Icon(
                          Icons.arrow_forward_ios,
                          size: 18.0,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(
              vertical: 5.0,
              horizontal: 24.0,
            ),
            child: GestureDetector(
              onTap: () {
                Utility.showLanguagePopup(context);
              },
              child: Container(
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(10.0),
                  color: Palette.white,
                  boxShadow: [
                    BoxShadow(
                      color: Palette.shadowColor.withOpacity(0.1),
                      blurRadius: 5.0, // soften the shadow
                      spreadRadius: 0.0, //extend the shadow
                      offset: const Offset(
                        0.0, // Move to right 10  horizontally
                        0.0, // Move to bottom 10 Vertically
                      ),
                    ),
                  ],
                ),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Expanded(
                      flex: 2,
                      child: Padding(
                        padding: EdgeInsets.symmetric(
                            vertical: 10.0, horizontal: 0.0),
                        child: CircleAvatar(
                          backgroundColor: Palette.secondaryColor,
                          // backgroundImage: AssetImage('assets/images/blog.jpeg'),
                          radius: 25.0,
                          child: Icon(
                            MdiIcons.googleTranslate,
                            color: Palette.white,
                          ),
                        ),
                      ),
                    ),
                    Expanded(
                      flex: 5,
                      child: Padding(
                        padding: const EdgeInsets.symmetric(
                            vertical: 0.0, horizontal: 5.0),
                        child: Row(
                          children: const [
                            Text(
                              'Language',
                              style: TextStyle(
                                  color: Colors.black,
                                  fontSize: 16.0,
                                  fontFamily: 'EuclidCircularA Medium'),
                            ),
                          ],
                        ),
                      ),
                    ),
                    const Expanded(
                      flex: 1,
                      child: Padding(
                        padding: EdgeInsets.all(5.0),
                        child: Icon(
                          Icons.arrow_forward_ios,
                          size: 18.0,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(
              vertical: 5.0,
              horizontal: 24.0,
            ),
            child: GestureDetector(
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => const WebviewPage(
                      url: 'http://www.cheftarunabirla.com/aboutUs/',
                      title: 'About Us',
                    ),
                  ),
                );
              },
              child: Container(
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(10.0),
                  color: Palette.white,
                  boxShadow: [
                    BoxShadow(
                      color: Palette.shadowColor.withOpacity(0.1),
                      blurRadius: 5.0, // soften the shadow
                      spreadRadius: 0.0, //extend the shadow
                      offset: const Offset(
                        0.0, // Move to right 10  horizontally
                        0.0, // Move to bottom 10 Vertically
                      ),
                    ),
                  ],
                ),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Expanded(
                      flex: 2,
                      child: Padding(
                        padding: EdgeInsets.symmetric(
                            vertical: 10.0, horizontal: 0.0),
                        child: CircleAvatar(
                          backgroundColor: Palette.secondaryColor,
                          // backgroundImage: AssetImage('assets/images/blog.jpeg'),
                          radius: 25.0,
                          child: Icon(
                            MdiIcons.informationVariant,
                            color: Palette.white,
                          ),
                        ),
                      ),
                    ),
                    Expanded(
                      flex: 5,
                      child: Padding(
                        padding: const EdgeInsets.symmetric(
                            vertical: 0.0, horizontal: 5.0),
                        child: Row(
                          children: const [
                            Text(
                              'About Us',
                              style: TextStyle(
                                  color: Colors.black,
                                  fontSize: 16.0,
                                  fontFamily: 'EuclidCircularA Medium'),
                            ),
                          ],
                        ),
                      ),
                    ),
                    const Expanded(
                      flex: 1,
                      child: Padding(
                        padding: EdgeInsets.all(5.0),
                        child: Icon(
                          Icons.arrow_forward_ios,
                          size: 18.0,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(
              vertical: 5.0,
              horizontal: 24.0,
            ),
            child: GestureDetector(
              onTap: () {
                rateMyApp(context);
                ratemyapp?.showRateDialog(context);
              },
              child: Container(
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(10.0),
                  color: Palette.white,
                  boxShadow: [
                    BoxShadow(
                      color: Palette.shadowColor.withOpacity(0.1),
                      blurRadius: 5.0, // soften the shadow
                      spreadRadius: 0.0, //extend the shadow
                      offset: const Offset(
                        0.0, // Move to right 10  horizontally
                        0.0, // Move to bottom 10 Vertically
                      ),
                    ),
                  ],
                ),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Expanded(
                      flex: 2,
                      child: Padding(
                        padding: EdgeInsets.symmetric(
                            vertical: 10.0, horizontal: 0.0),
                        child: CircleAvatar(
                          backgroundColor: Palette.secondaryColor,
                          // backgroundImage: AssetImage('assets/images/blog.jpeg'),
                          radius: 25.0,
                          child: Icon(
                            MdiIcons.starOutline,
                            color: Palette.white,
                          ),
                        ),
                      ),
                    ),
                    Expanded(
                      flex: 5,
                      child: Padding(
                        padding: const EdgeInsets.symmetric(
                            vertical: 0.0, horizontal: 5.0),
                        child: Row(
                          children: const [
                            Text(
                              'Rate Us',
                              style: TextStyle(
                                  color: Colors.black,
                                  fontSize: 16.0,
                                  fontFamily: 'EuclidCircularA Medium'),
                            ),
                          ],
                        ),
                      ),
                    ),
                    const Expanded(
                      flex: 1,
                      child: Padding(
                        padding: EdgeInsets.all(5.0),
                        child: Icon(
                          Icons.arrow_forward_ios,
                          size: 18.0,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(
              vertical: 5.0,
              horizontal: 24.0,
            ),
            child: GestureDetector(
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => const WebviewPage(
                      url: 'https://linktr.ee/cheftarunabirla',
                      title: 'Contact Us',
                    ),
                  ),
                );
              },
              child: Container(
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(10.0),
                  color: Palette.white,
                  boxShadow: [
                    BoxShadow(
                      color: Palette.shadowColor.withOpacity(0.1),
                      blurRadius: 5.0, // soften the shadow
                      spreadRadius: 0.0, //extend the shadow
                      offset: const Offset(
                        0.0, // Move to right 10  horizontally
                        0.0, // Move to bottom 10 Vertically
                      ),
                    ),
                  ],
                ),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Expanded(
                      flex: 2,
                      child: Padding(
                        padding: EdgeInsets.symmetric(
                            vertical: 10.0, horizontal: 0.0),
                        child: CircleAvatar(
                          backgroundColor: Palette.secondaryColor,
                          // backgroundImage: AssetImage('assets/images/blog.jpeg'),
                          radius: 25.0,
                          child: Icon(
                            MdiIcons.phone,
                            color: Palette.white,
                          ),
                        ),
                      ),
                    ),
                    Expanded(
                      flex: 5,
                      child: Padding(
                        padding: const EdgeInsets.symmetric(
                            vertical: 0.0, horizontal: 5.0),
                        child: Row(
                          children: const [
                            Text(
                              'Contact Us',
                              style: TextStyle(
                                  color: Colors.black,
                                  fontSize: 16.0,
                                  fontFamily: 'EuclidCircularA Medium'),
                            ),
                          ],
                        ),
                      ),
                    ),
                    const Expanded(
                      flex: 1,
                      child: Padding(
                        padding: EdgeInsets.all(5.0),
                        child: Icon(
                          Icons.arrow_forward_ios,
                          size: 18.0,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(
              vertical: 5.0,
              horizontal: 24.0,
            ),
            child: GestureDetector(
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => const WebviewPage(
                      url: 'http://www.cheftarunabirla.com/faq/',
                      title: 'FAQ',
                    ),
                  ),
                );
              },
              child: Container(
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(10.0),
                  color: Palette.white,
                  boxShadow: [
                    BoxShadow(
                      color: Palette.shadowColor.withOpacity(0.1),
                      blurRadius: 5.0, // soften the shadow
                      spreadRadius: 0.0, //extend the shadow
                      offset: const Offset(
                        0.0, // Move to right 10  horizontally
                        0.0, // Move to bottom 10 Vertically
                      ),
                    ),
                  ],
                ),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Expanded(
                      flex: 2,
                      child: Padding(
                        padding: EdgeInsets.symmetric(
                            vertical: 10.0, horizontal: 0.0),
                        child: CircleAvatar(
                          backgroundColor: Palette.secondaryColor,
                          // backgroundImage: AssetImage('assets/images/blog.jpeg'),
                          radius: 25.0,
                          child: Icon(
                            MdiIcons.commentQuestionOutline,
                            color: Palette.white,
                          ),
                        ),
                      ),
                    ),
                    Expanded(
                      flex: 5,
                      child: Padding(
                        padding: const EdgeInsets.symmetric(
                            vertical: 0.0, horizontal: 5.0),
                        child: Row(
                          children: const [
                            Text(
                              'FAQ',
                              style: TextStyle(
                                  color: Colors.black,
                                  fontSize: 16.0,
                                  fontFamily: 'EuclidCircularA Medium'),
                            ),
                          ],
                        ),
                      ),
                    ),
                    const Expanded(
                      flex: 1,
                      child: Padding(
                        padding: EdgeInsets.all(5.0),
                        child: Icon(
                          Icons.arrow_forward_ios,
                          size: 18.0,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(
              vertical: 5.0,
              horizontal: 24.0,
            ),
            child: GestureDetector(
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => const WebviewPage(
                      url: 'http://www.cheftarunabirla.com/feedback1',
                      title: 'Feedback',
                    ),
                  ),
                );
              },
              child: Container(
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(10.0),
                  color: Palette.white,
                  boxShadow: [
                    BoxShadow(
                      color: Palette.shadowColor.withOpacity(0.1),
                      blurRadius: 5.0, // soften the shadow
                      spreadRadius: 0.0, //extend the shadow
                      offset: const Offset(
                        0.0, // Move to right 10  horizontally
                        0.0, // Move to bottom 10 Vertically
                      ),
                    ),
                  ],
                ),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Expanded(
                      flex: 2,
                      child: Padding(
                        padding: EdgeInsets.symmetric(
                            vertical: 10.0, horizontal: 0.0),
                        child: CircleAvatar(
                          backgroundColor: Palette.secondaryColor,
                          radius: 25.0,
                          child: Icon(
                            MdiIcons.messageTextOutline,
                            color: Palette.white,
                          ),
                        ),
                      ),
                    ),
                    Expanded(
                      flex: 5,
                      child: Padding(
                        padding: EdgeInsets.symmetric(
                            vertical: 0.0, horizontal: 5.0),
                        child: Row(
                          children: [
                            Text(
                              'Feedback',
                              style: TextStyle(
                                  color: Colors.black,
                                  fontSize: 16.0,
                                  fontFamily: 'EuclidCircularA Medium'),
                            ),
                          ],
                        ),
                      ),
                    ),
                    const Expanded(
                      flex: 1,
                      child: Padding(
                        padding: EdgeInsets.all(5.0),
                        child: Icon(
                          Icons.arrow_forward_ios,
                          size: 18.0,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(
              vertical: 5.0,
              horizontal: 24.0,
            ),
            child: GestureDetector(
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => const WebviewPage(
                      url: 'http://www.cheftarunabirla.com/privacy-policy-2/',
                      title: 'Privacy Policy',
                    ),
                  ),
                );
              },
              child: Container(
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(10.0),
                  color: Palette.white,
                  boxShadow: [
                    BoxShadow(
                      color: Palette.shadowColor.withOpacity(0.1),
                      blurRadius: 5.0, // soften the shadow
                      spreadRadius: 0.0, //extend the shadow
                      offset: const Offset(
                        0.0, // Move to right 10  horizontally
                        0.0, // Move to bottom 10 Vertically
                      ),
                    ),
                  ],
                ),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Expanded(
                      flex: 2,
                      child: Padding(
                        padding: EdgeInsets.symmetric(
                            vertical: 10.0, horizontal: 0.0),
                        child: CircleAvatar(
                          backgroundColor: Palette.secondaryColor,
                          radius: 25.0,
                          child: Icon(
                            MdiIcons.bookLockOutline,
                            color: Palette.white,
                          ),
                        ),
                      ),
                    ),
                    Expanded(
                      flex: 5,
                      child: Padding(
                        padding: const EdgeInsets.symmetric(
                            vertical: 0.0, horizontal: 5.0),
                        child: Row(
                          children: const [
                            Text(
                              'Privacy Policy',
                              style: TextStyle(
                                  color: Colors.black,
                                  fontSize: 16.0,
                                  fontFamily: 'EuclidCircularA Medium'),
                            ),
                          ],
                        ),
                      ),
                    ),
                    const Expanded(
                      flex: 1,
                      child: Padding(
                        padding: EdgeInsets.all(5.0),
                        child: Icon(
                          Icons.arrow_forward_ios,
                          size: 18.0,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(
              vertical: 5.0,
              horizontal: 24.0,
            ),
            child: GestureDetector(
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => const WebviewPage(
                      url: 'http://www.cheftarunabirla.com/tnc/',
                      title: 'Terms & Conditions',
                    ),
                  ),
                );
              },
              child: Container(
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(10.0),
                  color: Palette.white,
                  boxShadow: [
                    BoxShadow(
                      color: Palette.shadowColor.withOpacity(0.1),
                      blurRadius: 5.0, // soften the shadow
                      spreadRadius: 0.0, //extend the shadow
                      offset: const Offset(
                        0.0, // Move to right 10  horizontally
                        0.0, // Move to bottom 10 Vertically
                      ),
                    ),
                  ],
                ),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Expanded(
                      flex: 2,
                      child: Padding(
                        padding: EdgeInsets.symmetric(
                            vertical: 10.0, horizontal: 0.0),
                        child: CircleAvatar(
                          backgroundColor: Palette.secondaryColor,
                          // backgroundImage: AssetImage('assets/images/blog.jpeg'),
                          radius: 25.0,
                          child: Icon(
                            MdiIcons.shieldLockOutline,
                            color: Palette.white,
                          ),
                        ),
                      ),
                    ),
                    Expanded(
                      flex: 5,
                      child: Padding(
                        padding: const EdgeInsets.symmetric(
                            vertical: 0.0, horizontal: 5.0),
                        child: Row(
                          children: const [
                            Text(
                              'Terms & Conditions',
                              style: TextStyle(
                                  color: Colors.black,
                                  fontSize: 16.0,
                                  fontFamily: 'EuclidCircularA Medium'),
                            ),
                          ],
                        ),
                      ),
                    ),
                    const Expanded(
                      flex: 1,
                      child: Padding(
                        padding: EdgeInsets.all(5.0),
                        child: Icon(
                          Icons.arrow_forward_ios,
                          size: 18.0,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24.0),
            child: GestureDetector(
              onTap: _showLogoutDialog,
              child: Container(
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(10.0),
                  color: Colors.white,
                  boxShadow: [
                    BoxShadow(
                      color: Colors.grey.withOpacity(0.1),
                      blurRadius: 5.0,
                      offset: const Offset(0.0, 0.0),
                    ),
                  ],
                ),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    const Expanded(
                      flex: 2,
                      child: Padding(
                        padding: EdgeInsets.symmetric(
                            vertical: 10.0, horizontal: 0.0),
                        child: CircleAvatar(
                          backgroundColor: Palette.secondaryColor,
                          radius: 25.0,
                          child: Icon(
                            Icons.logout,
                            color: Colors.white,
                          ),
                        ),
                      ),
                    ),
                    const Expanded(
                      flex: 5,
                      child: Padding(
                        padding: EdgeInsets.symmetric(horizontal: 5.0),
                        child: Text(
                          'Log Out',
                          style: TextStyle(
                              color: Colors.black,
                              fontSize: 16.0,
                              fontFamily: 'EuclidCircularA Medium'),
                        ),
                      ),
                    ),
                    const Expanded(
                      flex: 1,
                      child: Padding(
                        padding: EdgeInsets.all(5.0),
                        child: Icon(
                          Icons.arrow_forward_ios,
                          size: 18.0,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
          const SizedBox(
            height: 20.0,
          )
        ],
      ),
    );
  }

  // Future<void> _logout() async {
  //   // SharedPreferences prefs = await SharedPreferences.getInstance();
  //   // await prefs.clear(); // Clear all stored data (logout user).
  //   // Navigator.pushReplacementNamed(
  //   //     context, '/signin'); // Navigate to Sign-In Page.
  //   FirebaseAuth.instance.signOut().then(value){
  //     Navigator.pushAndRemoveUntil(context,MaterialPageRoute(builder: (context)=>SplashScreen(),),
  //     (route)=>false,);
  //   };
  // }
  Future<void> _logout() async {
    // Clear shared preferences if needed
    // SharedPreferences prefs = await SharedPreferences.getInstance();
    // await prefs.clear(); // Clear all stored data (logout user).

    // Sign out from Firebase and navigate to SplashScreen
    FirebaseAuth.instance.signOut().then((value) {
      Navigator.pushAndRemoveUntil(
        context,
        MaterialPageRoute(builder: (context) => SplashScreen()),
        (route) => false,
      );
    }).catchError((error) {
      // Handle error if sign out fails
      print("Error during sign out: $error");
    });
  }

  void _showLogoutDialog() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Confirm Logout'),
          content: const Text('Are you sure you want to log out?'),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(context); // Close the dialog.
              },
              child: const Text('Cancel'),
            ),
            TextButton(
              onPressed: () {
                Navigator.pop(context); // Close the dialog.
                _logout(); // Perform logout.
              },
              child: const Text('Log Out'),
            ),
          ],
        );
      },
    );
  }
}
