import 'dart:io';

import 'package:chef_taruna_birla/models/notifications.dart';
// import 'package:chef_taruna_birla/pages/blog/each_blog.dart';
import 'package:chef_taruna_birla/pages/course/each_course.dart';
import 'package:chef_taruna_birla/pages/live_integration/live_classes.dart';
import 'package:chef_taruna_birla/pages/product/each_product.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
// import 'package:ios_insecure_screen_detector/ios_insecure_screen_detector.dart';

import '../../api/api_functions.dart';
import '../../common/common.dart';
import '../../config/config.dart';
import '../../utils/utility.dart';
import '../book/each_book.dart';

class NotificationPage extends StatefulWidget {
  const NotificationPage({Key? key}) : super(key: key);

  @override
  State<NotificationPage> createState() => _NotificationPageState();
}

class _NotificationPageState extends State<NotificationPage> {
  bool isLoading = false;
  List<Notifications> notificationList = [];
  // final IosInsecureScreenDetector _insecureScreenDetector =
  //     IosInsecureScreenDetector();
  bool _isCaptured = false;

  Future<void> getUserNotifications() async {
    Utility.showProgress(true);

    String url =
        '${Constants.finalUrl}/users/getUserNotifications?user_id=${Application.userId}';
    Map<String, dynamic> _getResult =
        await ApiFunctions.getApiResult(url, Application.deviceToken);

    bool _status = _getResult['status'];
    var _data = _getResult['data'];
    print(_data);
    if (_status) {
      notificationList.clear();
      _data[ApiKeys.notifications].forEach((notification) {
        notificationList.add(Notifications.fromJson(notification));
      });
      setState(() {
        isLoading = true;
      });
      Utility.showProgress(false);
    } else {
      Utility.printLog('Something went wrong.');
      Utility.showProgress(false);
      Utility.databaseErrorPopup(context);
    }
  }

  _filterRetriever() async {
    try {
      final result = await InternetAddress.lookup('cheftarunabirla.com');
      if (result.isNotEmpty && result[0].rawAddress.isNotEmpty) {
        Utility.printLog('connected');
        getUserNotifications();
      }
    } on SocketException catch (_) {
      Utility.printLog('not connected');
      setState(() {
        isLoading = true;
      });
      Utility.showProgress(false);
      Utility.noInternetPopup(context);
    }
  }

  @override
  void initState() {
    // _filterRetriever();
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
    if (!kIsWeb) {
      _filterRetriever();
    } else {
      getUserNotifications();
    }
    super.initState();
  }

