import 'dart:io';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:chef_taruna_birla/pages/book/each_book.dart';
import 'package:chef_taruna_birla/pages/product/each_product.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
// import 'package:ios_insecure_screen_detector/ios_insecure_screen_detector.dart';
import 'package:lazy_load_scrollview/lazy_load_scrollview.dart';
import 'package:material_design_icons_flutter/material_design_icons_flutter.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../config/config.dart';
import '../../models/cart_item.dart';
import '../../services/mysql_db_service.dart';
import '../../utils/utility.dart';
import '../../viewmodels/main_container_viewmodel.dart';
import '../../widgets/image_placeholder.dart';
import '../course/each_course.dart';
import 'cart_page.dart';

class WhislistPage extends StatefulWidget {
  const WhislistPage({Key? key}) : super(key: key);

  @override
  State<WhislistPage> createState() => _WhislistPageState();
}

class _WhislistPageState extends State<WhislistPage> {
  bool isLoading = false;
  String user_id = '';
  List whislist = [];
  String url = Constants.isDevelopment
      ? Constants.devBackendUrl
      : Constants.prodBackendUrl;
  int offset = 0;
  bool isLoadingVertical = false;
  // final IosInsecureScreenDetector _insecureScreenDetector =
  //     IosInsecureScreenDetector();
  bool _isCaptured = false;

