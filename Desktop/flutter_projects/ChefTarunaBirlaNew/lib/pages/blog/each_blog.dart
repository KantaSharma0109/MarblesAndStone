import 'dart:async';
import 'dart:io';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:carousel_slider/carousel_options.dart';
import 'package:carousel_slider/carousel_slider.dart';
import 'package:chef_taruna_birla/widgets/text_to_html.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
// import 'package:ios_insecure_screen_detector/ios_insecure_screen_detector.dart';
import 'package:material_design_icons_flutter/material_design_icons_flutter.dart';
import 'package:path_provider/path_provider.dart';
import 'package:provider/provider.dart';
import 'package:share_plus/share_plus.dart';

import '../../config/config.dart';
import '../../services/mysql_db_service.dart';
import '../../utils/utility.dart';
import '../../viewmodels/deepLink.dart';
import '../../widgets/image_placeholder.dart';
import '../image/open_image.dart';
import '../main_container.dart';

class EachBlog extends StatefulWidget {
  final String title;
  final String description;
  final String id;
  final String time;
  final String share_url;
  const EachBlog({
    Key? key,
    required this.title,
    required this.description,
    required this.id,
    required this.time,
    required this.share_url,
  }) : super(key: key);

  @override
  _EachBlogState createState() => _EachBlogState();
}

class _EachBlogState extends State<EachBlog> {
  List<Widget> list = [];
  bool isLoading = false;
  String remotePDFpath = "";
  String imagePath = "";
  String url = Constants.isDevelopment
      ? Constants.devBackendUrl
      : Constants.prodBackendUrl;
  // final IosInsecureScreenDetector _insecureScreenDetector =
  //     IosInsecureScreenDetector();
  bool _isCaptured = false;

  Future<File> createFileOfPdfUrl() async {
    Completer<File> completer = Completer();
    print("Start download file from internet!");
    try {
      // "https://berlin2017.droidcon.cod.newthinking.net/sites/global.droidcon.cod.newthinking.net/files/media/documents/Flutter%20-%2060FPS%20UI%20of%20the%20future%20%20-%20DroidconDE%2017.pdf";
      // final url = "https://pdfkit.org/docs/guide.pdf";
      final url = imagePath;
      final filename = url.substring(url.lastIndexOf("/") + 1);
      var request = await HttpClient().getUrl(Uri.parse(url));
      var response = await request.close();
      var bytes = await consolidateHttpClientResponseBytes(response);
      var dir = await getApplicationDocumentsDirectory();
      print("Download files");
      print("${dir.path}/$filename");
      File file = File("${dir.path}/$filename");

      await file.writeAsBytes(bytes, flush: true);
      completer.complete(file);
    } catch (e) {
      throw Exception('Error parsing asset file!');
    }

    return completer.future;
  }

  // void _onShare(BuildContext context) async {
  //   final box = context.findRenderObject() as RenderBox?;
  //   await Share.shareFiles(
  //     [remotePDFpath],
  //     text:
  //         '${widget.title} to explore more blogs click on the link given below\n\n👇\n\n${widget.share_url != 'null' ? widget.share_url : 'https://play.google.com/store/apps/details?id=com.cheftarunbirla'}',
  //     sharePositionOrigin: box!.localToGlobal(Offset.zero) & box.size,
  //   );
  // }

