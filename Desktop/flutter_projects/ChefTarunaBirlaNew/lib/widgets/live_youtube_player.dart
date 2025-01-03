import 'package:flutter/material.dart';
import 'package:youtube_player_flutter/youtube_player_flutter.dart';

import '../config/config.dart';

class LiveYoutubePlayer extends StatefulWidget {
  final String url;
  const LiveYoutubePlayer({
    Key? key,
    required this.url,
  }) : super(key: key);

  @override
  State<LiveYoutubePlayer> createState() => _LiveYoutubePlayerState();
}

class _LiveYoutubePlayerState extends State<LiveYoutubePlayer> {
  late YoutubePlayerController _controller;
  late TextEditingController _idController;
  late TextEditingController _seekToController;

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
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return YoutubePlayer(
      aspectRatio: 9 / 16,
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
    );
  }
}
