import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
// import 'package:wakelock/wakelock.dart';
import 'package:youtube_player_flutter/youtube_player_flutter.dart';

import '../config/config.dart';

class YoutubePlayerPage extends StatefulWidget {
  final String url;
  final bool fullScreen;
  const YoutubePlayerPage(
      {Key? key, required this.url, required this.fullScreen})
      : super(key: key);

  @override
  _YoutubePlayerPageState createState() => _YoutubePlayerPageState();
}

class _YoutubePlayerPageState extends State<YoutubePlayerPage> {
  late YoutubePlayerController _controller;
  late TextEditingController _idController;
  late TextEditingController _seekToController;

  late bool isFullscreen;

  late PlayerState _playerState;
  late YoutubeMetaData _videoMetaData;
  double _volume = 100;
  bool _muted = false;
  bool _isPlayerReady = false;

  @override
  void initState() {
    super.initState();
    _controller = YoutubePlayerController(
      initialVideoId: widget.url.contains('youtube')
          ? YoutubePlayer.convertUrlToId(widget.url) ?? ''
          : widget.url,
      flags: const YoutubePlayerFlags(
        mute: false,
        autoPlay: true,
        disableDragSeek: false,
        loop: false,
        isLive: false,
        forceHD: false,
        enableCaption: true,
      ),
    )..addListener(listener);
    _idController = TextEditingController();
    _seekToController = TextEditingController();
    _videoMetaData = const YoutubeMetaData();
    _playerState = PlayerState.unknown;

    isFullscreen = widget.fullScreen;
    if (isFullscreen) {
      setLandscape();
    } else {
      setAllOrientation();
    }
  }

  Future setLandscape() async {
    // // await SystemChrome.setEnabledSystemUIOverlays([]);
    // await SystemChrome.setPreferredOrientations(
    //     [DeviceOrientation.landscapeLeft, DeviceOrientation.landscapeRight]);
    // await Wakelock.enable();
  }

  Future setAllOrientation() async {
    // await SystemChrome.setEnabledSystemUIMode(SystemUiMode.manual,
    //     overlays: SystemUiOverlay.values);
    // await SystemChrome.setPreferredOrientations(DeviceOrientation.values);
    // await Wakelock.disable();
  }

  void listener() {
    if (_isPlayerReady && mounted && !_controller.value.isFullScreen) {
      setState(() {
        _playerState = _controller.value.playerState;
        _videoMetaData = _controller.metadata;
      });
    }
  }

  @override
  void deactivate() {
    // Pauses video while navigating to next page.
    _controller.pause();
    super.deactivate();
  }

  @override
  void dispose() {
    _controller.dispose();
    _idController.dispose();
    _seekToController.dispose();
    setAllOrientation();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Center(
        child: ClipRRect(
          borderRadius: BorderRadius.circular(10.0),
          child: YoutubePlayer(
            aspectRatio: isFullscreen ? 9 / 16 : 16 / 9,
            controller: YoutubePlayerController(
              initialVideoId: widget.url,
              flags: const YoutubePlayerFlags(
                autoPlay: true,
              ),
            ),
            showVideoProgressIndicator: true,
            progressIndicatorColor: Palette.secondaryColor,
            progressColors: const ProgressBarColors(
              playedColor: Palette.secondaryColor,
              handleColor: Palette.primaryColor,
            ),
          ),
        ),
      ),
    );
  }
}
