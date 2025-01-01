import 'dart:io';
import 'dart:typed_data';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:chef_taruna_birla/viewmodels/main_container_viewmodel.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
// import 'package:ios_insecure_screen_detector/ios_insecure_screen_detector.dart';
import 'package:path_provider/path_provider.dart';
import 'package:provider/src/provider.dart';
import 'package:share_plus/share_plus.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../config/config.dart';
import '../../models/course.dart';
import '../../services/mysql_db_service.dart';
import '../../utils/utility.dart';
import '../../widgets/image_placeholder.dart';
import '../course/each_course.dart';

class MyCourses extends StatefulWidget {
  const MyCourses({Key? key}) : super(key: key);

  @override
  _MyCoursesState createState() => _MyCoursesState();
}

class _MyCoursesState extends State<MyCourses> {
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
  //   await Share.shareFiles(
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
          '$url/users/getUserCourses/$user_id?language_id=${Application.languageId}',
    );

    bool _status = _getNews['status'];
    var _data = _getNews['data'];
    // Utility.printLog(_data);
    if (_status) {
      // data loaded
      for (var i = 0; i < _data['data'].length; i++) {
        var item_category = _data['data'][i]['category'].toString();
        list.add(
          Course(
            id: _data['data'][i]['id'].toString(),
            title: _data['data'][i]['title'].toString(),
            description: _data['data'][i]['description'].toString(),
            promo_video: _data['data'][i]['promo_video'].toString(),
            price: _data['data'][i]['price'].toString(),
            discount_price: _data['data'][i]['discount_price'].toString(),
            days: _data['data'][i]['days'],
            category: _data['data'][i]['sub_category'].toString(),
            image_path: _data['data'][i]['image_path'].toString(),
            share_url: _data['data'][i]['share_url'].toString(),
            subscribed:
                int.parse(_data['data'][i]['status'].toString()) == 1 ? 1 : 0,
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
      Utility.noInternetPopup(context);
      setState(() {
        isLoading = true;
      });
      Utility.showProgress(false);
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
                  color: Palette.white,
                  size: 18.0,
                ),
                onPressed: () => Navigator.of(context).pop(),
              ),
              title: const Text(
                'My Courses',
                style: TextStyle(
                  color: Palette.white,
                  fontSize: 18.0,
                  fontFamily: 'EuclidCircularA Medium',
                ),
              ),
              backgroundColor: Palette.appBarColor,
              elevation: 10.0,
              shadowColor: Palette.shadowColor.withOpacity(0.1),
              centerTitle: false,
            ),
            body: Column(
              mainAxisAlignment: MainAxisAlignment.start,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(
                        vertical: 10.0, horizontal: 24.0),
                    child: SizedBox(
                      // height: 20.0,
                      child: !isLoading
                          ? Container()
                          : list.isEmpty
                              ? Center(
                                  child: Text(
                                    Platform.isIOS
                                        ? 'No course'
                                        : 'Purchase some courses first!!',
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
                                      scrollDirection: Axis.vertical,
                                      // physics: NeverScrollableScrollPhysics(),
                                      // shrinkWrap: true,
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
                                        int counter = 0;
                                        Provider.of<MainContainerViewModel>(
                                                context,
                                                listen: false)
                                            .cart
                                            .forEach((element) {
                                          if (element.item_id ==
                                                  list[index].id &&
                                              element.item_category ==
                                                  'course') {
                                            counter++;
                                          }
                                        });
                                        // Utility.printLog(counter);
                                        return Container(
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
                                                  // Navigator.push(
                                                  //   context,
                                                  //   MaterialPageRoute(
                                                  //     builder: (context) =>
                                                  //         EachCourse(
                                                  //       id: list[index].id,
                                                  //       title: list[index].title,
                                                  //       category:
                                                  //           list[index].category,
                                                  //       description:
                                                  //           list[index].description,
                                                  //       price: list[index].price,
                                                  //       discount_price: list[index]
                                                  //           .discount_price,
                                                  //       days: list[index]
                                                  //           .days
                                                  //           .toString(),
                                                  //       promo_video:
                                                  //           list[index].promo_video,
                                                  //     ),
                                                  //   ),
                                                  // );
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
                                                      height: 120.0,
                                                      width: double.infinity,
                                                    ),
                                                  ),
                                                ),
                                              ),
                                              Expanded(
                                                flex: 3,
                                                child: Padding(
                                                  padding: const EdgeInsets
                                                      .symmetric(
                                                      vertical: 0.0,
                                                      horizontal: 10.0),
                                                  child: GestureDetector(
                                                    onTap: () {
                                                      Navigator.push(
                                                        context,
                                                        MaterialPageRoute(
                                                          builder: (context) =>
                                                              EachCourse(
                                                            id: list[index].id,
                                                          ),
                                                        ),
                                                      );
                                                    },
                                                    child: Text(
                                                      list[index].title,
                                                      style: const TextStyle(
                                                        color: Colors.black,
                                                        fontSize: 16.0,
                                                        fontFamily:
                                                            'EuclidCircularA Regular',
                                                      ),
                                                      maxLines: 2,
                                                    ),
                                                  ),
                                                ),
                                              ),
                                              const SizedBox(
                                                height: 0.0,
                                              ),
                                              Expanded(
                                                flex: 2,
                                                child: Row(
                                                  crossAxisAlignment:
                                                      CrossAxisAlignment.center,
                                                  mainAxisAlignment:
                                                      MainAxisAlignment.end,
                                                  children: [
                                                    // Expanded(
                                                    //   child: Center(
                                                    //     child: Text(
                                                    //       list[index].category ==
                                                    //               'free'
                                                    //           ? 'Free'
                                                    //           : 'Rs ${list[index].discount_price}',
                                                    //       style: const TextStyle(
                                                    //         color:
                                                    //             Palette.contrastColor,
                                                    //         fontSize: 16.0,
                                                    //         fontFamily:
                                                    //             'EuclidCircularA Medium',
                                                    //       ),
                                                    //     ),
                                                    //   ),
                                                    // ),
                                                    Expanded(
                                                      child: GestureDetector(
                                                        onTap: () {
                                                          if (list[index]
                                                                  .category ==
                                                              'free') {
                                                            // Utility.printLog('its free');
                                                            Navigator.push(
                                                              context,
                                                              MaterialPageRoute(
                                                                builder:
                                                                    (context) =>
                                                                        EachCourse(
                                                                  id: list[
                                                                          index]
                                                                      .id,
                                                                ),
                                                              ),
                                                            );
                                                          } else {
                                                            if (list[index]
                                                                    .subscribed ==
                                                                0) {
                                                              // setState(() {
                                                              //   if (counter >= 1) {
                                                              //     Provider.of<MainContainerViewModel>(
                                                              //             context,
                                                              //             listen:
                                                              //                 false)
                                                              //         .cart
                                                              //         .removeWhere((element) =>
                                                              //             element.item_id ==
                                                              //                 list[index]
                                                              //                     .id &&
                                                              //             element.item_category ==
                                                              //                 'course');
                                                              //     context
                                                              //         .read<
                                                              //             MainContainerViewModel>()
                                                              //         .setCart(Provider.of<
                                                              //                     MainContainerViewModel>(
                                                              //                 context,
                                                              //                 listen:
                                                              //                     false)
                                                              //             .current_cart);
                                                              //     updateCart(
                                                              //         list[index].id,
                                                              //         'remove');
                                                              //   } else {
                                                              //     // var newObject =
                                                              //     //     CartItem(
                                                              //     //   id: list[index]
                                                              //     //       .id,
                                                              //     //   category:
                                                              //     //       'course',
                                                              //     // );
                                                              //     Provider.of<MainContainerViewModel>(
                                                              //             context,
                                                              //             listen:
                                                              //                 false)
                                                              //         .cart
                                                              //         .add(newObject);
                                                              //     context
                                                              //         .read<
                                                              //             MainContainerViewModel>()
                                                              //         .setCart(Provider.of<
                                                              //                     MainContainerViewModel>(
                                                              //                 context,
                                                              //                 listen:
                                                              //                     false)
                                                              //             .cart);
                                                              //     updateCart(
                                                              //         list[index].id,
                                                              //         'add');
                                                              //   }
                                                              // });
                                                            } else {
                                                              Navigator.push(
                                                                context,
                                                                MaterialPageRoute(
                                                                  builder:
                                                                      (context) =>
                                                                          EachCourse(
                                                                    id: list[
                                                                            index]
                                                                        .id,
                                                                  ),
                                                                ),
                                                              );
                                                            }
                                                          }
                                                        },
                                                        child: list[index]
                                                                    .subscribed ==
                                                                1
                                                            ? Container(
                                                                height: double
                                                                    .infinity,
                                                                child: Center(
                                                                  child: Row(
                                                                    crossAxisAlignment:
                                                                        CrossAxisAlignment
                                                                            .center,
                                                                    mainAxisAlignment:
                                                                        MainAxisAlignment
                                                                            .center,
                                                                    children: const [
                                                                      Text(
                                                                        'Open',
                                                                        style:
                                                                            TextStyle(
                                                                          color:
                                                                              Colors.white,
                                                                          fontSize:
                                                                              12.0,
                                                                          fontFamily:
                                                                              'EuclidCircularA Regular',
                                                                        ),
                                                                      ),
                                                                    ],
                                                                  ),
                                                                ),
                                                                decoration:
                                                                    const BoxDecoration(
                                                                  color: Palette
                                                                      .secondaryColor,
                                                                  borderRadius:
                                                                      BorderRadius
                                                                          .only(
                                                                    topLeft: Radius
                                                                        .circular(
                                                                            0.0),
                                                                    topRight: Radius
                                                                        .circular(
                                                                            0.0),
                                                                    bottomLeft:
                                                                        Radius.circular(
                                                                            10.0),
                                                                    bottomRight:
                                                                        Radius.circular(
                                                                            10.0),
                                                                  ),
                                                                ),
                                                              )
                                                            : counter == 0
                                                                ? Container(
                                                                    height: double
                                                                        .infinity,
                                                                    child:
                                                                        Center(
                                                                      child:
                                                                          Row(
                                                                        crossAxisAlignment:
                                                                            CrossAxisAlignment.center,
                                                                        mainAxisAlignment:
                                                                            MainAxisAlignment.center,
                                                                        children: [
                                                                          Text(
                                                                            list[index].category == 'free'
                                                                                ? 'Read'
                                                                                : 'Add',
                                                                            style:
                                                                                const TextStyle(
                                                                              color: Colors.white,
                                                                              fontSize: 12.0,
                                                                              fontFamily: 'EuclidCircularA Regular',
                                                                            ),
                                                                          ),
                                                                          const Icon(
                                                                            Icons.add,
                                                                            color:
                                                                                Colors.white,
                                                                            size:
                                                                                16.0,
                                                                          )
                                                                        ],
                                                                      ),
                                                                    ),
                                                                    decoration:
                                                                        const BoxDecoration(
                                                                      color: Palette
                                                                          .secondaryColor,
                                                                      borderRadius:
                                                                          BorderRadius
                                                                              .only(
                                                                        topLeft:
                                                                            Radius.circular(0.0),
                                                                        topRight:
                                                                            Radius.circular(0.0),
                                                                        bottomLeft:
                                                                            Radius.circular(10.0),
                                                                        bottomRight:
                                                                            Radius.circular(10.0),
                                                                      ),
                                                                    ),
                                                                  )
                                                                : Container(
                                                                    height: double
                                                                        .infinity,
                                                                    child:
                                                                        Center(
                                                                      child:
                                                                          Row(
                                                                        crossAxisAlignment:
                                                                            CrossAxisAlignment.center,
                                                                        mainAxisAlignment:
                                                                            MainAxisAlignment.center,
                                                                        children: [
                                                                          Text(
                                                                            list[index].category == 'free'
                                                                                ? 'Read'
                                                                                : 'Remove',
                                                                            style:
                                                                                const TextStyle(
                                                                              color: Colors.white,
                                                                              fontSize: 12.0,
                                                                              fontFamily: 'EuclidCircularA Regular',
                                                                            ),
                                                                          ),
                                                                        ],
                                                                      ),
                                                                    ),
                                                                    decoration:
                                                                        const BoxDecoration(
                                                                      color: Palette
                                                                          .secondaryColor,
                                                                      borderRadius:
                                                                          BorderRadius
                                                                              .only(
                                                                        topLeft:
                                                                            Radius.circular(0.0),
                                                                        topRight:
                                                                            Radius.circular(0.0),
                                                                        bottomLeft:
                                                                            Radius.circular(10.0),
                                                                        bottomRight:
                                                                            Radius.circular(10.0),
                                                                      ),
                                                                    ),
                                                                  ),
                                                      ),
                                                    ),
                                                  ],
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
