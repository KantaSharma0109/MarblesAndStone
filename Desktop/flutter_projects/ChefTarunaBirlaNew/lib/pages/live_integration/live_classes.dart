import 'dart:io';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:chef_taruna_birla/common/common.dart';
import 'package:chef_taruna_birla/models/live.dart';
import 'package:chef_taruna_birla/pages/live_integration/live_page.dart';
import 'package:chef_taruna_birla/pages/profile/user_account.dart';
import 'package:chef_taruna_birla/utils/utility.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
// import 'package:ios_insecure_screen_detector/ios_insecure_screen_detector.dart';
import 'package:provider/provider.dart';
// import 'package:razorpay_flutter/razorpay_flutter.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../api/api_functions.dart';
import '../../config/config.dart';
import '../../services/mysql_db_service.dart';
import '../../viewmodels/deepLink.dart';
import '../../viewmodels/main_container_viewmodel.dart';
import '../../widgets/image_placeholder.dart';
import '../course/each_course.dart';
import '../main_container.dart';
import '../notifications/notification_page.dart';

class LiveClasses extends StatefulWidget {
  const LiveClasses({Key? key}) : super(key: key);

  @override
  State<LiveClasses> createState() => _LiveClassesState();
}

class _LiveClassesState extends State<LiveClasses> {
  List<Live> liveList = [];
  bool isLoading = false;
  String userName = '';
  String phoneNumber = '';
  String url = Constants.finalUrl;
  String wallet = '0';
  // final IosInsecureScreenDetector _insecureScreenDetector =
  //     IosInsecureScreenDetector();
  bool _isCaptured = false;
  Map<String, dynamic>? paymentParameter = {};
  // late Razorpay _razorpay;
  String liveId = '';

  Future<void> getLive() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    final savedWallet = prefs.getString('wallet') ?? '0';
    setState(() {
      wallet = savedWallet;
    });
    Map<String, dynamic> _getNews = await MySqlDBService().runQuery(
      requestType: RequestType.GET,
      url:
          '$url/getUserLive/${Application.userId}?language_id=${Application.languageId}',
    );

