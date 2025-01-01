import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
// import 'package:ios_insecure_screen_detector/ios_insecure_screen_detector.dart';

import '../../config/config.dart';
import '../../utils/utility.dart';
import '../../widgets/webviewx_page.dart';

class CartPaymentPage extends StatefulWidget {
  final String url;
  const CartPaymentPage({Key? key, required this.url}) : super(key: key);

  @override
  State<CartPaymentPage> createState() => _CartPaymentPageState();
}

class _CartPaymentPageState extends State<CartPaymentPage> {
  // final IosInsecureScreenDetector _insecureScreenDetector =
  //     IosInsecureScreenDetector();
  bool _isCaptured = false;

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
    super.initState();
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
                  color: Colors.white,
                  size: 18.0,
                ),
                onPressed: () => Navigator.of(context).pop(),
              ),
              title: const Text(
                'Cart Payment',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 18.0,
                  fontFamily: 'EuclidCircularA Medium',
                ),
              ),
              backgroundColor: Palette.appBarColor,
              elevation: 10.0,
              shadowColor: Palette.shadowColor.withOpacity(0.1),
              centerTitle: false,
            ),
            body: WebviewXPage(
              url: widget.url,
              fullScreen: false,
            ),
          );
  }
}
