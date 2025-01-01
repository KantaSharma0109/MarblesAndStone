import 'dart:io';

import 'package:chef_taruna_birla/pages/common/video_player.dart';
import 'package:flutter/material.dart';
// import 'package:ios_insecure_screen_detector/ios_insecure_screen_detector.dart';

import '../../config/config.dart';
import '../../utils/utility.dart';
import '../../widgets/youtube_player_page.dart';

class VideoPage extends StatefulWidget {
  final String url;
  const VideoPage({Key? key, required this.url}) : super(key: key);

  @override
  _VideoPageState createState() => _VideoPageState();
}

class _VideoPageState extends State<VideoPage> {
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
        : WillPopScope(
            onWillPop: () async {
              Navigator.of(context).pop();
              return false;
            },
            child: Scaffold(
              backgroundColor: Colors.black,
              // appBar: AppBar(
              //   leading: IconButton(
              //     icon: const Icon(
              //       Icons.arrow_back_ios,
              //       color: Colors.white,
              //       size: 18.0,
              //     ),
              //     onPressed: () => Navigator.of(context).pop(),
              //   ),
              //   title: const Text(
              //     '',
              //     style: TextStyle(
              //       color: Colors.black,
              //       fontSize: 18.0,
              //       fontFamily: 'EuclidCircularA Medium',
              //     ),
              //   ),
              //   backgroundColor: Colors.black,
              //   elevation: 0.0,
              //   shadowColor: const Color(0xffFFF0D0).withOpacity(0.2),
              //   centerTitle: true,
              // ),
              body: Center(
                child: widget.url.contains('youtube')
                    ? YoutubePlayerPage(
                        url: widget.url.split('v=')[1],
                        fullScreen: true,
                      )
                    : VideoPlayerPage(
                        url: widget.url,
                        fullScreen: true,
                        page: 'full_video',
                      ),
              ),
            ),
          );
  }
}
