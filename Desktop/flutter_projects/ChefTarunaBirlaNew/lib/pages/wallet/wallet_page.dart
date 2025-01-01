import 'dart:io';

import 'package:chef_taruna_birla/pages/wallet/apple_cart_payment_page.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
// import 'package:ios_insecure_screen_detector/ios_insecure_screen_detector.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../config/config.dart';
import '../../services/mysql_db_service.dart';
import '../../utils/utility.dart';

class WalletPage extends StatefulWidget {
  const WalletPage({Key? key}) : super(key: key);

  @override
  _WalletPageState createState() => _WalletPageState();
}

class _WalletPageState extends State<WalletPage> {
  bool isLoading = false;
  String phoneNumber = '';
  String wallet = '';
  final moneyController = TextEditingController();
  String url = Constants.finalUrl;
  // final IosInsecureScreenDetector _insecureScreenDetector =
  //     IosInsecureScreenDetector();
  bool _isCaptured = false;

  Future<void> getUserDetails() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();

    Map<String, dynamic> _getNews = await MySqlDBService().runQuery(
      requestType: RequestType.GET,
      url: '$url/users/getUserDetails/${Application.phoneNumber}',
    );

    bool _status = _getNews['status'];
    var _data = _getNews['data'];
    // Utility.printLog(_data);
    if (_status) {
      if (_data['data'].length != 0) {
        wallet = _data['data'][0]['wallet'].toString();
        prefs.setString('wallet', _data['data'][0]['wallet'].toString());
      }
      Utility.showProgress(false);
      setState(() => isLoading = true);
    } else {
      Utility.printLog('Something went wrong.');
      Utility.showProgress(false);
      Utility.databaseErrorPopup(context);
    }
  }

  @override
  void initState() {
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
    getUserDetails();
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
                'Wallet',
                style: TextStyle(
                  color: Palette.white,
                  fontSize: 18.0,
                  fontFamily: 'EuclidCircularA Medium',
                ),
              ),
              backgroundColor: Palette.appBarColor,
              elevation: 10.0,
              shadowColor: Palette.shadowColor.withOpacity(1.0),
              centerTitle: false,
            ),
            body: !isLoading
                ? Container()
                : Padding(
                    padding: const EdgeInsets.symmetric(
                        vertical: 0.0, horizontal: 24.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisAlignment: MainAxisAlignment.start,
                      children: [
                        const SizedBox(
                          height: 30.0,
                        ),
                        Container(
                          width: double.infinity,
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(10.0),
                            color: Colors.white,
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
                          child: Padding(
                            padding: const EdgeInsets.symmetric(
                                vertical: 20.0, horizontal: 12.0),
                            child: Text(
                              'Rs. $wallet',
                              style: const TextStyle(
                                  color: Colors.black,
                                  fontSize: 20.0,
                                  fontFamily: 'EuclidCircularA Medium'),
                            ),
                          ),
                        ),
                        const SizedBox(
                          height: 20.0,
                        ),
                        GestureDetector(
                          onTap: () {
                            Navigator.pop(context);
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) =>
                                    const AppleCartPaymentPage(),
                              ),
                            );
                          },
                          child: Container(
                            height: 48.0,
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(10),
                              color: Palette.contrastColor,
                              boxShadow: [
                                BoxShadow(
                                  color:
                                      const Color(0xffFFF0D0).withOpacity(0.0),
                                  blurRadius: 30.0, // soften the shadow
                                  spreadRadius: 0.0, //extend the shadow
                                  offset: const Offset(
                                    0.0, // Move to right 10  horizontally
                                    0.0, // Move to bottom 10 Vertically
                                  ),
                                ),
                              ],
                            ),
                            child: const Center(
                              child: Text(
                                'Add Money',
                                style: TextStyle(
                                  color: Colors.white,
                                  fontSize: 16.0,
                                  fontFamily: 'EuclidCircularA Medium',
                                ),
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
          );
  }
}
