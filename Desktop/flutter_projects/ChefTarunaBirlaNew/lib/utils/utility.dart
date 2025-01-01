import 'dart:io';

import 'package:chef_taruna_birla/pages/startup/splash.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';
// import 'package:launch_review/launch_review.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:url_launcher/url_launcher.dart';

import '../api/api_functions.dart';
import '../config/config.dart';
import '../viewmodels/main_container_viewmodel.dart';

class Utility {
  //Print statement function
  static void printLog(String msg) {
    if (Constants.isDevelopment) {
      print(msg);
    }
  }

  //show progress
  static void showProgress(bool status) {
    if (status) {
      EasyLoading.show(
        status: 'Please Wait',
        maskType: EasyLoadingMaskType.black,
      );
    } else {
      EasyLoading.dismiss();
    }
  }

  static ScaffoldFeatureController<SnackBar, SnackBarClosedReason> showSnacbar(
      BuildContext context, String message,
      {int duration = 1, Function? onClicked}) {
    return ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: GestureDetector(
          onTap: () {
            if (onClicked != null) {
              onClicked();
            }
          },
          child: Container(
            decoration: BoxDecoration(
              color: Palette.black.withOpacity(0.8),
              borderRadius: BorderRadius.circular(10.0),
            ),
            height: 60.0,
            child: Center(
              child: Text(
                message,
                textAlign: TextAlign.center,
              ),
            ),
          ),
        ),
        backgroundColor: Palette.black.withOpacity(0.0),
        padding:
            const EdgeInsets.only(bottom: 20, left: 16, right: 16, top: 20),
        behavior: SnackBarBehavior.fixed,
        duration: Duration(seconds: duration),
        elevation: 0,
      ),
    );
  }

  //Open Whatsapp
  static void openWhatsapp(BuildContext context) async {
    var whatsapp = Application.adminPhoneNumber;
    var whatsappURl_android = "whatsapp://send?phone=" + whatsapp + "";
    var whatappURL_ios = "https://wa.me/$whatsapp";
    if (Platform.isIOS) {
      // for iOS phone only
      if (await canLaunchUrl(Uri.parse(whatappURL_ios))) {
        await launchUrl(Uri.parse(whatappURL_ios));
      } else {
        Utility.showSnacbar(context, "whatsapp not installed");
      }
    } else {
      // android , web
      if (await canLaunchUrl(Uri.parse(whatsappURl_android))) {
        await launchUrl(Uri.parse(whatsappURl_android));
      } else {
        Utility.showSnacbar(context, "whatsapp not installed");
      }
    }
  }

  //Update Application Popup
  static Future<void> updateApplicationDialog(BuildContext context) {
    return showDialog<void>(
      context: context,
      barrierDismissible: false, // user must tap button!
      builder: (BuildContext context) {
        return WillPopScope(
          onWillPop: () async {
            return false;
          },
          child: AlertDialog(
            shape: const RoundedRectangleBorder(
                borderRadius: BorderRadius.all(Radius.circular(10.0))),
            contentPadding: const EdgeInsets.all(0.0),
            title: const Text(
              'date Available',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontFamily: 'CenturyGothic',
                fontSize: 20.0,
                color: Colors.black,
              ),
            ),
            content: SingleChildScrollView(
              child: ClipRRect(
                borderRadius: BorderRadius.circular(10.0),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    const SizedBox(
                      height: 10.0,
                    ),
                    const Padding(
                      padding: EdgeInsets.all(8.0),
                      child: Text(
                        'Enjoy seamless experience of the application with our new update',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          fontFamily: 'EuclidCircularA Regular',
                          fontSize: 16.0,
                          color: Color(0xff8e8e8e),
                        ),
                      ),
                    ),
                    const SizedBox(
                      height: 10.0,
                    ),
                    Row(
                      children: [
                        Expanded(
                          child: InkWell(
                            onTap: () {
                              // LaunchReview.launch(
                              //   androidAppId: "com.cheftarunbirla",
                              //   iOSAppId: "com.technotwist.tarunaBirla",
                              // );
                            },
                            child: Container(
                              decoration: const BoxDecoration(
                                  color: Palette.contrastColor),
                              child: const Center(
                                child: Padding(
                                  padding: EdgeInsets.symmetric(
                                      vertical: 12.0, horizontal: 0.0),
                                  child: Text(
                                    'Update',
                                    style: TextStyle(
                                      fontFamily: 'CenturyGothic',
                                      fontSize: 16.0,
                                      color: Colors.white,
                                    ),
                                  ),
                                ),
                              ),
                            ),
                          ),
                        ),
                        // Expanded(
                        //   child: InkWell(
                        //     onTap: () => Navigator.of(context).pop(),
                        //     child: Container(
                        //       decoration: const BoxDecoration(
                        //         color: Color(0xfff4f4f4),
                        //       ),
                        //       child: const Center(
                        //         child: Padding(
                        //           padding: EdgeInsets.symmetric(
                        //               vertical: 12.0, horizontal: 0.0),
                        //           child: Text(
                        //             'Cancel',
                        //             style: TextStyle(
                        //               fontFamily: 'CenturyGothic',
                        //               fontSize: 16.0,
                        //               color: Colors.black,
                        //             ),
                        //           ),
                        //         ),
                        //       ),
                        //     ),
                        //   ),
                        // ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ),
        );
      },
    );
  }

  //Rate Application Popup
  static Future<void> rateApplicationDialog(BuildContext context) {
    return showDialog<void>(
      context: context,
      barrierDismissible: false, // user must tap button!
      builder: (BuildContext context) {
        return AlertDialog(
          shape: const RoundedRectangleBorder(
              borderRadius: BorderRadius.all(Radius.circular(10.0))),
          contentPadding: const EdgeInsets.all(0.0),
          title: const Text(
            'Rate our app!!',
            textAlign: TextAlign.center,
            style: TextStyle(
              fontFamily: 'CenturyGothic',
              fontSize: 20.0,
              color: Colors.black,
            ),
          ),
          content: SingleChildScrollView(
            child: ClipRRect(
              borderRadius: BorderRadius.circular(10.0),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  const SizedBox(
                    height: 10.0,
                  ),
                  const Padding(
                    padding: EdgeInsets.all(8.0),
                    child: Text(
                      'Please rate our app, it is important to us!!',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontFamily: 'EuclidCircularA Regular',
                        fontSize: 16.0,
                        color: Color(0xff8e8e8e),
                      ),
                    ),
                  ),
                  const SizedBox(
                    height: 10.0,
                  ),
                  Row(
                    children: [
                      Expanded(
                        child: InkWell(
                          onTap: () {
                            // LaunchReview.launch(
                            //   androidAppId: "com.cheftarunbirla",
                            //   iOSAppId: "com.technotwist.tarunaBirla",
                            // );
                          },
                          child: Container(
                            decoration: const BoxDecoration(
                                color: Palette.contrastColor),
                            child: const Center(
                              child: Padding(
                                padding: EdgeInsets.symmetric(
                                    vertical: 12.0, horizontal: 0.0),
                                child: Text(
                                  'Rate',
                                  style: TextStyle(
                                    fontFamily: 'CenturyGothic',
                                    fontSize: 16.0,
                                    color: Colors.white,
                                  ),
                                ),
                              ),
                            ),
                          ),
                        ),
                      ),
                      Expanded(
                        child: InkWell(
                          onTap: () => Navigator.of(context).pop(),
                          child: Container(
                            decoration: const BoxDecoration(
                              color: Color(0xfff4f4f4),
                            ),
                            child: const Center(
                              child: Padding(
                                padding: EdgeInsets.symmetric(
                                    vertical: 12.0, horizontal: 0.0),
                                child: Text(
                                  'Cancel',
                                  style: TextStyle(
                                    fontFamily: 'CenturyGothic',
                                    fontSize: 16.0,
                                    color: Colors.black,
                                  ),
                                ),
                              ),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  //No internet Popup
  static Future<void> noInternetPopup(BuildContext context) {
    return showDialog<void>(
      context: context,
      barrierDismissible: false, // user must tap button!
      builder: (BuildContext context) {
        return AlertDialog(
          shape: const RoundedRectangleBorder(
              borderRadius: BorderRadius.all(Radius.circular(10.0))),
          contentPadding: const EdgeInsets.all(0.0),
          title: const Text(
            'OOP\'S!!',
            textAlign: TextAlign.center,
            style: TextStyle(
              fontFamily: 'CenturyGothic',
              fontSize: 20.0,
              color: Colors.black,
            ),
          ),
          content: SingleChildScrollView(
            child: ClipRRect(
              borderRadius: BorderRadius.circular(10.0),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  const SizedBox(
                    height: 10.0,
                  ),
                  const Padding(
                    padding: EdgeInsets.all(8.0),
                    child: Text(
                      'No Internet Connection!!',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontFamily: 'EuclidCircularA Regular',
                        fontSize: 16.0,
                        color: Color(0xff8e8e8e),
                      ),
                    ),
                  ),
                  const SizedBox(
                    height: 10.0,
                  ),
                  Row(
                    children: [
                      Expanded(
                        child: InkWell(
                          onTap: () {
                            Navigator.pushAndRemoveUntil(
                              context,
                              MaterialPageRoute(
                                builder: (context) => const SplashScreen(),
                              ),
                              (Route<dynamic> route) => false,
                            );
                          },
                          child: Container(
                            decoration: const BoxDecoration(
                                color: Palette.contrastColor),
                            child: const Center(
                              child: Padding(
                                padding: EdgeInsets.symmetric(
                                    vertical: 12.0, horizontal: 0.0),
                                child: Text(
                                  'Retry',
                                  style: TextStyle(
                                    fontFamily: 'CenturyGothic',
                                    fontSize: 16.0,
                                    color: Colors.white,
                                  ),
                                ),
                              ),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  //Logout Popup
  static Future<void> logout(BuildContext context) {
    return showDialog<void>(
      context: context,
      barrierDismissible: false, // user must tap button!
      builder: (BuildContext context) {
        return AlertDialog(
          shape: const RoundedRectangleBorder(
              borderRadius: BorderRadius.all(Radius.circular(10.0))),
          contentPadding: const EdgeInsets.all(0.0),
          title: const Text(
            'OOP\'S!!',
            textAlign: TextAlign.center,
            style: TextStyle(
              fontFamily: 'CenturyGothic',
              fontSize: 20.0,
              color: Colors.black,
            ),
          ),
          content: SingleChildScrollView(
            child: ClipRRect(
              borderRadius: BorderRadius.circular(10.0),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  const SizedBox(
                    height: 10.0,
                  ),
                  const Padding(
                    padding: EdgeInsets.all(8.0),
                    child: Text(
                      'Looks Like you are already logged in some other device,So you have been logged out from this device!!',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontFamily: 'EuclidCircularA Regular',
                        fontSize: 16.0,
                        color: Color(0xff8e8e8e),
                      ),
                    ),
                  ),
                  const SizedBox(
                    height: 10.0,
                  ),
                  // Row(
                  //   children: [
                  //     Expanded(
                  //       child: InkWell(
                  //         onTap: () {
                  //           logoutUser(context);
                  //           Navigator.of(context).pop();
                  //         },
                  //         child: Container(
                  //           decoration: const BoxDecoration(
                  //               color: Palette.contrastColor),
                  //           child: const Center(
                  //             child: Padding(
                  //               padding: EdgeInsets.symmetric(
                  //                   vertical: 12.0, horizontal: 0.0),
                  //               child: Text(
                  //                 'Logout',
                  //                 style: TextStyle(
                  //                   fontFamily: 'CenturyGothic',
                  //                   fontSize: 16.0,
                  //                   color: Colors.white,
                  //                 ),
                  //               ),
                  //             ),
                  //           ),
                  //         ),
                  //       ),
                  //     ),
                  //   ],
                  // ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  //Logout Popup
  static Future<void> forceLogout(BuildContext context) {
    return showDialog<void>(
      context: context,
      barrierDismissible: false, // user must tap button!
      builder: (BuildContext context) {
        return AlertDialog(
          shape: const RoundedRectangleBorder(
              borderRadius: BorderRadius.all(Radius.circular(10.0))),
          contentPadding: const EdgeInsets.all(0.0),
          title: const Text(
            'OOP\'S!!',
            textAlign: TextAlign.center,
            style: TextStyle(
              fontFamily: 'CenturyGothic',
              fontSize: 20.0,
              color: Colors.black,
            ),
          ),
          content: SingleChildScrollView(
            child: ClipRRect(
              borderRadius: BorderRadius.circular(10.0),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  const SizedBox(
                    height: 10.0,
                  ),
                  Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Text(
                      'Looks Like you had taken a screenshot or screen Recording so you are being forced Logout!! contact ${Application.adminPhoneNumber} for further process',
                      textAlign: TextAlign.center,
                      style: const TextStyle(
                        fontFamily: 'EuclidCircularA Regular',
                        fontSize: 16.0,
                        color: Color(0xff8e8e8e),
                      ),
                    ),
                  ),
                  const SizedBox(
                    height: 10.0,
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  //Logout Function
  static void forceLogoutUser(BuildContext context) async {
    showProgress(true);
    Map<String, String> params = {
      'user_id': Application.userId,
    };
    String url = '${Constants.finalUrl}/users/increaseWarningCount';
    Map<String, dynamic> _postResult =
        await ApiFunctions.postApiResult(url, Application.deviceToken, params);
    bool _status = _postResult['status'];
    var _data = _postResult['data'];
    if (_status) {
      showProgress(false);
      showProfileEditSuccessMessage(
          'Warning',
          'You are not allowed to take screenshots in case you do, you will be blocked by admin,\nFor more information contact ${Application.adminPhoneNumber}',
          context);
      // showSnacbar(context, 'This is an warning you are not allowed to take screen shots');
      // SharedPreferences prefs = await SharedPreferences.getInstance();
      // prefs.setString('phonenumber', '');
      // prefs.setString('user_id', '');
      // prefs.setString("address", '');
      // prefs.setString("pincode", '');
      // Application.phoneNumber = '';
      // Application.userId = '';
      // Application.address = '';
      // Application.pincode = '';
      //
      // Future.delayed(const Duration(milliseconds: 1500), () {
      //   Provider.of<MainContainerViewModel>(context, listen: false).setIndex(0);
      //   Navigator.pushAndRemoveUntil(
      //     context,
      //     MaterialPageRoute(
      //       builder: (context) => const SplashScreen(),
      //     ),
      //     (Route<dynamic> route) => false,
      //   );
      // });
    } else {
      showProgress(false);
      // SharedPreferences prefs = await SharedPreferences.getInstance();
      // prefs.setString('phonenumber', '');
      // prefs.setString("address", '');
      // prefs.setString("pincode", '');
      // Application.phoneNumber = '';
      // Application.address = '';
      // Application.pincode = '';
      //
      // Future.delayed(const Duration(milliseconds: 1500), () {
      //   Provider.of<MainContainerViewModel>(context, listen: false).setIndex(0);
      //   Navigator.pushAndRemoveUntil(
      //     context,
      //     MaterialPageRoute(
      //       builder: (context) => const SplashScreen(),
      //     ),
      //     (Route<dynamic> route) => false,
      //   );
      // });
    }
  }

  //Logout Function
  static void logoutUser(BuildContext context) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    prefs.setString('phonenumber', '');
    prefs.setString("address", '');
    prefs.setString("pincode", '');
    Application.phoneNumber = '';
    Application.address = '';
    Application.pincode = '';

    // Future.delayed(const Duration(milliseconds: 1000), () {
    //   Provider.of<MainContainerViewModel>(context, listen: false).setIndex(0);
    //   Navigator.pushAndRemoveUntil(
    //     context,
    //     MaterialPageRoute(
    //       builder: (context) => const SplashScreen(),
    //     ),
    //     (Route<dynamic> route) => false,
    //   );
    // });
  }

  //Database Error Popup
  static Future<void> databaseErrorPopup(BuildContext context) {
    return showDialog<void>(
      context: context,
      barrierDismissible: false, // user must tap button!
      builder: (BuildContext context) {
        return AlertDialog(
          shape: const RoundedRectangleBorder(
              borderRadius: BorderRadius.all(Radius.circular(10.0))),
          contentPadding: const EdgeInsets.all(0.0),
          title: const Text(
            'OOP\'S!!',
            textAlign: TextAlign.center,
            style: TextStyle(
              fontFamily: 'CenturyGothic',
              fontSize: 20.0,
              color: Colors.black,
            ),
          ),
          content: SingleChildScrollView(
            child: ClipRRect(
              borderRadius: BorderRadius.circular(10.0),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  const SizedBox(
                    height: 10.0,
                  ),
                  const Padding(
                    padding: EdgeInsets.all(8.0),
                    child: Text(
                      'Sorry for inconvenience. The servers are down due to some technical issue,Please visit after some time!!',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontFamily: 'EuclidCircularA Regular',
                        fontSize: 16.0,
                        color: Color(0xff8e8e8e),
                      ),
                    ),
                  ),
                  const SizedBox(
                    height: 10.0,
                  ),
                  Row(
                    children: [
                      Expanded(
                        child: InkWell(
                          onTap: () {
                            if (Platform.isIOS) {
                              exit(0);
                            } else {
                              SystemNavigator.pop();
                            }
                          },
                          child: Container(
                            decoration: const BoxDecoration(
                                color: Palette.contrastColor),
                            child: const Center(
                              child: Padding(
                                padding: EdgeInsets.symmetric(
                                    vertical: 12.0, horizontal: 0.0),
                                child: Text(
                                  'OK',
                                  style: TextStyle(
                                    fontFamily: 'CenturyGothic',
                                    fontSize: 16.0,
                                    color: Colors.white,
                                  ),
                                ),
                              ),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  //Authentication Error Popup
  static Future<void> authErrorPopup(BuildContext context, String message) {
    return showDialog<void>(
      context: context,
      barrierDismissible: false, // user must tap button!
      builder: (BuildContext context) {
        return AlertDialog(
          shape: const RoundedRectangleBorder(
              borderRadius: BorderRadius.all(Radius.circular(10.0))),
          contentPadding: const EdgeInsets.all(0.0),
          title: const Text(
            'OOP\'S!!',
            textAlign: TextAlign.center,
            style: TextStyle(
              fontFamily: 'CenturyGothic',
              fontSize: 20.0,
              color: Colors.black,
            ),
          ),
          content: SingleChildScrollView(
            child: ClipRRect(
              borderRadius: BorderRadius.circular(10.0),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  const SizedBox(
                    height: 10.0,
                  ),
                  Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Text(
                      message,
                      textAlign: TextAlign.center,
                      style: const TextStyle(
                        fontFamily: 'EuclidCircularA Regular',
                        fontSize: 16.0,
                        color: Color(0xff8e8e8e),
                      ),
                    ),
                  ),
                  const SizedBox(
                    height: 10.0,
                  ),
                  Row(
                    children: [
                      Expanded(
                        child: InkWell(
                          onTap: () {
                            // if (Platform.isIOS) {
                            //   exit(0);
                            // } else {
                            //   SystemNavigator.pop();
                            // }
                            Provider.of<MainContainerViewModel>(context,
                                    listen: false)
                                .setIndex(0);
                            Navigator.pushAndRemoveUntil(
                              context,
                              MaterialPageRoute(
                                builder: (context) => const SplashScreen(),
                              ),
                              (Route<dynamic> route) => false,
                            );
                          },
                          child: Container(
                            decoration: const BoxDecoration(
                                color: Palette.contrastColor),
                            child: const Center(
                              child: Padding(
                                padding: EdgeInsets.symmetric(
                                    vertical: 12.0, horizontal: 0.0),
                                child: Text(
                                  'OK',
                                  style: TextStyle(
                                    fontFamily: 'CenturyGothic',
                                    fontSize: 16.0,
                                    color: Colors.white,
                                  ),
                                ),
                              ),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  //Exit Application Popup
  static Future<void> exitApplicationPopup(BuildContext context) {
    return showDialog<void>(
      context: context,
      barrierDismissible: false, // user must tap button!
      builder: (BuildContext context) {
        return AlertDialog(
          shape: const RoundedRectangleBorder(
              borderRadius: BorderRadius.all(Radius.circular(10.0))),
          contentPadding: const EdgeInsets.all(0.0),
          title: const Text(
            'Exit Application',
            textAlign: TextAlign.center,
            style: TextStyle(
              fontFamily: 'CenturyGothic',
              fontSize: 20.0,
              color: Colors.black,
            ),
          ),
          content: SingleChildScrollView(
            child: ClipRRect(
              borderRadius: BorderRadius.circular(10.0),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  const SizedBox(
                    height: 10.0,
                  ),
                  const Padding(
                    padding: EdgeInsets.all(8.0),
                    child: Text(
                      'Do you want to exit the application?',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontFamily: 'EuclidCircularA Regular',
                        fontSize: 16.0,
                        color: Color(0xff8e8e8e),
                      ),
                    ),
                  ),
                  const SizedBox(
                    height: 10.0,
                  ),
                  Row(
                    children: [
                      Expanded(
                        child: InkWell(
                          onTap: () {
                            if (Platform.isIOS) {
                              exit(0);
                            } else {
                              SystemNavigator.pop();
                            }
                          },
                          child: Container(
                            decoration: const BoxDecoration(
                                color: Palette.contrastColor),
                            child: const Center(
                              child: Padding(
                                padding: EdgeInsets.symmetric(
                                    vertical: 12.0, horizontal: 0.0),
                                child: Text(
                                  'OK',
                                  style: TextStyle(
                                    fontFamily: 'CenturyGothic',
                                    fontSize: 16.0,
                                    color: Colors.white,
                                  ),
                                ),
                              ),
                            ),
                          ),
                        ),
                      ),
                      Expanded(
                        child: InkWell(
                          onTap: () => Navigator.of(context).pop(),
                          child: Container(
                            decoration: const BoxDecoration(
                              color: Color(0xfff4f4f4),
                            ),
                            child: const Center(
                              child: Padding(
                                padding: EdgeInsets.symmetric(
                                    vertical: 12.0, horizontal: 0.0),
                                child: Text(
                                  'Cancel',
                                  style: TextStyle(
                                    fontFamily: 'CenturyGothic',
                                    fontSize: 16.0,
                                    color: Colors.black,
                                  ),
                                ),
                              ),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  //Show Value Popup
  static Future<void> showValuePopup(BuildContext context) {
    return showDialog<void>(
      context: context,
      barrierDismissible: false, // user must tap button!
      builder: (BuildContext context) {
        return AlertDialog(
          shape: const RoundedRectangleBorder(
              borderRadius: BorderRadius.all(Radius.circular(10.0))),
          contentPadding: const EdgeInsets.all(0.0),
          title: const Text(
            'Username required!!',
            textAlign: TextAlign.center,
            style: TextStyle(
              fontFamily: 'CenturyGothic',
              fontSize: 20.0,
              color: Colors.black,
            ),
          ),
          content: SingleChildScrollView(
            child: ClipRRect(
              borderRadius: BorderRadius.circular(10.0),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: const [
                  SizedBox(
                    height: 10.0,
                  ),
                  Padding(
                    padding: EdgeInsets.all(8.0),
                    child: Text(
                      'You need to update your name first',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontFamily: 'EuclidCircularA Regular',
                        fontSize: 16.0,
                        color: Color(0xff8e8e8e),
                      ),
                    ),
                  ),
                  SizedBox(
                    height: 10.0,
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  //Database Error Popup
  static Future<void> subscriptionEndedPopup(BuildContext context) {
    return showDialog<void>(
      context: context,
      barrierDismissible: false, // user must tap button!
      builder: (BuildContext context) {
        return AlertDialog(
          shape: const RoundedRectangleBorder(
              borderRadius: BorderRadius.all(Radius.circular(10.0))),
          contentPadding: const EdgeInsets.all(0.0),
          title: const Text(
            'Your subscription ended !!',
            textAlign: TextAlign.center,
            style: TextStyle(
              fontFamily: 'CenturyGothic',
              fontSize: 20.0,
              color: Colors.black,
            ),
          ),
          content: SingleChildScrollView(
            child: ClipRRect(
              borderRadius: BorderRadius.circular(10.0),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  const SizedBox(
                    height: 10.0,
                  ),
                  const Padding(
                    padding: EdgeInsets.all(8.0),
                    child: Text(
                      'Looks like your subscription has ended please purchase again to continue!!',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontFamily: 'EuclidCircularA Regular',
                        fontSize: 16.0,
                        color: Color(0xff8e8e8e),
                      ),
                    ),
                  ),
                  const SizedBox(
                    height: 10.0,
                  ),
                  Row(
                    children: [
                      Expanded(
                        child: InkWell(
                          onTap: () {
                            Navigator.pop(context);
                          },
                          child: Container(
                            decoration: const BoxDecoration(
                                color: Palette.contrastColor),
                            child: const Center(
                              child: Padding(
                                padding: EdgeInsets.symmetric(
                                    vertical: 12.0, horizontal: 0.0),
                                child: Text(
                                  'OK',
                                  style: TextStyle(
                                    fontFamily: 'CenturyGothic',
                                    fontSize: 16.0,
                                    color: Colors.white,
                                  ),
                                ),
                              ),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  //Update Lanuage Function
  static void changeLanguage(BuildContext context, String languageId) async {
    if (Application.languageId != languageId) {
      SharedPreferences prefs = await SharedPreferences.getInstance();
      prefs.setString("language_id", languageId);
      Provider.of<MainContainerViewModel>(context, listen: false).setIndex(0);
      Navigator.pushAndRemoveUntil(
        context,
        MaterialPageRoute(
          builder: (context) => const SplashScreen(),
        ),
        (Route<dynamic> route) => false,
      );
    } else {
      Navigator.of(context).pop();
    }
  }

  //Database Error Popup
  static Future<void> showLanguagePopup(BuildContext context) {
    return showDialog<void>(
      context: context,
      barrierDismissible: false, // user must tap button!
      builder: (BuildContext context) {
        return AlertDialog(
          shape: const RoundedRectangleBorder(
              borderRadius: BorderRadius.all(Radius.circular(10.0))),
          contentPadding: const EdgeInsets.all(0.0),
          title: const Text(
            'Change language',
            textAlign: TextAlign.center,
            style: TextStyle(
              fontFamily: 'CenturyGothic',
              fontSize: 20.0,
              color: Colors.black,
            ),
          ),
          content: SingleChildScrollView(
            child: ClipRRect(
              borderRadius: BorderRadius.circular(10.0),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  const SizedBox(
                    height: 10.0,
                  ),
                  Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: GestureDetector(
                      onTap: () {
                        changeLanguage(context, '1');
                      },
                      child: Container(
                        width: double.infinity,
                        decoration: BoxDecoration(
                          color: Application.languageId == '1'
                              ? Palette.secondaryColor
                              : Palette.white,
                          border: Border.all(
                            width: 1.0,
                            color: Palette.secondaryColor,
                          ),
                          borderRadius: BorderRadius.circular(8.0),
                        ),
                        child: Padding(
                          padding: const EdgeInsets.all(10.0),
                          child: Center(
                            child: Text(
                              'English',
                              textAlign: TextAlign.center,
                              style: TextStyle(
                                fontFamily: 'EuclidCircularA Regular',
                                fontSize: 16.0,
                                color: Application.languageId == '1'
                                    ? Palette.white
                                    : Palette.black,
                              ),
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: GestureDetector(
                      onTap: () {
                        changeLanguage(context, '2');
                      },
                      child: Container(
                        width: double.infinity,
                        decoration: BoxDecoration(
                          color: Application.languageId == '2'
                              ? Palette.secondaryColor
                              : Palette.white,
                          border: Border.all(
                            width: 1.0,
                            color: Palette.secondaryColor,
                          ),
                          borderRadius: BorderRadius.circular(8.0),
                        ),
                        child: Padding(
                          padding: const EdgeInsets.all(10.0),
                          child: Center(
                            child: Text(
                              'हिन्दी',
                              textAlign: TextAlign.center,
                              style: TextStyle(
                                fontFamily: 'EuclidCircularA Regular',
                                fontSize: 16.0,
                                color: Application.languageId == '2'
                                    ? Palette.white
                                    : Palette.secondaryColor,
                              ),
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(
                    height: 10.0,
                  ),
                  Row(
                    children: [
                      Expanded(
                        child: InkWell(
                          onTap: () {
                            Navigator.pop(context);
                          },
                          child: Container(
                            decoration: const BoxDecoration(
                                color: Palette.contrastColor),
                            child: const Center(
                              child: Padding(
                                padding: EdgeInsets.symmetric(
                                    vertical: 12.0, horizontal: 0.0),
                                child: Text(
                                  'Cancel',
                                  style: TextStyle(
                                    fontFamily: 'CenturyGothic',
                                    fontSize: 16.0,
                                    color: Colors.white,
                                  ),
                                ),
                              ),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  //Database Error Popup
  static Future<void> showProfileEditSuccessMessage(
      String title, String message, BuildContext context) {
    return showDialog<void>(
      context: context,
      barrierDismissible: false, // user must tap button!
      builder: (BuildContext context) {
        return AlertDialog(
          shape: const RoundedRectangleBorder(
              borderRadius: BorderRadius.all(Radius.circular(10.0))),
          contentPadding: const EdgeInsets.all(0.0),
          title: Text(
            title,
            textAlign: TextAlign.center,
            style: const TextStyle(
              fontFamily: 'CenturyGothic',
              fontSize: 20.0,
              color: Colors.black,
            ),
          ),
          content: SingleChildScrollView(
            child: ClipRRect(
              borderRadius: BorderRadius.circular(10.0),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  const SizedBox(
                    height: 10.0,
                  ),
                  Padding(
                    padding: EdgeInsets.all(8.0),
                    child: Text(
                      message,
                      textAlign: TextAlign.center,
                      style: const TextStyle(
                        fontFamily: 'EuclidCircularA Regular',
                        fontSize: 16.0,
                        color: Color(0xff8e8e8e),
                      ),
                    ),
                  ),
                  const SizedBox(
                    height: 10.0,
                  ),
                  Row(
                    children: [
                      Expanded(
                        child: InkWell(
                          onTap: () {
                            Navigator.pop(context);
                          },
                          child: Container(
                            decoration: const BoxDecoration(
                                color: Palette.contrastColor),
                            child: const Center(
                              child: Padding(
                                padding: EdgeInsets.symmetric(
                                    vertical: 12.0, horizontal: 0.0),
                                child: Text(
                                  'OK',
                                  style: TextStyle(
                                    fontFamily: 'CenturyGothic',
                                    fontSize: 16.0,
                                    color: Colors.white,
                                  ),
                                ),
                              ),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}
