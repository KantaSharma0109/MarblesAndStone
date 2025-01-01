import 'dart:io';
import 'dart:typed_data';

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
import '../../models/order.dart';
import '../../services/mysql_db_service.dart';
import '../../utils/utility.dart';

class MyOrders extends StatefulWidget {
  const MyOrders({Key? key}) : super(key: key);

  @override
  _MyOrdersState createState() => _MyOrdersState();
}

class _MyOrdersState extends State<MyOrders> {
  List list = [];
  bool isLoading = false;
  String user_id = '';
  String url = Constants.isDevelopment
      ? Constants.devBackendUrl
      : Constants.prodBackendUrl;
  // final IosInsecureScreenDetector _insecureScreenDetector =
  //     IosInsecureScreenDetector();
  bool _isCaptured = false;

  // void _onShare(BuildContext context) async {
  //   final ByteData bytes = await rootBundle.load('assets/images/logo.png');
  //   final Uint8List list = bytes.buffer.asUint8List();

  //   final tempDir = await getTemporaryDirectory();
  //   final file = await new File('${tempDir.path}/image.jpg').create();
  //   file.writeAsBytesSync(list);
  //   final box = context.findRenderObject() as RenderBox?;
  //   await Share.shareFiles(
  //     ['${file.path}'],
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

  Future<void> getUserOrders() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    final userId = prefs.getString('user_id') ?? '';
    setState(() {
      user_id = userId;
    });
    Map<String, dynamic> _getNews = await MySqlDBService().runQuery(
      requestType: RequestType.GET,
      url: '$url/users/getUserOrders/$user_id',
    );

    bool _status = _getNews['status'];
    var _data = _getNews['data'];
    // Utility.printLog(_data);
    if (_status) {
      // data loaded
      for (var i = 0; i < _data['data'].length; i++) {
        var item_category = _data['data'][i]['category'].toString();
        list.add(
          Orders(
            id: _data['data'][i]['id'].toString(),
            name: _data['data'][i]['name'].toString(),
            date: _data['data'][i]['date_purchased'].toString(),
            item_id: item_category == 'course'
                ? _data['data'][i]['course_id'].toString()
                : item_category == 'product'
                    ? _data['data'][i]['product_id'].toString()
                    : item_category == 'book'
                        ? _data['data'][i]['book_id'].toString()
                        : '',
            category: _data['data'][i]['category'].toString(),
            paid_price: _data['data'][i]['paid_price'].toString(),
            price: _data['data'][i]['price'].toString(),
            image_path: _data['data'][i]['image_path'].toString(),
            order_image: _data['data'][i]['order_image'].toString(),
            quantity: int.parse(
                _data['data'][i]['quantity'].toString() == 'null'
                    ? '0'
                    : _data['data'][i]['quantity'].toString()),
            payment_status: _data['data'][i]['payment_status'].toString(),
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
        getUserOrders();
      }
    } on SocketException catch (_) {
      Utility.printLog('not connected');
      Utility.showProgress(false);
      setState(() {
        isLoading = true;
      });
      Utility.noInternetPopup(context);
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
      getUserOrders();
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
                'My Orders',
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
            body: !isLoading
                ? Container()
                : list.isEmpty
                    ? const Center(
                        child: Text(
                          'No orders right now!!',
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            color: Colors.black,
                            fontSize: 18.0,
                            fontFamily: 'EuclidCircularA Medium',
                          ),
                        ),
                      )
                    : Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const SizedBox(
                            height: 10.0,
                          ),
                          Expanded(
                            child: Padding(
                              padding: const EdgeInsets.symmetric(
                                  vertical: 00.0, horizontal: 24.0),
                              child: ListView.builder(
                                itemCount: list.length,
                                itemBuilder: (BuildContext context, int index) {
                                  return Padding(
                                    padding: const EdgeInsets.symmetric(
                                      vertical: 8.0,
                                      horizontal: 0.0,
                                    ),
                                    child: Container(
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
                                      child: Row(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          Expanded(
                                            flex: 2,
                                            child: Padding(
                                              padding:
                                                  const EdgeInsets.all(5.0),
                                              child: ClipRRect(
                                                borderRadius:
                                                    BorderRadius.circular(8.0),
                                                child: CachedNetworkImage(
                                                  imageUrl: list[index]
                                                              .order_image
                                                              .toString() !=
                                                          'null'
                                                      ? list[index].order_image
                                                      : Constants
                                                              .imgBackendUrl +
                                                          list[index]
                                                              .image_path,
                                                  placeholder: (context, url) =>
                                                      const ImagePlaceholder(),
                                                  errorWidget: (context, url,
                                                          error) =>
                                                      const ImagePlaceholder(),
                                                  fit: BoxFit.cover,
                                                  height: 80.0,
                                                  width: double.infinity,
                                                ),
                                              ),
                                            ),
                                          ),
                                          Expanded(
                                            flex: 4,
                                            child: Padding(
                                              padding:
                                                  const EdgeInsets.all(0.0),
                                              child: Column(
                                                crossAxisAlignment:
                                                    CrossAxisAlignment.start,
                                                mainAxisAlignment:
                                                    MainAxisAlignment.start,
                                                children: [
                                                  const SizedBox(
                                                    height: 10.0,
                                                  ),
                                                  Padding(
                                                    padding: const EdgeInsets
                                                        .symmetric(
                                                        vertical: 0.0,
                                                        horizontal: 10.0),
                                                    child: Column(
                                                      crossAxisAlignment:
                                                          CrossAxisAlignment
                                                              .start,
                                                      mainAxisAlignment:
                                                          MainAxisAlignment
                                                              .start,
                                                      children: [
                                                        Text(
                                                          '${list[index].name}',
                                                          style: const TextStyle(
                                                              color:
                                                                  Colors.black,
                                                              fontSize: 14.0,
                                                              fontFamily:
                                                                  'EuclidCircularA Medium'),
                                                        ),
                                                        const SizedBox(
                                                          height: 20.0,
                                                        ),
                                                        Row(
                                                          mainAxisAlignment:
                                                              MainAxisAlignment
                                                                  .spaceBetween,
                                                          crossAxisAlignment:
                                                              CrossAxisAlignment
                                                                  .end,
                                                          children: [
                                                            Text(
                                                              'Rs. ${list[index].price}',
                                                              style: const TextStyle(
                                                                  color: Colors
                                                                      .black,
                                                                  fontSize:
                                                                      16.0,
                                                                  fontFamily:
                                                                      'EuclidCircularA Medium'),
                                                            ),
                                                            Text(
                                                              list[index]
                                                                  .date
                                                                  .toString()
                                                                  .substring(
                                                                      0, 10),
                                                              style: const TextStyle(
                                                                  color: Colors
                                                                      .black,
                                                                  fontSize:
                                                                      12.0,
                                                                  fontFamily:
                                                                      'EuclidCircularA Regular'),
                                                            ),
                                                          ],
                                                        ),
                                                      ],
                                                    ),
                                                  ),
                                                  const SizedBox(
                                                    height: 10.0,
                                                  ),
                                                ],
                                              ),
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                  );
                                },
                              ),
                            ),
                          ),
                        ],
                      ),
          );
  }
}