  @override
  void dispose() {
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return _isCaptured
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
        : Scaffold(
            backgroundColor: Palette.scaffoldColor,
            appBar: AppBar(
              leading: IconButton(
                icon: const Icon(
                  Icons.arrow_back_ios,
                  color: Palette.white,
                  size: 18.0,
                ),
                onPressed: () => Navigator.of(context).pop(),
              ),
              title: const Text(
                'Notifications',
                style: TextStyle(
                  color: Palette.white,
                  fontSize: 18.0,
                  fontFamily: 'EuclidCircularA Medium',
                ),
              ),
              backgroundColor: Palette.appBarColor,
              elevation: 10.0,
              shadowColor: Palette.shadowColor.withOpacity(0.1),
              centerTitle: false,
            ),
            body: !isLoading
                ? Container()
                : notificationList.isEmpty
                    ? const Center(
                        child: Text(
                          'No notifications till now..',
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            color: Palette.black,
                            fontSize: 14.0,
                            fontFamily: 'EuclidCircularA Medium',
                          ),
                        ),
                      )
                    : SingleChildScrollView(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const SizedBox(
                              height: 20.0,
                            ),
                            Padding(
                              padding: const EdgeInsets.symmetric(
                                  vertical: 00.0, horizontal: 24.0),
                              child: ListView.builder(
                                shrinkWrap: true,
                                physics: const NeverScrollableScrollPhysics(),
                                itemCount: notificationList.length,
                                itemBuilder: (BuildContext context, int index) {
                                  return Padding(
                                    padding: const EdgeInsets.symmetric(
                                      vertical: 5.0,
                                      horizontal: 0.0,
                                    ),
                                    child: GestureDetector(
                                      onTap: () {
                                        if (notificationList[index].category ==
                                            'course') {
                                          Navigator.push(
                                            context,
                                            MaterialPageRoute(
                                              builder: (context) => EachCourse(
                                                id: notificationList[index]
                                                    .item_id,
                                              ),
                                            ),
                                          );
                                        } else if (notificationList[index]
                                                .category ==
                                            'product') {
                                          Navigator.push(
                                            context,
                                            MaterialPageRoute(
                                              builder: (context) => EachProduct(
                                                id: notificationList[index]
                                                    .item_id,
                                              ),
                                            ),
                                          );
                                        } else if (notificationList[index]
                                                .category ==
                                            'live') {
                                          Navigator.push(
                                            context,
                                            MaterialPageRoute(
                                              builder: (context) =>
                                                  const LiveClasses(),
                                            ),
                                          );
                                        } else if (notificationList[index]
                                                .category ==
                                            'book') {
                                          Navigator.push(
                                            context,
                                            MaterialPageRoute(
                                              builder: (context) => EachBook(
                                                id: notificationList[index]
                                                    .item_id,
                                              ),
                                            ),
                                          );
                                        } else if (notificationList[index]
                                                .category ==
                                            'blog') {
                                          // Navigator.push(
                                          //   context,
                                          //   MaterialPageRoute(
                                          //     builder: (context) => EachBlog(
                                          //       id: notificationList[index]
                                          //           .item_id,
                                          //       description: '',
                                          //       share_url: '',
                                          //       title: '',
                                          //       time: '',
                                          //     ),
                                          //   ),
                                          // );
                                        } else if (notificationList[index]
                                                .category ==
                                            'payment') {
                                          Utility.showSnacbar(context,
                                              'Please contact ${Application.adminPhoneNumber} if you have any doubt regarding this payment message');
                                        } else if (notificationList[index]
                                                .category ==
                                            'warning') {
                                          Utility.showSnacbar(context,
                                              'Please contact ${Application.adminPhoneNumber} if you have any doubt regarding this warning');
                                        }
                                      },
                                      child: Container(
                                        decoration: BoxDecoration(
                                          borderRadius:
                                              BorderRadius.circular(8.0),
                                          color: Colors.white,
                                          boxShadow: [
                                            BoxShadow(
                                              color: Palette.shadowColor
                                                  .withOpacity(0.1),
                                              blurRadius:
                                                  5.0, // soften the shadow
                                              spreadRadius:
                                                  0.0, //extend the shadow
                                              offset: const Offset(
                                                0.0, // Move to right 10  horizontally
                                                0.0, // Move to bottom 10 Vertically
                                              ),
                                            ),
                                          ],
                                        ),
                                        child: Padding(
                                          padding: const EdgeInsets.all(8.0),
                                          child: Column(
                                            crossAxisAlignment:
                                                CrossAxisAlignment.start,
                                            mainAxisAlignment:
                                                MainAxisAlignment.start,
                                            children: [
                                              Text(
                                                notificationList[index].message,
                                                style: const TextStyle(
                                                  color: Palette.black,
                                                  fontSize: 16.0,
                                                  fontFamily:
                                                      'EuclidCircularA Regular',
                                                ),
                                              ),
                                              const SizedBox(
                                                height: 10.0,
                                              ),
                                              SizedBox(
                                                width: double.infinity,
                                                child: Text(
                                                  notificationList[index]
                                                      .created_at
                                                      .substring(0, 10),
                                                  style: const TextStyle(
                                                    color: Palette.black,
                                                    fontSize: 12.0,
                                                    fontFamily:
                                                        'EuclidCircularA Regular',
                                                  ),
                                                  textAlign: TextAlign.right,
                                                ),
                                              ),
                                            ],
                                          ),
                                        ),
                                      ),
                                    ),
                                  );
                                },
                              ),
                            ),
                            const SizedBox(
                              height: 15.0,
                            ),
                          ],
                        ),
                      ),
          );
  }
}
