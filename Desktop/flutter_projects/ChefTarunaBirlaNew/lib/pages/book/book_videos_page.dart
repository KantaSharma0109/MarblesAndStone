import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
// import 'package:ios_insecure_screen_detector/ios_insecure_screen_detector.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../config/config.dart';
import '../../models/cart_item.dart';
import '../../services/mysql_db_service.dart';
import '../../utils/utility.dart';
import '../../viewmodels/main_container_viewmodel.dart';
import '../cart/cart_page.dart';
import '../common/video_web_player.dart';

class BookVideosPage extends StatefulWidget {
  final String book_id;
  final String name;
  final int book_subscribed;
  final String only_video_price;
  final String only_video_discount_price;
  const BookVideosPage(
      {Key? key,
      required this.book_id,
      required this.name,
      required this.book_subscribed,
      required this.only_video_price,
      required this.only_video_discount_price})
      : super(key: key);

  @override
  _BookVideosPageState createState() => _BookVideosPageState();
}

class VideoList {
  late final String name;
  late final String url;

  VideoList({
    required this.name,
    required this.url,
  });
}

class _BookVideosPageState extends State<BookVideosPage> {
  List<VideoList> list = [];
  bool isLoading = false;
  bool isSubscriptionLoading = false;
  String user_id = '';
  String daysLeft = '';
  final reviewController = TextEditingController();
  int subscribed = 0;
  int counter = 0;
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
        'category': 'book-videos',
        'id': widget.book_id,
      },
    );

    bool _status = _updateCart['status'];
    var _data = _updateCart['data'];
    // Utility.printLog(_data);
    if (_status) {
      // data loaded
      // Utility.printLog(_data);
      if (value == 'add') {
        Utility.showSnacbar(context, 'Item successfully added to cart!!');
        Future.delayed(const Duration(milliseconds: 500), () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => const CartPage(),
            ),
          );
        });
      } else {
        Utility.showSnacbar(context, 'Item successfully removed from cart!!');
      }
    } else {
      Utility.printLog('Something went wrong.');
    }
  }

  Future<void> updateBookSubscription() async {
    Map<String, dynamic> _getNews = await MySqlDBService().runQuery(
      requestType: RequestType.GET,
      url: '$url/users/updateBookVideosSubscription/${widget.book_id}/$user_id',
    );

    bool _status = _getNews['status'];
    var _data = _getNews['data'];
    // Utility.Utility.printLogLog(_data);
    if (_status) {
      setState(() => isSubscriptionLoading = true);
    } else {
      Utility.printLog('Something went wrong.');
    }
  }

  Future<void> getBookSubscription() async {
    Map<String, dynamic> _getNews = await MySqlDBService().runQuery(
      requestType: RequestType.GET,
      url: '$url/users/getBookVideosSubscription/${widget.book_id}/$user_id',
    );

    bool _status = _getNews['status'];
    var _data = _getNews['data'];
    // Utility.Utility.printLogLog(_data);
    if (_status) {
      if (_data['data'].length != 0) {
        var start_date = DateTime.now();
        var end_date = DateTime.parse(_data['data'][0]['end_date'].toString());
        var diff = end_date.difference(start_date);
        // Utility.Utility.printLogLog(diff.inDays);
        if (diff.inDays <= 0) {
          subscribed = 0;
          updateBookSubscription();
        } else if (diff.inDays > 0) {
          subscribed = 1;
          setState(() {
            daysLeft = diff.inDays.toString();
            isSubscriptionLoading = true;
          });
        }
      } else {
        subscribed = 0;
        setState(() => isSubscriptionLoading = true);
      }
      Utility.showProgress(false);
    } else {
      Utility.printLog('Something went wrong.');
      Utility.showProgress(false);
      Utility.databaseErrorPopup(context);
    }
  }

  Future<void> getBookVideos() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    final userId = prefs.getString('user_id') ?? '';
    setState(() {
      user_id = userId;
    });
    Map<String, dynamic> _getNews = await MySqlDBService().runQuery(
      requestType: RequestType.GET,
      url:
          '$url/getBookVideos/${widget.book_id}?language_id=${Application.languageId}',
    );

    bool _status = _getNews['status'];
    var _data = _getNews['data'];
    // Utility.printLog(_data);
    if (_status) {
      // data loaded
      list.clear();
      for (var i = 0; i < _data['data'].length; i++) {
        list.add(VideoList(
          name: _data['data'][i]['name'].toString(),
          url: _data['data'][i]['path'].toString(),
        ));
      }
      setState(() => isLoading = true);
      getBookSubscription();
    } else {
      Utility.printLog('Something went wrong.');
      Utility.showProgress(false);
      Utility.noInternetPopup(context);
    }
  }

  _filterRetriever() async {
    try {
      final result = await InternetAddress.lookup('cheftarunabirla.com');
      if (result.isNotEmpty && result[0].rawAddress.isNotEmpty) {
        Utility.printLog('connected');
        getBookVideos();
      }
    } on SocketException catch (_) {
      Utility.printLog('not connected');
      setState(() {
        isLoading = true;
      });
      Utility.showProgress(false);
      Utility.noInternetPopup(context);
    }
  }

  @override
  void initState() {
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
      getBookVideos();
    }
    super.initState();

    Provider.of<MainContainerViewModel>(context, listen: false)
        .cart
        .forEach((element) {
      if (element.item_id == widget.book_id &&
          element.item_category == 'book-videos') {
        counter++;
      }
    });
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
              title: Text(
                "${widget.name}'s Videos",
                style: const TextStyle(
                  color: Palette.white,
                  fontSize: 18.0,
                  fontFamily: 'EuclidCircularA Medium',
                ),
              ),
              backgroundColor: Palette.appBarColor,
              elevation: 10.0,
              shadowColor: Palette.shadowColor.withOpacity(1.0),
              centerTitle: false,
            ),
            body: !isSubscriptionLoading
                ? Container()
                : list.isEmpty
                    ? Container()
                    : Container(
                        margin: const EdgeInsets.only(top: 10.0),
                        child: Column(
                          children: [
                            const SizedBox(
                              height: 5.0,
                            ),
                            subscribed != 0
                                ? Text(
                                    subscribed != 0
                                        ? '$daysLeft days left'
                                        : '',
                                    style: TextStyle(
                                        color: subscribed != 0
                                            ? int.parse(daysLeft) > 7
                                                ? Colors.green
                                                : Colors.redAccent
                                            : Colors.black,
                                        fontSize: subscribed != 0 ? 16.0 : 0.0,
                                        fontFamily: 'EuclidCircularA Medium'),
                                  )
                                : Container(),
                            const SizedBox(
                              height: 10.0,
                            ),
                            Expanded(
                              child: ListView.builder(
                                scrollDirection: Axis.vertical,
                                itemCount: list.length,
                                itemBuilder: (context, index) {
                                  return GestureDetector(
                                    onTap: () {
                                      if (subscribed == 1) {
                                        Navigator.push(
                                          context,
                                          MaterialPageRoute(
                                            builder: (context) => VideoWebPage(
                                                url: list[index].url),
                                          ),
                                        );
                                      }
                                    },
                                    child: Container(
                                      margin: const EdgeInsets.only(
                                          top: 5.0,
                                          bottom: 10.0,
                                          left: 24.0,
                                          right: 24.0),
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
                                            CrossAxisAlignment.center,
                                        mainAxisAlignment:
                                            MainAxisAlignment.spaceBetween,
                                        children: [
                                          Expanded(
                                            child: Padding(
                                              padding:
                                                  const EdgeInsets.symmetric(
                                                      vertical: 23.0,
                                                      horizontal: 15.0),
                                              child: Row(
                                                children: [
                                                  Text(
                                                    list[index].name,
                                                    maxLines: 2,
                                                    style: const TextStyle(
                                                        color: Colors.black,
                                                        fontSize: 16.0,
                                                        fontFamily:
                                                            'EuclidCircularA Medium'),
                                                  ),
                                                ],
                                              ),
                                            ),
                                          ),
                                          const Padding(
                                            padding: EdgeInsets.symmetric(
                                                vertical: 20.0,
                                                horizontal: 10.0),
                                            child: Icon(
                                              Icons.play_circle_outline,
                                              size: 24.0,
                                              color: Palette.black,
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                  );
                                },
                              ),
                            ),
                            subscribed == 1
                                ? Container()
                                : Container(
                                    height: 70.0,
                                    decoration: BoxDecoration(
                                      color: Colors.white,
                                      gradient: LinearGradient(
                                        colors: [
                                          Palette.primaryColor.withOpacity(0.0),
                                          Palette.primaryColor,
                                        ],
                                        begin: Alignment.topCenter,
                                        end: Alignment.bottomCenter,
                                        tileMode: TileMode.clamp,
                                      ),
                                      boxShadow: [
                                        BoxShadow(
                                          color: Palette.shadowColor
                                              .withOpacity(0.0),
                                          blurRadius: 30.0, // soften the shadow
                                          spreadRadius: 0.0, //extend the shadow
                                          offset: const Offset(
                                            0.0, // Move to right 10  horizontally
                                            0.0, // Move to bottom 10 Vertically
                                          ),
                                        ),
                                      ],
                                    ),
                                    child: Padding(
                                      padding: const EdgeInsets.symmetric(
                                          vertical: 10.0, horizontal: 24.0),
                                      child: GestureDetector(
                                        onTap: () {
                                          if (widget.book_subscribed == 0) {
                                            Utility.showSnacbar(context,
                                                "You need to purchase book also for this!! so please go back and add it to cart!!");
                                          } else {
                                            setState(() {
                                              if (counter >= 1) {
                                                Provider.of<MainContainerViewModel>(
                                                        context,
                                                        listen: false)
                                                    .cart
                                                    .removeWhere((element) =>
                                                        element.item_id ==
                                                            widget.book_id &&
                                                        element.item_category ==
                                                            'book-videos');
                                                context
                                                    .read<
                                                        MainContainerViewModel>()
                                                    .setCart(Provider.of<
                                                                MainContainerViewModel>(
                                                            context,
                                                            listen: false)
                                                        .cart);
                                                counter = 0;
                                                updateCart(
                                                    widget.book_id, 'remove');
                                              } else {
                                                var newItem = CartItem(
                                                  cart_id: '',
                                                  item_id: widget.book_id,
                                                  name: widget.name,
                                                  price: int.parse(widget
                                                      .only_video_discount_price),
                                                  cart_category: 'cart',
                                                  image_path: '',
                                                  quantity: 0,
                                                  item_category: 'course',
                                                );
                                                Provider.of<MainContainerViewModel>(
                                                        context,
                                                        listen: false)
                                                    .cart
                                                    .add(newItem);
                                                context
                                                    .read<
                                                        MainContainerViewModel>()
                                                    .setCart(Provider.of<
                                                                MainContainerViewModel>(
                                                            context,
                                                            listen: false)
                                                        .cart);
                                                counter = 1;
                                                updateCart(
                                                    widget.book_id, 'add');
                                              }
                                            });
                                          }
                                        },
                                        child: Container(
                                          decoration: BoxDecoration(
                                            borderRadius:
                                                BorderRadius.circular(10),
                                            color: Palette.contrastColor,
                                            boxShadow: [
                                              BoxShadow(
                                                color: const Color(0xffFFF0D0)
                                                    .withOpacity(0.0),
                                                blurRadius:
                                                    30.0, // soften the shadow
                                                spreadRadius:
                                                    0.0, //extend the shadow
                                                offset: const Offset(
                                                  0.0, // Move to right 10  horizontally
                                                  0.0, // Move to bottom 10 Vertically
                                                ),
                                              ),
                                            ],
                                          ),
                                          child: Center(
                                            child: Row(
                                              mainAxisAlignment:
                                                  MainAxisAlignment.center,
                                              crossAxisAlignment:
                                                  CrossAxisAlignment.center,
                                              children: [
                                                Expanded(
                                                  child: Center(
                                                    child: Text(
                                                      counter >= 1
                                                          ? 'Remove'
                                                          : 'Add to cart',
                                                      style: const TextStyle(
                                                        color: Colors.white,
                                                        fontSize: 16.0,
                                                        fontFamily:
                                                            'EuclidCircularA Medium',
                                                      ),
                                                    ),
                                                  ),
                                                ),
                                                const Padding(
                                                  padding: EdgeInsets.symmetric(
                                                      vertical: 10.0,
                                                      horizontal: 0.0),
                                                  child: VerticalDivider(
                                                    width: 2.0,
                                                    color: Colors.white70,
                                                  ),
                                                ),
                                                Expanded(
                                                  child: Center(
                                                    child: Row(
                                                      mainAxisAlignment:
                                                          MainAxisAlignment
                                                              .center,
                                                      crossAxisAlignment:
                                                          CrossAxisAlignment
                                                              .end,
                                                      children: [
                                                        Text(
                                                          'Rs ${widget.only_video_discount_price}',
                                                          style:
                                                              const TextStyle(
                                                            color: Colors.white,
                                                            fontSize: 16.0,
                                                            fontFamily:
                                                                'EuclidCircularA Medium',
                                                          ),
                                                        ),
                                                        const SizedBox(
                                                          width: 5.0,
                                                        ),
                                                        Text(
                                                          widget
                                                              .only_video_price,
                                                          style: const TextStyle(
                                                              color:
                                                                  Colors.white,
                                                              fontSize: 14.0,
                                                              fontFamily:
                                                                  'EuclidCircularA Regular',
                                                              decoration:
                                                                  TextDecoration
                                                                      .lineThrough),
                                                        ),
                                                      ],
                                                    ),
                                                  ),
                                                ),
                                              ],
                                            ),
                                          ),
                                        ),
                                      ),
                                    ),
                                  )
                          ],
                        ),
                      ),
          );
  }
}
