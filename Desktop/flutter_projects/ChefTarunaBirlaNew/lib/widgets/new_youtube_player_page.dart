import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
// import 'package:wakelock/wakelock.dart';
import 'package:wakelock_plus/wakelock_plus.dart';
import 'package:youtube_player_flutter/youtube_player_flutter.dart';

class NewYoutubePlayerPage extends StatefulWidget {
  final String url;
  final bool fullScreen;
  const NewYoutubePlayerPage({
    Key? key,
    required this.url,
    required this.fullScreen,
  }) : super(key: key);

  @override
  State<NewYoutubePlayerPage> createState() => _NewYoutubePlayerPageState();
}

class _NewYoutubePlayerPageState extends State<NewYoutubePlayerPage> {
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
    print(widget.url);
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
    _playerState = PlayerState.playing;

    isFullscreen = widget.fullScreen;
    if (isFullscreen) {
      setLandscape();
    } else {
      setAllOrientation();
    }
  }

  Future setLandscape() async {
    // await SystemChrome.setEnabledSystemUIOverlays([]);
    await SystemChrome.setPreferredOrientations(
        [DeviceOrientation.landscapeLeft, DeviceOrientation.landscapeRight]);
    await WakelockPlus.enabled;
  }

  Future setAllOrientation() async {
    await SystemChrome.setEnabledSystemUIMode(SystemUiMode.manual,
        overlays: SystemUiOverlay.values);
    await SystemChrome.setPreferredOrientations(DeviceOrientation.values);
    await WakelockPlus.enabled;
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
    return YoutubePlayerBuilder(
        onExitFullScreen: () {
          // The player forces portraitUp after exiting fullscreen. This overrides the behaviour.
          // SystemChrome.setPreferredOrientations(DeviceOrientation.values);
        },
        player: YoutubePlayer(
          controller: _controller,
          aspectRatio: isFullscreen ? 16 / 9 : 9 / 16,
          showVideoProgressIndicator: true,
          progressIndicatorColor: Colors.blueAccent,
          topActions: <Widget>[
            const SizedBox(width: 8.0),
            Expanded(
              child: Text(
                _controller.metadata.title,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 18.0,
                ),
                overflow: TextOverflow.ellipsis,
                maxLines: 1,
              ),
            ),
            // IconButton(
            //   icon: const Icon(
            //     Icons.settings,
            //     color: Colors.white,
            //     size: 25.0,
            //   ),
            //   onPressed: () {
            //     log('Settings Tapped!');
            //   },
            // ),
          ],
          onReady: () {
            _isPlayerReady = true;
          },
          onEnded: (data) {
            // _controller
            //     .load(_ids[(_ids.indexOf(data.videoId) + 1) % _ids.length]);
            // _showSnackBar('Next Video Started!');
          },
        ),
        builder: (context, player) {
          return Center(
            child: Container(
              child: player,
            ),
          );
        });
  }
}