  Future<void> updateCart(id, value, category) async {
    Map<String, dynamic> _updateCart = await MySqlDBService().runQuery(
      requestType: RequestType.POST,
      url:
          value == 'add' ? '$url/users/addtocart' : '$url/users/removefromcart',
      body: {
        'user_id': user_id,
        'category': category,
        'id': id,
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
      setState(() {
        isLoading = false;
      });
      getUserWhislist();
    } else {
      Utility.printLog('Something went wrong.');
    }
  }

  Future<void> updateWhislist(id, value, category) async {
    Map<String, dynamic> _updateCart = await MySqlDBService().runQuery(
      requestType: RequestType.POST,
      url: value == 'add'
          ? '$url/users/addtowhislist'
          : '$url/users/removefromwhislist',
      body: {
        'user_id': user_id,
        'category': category,
        'id': id,
      },
    );

    bool _status = _updateCart['status'];
    var _data = _updateCart['data'];
    // print(_data);
    if (_status) {
      setState(() {
        isLoading = false;
      });
      getUserWhislist();
    } else {
      Utility.printLog('Something went wrong.');
    }
  }

  Future<void> updateCartQuantity(id, value) async {
    Map<String, dynamic> _updateCart = await MySqlDBService().runQuery(
      requestType: RequestType.POST,
      url: value == 'add'
          ? '$url/users/updatecartquantity'
          : '$url/users/subtractcartquantity',
      body: {
        'id': id,
      },
    );

    bool _status = _updateCart['status'];
    var _data = _updateCart['data'];
    // Utility.printLog(_data);
    if (_status) {
      // data loaded
      // Utility.printLog(_data);
      getUserWhislist();
    } else {
      Utility.printLog('Something went wrong.');
    }
  }

  Future<void> getUserWhislist() async {
    Utility.showProgress(true);
    SharedPreferences prefs = await SharedPreferences.getInstance();
    final userId = prefs.getString('user_id') ?? '';
    setState(() {
      user_id = userId;
    });
    Map<String, dynamic> _getNews = await MySqlDBService().runQuery(
      requestType: RequestType.GET,
      url:
          'users/getUserWhislist/$user_id/$offset?language_id=${Application.languageId}',
    );

    bool _status = _getNews['status'];
    var _data = _getNews['data'];
    Utility.printLog(_data.toString());
    if (_status) {
      if (!isLoadingVertical) {
        whislist.clear();
      }
      for (var i = 0; i < _data['data'].length; i++) {
        if (_data['data'][i]['category'].toString() == 'course') {
          whislist.add(
            CartItem(
              cart_id: _data['data'][i]['id'].toString(),
              item_id: _data['data'][i]['course_id'].toString(),
              name: _data['data'][i]['name'].toString(),
              price: int.parse(_data['data'][i]['price'].toString()),
              cart_category: _data['data'][i]['cart_category'].toString(),
              image_path: _data['data'][i]['image_path'].toString(),
              quantity: int.parse(
                _data['data'][i]['quantity'].toString(),
              ),
              item_category: _data['data'][i]['category'].toString(),
            ),
          );
        }
        if (_data['data'][i]['category'].toString() == 'product') {
          whislist.add(
            CartItem(
              cart_id: _data['data'][i]['id'].toString(),
              item_id: _data['data'][i]['product_id'].toString(),
              name: _data['data'][i]['name'].toString(),
              price: int.parse(_data['data'][i]['price'].toString()),
              cart_category: _data['data'][i]['cart_category'].toString(),
              image_path: _data['data'][i]['image_path'].toString(),
              quantity: int.parse(
                _data['data'][i]['quantity'].toString(),
              ),
              item_category: _data['data'][i]['category'].toString(),
            ),
          );
        }
        if (_data['data'][i]['category'].toString() == 'book') {
          whislist.add(
            CartItem(
              cart_id: _data['data'][i]['id'].toString(),
              item_id: _data['data'][i]['book_id'].toString(),
              name: _data['data'][i]['name'].toString(),
              price: int.parse(_data['data'][i]['price'].toString()),
              cart_category: _data['data'][i]['cart_category'].toString(),
              image_path: _data['data'][i]['image_path'].toString(),
              quantity: int.parse(
                _data['data'][i]['quantity'].toString(),
              ),
              item_category: _data['data'][i]['category'].toString(),
            ),
          );
        }
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

  _filterRetriever() async {
    try {
      final result = await InternetAddress.lookup(Constants.internetCheckUrl);
      if (result.isNotEmpty && result[0].rawAddress.isNotEmpty) {
        Utility.printLog('connected');
        getUserWhislist();
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
    if (!kIsWeb) {
      _filterRetriever();
    } else {
      getUserWhislist();
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
    getUserWhislist();
    // Add in an artificial delay
    await Future.delayed(const Duration(seconds: 1));

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
                'Whislist',
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
            body: LazyLoadScrollView(
              isLoading: isLoadingVertical,
              onEndOfPage: () {
                setState(() {
                  offset = offset + 20;
                });
                _loadMoreVertical();
              },
              child: Scrollbar(
                child: SingleChildScrollView(
                  scrollDirection: Axis.vertical,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisAlignment: MainAxisAlignment.start,
                    children: [
                      const SizedBox(
                        height: 10.0,
                      ),
                      !isLoading
                          ? Container()
                          : whislist.isEmpty
                              ? const Center(
                                  child: Text(
                                    'No items added to Whislist..',
                                    textAlign: TextAlign.center,
                                    style: TextStyle(
                                      color: Palette.black,
                                      fontSize: 14.0,
                                      fontFamily: 'EuclidCircularA Medium',
                                    ),
                                  ),
                                )
                              : LayoutBuilder(
                                  builder: (BuildContext context,
                                      BoxConstraints constraints) {
                                    return GridView.builder(
                                      physics:
                                          const NeverScrollableScrollPhysics(),
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
                                            ? 0.72
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
                                        mainAxisSpacing: 0.0,
                                        crossAxisSpacing: 18.0,
                                      ),
                                      itemCount: whislist.length,
                                      itemBuilder: (context, index) {
                                        int counter = 0;
                                        Provider.of<MainContainerViewModel>(
                                                context,
                                                listen: false)
                                            .cart
                                            .forEach((element) {
                                          if (element.item_id ==
                                                  whislist[index].item_id &&
                                              element.item_category ==
                                                  whislist[index]
                                                      .item_category &&
                                              element.cart_category == 'cart') {
                                            counter++;
                                          }
                                        });
                                        return GestureDetector(
                                          onTap: () {
                                            if (whislist[index].item_category ==
                                                'course') {
                                              Navigator.push(
                                                context,
                                                MaterialPageRoute(
                                                  builder: (context) =>
                                                      EachCourse(
                                                    id: whislist[index].item_id,
                                                  ),
                                                ),
                                              );
                                            } else if (whislist[index]
                                                    .item_category ==
                                                'product') {
                                              Navigator.push(
                                                context,
                                                MaterialPageRoute(
                                                  builder: (context) =>
                                                      EachProduct(
                                                    id: whislist[index].item_id,
                                                  ),
                                                ),
                                              );
                                            } else if (whislist[index]
                                                    .item_category ==
                                                'book') {
                                              Navigator.push(
                                                context,
                                                MaterialPageRoute(
                                                  builder: (context) =>
                                                      EachBook(
                                                    id: whislist[index].item_id,
                                                  ),
                                                ),
                                              );
                                            }
                                          },
                                          child: Container(
                                            margin: EdgeInsets.fromLTRB(
                                                index % 2 == 0 ? 24.0 : 0.0,
                                                9.0,
                                                index % 2 == 0 ? 0.0 : 24.0,
                                                9.0),
                                            decoration: BoxDecoration(
                                              borderRadius:
                                                  BorderRadius.circular(10.0),
                                              color: Palette.white,
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
                                            child: Stack(
                                              children: [
                                                Column(
                                                  crossAxisAlignment:
                                                      CrossAxisAlignment.start,
                                                  mainAxisAlignment:
                                                      MainAxisAlignment.start,
                                                  children: [
                                                    Expanded(
                                                      flex: 3,
                                                      child: Padding(
                                                        padding:
                                                            const EdgeInsets
                                                                .all(5.0),
                                                        child: ClipRRect(
                                                          borderRadius:
                                                              BorderRadius
                                                                  .circular(
                                                                      10.0),
                                                          child:
                                                              CachedNetworkImage(
                                                            imageUrl: Constants
                                                                    .imgBackendUrl +
                                                                whislist[index]
                                                                    .image_path,
                                                            placeholder: (context,
                                                                    url) =>
                                                                const ImagePlaceholder(),
                                                            errorWidget: (context,
                                                                    url,
                                                                    error) =>
                                                                const ImagePlaceholder(),
                                                            fit: BoxFit.cover,
                                                            width:
                                                                double.infinity,
                                                          ),
                                                        ),
                                                      ),
                                                    ),
                                                    Expanded(
                                                      flex: 4,
                                                      child: Column(
                                                        crossAxisAlignment:
                                                            CrossAxisAlignment
                                                                .center,
                                                        mainAxisAlignment:
                                                            MainAxisAlignment
                                                                .spaceBetween,
                                                        children: [
                                                          Padding(
                                                            padding:
                                                                const EdgeInsets
                                                                    .all(5.0),
                                                            child: Text(
                                                              whislist[index]
                                                                  .name,
                                                              textAlign:
                                                                  TextAlign
                                                                      .center,
                                                              maxLines: 2,
                                                              style:
                                                                  const TextStyle(
                                                                color: Palette
                                                                    .black,
                                                                fontSize: 16.0,
                                                                fontFamily:
                                                                    'EuclidCircularA Regular',
                                                              ),
                                                            ),
                                                          ),
                                                          Padding(
                                                            padding:
                                                                const EdgeInsets
                                                                    .all(5.0),
                                                            child: Text(
                                                              whislist[index]
                                                                          .price ==
                                                                      '0'
                                                                  ? 'Free'
                                                                  : 'Rs ${whislist[index].price}',
                                                              style:
                                                                  const TextStyle(
                                                                color: Palette
                                                                    .contrastColor,
                                                                fontSize: 20.0,
                                                                fontFamily:
                                                                    'EuclidCircularA Medium',
                                                              ),
                                                            ),
                                                          ),
                                                          const SizedBox(
                                                            height: 5.0,
                                                          ),
                                                          GestureDetector(
                                                            onTap: () {
                                                              setState(() {
                                                                if (counter >=
                                                                    1) {
                                                                  Provider.of<MainContainerViewModel>(
                                                                          context,
                                                                          listen:
                                                                              false)
                                                                      .cart
                                                                      .removeWhere((element) =>
                                                                          element.item_id == whislist[index].item_id &&
                                                                          element.item_category ==
                                                                              whislist[index]
                                                                                  .item_category &&
                                                                          element.cart_category ==
                                                                              'cart');
                                                                  context
                                                                      .read<
                                                                          MainContainerViewModel>()
                                                                      .setCart(Provider.of<MainContainerViewModel>(
                                                                              context,
                                                                              listen: false)
                                                                          .cart);
                                                                  counter = 0;
                                                                  updateCart(
                                                                      whislist[
                                                                              index]
                                                                          .item_id,
                                                                      'remove',
                                                                      whislist[
                                                                              index]
                                                                          .item_category);
                                                                } else {
                                                                  var newItem =
                                                                      CartItem(
                                                                    cart_id: '',
                                                                    item_id: whislist[
                                                                            index]
                                                                        .item_id,
                                                                    name: whislist[
                                                                            index]
                                                                        .name,
                                                                    price: whislist[
                                                                            index]
                                                                        .price,
                                                                    cart_category:
                                                                        'cart',
                                                                    image_path:
                                                                        whislist[index]
                                                                            .image_path,
                                                                    quantity: 0,
                                                                    item_category:
                                                                        whislist[index]
                                                                            .item_category,
                                                                  );
                                                                  Provider.of<MainContainerViewModel>(
                                                                          context,
                                                                          listen:
                                                                              false)
                                                                      .cart
                                                                      .add(
                                                                          newItem);
                                                                  context
                                                                      .read<
                                                                          MainContainerViewModel>()
                                                                      .setCart(Provider.of<MainContainerViewModel>(
                                                                              context,
                                                                              listen: false)
                                                                          .cart);
                                                                  counter = 1;
                                                                  updateCart(
                                                                      whislist[
                                                                              index]
                                                                          .item_id,
                                                                      'add',
                                                                      whislist[
                                                                              index]
                                                                          .item_category);
                                                                }
                                                              });
                                                            },
                                                            child: Container(
                                                              width: double
                                                                  .infinity,
                                                              decoration:
                                                                  const BoxDecoration(
                                                                color: Palette
                                                                    .secondaryColor,
                                                                borderRadius: BorderRadius.only(
                                                                    bottomLeft:
                                                                        Radius.circular(
                                                                            10.0),
                                                                    bottomRight:
                                                                        Radius.circular(
                                                                            10.0)),
                                                              ),
                                                              child: Padding(
                                                                padding:
                                                                    const EdgeInsets
                                                                        .only(
                                                                        top:
                                                                            10.0,
                                                                        bottom:
                                                                            10.0),
                                                                child: Center(
                                                                  child:
                                                                      counter >=
                                                                              1
                                                                          ? Text(
                                                                              whislist[index].price == '0' ? 'Read' : 'Remove',
                                                                              style: const TextStyle(
                                                                                color: Palette.white,
                                                                                fontSize: 14.0,
                                                                                fontFamily: 'EuclidCircularA Medium',
                                                                              ),
                                                                            )
                                                                          : Text(
                                                                              whislist[index].price == '0' ? 'Read' : 'Add to cart',
                                                                              style: const TextStyle(
                                                                                color: Palette.white,
                                                                                fontSize: 14.0,
                                                                                fontFamily: 'EuclidCircularA Medium',
                                                                              ),
                                                                            ),
                                                                ),
                                                              ),
                                                            ),
                                                          )
                                                        ],
                                                      ),
                                                    ),
                                                  ],
                                                ),
                                                Positioned(
                                                  top: 10,
                                                  right: 10,
                                                  child: GestureDetector(
                                                    onTap: () {
                                                      setState(() {
                                                        Provider.of<MainContainerViewModel>(
                                                                context,
                                                                listen: false)
                                                            .whislist
                                                            .removeWhere((element) =>
                                                                element.item_id == whislist[index].item_id &&
                                                                element.item_category ==
                                                                    whislist[
                                                                            index]
                                                                        .item_category &&
                                                                element.cart_category ==
                                                                    'whislist');
                                                        context
                                                            .read<
                                                                MainContainerViewModel>()
                                                            .setWhislist(Provider.of<
                                                                        MainContainerViewModel>(
                                                                    context,
                                                                    listen:
                                                                        false)
                                                                .whislist);
                                                        updateWhislist(
                                                            whislist[index]
                                                                .item_id,
                                                            'remove',
                                                            whislist[index]
                                                                .item_category);
                                                      });
                                                    },
                                                    child: Container(
                                                      height: 30.0,
                                                      width: 30.0,
                                                      decoration: BoxDecoration(
                                                        color: Palette.white,
                                                        borderRadius:
                                                            BorderRadius
                                                                .circular(50.0),
                                                        boxShadow: [
                                                          BoxShadow(
                                                            color: Palette
                                                                .shadowColor
                                                                .withOpacity(
                                                                    0.1),
                                                            blurRadius:
                                                                5.0, // soften the shadow
                                                            spreadRadius:
                                                                0.0, //extend the shadow
                                                            offset:
                                                                const Offset(
                                                              0.0, // Move to right 10  horizontally
                                                              0.0, // Move to bottom 10 Vertically
                                                            ),
                                                          ),
                                                        ],
                                                      ),
                                                      child: Icon(
                                                        MdiIcons.heart,
                                                        size: 20.0,
                                                        color: Palette
                                                            .contrastColor,
                                                      ),
                                                    ),
                                                  ),
                                                )
                                              ],
                                            ),
                                          ),
                                        );
                                      },
                                    );
                                  },
                                ),
                      !isLoading
                          ? Container()
                          : Container(
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
              ),
            ),
          );
  }
}