  Future<void> getBlogImages() async {
    Map<String, dynamic> _getNews = await MySqlDBService().runQuery(
      requestType: RequestType.GET,
      url:
          '$url/getBlogImages/${widget.id}?language_id=${Application.languageId}',
    );

    bool _status = _getNews['status'];
    var _data = _getNews['data'];
    print(_data);
    if (_status) {
      // data loaded
      if (_data['data'].length > 0) {
        imagePath =
            Constants.imgBackendUrl + _data['data'][0]['path'].toString();
      } else {
        imagePath = Constants.imgBackendUrl + '/images/all/logo.png';
      }
      for (var i = 0; i < _data['data'].length; i++) {
        list.add(
          GestureDetector(
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => OpenImage(
                    url: Constants.imgBackendUrl +
                        _data['data'][0]['path'].toString(),
                  ),
                ),
              );
            },
            child: Container(
              margin:
                  const EdgeInsets.symmetric(vertical: 0.0, horizontal: 8.0),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(10.0),
                child: SizedBox(
                  width: double.infinity,
                  height: 300.0,
                  child: CachedNetworkImage(
                    imageUrl: Constants.imgBackendUrl +
                        _data['data'][i]['path'].toString(),
                    placeholder: (context, url) => const ImagePlaceholder(),
                    errorWidget: (context, url, error) =>
                        const ImagePlaceholder(),
                    // fadeOutDuration: const Duration(seconds: 1),
                    // fadeInDuration: const Duration(seconds: 1),
                    fit: BoxFit.cover,
                    // width: 144.0,
                    height: 200.0,
                  ),
                ),
              ),
            ),
          ),
        );
      }
      setState(() => isLoading = true);
      Utility.showProgress(false);
    } else {
      Utility.printLog('Something went wrong.');
      Utility.showProgress(false);
    }
  }

  _filterRetriever() async {
    try {
      final result = await InternetAddress.lookup(Constants.internetCheckUrl);
      if (result.isNotEmpty && result[0].rawAddress.isNotEmpty) {
        Utility.printLog('connected');
        getBlogImages();
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
    // if (Platform.isIOS) {
    //   _insecureScreenDetector.initialize();
    //   _insecureScreenDetector.addListener(() {
    //     Utility.printLog('add event listener');
    //     Utility.forceLogoutUser(context);
    //     // Utility.forceLogout(context);
    //   }, (isCaptured) {
    //     Utility.printLog('screen recording event listener');
    //     // Utility.forceLogoutUser(context);
    //     // Utility.forceLogout(context);
    //     setState(() {
    //       _isCaptured = isCaptured;
    //     });
    //   });
    // }
    if (!kIsWeb) {
      _filterRetriever();
    } else {
      getBlogImages();
    }
    Utility.showProgress(true);
    super.initState();
  }

  @override
  void dispose() {
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
                  '',
                  style: TextStyle(
                    color: Colors.black,
                    fontSize: 18.0,
                    fontFamily: 'EuclidCircularA Medium',
                  ),
                ),
                backgroundColor: Palette.appBarColor,
                elevation: 10.0,
                shadowColor: const Color(0xffFFF0D0).withOpacity(0.2),
                centerTitle: true,
                actions: [
                  IconButton(
                    onPressed: () {
                      // _saveFilter();
                      createFileOfPdfUrl().then((f) {
                        setState(() {
                          remotePDFpath = f.path;
                        });
                        // _onShare(context);
                      });
                    },
                    icon: Icon(
                      MdiIcons.shareVariant,
                      color: Palette.white,
                    ),
                  ),
                ],
              ),
              body: SingleChildScrollView(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const SizedBox(
                      height: 20.0,
                    ),
                    Center(
                      child: list.isEmpty
                          ? Container(
                              height: 0.0,
                            )
                          : SizedBox(
                              height: 200.0,
                              width: double.infinity,
                              child: !isLoading
                                  ? Container()
                                  : CarouselSlider(
                                      options: CarouselOptions(
                                        aspectRatio: 1 / 1,
                                        autoPlay: true,
                                        viewportFraction: 0.9,
                                        autoPlayAnimationDuration:
                                            const Duration(milliseconds: 1000),
                                        enlargeCenterPage: false,
                                        enableInfiniteScroll:
                                            list.length == 1 ? false : true,
                                      ),
                                      items: list
                                          .map(
                                            (item) => item,
                                          )
                                          .toList(),
                                    ),
                            ),
                    ),
                    const SizedBox(
                      height: 20.0,
                    ),
                    Padding(
                      padding: const EdgeInsets.symmetric(
                          vertical: 00.0, horizontal: 24.0),
                      child: Text(
                        widget.title,
                        style: const TextStyle(
                            color: Palette.black,
                            fontSize: 24.0,
                            fontFamily: 'CenturyGothic'),
                      ),
                    ),
                    const SizedBox(
                      height: 5.0,
                    ),
                    Padding(
                      padding: const EdgeInsets.symmetric(
                          vertical: 00.0, horizontal: 24.0),
                      child: Text(
                        widget.time,
                        style: const TextStyle(
                            color: Palette.contrastColor,
                            fontSize: 14.0,
                            fontFamily: 'CenturyGothic'),
                      ),
                    ),
                    const SizedBox(
                      height: 15.0,
                    ),
                    widget.description.contains('<')
                        ? Padding(
                            padding: const EdgeInsets.symmetric(
                                vertical: 00.0, horizontal: 24.0),
                            child: TextToHtml(
                              description: widget.description,
                              textColor: Palette.black,
                              fontSize: 16.0,
                            ),
                          )
                        : Padding(
                            padding: const EdgeInsets.symmetric(
                                vertical: 00.0, horizontal: 24.0),
                            child: Text(
                              widget.description,
                              style: const TextStyle(
                                  color: Colors.black,
                                  fontSize: 16.0,
                                  fontFamily: 'EuclidCircularA Regular'),
                            ),
                          ),
                    const SizedBox(
                      height: 30.0,
                    )
                  ],
                ),
              ),
            ),
          );
  }
}
