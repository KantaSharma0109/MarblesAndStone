import 'dart:io';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:chef_taruna_birla/pages/common/video_web_player.dart';
import 'package:chef_taruna_birla/widgets/image_placeholder.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
// import 'package:ios_insecure_screen_detector/ios_insecure_screen_detector.dart';
import 'package:lazy_load_scrollview/lazy_load_scrollview.dart';

import '../../config/config.dart';
import '../../services/mysql_db_service.dart';
import '../../utils/utility.dart';
import '../image/open_image.dart';

class GalleryPage extends StatefulWidget {
  final bool isItemGallery;
  final String itemId;
  final String itemCategory;
  const GalleryPage({
    Key? key,
    required this.isItemGallery,
    required this.itemId,
    required this.itemCategory,
  }) : super(key: key);

  @override
  _GalleryPageState createState() => _GalleryPageState();
}

class _GalleryPageState extends State<GalleryPage> {
  List<Widget> list = [];
  bool isLoading = false;
  int offset = 0;
  bool isLoadingVertical = false;
  String url = Constants.isDevelopment
      ? Constants.devBackendUrl
      : Constants.prodBackendUrl;
  // final IosInsecureScreenDetector _insecureScreenDetector =
  //     IosInsecureScreenDetector();
  bool _isCaptured = false;