    bool _status = _getNews['status'];
    var _data = _getNews['data'];
    // Utility.printLog(_data.toString());
    if (_status) {
      liveList.clear();
      _data[ApiKeys.data].forEach((live) {
        liveList.add(Live.fromJson(live));
      });
      phoneNumber = Application.phoneNumber;
      userName = Application.userName;
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

  Future<void> applePayment(String live_id, String payable_price) async {
    Map<String, dynamic> _updateCart = await MySqlDBService().runQuery(
      requestType: RequestType.GET,
      url:
          '$url/complete_apple_payment_live/${Application.userId}/$live_id/$payable_price',
    );

    bool _status = _updateCart['status'];
    var _data = _updateCart['data'];
    if (_status) {
      int newWalletPrice = int.parse(wallet) - int.parse(payable_price);
      SharedPreferences prefs = await SharedPreferences.getInstance();
      prefs.setString('wallet', newWalletPrice.toString());
      Utility.showProgress(false);
      Utility.showSnacbar(context,
          "Your payment is successful, your remaining wallet amount is $newWalletPrice");
      getLive();
    } else {
      Utility.printLog('Something went wrong.');
    }
  }

  _filterRetriever() async {
    try {
      final result = await InternetAddress.lookup('cheftarunabirla.com');
      if (result.isNotEmpty && result[0].rawAddress.isNotEmpty) {
        Utility.printLog('connected');
        getLive();
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
    // _razorpay = Razorpay();
    // _razorpay.on(Razorpay.EVENT_PAYMENT_SUCCESS, _handlePaymentSuccess);
    // _razorpay.on(Razorpay.EVENT_PAYMENT_ERROR, _handlePaymentError);
    // _razorpay.on(Razorpay.EVENT_EXTERNAL_WALLET, _handleExternalWallet);
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
    if (!kIsWeb) {
      _filterRetriever();
    } else {
      getLive();
    }
    super.initState();
  }

  @override
  void dispose() {
    // _razorpay.clear();
    super.dispose();
  }

  void goBack() {
    print('back button clicked');
    if (Provider.of<DeepLink>(context, listen: false).deepLinkUrl.isNotEmpty) {
      context.read<DeepLink>().setDeepLinkUrl('');
      // context.read<CurrentIndex>().setIndex(0);
      // Navigator.of(context).pop();
      Navigator.pushAndRemoveUntil(
        context,
        MaterialPageRoute(
          builder: (context) => const MainContainer(),
        ),
        (Route<dynamic> route) => false,
      );
    } else {
      Navigator.of(context).pop();
    }
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
        : WillPopScope(
            onWillPop: () async {
              goBack();
              return false;
            },
            child: Scaffold(
              backgroundColor: Palette.scaffoldColor,
              appBar: AppBar(
                leading: IconButton(
                  icon: const Icon(
                    Icons.arrow_back_ios,
                    color: Palette.white,
                    size: 18.0,
                  ),
                  onPressed: () => goBack(),
                ),
                title: const Text(
                  'Live Courses',
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
                  : liveList.isEmpty
                      ? const Center(
                          child: Text(
                            'No Live Classes Present..',
                            textAlign: TextAlign.center,
                            style: TextStyle(
                              color: Palette.black,
                              fontSize: 14.0,
                              fontFamily: 'EuclidCircularA Medium',
                            ),
                          ),
                        )
                      : Padding(
                          padding: const EdgeInsets.only(top: 8.0, bottom: 8.0),
                          child: ListView.builder(
                            scrollDirection: Axis.vertical,
                            itemCount: liveList.length,
                            itemBuilder: (context, index) {
                              return Padding(
                                padding: const EdgeInsets.symmetric(
                                    vertical: 10.0, horizontal: 24.0),
                                child: Container(
                                  decoration: BoxDecoration(
                                    borderRadius: BorderRadius.circular(10.0),
                                    color: Palette.white,
                                    boxShadow: [
                                      BoxShadow(
                                        color: Palette.shadowColor
                                            .withOpacity(0.1),
                                        blurRadius: 5.0, // soften the shadow
                                        spreadRadius: 0.0, //extend the shadow
                                        offset: const Offset(
                                          0.0, // Move to right 10  horizontally
                                          0.0, // Move to bottom 10 Vertically
                                        ),
                                      ),
                                    ],
                                  ),
                                  child: Column(
                                    children: [
                                      GestureDetector(
                                        onTap: () {
                                          if ((liveList[index].course_id ?? "")
                                              .isEmpty) {
                                            Utility.showSnacbar(context,
                                                "Class not linked to course yet!!");
                                          } else {
                                            Navigator.push(
                                              context,
                                              MaterialPageRoute(
                                                builder: (context) =>
                                                    EachCourse(
                                                  id: liveList[index]
                                                          .course_id ??
                                                      "",
                                                ),
                                              ),
                                            );
                                          }
                                        },
                                        child: SizedBox(
                                          height: 200.0,
                                          child: Padding(
                                            padding: const EdgeInsets.all(5.0),
                                            child: ClipRRect(
                                              borderRadius:
                                                  BorderRadius.circular(10.0),
                                              child: CachedNetworkImage(
                                                imageUrl: Constants
                                                        .imgBackendUrl +
                                                    liveList[index].image_path,
                                                placeholder: (context, url) =>
                                                    const ImagePlaceholder(),
                                                errorWidget: (context, url,
                                                        error) =>
                                                    const ImagePlaceholder(),
                                                fit: BoxFit.cover,
                                                width: double.infinity,
                                              ),
                                            ),
                                          ),
                                        ),
                                      ),
                                      GestureDetector(
                                        onTap: () {
                                          if ((liveList[index].course_id ?? "")
                                              .isEmpty) {
                                            Utility.showSnacbar(context,
                                                "Class not linked to course yet!!");
                                          } else {
                                            Navigator.push(
                                              context,
                                              MaterialPageRoute(
                                                builder: (context) =>
                                                    EachCourse(
                                                  id: liveList[index]
                                                          .course_id ??
                                                      "",
                                                ),
                                              ),
                                            );
                                          }
                                        },
                                        child: Container(
                                          color: Palette.white,
                                          child: Column(
                                            children: [
                                              Padding(
                                                padding:
                                                    const EdgeInsets.all(5.0),
                                                child: Text(
                                                  liveList[index].title,
                                                  textAlign: TextAlign.center,
                                                  maxLines: 2,
                                                  style: const TextStyle(
                                                    color: Palette.black,
                                                    fontSize: 16.0,
                                                    fontFamily:
                                                        'EuclidCircularA Regular',
                                                  ),
                                                ),
                                              ),
                                              Padding(
                                                padding:
                                                    const EdgeInsets.all(5.0),
                                                child: Text(
                                                  DateTime.parse(liveList[index]
                                                          .live_date)
                                                      .toString()
                                                      .substring(0, 10),
                                                  textAlign: TextAlign.center,
                                                  maxLines: 1,
                                                  style: const TextStyle(
                                                    color: Palette.black,
                                                    fontSize: 16.0,
                                                    fontFamily:
                                                        'EuclidCircularA Medium',
                                                  ),
                                                ),
                                              ),
                                              Padding(
                                                padding:
                                                    const EdgeInsets.all(5.0),
                                                child: Text(
                                                  liveList[index].price ==
                                                          liveList[index]
                                                              .discount_price
                                                      ? liveList[index].price ==
                                                                  '0' &&
                                                              liveList[index]
                                                                      .discount_price ==
                                                                  '0'
                                                          ? 'Free'
                                                          : 'Rs ${liveList[index].discount_price}'
                                                      : 'Rs ${liveList[index].discount_price}',
                                                  style: const TextStyle(
                                                    color:
                                                        Palette.contrastColor,
                                                    fontSize: 20.0,
                                                    fontFamily:
                                                        'EuclidCircularA Medium',
                                                  ),
                                                ),
                                              ),
                                              Padding(
                                                padding:
                                                    const EdgeInsets.all(5.0),
                                                child: Row(
                                                  crossAxisAlignment:
                                                      CrossAxisAlignment.center,
                                                  mainAxisAlignment:
                                                      MainAxisAlignment.center,
                                                  children: [
                                                    Text(
                                                      liveList[index]
                                                                  .discount_price ==
                                                              liveList[index]
                                                                  .price
                                                          ? ''
                                                          : 'Rs ${liveList[index].price}',
                                                      style: const TextStyle(
                                                        color: Palette.grey,
                                                        fontSize: 16.0,
                                                        fontFamily:
                                                            'EuclidCircularA Regular',
                                                        decoration:
                                                            TextDecoration
                                                                .lineThrough,
                                                      ),
                                                    ),
                                                    const SizedBox(
                                                      width: 10.0,
                                                    ),
                                                    Text(
                                                      liveList[index]
                                                                  .discount_price ==
                                                              liveList[index]
                                                                  .price
                                                          ? ''
                                                          : '${(((int.parse(liveList[index].price) - int.parse(liveList[index].discount_price)) / int.parse(liveList[index].price)) * 100).toString().substring(0, 4)} %',
                                                      style: const TextStyle(
                                                        color: Palette.discount,
                                                        fontSize: 16.0,
                                                        fontFamily:
                                                            'EuclidCircularA Medium',
                                                      ),
                                                    ),
                                                  ],
                                                ),
                                              ),
                                              const SizedBox(
                                                height: 10.0,
                                              ),
                                            ],
                                          ),
                                        ),
                                      ),
                                      GestureDetector(
                                        onTap: () async {
                                          if (Application.phoneNumber.isEmpty) {
                                            Utility.showSnacbar(context,
                                                "Please login first!!");
                                            Provider.of<MainContainerViewModel>(
                                                    context,
                                                    listen: false)
                                                .setIndex(4);
                                            Navigator.pop(context);
                                          } else {
                                            if (liveList[index]
                                                    .discount_price ==
                                                '0') {
                                              if (liveList[index].url ==
                                                  'null') {
                                                Utility.showSnacbar(context,
                                                    "Class not started yet!!");
                                              } else {
                                                if (Application
                                                    .userName.isEmpty) {
                                                  Utility.showValuePopup(
                                                      context);
                                                  await Future.delayed(
                                                      const Duration(
                                                          milliseconds: 1000));
                                                  Navigator.pop(context);
                                                  Navigator.push(
                                                    context,
                                                    MaterialPageRoute(
                                                      builder: (context) =>
                                                          const UserAccount(),
                                                    ),
                                                  );
                                                } else {
                                                  Navigator.push(
                                                    context,
                                                    MaterialPageRoute(
                                                      builder: (context) =>
                                                          LivePage(
                                                        live_id:
                                                            liveList[index].id,
                                                        user_id:
                                                            Application.userId,
                                                        url:
                                                            liveList[index].url,
                                                        userName: userName,
                                                        liveUserCount:
                                                            liveList[index]
                                                                .liveUsersCount,
                                                      ),
                                                    ),
                                                  );
                                                }
                                              }
                                            } else {
                                              if (liveList[index].subscribed ==
                                                  0) {
                                                // if (Platform.isAndroid) {
                                                // Navigator.pop(context);
                                                // Navigator.push(
                                                //   context,
                                                //   MaterialPageRoute(
                                                //     builder: (context) =>
                                                //         LivePaymentPage(
                                                //             url:
                                                //                 '$url/livesubscription/${liveList[index].discount_price}/${Application.userId}/${liveList[index].id}'),
                                                //   ),
                                                // );
                                                _initiatePayment(
                                                    double.parse(liveList[index]
                                                        .discount_price),
                                                    liveList[index].id);
                                                // } else {
                                                //   if (int.parse(liveList[index]
                                                //           .discount_price) >
                                                //       int.parse(wallet)) {
                                                //     Utility.showSnacbar(context,
                                                //         "Not Enough money in wallet !! please add money");
                                                //     await Future.delayed(
                                                //         const Duration(
                                                //             milliseconds:
                                                //                 1000));
                                                //     Navigator.push(
                                                //       context,
                                                //       MaterialPageRoute(
                                                //         builder: (context) =>
                                                //             const WalletPage(),
                                                //       ),
                                                //     );
                                                //   } else {
                                                //     Utility.showProgress(true);
                                                //     applePayment(
                                                //         liveList[index].id,
                                                //         liveList[index]
                                                //             .discount_price);
                                                //   }
                                                // }
                                              } else {
                                                if (liveList[index].url ==
                                                    'null') {
                                                  Utility.showSnacbar(context,
                                                      "Class not started yet");
                                                } else {
                                                  if (Application
                                                      .userName.isEmpty) {
                                                    Utility.showValuePopup(
                                                        context);
                                                    await Future.delayed(
                                                        const Duration(
                                                            milliseconds:
                                                                1000));
                                                    Navigator.pop(context);
                                                    Navigator.push(
                                                      context,
                                                      MaterialPageRoute(
                                                        builder: (context) =>
                                                            const UserAccount(),
                                                      ),
                                                    );
                                                  } else {
                                                    Navigator.push(
                                                      context,
                                                      MaterialPageRoute(
                                                        builder: (context) =>
                                                            LivePage(
                                                          live_id:
                                                              liveList[index]
                                                                  .id,
                                                          user_id: Application
                                                              .userId,
                                                          url: liveList[index]
                                                              .url,
                                                          userName: Application
                                                              .userName,
                                                          liveUserCount:
                                                              liveList[index]
                                                                  .liveUsersCount,
                                                        ),
                                                      ),
                                                    );
                                                  }
                                                }
                                              }
                                            }
                                          }
                                        },
                                        child: Container(
                                          width: double.infinity,
                                          decoration: const BoxDecoration(
                                            color: Palette.secondaryColor,
                                            borderRadius: BorderRadius.only(
                                              bottomRight:
                                                  Radius.circular(10.0),
                                              bottomLeft: Radius.circular(10.0),
                                            ),
                                          ),
                                          child: Center(
                                            child: Padding(
                                              padding:
                                                  const EdgeInsets.all(8.0),
                                              child: Text(
                                                liveList[index]
                                                            .discount_price ==
                                                        '0'
                                                    ? liveList[index].url ==
                                                            'null'
                                                        ? 'Not started yet'
                                                        : 'Join'
                                                    : liveList[index]
                                                                .subscribed ==
                                                            0
                                                        ? 'Pay Now'
                                                        : liveList[index].url ==
                                                                'null'
                                                            ? 'Not started yet'
                                                            : 'Join',
                                                style: const TextStyle(
                                                  color: Palette.white,
                                                  fontSize: 16.0,
                                                  fontFamily:
                                                      'EuclidCircularA Medium',
                                                ),
                                              ),
                                            ),
                                          ),
                                        ),
                                      )
                                    ],
                                  ),
                                ),
                              );
                            },
                          ),
                        ),
            ),
          );
  }

  Future _initiatePayment(double value, String id) async {
    Utility.showProgress(true);
    setState(() {
      liveId = id;
    });
    Map<String, String> params = {
      "total": value.toString(),
    };
    String url = '${Constants.finalUrl}/subscription_api/paymentInitiate';
    Map<String, dynamic> initiatePayment =
        await ApiFunctions.postApiResult(url, Application.deviceToken, params);
    bool status = initiatePayment['status'];
    var data = initiatePayment['data'];
    if (status) {
      Utility.showProgress(false);
      try {
        // _razorpay.open(data!);
      } catch (e) {
        Utility.printLog("Payment Payment error $e");
      }
    } else {
      Utility.printLog('Something went wrong while saving token.');
      Utility.printLog('Some error occurred');
      Utility.showProgress(false);
      Utility.showSnacbar(context, 'Some error occurred!!');
    }
  }

  // void _handlePaymentSuccess(PaymentSuccessResponse response) async {
  //   Utility.printLog("Payment Checkout Success ${response.paymentId}");
  //   // _razorpay.clear();
  //   Utility.showProgress(true);
  //   Map<String, String> params = {};
  //   String url =
  //       '${Constants.finalUrl}/complete_payment_live_mobile/${Application.userId}/$liveId';
  //   Map<String, dynamic> paymentSuccess =
  //       await ApiFunctions.postApiResult(url, Application.deviceToken, params);
  //   bool status = paymentSuccess['status'];
  //   var data = paymentSuccess['data'];
  //   if (status) {
  //     // print(data);
  //     if (data[ApiKeys.message].toString() == 'payment_success') {
  //       Utility.showProgress(false);
  //       Provider.of<MainContainerViewModel>(context, listen: false)
  //           .setNotificationCount();
  //       Navigator.pushReplacement(
  //         context,
  //         MaterialPageRoute(
  //           builder: (context) => const LiveClasses(),
  //         ),
  //       );
  //       Utility.showSnacbar(
  //         context,
  //         'Your purchase of live class is successful!!, please click here to check',
  //         onClicked: () {
  //           Navigator.push(
  //             context,
  //             MaterialPageRoute(builder: (context) => const NotificationPage()),
  //           );
  //         },
  //         duration: 2,
  //       );
  //     } else if (data[ApiKeys.message].toString() == 'payment_failed' ||
  //         data[ApiKeys.message].toString() == 'Database_connection_error') {
  //       Utility.showProgress(false);
  //       Utility.showSnacbar(context, 'Payment Failed!!');
  //     }
  //   } else {
  //     Utility.printLog('Something went wrong while saving token.');
  //     Utility.printLog('Some error occurred');
  //     Utility.showProgress(false);
  //     Utility.showSnacbar(context, 'Some error occurred!!');
  //   }
  // }

  // void _handlePaymentError(PaymentFailureResponse response) {
  //   Utility.printLog(
  //       "Payment Checkout Failure ${response.code} ${response.message}");
  //   // _razorpay.clear();
  //   Utility.showSnacbar(context, 'Payment Failed!!');
  // }

  // void _handleExternalWallet(ExternalWalletResponse response) async {
  //   Utility.printLog("Payment Checkout Wallet ${response.walletName}");
  //   // _razorpay.clear();
  //   Utility.showProgress(true);
  //   Map<String, String> params = {};
  //   String url =
  //       '${Constants.finalUrl}/complete_payment_live_mobile/${Application.userId}/$liveId';
  //   Map<String, dynamic> paymentSuccess =
  //       await ApiFunctions.postApiResult(url, Application.deviceToken, params);
  //   bool status = paymentSuccess['status'];
  //   var data = paymentSuccess['data'];
  //   if (status) {
  //     if (data[ApiKeys.message].toString() == 'payment_success') {
  //       Utility.showProgress(false);
  //       Provider.of<MainContainerViewModel>(context, listen: false)
  //           .setNotificationCount();
  //       Navigator.pushReplacement(
  //         context,
  //         MaterialPageRoute(
  //           builder: (context) => const LiveClasses(),
  //         ),
  //       );
  //       Utility.showSnacbar(
  //         context,
  //         'Your purchase of live class is successful!!, please click here to check',
  //         onClicked: () {
  //           Navigator.push(
  //             context,
  //             MaterialPageRoute(builder: (context) => const NotificationPage()),
  //           );
  //         },
  //         duration: 2,
  //       );
  //     } else if (data[ApiKeys.message].toString() == 'payment_failed' ||
  //         data[ApiKeys.message].toString() == 'Database_connection_error') {
  //       Utility.showProgress(false);
  //       Utility.showSnacbar(context, 'Payment Failed!!');
  //     }
  //   } else {
  //     Utility.printLog('Something went wrong while saving token.');
  //     Utility.printLog('Some error occurred');
  //     Utility.showProgress(false);
  //     Utility.showSnacbar(context, 'Some error occurred!!');
  //   }
  // }
}
