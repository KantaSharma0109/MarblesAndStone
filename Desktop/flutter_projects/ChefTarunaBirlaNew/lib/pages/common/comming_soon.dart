import 'dart:io';

import 'package:flutter/material.dart';
// import 'package:ios_insecure_screen_detector/ios_insecure_screen_detector.dart';

import '../../config/config.dart';
import '../../utils/utility.dart';

class CommingSoonPage extends StatefulWidget {
  final String title;
  const CommingSoonPage({Key? key, required this.title}) : super(key: key);

  @override
  State<CommingSoonPage> createState() => _CommingSoonPageState();
}

class _CommingSoonPageState extends State<CommingSoonPage> {
  // final IosInsecureScreenDetector _insecureScreenDetector =
  // IosInsecureScreenDetector();
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
                  color: Palette.white,
                  size: 18.0,
                ),
                onPressed: () => Navigator.of(context).pop(),
              ),
              title: Text(
                widget.title,
                style: const TextStyle(
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
            body: Center(
              child: Image.asset(
                'assets/images/coming-soon.png',
                width: 200.0,
              ),
            ),
          );
  }
}
