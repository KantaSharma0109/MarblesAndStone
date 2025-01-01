import 'dart:io';

import 'package:chef_taruna_birla/pages/common/video_player.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
// import 'package:ios_insecure_screen_detector/ios_insecure_screen_detector.dart';
// import 'package:wakelock/wakelock.dart';
import 'package:wakelock_plus/wakelock_plus.dart';

import '../../config/config.dart';
import '../../utils/utility.dart';
import '../../widgets/new_youtube_player_page.dart';
import '../../widgets/webviewx_page.dart';

class VideoWebPage extends StatefulWidget {
  final String url;
  final bool isFullscreen;
  const VideoWebPage({Key? key, required this.url, this.isFullscreen = false})
      : super(key: key);

  @override
  State<VideoWebPage> createState() => _VideoWebPageState();
}

class _VideoWebPageState extends State<VideoWebPage> {
  // final IosInsecureScreenDetector _insecureScreenDetector =
  //     IosInsecureScreenDetector();
  bool _isCaptured = false;
  @override
  void initState() {
    super.initState();
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
    if (widget.isFullscreen) {
      setLandscape();
    } else {
      setAllOrientation();
    }
  }

  Future setLandscape() async {
    await SystemChrome.setPreferredOrientations(
        [DeviceOrientation.landscapeLeft, DeviceOrientation.landscapeRight]);
    // await Wakelock.enable();
    await WakelockPlus.enabled;
  }

  @override
  void dispose() {
    setAllOrientation();
    super.dispose();
  }

  Future setAllOrientation() async {
    await SystemChrome.setEnabledSystemUIMode(SystemUiMode.manual,
        overlays: SystemUiOverlay.values);
    // await SystemChrome.setPreferredOrientations(DeviceOrientation.values);
    await SystemChrome.setPreferredOrientations([
      DeviceOrientation.portraitUp,
      DeviceOrientation.portraitDown,
    ]);
    // await Wakelock.disable();
    await WakelockPlus.enabled;
  }

  String getYoutubeVideoId(String url) {
    RegExp regExp = RegExp(
      r'.*(?:(?:youtu\.be\/|v\/|vi\/|u\/\w\/|embed\/)|(?:(?:watch)?\?v(?:i)?=|\&v(?:i)?=))([^#\&\?]*).*',
      caseSensitive: false,
      multiLine: false,
    );
    final match = regExp.firstMatch(url)?.group(1); // <- This is the fix
    String? str = match;
    return str ?? "";
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
        : widget.url.contains('youtube')
            ? Scaffold(
                backgroundColor: Colors.black,
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
                    '',
                  ),
                  backgroundColor: Palette.black,
                  elevation: 0.0,
                  centerTitle: true,
                ),
                body: Stack(
                  children: [
                    widget.url.contains('youtube')
                        ? widget.url.contains('shorts')
                            ? NewYoutubePlayerPage(
                                url: widget.url
                                    .substring(widget.url.length - 11),
                                fullScreen: widget.isFullscreen,
                              )
                            : NewYoutubePlayerPage(
                                url: widget.url,
                                fullScreen: widget.isFullscreen,
                              )
                        : widget.url.contains('vimeo')
                            ? WebviewXPage(
                                url: widget.url,
                                fullScreen: widget.isFullscreen,
                              )
                            : VideoPlayerPage(
                                url: widget.url,
                                fullScreen: widget.isFullscreen,
                                page: 'full_video',
                              ),
                  ],
                ),
              )
            : Scaffold(
                backgroundColor: Colors.black,
                body: Stack(
                  children: [
                    widget.url.contains('youtube')
                        ? widget.url.contains('shorts')
                            ? NewYoutubePlayerPage(
                                url: widget.url
                                    .substring(widget.url.length - 11),
                                fullScreen: widget.isFullscreen,
                              )
                            : NewYoutubePlayerPage(
                                url: widget.url,
                                fullScreen: widget.isFullscreen,
                              )
                        : widget.url.contains('vimeo')
                            ? WebviewXPage(
                                url: widget.url,
                                fullScreen: widget.isFullscreen,
                              )
                            : VideoPlayerPage(
                                url: widget.url,
                                fullScreen: widget.isFullscreen,
                                page: 'full_video',
                              ),
                  ],
                ),
              );
  }
}
