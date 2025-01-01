import 'dart:io';
import 'dart:typed_data';
import 'package:http/http.dart' as http;

import 'package:cached_network_image/cached_network_image.dart';
import 'package:chef_taruna_birla/widgets/image_placeholder.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
// import 'package:ios_insecure_screen_detector/ios_insecure_screen_detector.dart';
import 'package:path_provider/path_provider.dart';
import 'package:share_plus/share_plus.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../config/config.dart';
import '../../models/book.dart';
import '../../services/mysql_db_service.dart';
import '../../utils/utility.dart';
import '../book/each_book.dart';

class MyBooks extends StatefulWidget {
  const MyBooks({Key? key}) : super(key: key);

  @override
  State<MyBooks> createState() => _MyBooksState();
}

class _MyBooksState extends State<MyBooks> {
  List list = [];
  bool isLoading = false;
  String user_id = '';
  String url = Constants.isDevelopment
      ? Constants.devBackendUrl
      : Constants.prodBackendUrl;
  // final IosInsecureScreenDetector _insecureScreenDetector =
  //     IosInsecureScreenDetector();
  bool _isCaptured = false;

  Future<void> updateCart(id, value) async {
    Map<String, dynamic> _updateCart = await MySqlDBService().runQuery(
      requestType: RequestType.POST,
      url:
          value == 'add' ? '$url/users/addtocart' : '$url/users/removefromcart',
      body: {
        'user_id': user_id,
        'category': 'course',
        'id': id,
      },
    );

    bool _status = _updateCart['status'];
    var _data = _updateCart['data'];
    // Utility.printLog(_data);
    if (_status) {
      // data loaded
      Utility.printLog(_data);
    } else {
      Utility.printLog('Something went wrong.');
      Utility.showProgress(false);
    }
  }

  // void _onShare(BuildContext context) async {
  //   final ByteData bytes = await rootBundle.load('assets/images/logo.png');
  //   final Uint8List list = bytes.buffer.asUint8List();

  //   final tempDir = await getTemporaryDirectory();
  //   final file = await File('${tempDir.path}/image.jpg').create();
  //   file.writeAsBytesSync(list);
  //   final box = context.findRenderObject() as RenderBox?;
  //   await Share.shareXFiles(
  //     [(file.path)],
  //     text:
  //         'To explore more products and courses click on the link given below\n\n👇https://play.google.com/store/apps/details?id=com.cheftarunbirla',
  //     sharePositionOrigin: box!.localToGlobal(Offset.zero) & box.size,
  //   );
  // }
  void _onShare(BuildContext context) async {
    // Load the image from assets
    final ByteData bytes = await rootBundle.load('assets/images/logo.png');
    final Uint8List list = bytes.buffer.asUint8List();

    // Create a temporary file to save the image
    final tempDir = await getTemporaryDirectory();
    final file = await File('${tempDir.path}/image.jpg').create();
    await file.writeAsBytes(list);

    // Convert the file path to XFile
    final xFile = XFile(file.path);

    // Get the box for sharing position
    final box = context.findRenderObject() as RenderBox?;

    // Share the file using Share.shareXFiles
    await Share.shareXFiles(
      [xFile],
      text:
          'To explore more products and courses click on the link given below\n\n👇https://play.google.com/store/apps/details?id=com.cheftarunbirla',
      sharePositionOrigin: box!.localToGlobal(Offset.zero) & box.size,
    );
  }

  Future<void> getUserCourses() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    final userId = prefs.getString('user_id') ?? '';
    setState(() {
      user_id = userId;
    });
    Map<String, dynamic> _getNews = await MySqlDBService().runQuery(
      requestType: RequestType.GET,
      url:
          '$url/users/getUserBooks/$user_id?language_id=${Application.languageId}',
    );