  Future<void> getGalleryImages() async {
    Map<String, dynamic> _getNews = await MySqlDBService().runQuery(
      requestType: RequestType.GET,
      url: widget.isItemGallery
          ? widget.itemCategory == 'course'
              ? '$url/getCourseImages/${widget.itemId}/$offset?category=gallery'
              : widget.itemCategory == 'product'
                  ? '$url/getProductImages/${widget.itemId}/$offset'
                  : '$url/getImages/${widget.itemId}/$offset?category=gallery'
          : '$url/getGalleryImages/$offset',
    );

    bool _status = _getNews['status'];
    var _data = _getNews['data'];
    // Utility.printLog(_data);
    if (_status) {
      list.clear();
      for (var i = 0; i < _data['data'].length; i++) {
        list.add(
          GestureDetector(
            onTap: () {
              _data['data'][i]['iv_category'] == 'video'
                  ? Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => VideoWebPage(
                          url: 'https://www.youtube.com/watch?v=' +
                              _data['data'][i]['path'].toString(),
                          isFullscreen: int.parse(_data['data'][i]
                                          ['is_full_screen']
                                      .toString()) ==
                                  0
                              ? false
                              : true,
                        ),
                      ),
                    )
                  : Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => OpenImage(
                          url: Constants.finalUrl +
                              _data['data'][i]['path'].toString(),
                        ),
                      ),
                    );
            },
            child: ClipRRect(
              borderRadius: BorderRadius.circular(8.0),
              child: Stack(
                alignment: Alignment.center,
                children: [
                  CachedNetworkImage(
                    imageUrl: _data['data'][i]['iv_category'] == 'video'
                        ? Constants.finalUrl +
                            _data['data'][i]['thumbnail'].toString()
                        : Constants.finalUrl +
                            _data['data'][i]['path'].toString(),
                    placeholder: (context, url) => const ImagePlaceholder(),
                    errorWidget: (context, url, error) =>
                        const ImagePlaceholder(),
                    fit: BoxFit.cover,
                    width: double.infinity,
                    height: double.infinity,
                    alignment: Alignment.topCenter,
                  ),
                  _data['data'][i]['iv_category'] == 'video'
                      ? Container(
                          height: 50.0,
                          width: 50.0,
                          decoration: BoxDecoration(
                            color: Palette.secondaryColor,
                            borderRadius: BorderRadius.circular(50.0),
                            boxShadow: [
                              BoxShadow(
                                color: const Color(0xff000000).withOpacity(0.2),
                                blurRadius: 10.0, // soften the shadow
                                spreadRadius: 0.0, //extend the shadow
                                offset: const Offset(
                                  0.0, // Move to right 10  horizontally
                                  0.0, // Move to bottom 10 Vertically
                                ),
                              ),
                            ],
                          ),
                          child: const Center(
                            child: Icon(
                              Icons.play_arrow_rounded,
                              color: Colors.white,
                              size: 40.0,
                            ),
                          ),
                        )
                      : Container(),
                ],
              ),
            ),
          ),
        );
      }
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

  Future<void> getMoreGalleryImages() async {
    Map<String, dynamic> _getNews = await MySqlDBService().runQuery(
      requestType: RequestType.GET,
      url: widget.isItemGallery
          ? widget.itemCategory == 'course'
              ? '$url/getCourseImages/${widget.itemId}/$offset'
              : '$url/getProductImages/${widget.itemId}/$offset'
          : '$url/getGalleryImages/$offset',
    );

    bool _status = _getNews['status'];
    var _data = _getNews['data'];
    // Utility.printLog(_data);
    if (_status) {
      for (var i = 0; i < _data['data'].length; i++) {
        list.add(
          GestureDetector(
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => OpenImage(
                    url: Constants.imgBackendUrl +
                        _data['data'][i]['path'].toString(),
                  ),
                ),
              );
            },
            child: ClipRRect(
              borderRadius: BorderRadius.circular(8.0),
              child: CachedNetworkImage(
                imageUrl: Constants.imgBackendUrl +
                    _data['data'][i]['path'].toString(),
                placeholder: (context, url) => const ImagePlaceholder(),
                errorWidget: (context, url, error) => const ImagePlaceholder(),
                fit: BoxFit.cover,
                width: double.infinity,
                height: double.infinity,
                alignment: Alignment.topCenter,
              ),
            ),
          ),
        );
      }
      setState(() {
        isLoading = true;
      });
    } else {
      Utility.printLog('Something went wrong.');
      Utility.databaseErrorPopup(context);
    }
  }

  _filterRetriever() async {
    try {
      final result = await InternetAddress.lookup('cheftarunabirla.com');
      if (result.isNotEmpty && result[0].rawAddress.isNotEmpty) {
        Utility.printLog('connected');
        getGalleryImages();
      }
    } on SocketException catch (_) {
      Utility.printLog('not connected');
      Utility.showProgress(false);
      Utility.noInternetPopup(context);
      setState(() {
        isLoading = true;
      });
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
    Utility.showProgress(true);
    if (!kIsWeb) {
      _filterRetriever();
    } else {
      getGalleryImages();
    }
    super.initState();
  }

  @override
  void dispose() {
    super.dispose();
  }

  Future _loadMoreVertical() async {
    setState(() {
      isLoadingVertical = true;
    });
    Utility.printLog('ended');
    getMoreGalleryImages();
    // Add in an artificial delay
    await new Future.delayed(const Duration(seconds: 1));
    // Utility.printLog('ended after delay');

    setState(() {
      isLoadingVertical = false;
    });
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
                'Gallery',
                style: TextStyle(
                  color: Palette.white,
                  fontSize: 18.0,
                  fontFamily: 'EuclidCircularA Medium',
                ),
              ),
              backgroundColor: Palette.appBarColor,
              elevation: 10.0,
              shadowColor: const Color(0xffFFF0D0).withOpacity(0.2),
              centerTitle: false,
            ),
            body: !isLoading
                ? Container()
                : list.isEmpty
                    ? const Center(
                        child: Text(
                          'No Images Present',
                          style: TextStyle(
                            color: Palette.black,
                            fontSize: 18.0,
                            fontFamily: 'EuclidCircularA Medium',
                          ),
                        ),
                      )
                    : SizedBox(
                        height: double.infinity,
                        child: Column(
                          children: [
                            Expanded(
                              child: LazyLoadScrollView(
                                isLoading: isLoadingVertical,
                                onEndOfPage: () {
                                  setState(() {
                                    offset = offset + 20;
                                  });
                                  _loadMoreVertical();
                                },
                                child: Scrollbar(
                                  child: GridView.count(
                                    crossAxisCount: 2,
                                    mainAxisSpacing: 12,
                                    crossAxisSpacing: 12,
                                    padding: const EdgeInsets.symmetric(
                                        vertical: 15.0, horizontal: 24.0),
                                    childAspectRatio: 0.8,
                                    children: list,
                                  ),
                                ),
                              ),
                            ),
                            Container(
                              child: !isLoadingVertical
                                  ? const Center()
                                  : const Padding(
                                      padding: EdgeInsets.all(8.0),
                                      child: Center(
                                        child: Text('Loading...'),
                                      ),
                                    ),
                            ),
                          ],
                        ),
                      ),
          );
  }
}