    bool _status = _getNews['status'];
    var _data = _getNews['data'];
    // Utility.printLog(_data);
    if (_status) {
      // data loaded
      for (var i = 0; i < _data['data'].length; i++) {
        var item_category = _data['data'][i]['category'].toString();
        list.add(
          Book(
            id: _data['data'][i]['id'].toString(),
            title: _data['data'][i]['title'].toString(),
            description: _data['data'][i]['description'].toString(),
            price: _data['data'][i]['price'].toString(),
            discount_price: _data['data'][i]['discount_price'].toString(),
            days: _data['data'][i]['days'],
            category: _data['data'][i]['sub_category'].toString(),
            image_path: _data['data'][i]['image_path'].toString(),
            pdflink: _data['data'][i]['pdf'].toString(),
            count: int.parse(
              _data['data'][i]['count'].toString(),
            ),
            price_with_video: _data['data'][i]['price_with_video'].toString(),
            discount_price_with_video:
                _data['data'][i]['discount_price_with_video'].toString(),
            video_days: _data['data'][i]['video_days'],
            only_video_price: _data['data'][i]['only_video_price'].toString(),
            only_video_discount_price:
                _data['data'][i]['only_video_discount_price'].toString(),
            share_url: _data['data'][i]['share_url'].toString() == 'null'
                ? ''
                : _data['data'][i]['share_url'].toString(),
            include_videos: _data['data'][i]['include_videos'].toString(),
          ),
        );
      }
      setState(() => isLoading = true);
      Utility.showProgress(false);
    } else {
      Utility.printLog('Something went wrong.');
      Utility.showProgress(false);
      Utility.databaseErrorPopup(context);
    }
  }

  _filterRetriever() async {
    try {
      final result = await InternetAddress.lookup('cheftarunabirla.com');
      if (result.isNotEmpty && result[0].rawAddress.isNotEmpty) {
        Utility.printLog('connected');
        getUserCourses();
      }
    } on SocketException catch (_) {
      Utility.printLog('not connected');
      Utility.showProgress(false);
      setState(() {
        isLoading = true;
      });
      Utility.databaseErrorPopup(context);
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
    Utility.showProgress(true);
    if (!kIsWeb) {
      _filterRetriever();
    } else {
      getUserCourses();
    }
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
                  color: Colors.white,
                  size: 18.0,
                ),
                onPressed: () => Navigator.of(context).pop(),
              ),
              title: const Text(
                'My Books',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 18.0,
                  fontFamily: 'EuclidCircularA Medium',
                ),
              ),
              backgroundColor: Palette.appBarColor,
              elevation: 10.0,
              shadowColor: const Color(0xffFFF0D0).withOpacity(0.2),
              centerTitle: false,
            ),
            body: Column(
              mainAxisAlignment: MainAxisAlignment.start,
              children: [
                const SizedBox(
                  height: 20.0,
                ),
                Expanded(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(
                        vertical: 0.0, horizontal: 24.0),
                    child: SizedBox(
                      // height: 20.0,
                      child: !isLoading
                          ? const Text(
                              'Loading...',
                              style: TextStyle(
                                color: Colors.black,
                                fontSize: 16.0,
                                fontFamily: 'EuclidCircularA Regular',
                              ),
                            )
                          : list.isEmpty
                              ? Center(
                                  child: Text(
                                    Platform.isIOS
                                        ? 'No Books'
                                        : 'Purchase some books first!!',
                                    textAlign: TextAlign.center,
                                    style: const TextStyle(
                                      color: Colors.black,
                                      fontSize: 18.0,
                                      fontFamily: 'EuclidCircularA Medium',
                                    ),
                                  ),
                                )
                              : LayoutBuilder(
                                  builder: (BuildContext context,
                                      BoxConstraints constraints) {
                                    return GridView.builder(
                                      // physics: NeverScrollableScrollPhysics(),
                                      shrinkWrap: true,
                                      gridDelegate:
                                          SliverGridDelegateWithFixedCrossAxisCount(
                                        crossAxisCount:
                                            constraints.maxWidth < 576
                                                ? 2
                                                : constraints.maxWidth < 768
                                                    ? 3
                                                    : constraints.maxWidth < 992
                                                        ? 4
                                                        : 6,
                                        childAspectRatio: constraints.maxWidth <
                                                576
                                            ? 0.75
                                            : constraints.maxWidth < 768
                                                ? 0.8
                                                : constraints.maxWidth < 992
                                                    ? 0.8
                                                    : constraints.maxWidth <
                                                            1024
                                                        ? 0.7
                                                        : constraints.maxWidth <
                                                                1220
                                                            ? 0.7
                                                            : 0.9,
                                        mainAxisSpacing: 18.0,
                                        crossAxisSpacing: 18.0,
                                      ),
                                      itemCount: list.length,
                                      itemBuilder: (context, index) {
                                        // Utility.printLog(counter);
                                        return Container(
                                          // height: 230.0,
                                          decoration: BoxDecoration(
                                            borderRadius:
                                                BorderRadius.circular(10.0),
                                            color: Colors.white,
                                            boxShadow: [
                                              BoxShadow(
                                                color: Palette.shadowColor
                                                    .withOpacity(0.1),
                                                blurRadius:
                                                    5.0, // soften the shadow
                                                spreadRadius:
                                                    0.0, //extend the shadow
                                                offset: const Offset(
                                                  0.0, // Move to right 10  horizontally
                                                  0.0, // Move to bottom 10 Vertically
                                                ),
                                              ),
                                            ],
                                          ),
                                          child: Column(
                                            crossAxisAlignment:
                                                CrossAxisAlignment.start,
                                            children: [
                                              GestureDetector(
                                                onTap: () {
                                                  Navigator.push(
                                                    context,
                                                    MaterialPageRoute(
                                                      builder: (context) =>
                                                          EachBook(
                                                        id: list[index].id,
                                                      ),
                                                    ),
                                                  );
                                                },
                                                child: Padding(
                                                  padding:
                                                      const EdgeInsets.all(5.0),
                                                  child: ClipRRect(
                                                    borderRadius:
                                                        BorderRadius.circular(
                                                            8.0),
                                                    child: CachedNetworkImage(
                                                      imageUrl: Constants
                                                              .imgBackendUrl +
                                                          list[index]
                                                              .image_path,
                                                      placeholder: (context,
                                                              url) =>
                                                          const ImagePlaceholder(),
                                                      errorWidget: (context,
                                                              url, error) =>
                                                          const ImagePlaceholder(),
                                                      fit: BoxFit.cover,
                                                      height: 192.0,
                                                      width: double.infinity,
                                                    ),
                                                  ),
                                                ),
                                              ),
                                            ],
                                          ),
                                        );
                                      },
                                    );
                                  },
                                ),
                    ),
                  ),
                ),
              ],
            ),
          );
  }
}
