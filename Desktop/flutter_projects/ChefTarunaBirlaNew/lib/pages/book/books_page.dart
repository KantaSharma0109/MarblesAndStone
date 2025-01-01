import 'dart:io';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:chef_taruna_birla/pages/cart/whislist_page.dart';
import 'package:chef_taruna_birla/widgets/image_placeholder.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
// import 'package:ios_insecure_screen_detector/ios_insecure_screen_detector.dart';
import 'package:material_design_icons_flutter/material_design_icons_flutter.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../config/config.dart';
import '../../models/book.dart';
import '../../services/mysql_db_service.dart';
import '../../utils/utility.dart';
import '../../viewmodels/main_container_viewmodel.dart';
import '../cart/cart_page.dart';
import 'each_book.dart';

class BooksPage extends StatefulWidget {
  const BooksPage({Key? key}) : super(key: key);

  @override
  _BooksPageState createState() => _BooksPageState();
}

class _BooksPageState extends State<BooksPage> {
  List booklist = [];
  bool isLoading = false;
  int offset = 0;
  String user_id = '';
  String url = Constants.finalUrl;
  // final IosInsecureScreenDetector _insecureScreenDetector =
  //     IosInsecureScreenDetector();
  bool _isCaptured = false;

  Future<void> getBooks() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    final userId = prefs.getString('user_id') ?? '';
    setState(() {
      user_id = userId;
    });
    Map<String, dynamic> _getNews = await MySqlDBService().runQuery(
      requestType: RequestType.GET,
      url: '$url/getUserBook/$user_id?language_id=${Application.languageId}2',
    );

    bool _status = _getNews['status'];
    var _data = _getNews['data'];
    // Utility.printLog(_data['data'].length);
    if (_status) {
      booklist.clear();
      for (var i = 0; i < _data['data'].length; i++) {
        booklist.add(
          Book(
            id: _data['data'][i]['id'].toString(),
            title: _data['data'][i]['title'].toString(),
            description: _data['data'][i]['description'].toString(),
            price: _data['data'][i]['price'].toString(),
            discount_price: _data['data'][i]['discount_price'].toString(),
            days: _data['data'][i]['days'],
            category: _data['data'][i]['category'].toString(),
            image_path: _data['data'][i]['image_path'].toString(),
            count: _data['data'][i]['count'],
            pdflink: _data['data'][i]['pdf'].toString() == 'null'
                ? ''
                : _data['data'][i]['pdf'].toString(),
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
      setState(() {
        isLoading = true;
      });
    } else {
      Utility.printLog('Something went wrong.');
    }
  }

  _filterRetriever() async {
    try {
      final result = await InternetAddress.lookup('cheftarunabirla.com');
      if (result.isNotEmpty && result[0].rawAddress.isNotEmpty) {
        Utility.printLog('connected');
        getBooks();
      }
    } on SocketException catch (_) {
      Utility.printLog('not connected');
      _showMyDialog();
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
    if (!kIsWeb) {
      _filterRetriever();
    } else {
      getBooks();
    }
    super.initState();
  }

  @override
  void dispose() {
    super.dispose();
  }

  Future<void> _showMyDialog() async {
    return showDialog<void>(
      context: context,
      barrierDismissible: false, // user must tap button!
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('No Internet Connection!'),
          content: SingleChildScrollView(
            child: ListBody(
              children: const <Widget>[
                Text('Please Connect to internet'),
              ],
            ),
          ),
          actions: <Widget>[
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('Ok'),
            ),
          ],
        );
      },
    );
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
                'Books',
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
              actions: [
                Stack(
                  alignment: Alignment.center,
                  clipBehavior: Clip.none,
                  children: [
                    IconButton(
                      onPressed: () {
                        // _saveFilter();
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => const WhislistPage(),
                          ),
                        );
                      },
                      icon: Icon(
                        MdiIcons.heartOutline,
                        color: Palette.appBarIconsColor,
                      ),
                    ),
                    Positioned(
                      top: 20,
                      right: 10,
                      child: context
                              .watch<MainContainerViewModel>()
                              .whislist
                              .isNotEmpty
                          ? Container(
                              height: 10.0,
                              width: 10.0,
                              decoration: BoxDecoration(
                                  color: Colors.green,
                                  borderRadius: BorderRadius.circular(50.0)),
                            )
                          : const Center(),
                    )
                  ],
                ),
                Stack(
                  alignment: Alignment.center,
                  clipBehavior: Clip.none,
                  children: [
                    IconButton(
                      onPressed: () {
                        // _saveFilter();
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => const CartPage(),
                          ),
                        );
                      },
                      icon: Icon(
                        MdiIcons.shoppingOutline,
                        color: Palette.appBarIconsColor,
                      ),
                    ),
                    Positioned(
                      top: 20,
                      right: 10,
                      child: context
                              .watch<MainContainerViewModel>()
                              .cart
                              .isNotEmpty
                          ? Container(
                              height: 10.0,
                              width: 10.0,
                              decoration: BoxDecoration(
                                  color: Colors.green,
                                  borderRadius: BorderRadius.circular(50.0)),
                            )
                          : const Center(),
                    )
                  ],
                ),
              ],
            ),
            body: !isLoading
                ? const Center(
                    child: CircularProgressIndicator(),
                  )
                : Padding(
                    padding: const EdgeInsets.symmetric(
                        vertical: 20.0, horizontal: 0),
                    child: Column(
                      children: [
                        Expanded(
                          flex: 1,
                          child: ListView.builder(
                            scrollDirection: Axis.horizontal,
                            itemBuilder: (BuildContext context, int index) {
                              int counter = 0;
                              Provider.of<MainContainerViewModel>(context,
                                      listen: false)
                                  .cart
                                  .forEach((element) {
                                if (element.item_id == booklist[index].id &&
                                    element.item_category == 'book') {
                                  counter++;
                                }
                              });
                              return Container(
                                margin: EdgeInsets.fromLTRB(
                                    index == 0 ? 24.0 : 0.0, 0.0, 20.0, 0.0),
                                width: 320.0,
                                // height: 400.0,
                                decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(10.0),
                                  color: Colors.white,
                                  boxShadow: [
                                    BoxShadow(
                                      color:
                                          Palette.shadowColor.withOpacity(0.1),
                                      blurRadius: 5.0, // soften the shadow
                                      spreadRadius: 0.0, //extend the shadow
                                      offset: const Offset(
                                        0.0, // Move to right 10  horizontally
                                        0.0, // Move to bottom 10 Vertically
                                      ),
                                    ),
                                  ],
                                ),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  mainAxisAlignment: MainAxisAlignment.start,
                                  children: [
                                    Expanded(
                                      flex: 8,
                                      child: GestureDetector(
                                        onTap: () {
                                          Navigator.push(
                                            context,
                                            MaterialPageRoute(
                                              builder: (context) => EachBook(
                                                id: booklist[index].id,
                                              ),
                                            ),
                                          );
                                        },
                                        child: Padding(
                                          padding: const EdgeInsets.all(5.0),
                                          child: ClipRRect(
                                            borderRadius:
                                                BorderRadius.circular(8.0),
                                            child: CachedNetworkImage(
                                              imageUrl: Constants
                                                      .imgBackendUrl +
                                                  booklist[index].image_path,
                                              placeholder: (context, url) =>
                                                  const ImagePlaceholder(),
                                              errorWidget:
                                                  (context, url, error) =>
                                                      const ImagePlaceholder(),
                                              fit: BoxFit.cover,
                                              width: double.infinity,
                                            ),
                                          ),
                                        ),
                                      ),
                                    ),
                                    Expanded(
                                      flex: 5,
                                      child: ClipRRect(
                                        child: Padding(
                                          padding: const EdgeInsets.all(10.0),
                                          child: Column(
                                            crossAxisAlignment:
                                                CrossAxisAlignment.start,
                                            mainAxisAlignment:
                                                MainAxisAlignment.start,
                                            children: [
                                              GestureDetector(
                                                onTap: () {
                                                  Navigator.push(
                                                    context,
                                                    MaterialPageRoute(
                                                      builder: (context) =>
                                                          EachBook(
                                                        id: booklist[index].id,
                                                      ),
                                                    ),
                                                  );
                                                },
                                                child: Text(
                                                  '${booklist[index].title} (${booklist[index].category})',
                                                  style: const TextStyle(
                                                      color: Colors.black,
                                                      fontSize: 20.0,
                                                      fontFamily:
                                                          'CenturyGothic'),
                                                ),
                                              ),
                                              const SizedBox(
                                                height: 15.0,
                                              ),
                                              GestureDetector(
                                                onTap: () {
                                                  Navigator.push(
                                                    context,
                                                    MaterialPageRoute(
                                                      builder: (context) =>
                                                          EachBook(
                                                        id: booklist[index].id,
                                                      ),
                                                    ),
                                                  );
                                                },
                                                child: Text(
                                                  '${booklist[index].description.substring(0, 250)}...',
                                                  style: const TextStyle(
                                                      color: Colors.black38,
                                                      fontSize: 16.0,
                                                      fontFamily:
                                                          'EuclidCircularA Regular'),
                                                ),
                                              ),
                                            ],
                                          ),
                                        ),
                                      ),
                                    ),
                                    Expanded(
                                      flex: 1,
                                      child: Row(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.center,
                                        mainAxisAlignment:
                                            MainAxisAlignment.end,
                                        children: [
                                          Expanded(
                                            child: Center(
                                              child: Text(
                                                'Rs ${booklist[index].discount_price}',
                                                style: const TextStyle(
                                                  color: Palette.contrastColor,
                                                  fontSize: 16.0,
                                                  fontFamily:
                                                      'EuclidCircularA Medium',
                                                ),
                                              ),
                                            ),
                                          ),
                                          Expanded(
                                            child: GestureDetector(
                                              onTap: () {
                                                // if (booklist[index].category ==
                                                //     'free') {
                                                //   Utility.printLog('its free');
                                                // } else {
                                                //   setState(() {
                                                //     if (counter >= 1) {
                                                //       Provider.of<MainContainerViewModel>(
                                                //               context,
                                                //               listen: false)
                                                //           .cart
                                                //           .removeWhere((element) =>
                                                //               element.item_id ==
                                                //                   booklist[index]
                                                //                       .id &&
                                                //               element.item_category ==
                                                //                   'book');
                                                //       context
                                                //           .read<
                                                //               MainContainerViewModel>()
                                                //           .setCart(Provider.of<
                                                //                       MainContainerViewModel>(
                                                //                   context,
                                                //                   listen: false)
                                                //               .cart);
                                                //       updateCart(booklist[index].id,
                                                //           'remove');
                                                //     } else {
                                                //       // var newObject = Cart(
                                                //       //   id: booklist[index].id,
                                                //       //   category: 'book',
                                                //       // );
                                                //       // Provider.of<MainContainerViewModel>(context,
                                                //       //         listen: false)
                                                //       //     .cart
                                                //       //     .add(newObject);
                                                //       // context
                                                //       //     .read<MainContainerViewModel>()
                                                //       //     .setCart(
                                                //       //         Provider.of<MainContainerViewModel>(
                                                //       //                 context,
                                                //       //                 listen: false)
                                                //       //             .cart);
                                                //       // updateCart(
                                                //       //     booklist[index].id, 'add');
                                                //     }
                                                //   });
                                                // }
                                                Navigator.push(
                                                  context,
                                                  MaterialPageRoute(
                                                    builder: (context) =>
                                                        EachBook(
                                                      id: booklist[index]
                                                          .id
                                                          .toString(),
                                                    ),
                                                  ),
                                                );
                                              },
                                              child:
                                                  // counter == 0
                                                  //     ?
                                                  Container(
                                                height: double.infinity,
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
                                                        style: TextStyle(
                                                          color: Colors.white,
                                                          fontSize: 16.0,
                                                          fontFamily:
                                                              'EuclidCircularA Regular',
                                                        ),
                                                      ),
                                                    ],
                                                  ),
                                                ),
                                                decoration: const BoxDecoration(
                                                  color: Palette.secondaryColor,
                                                  borderRadius:
                                                      BorderRadius.only(
                                                    topLeft:
                                                        Radius.circular(8.0),
                                                    topRight:
                                                        Radius.circular(0.0),
                                                    bottomLeft:
                                                        Radius.circular(0.0),
                                                    bottomRight:
                                                        Radius.circular(10.0),
                                                  ),
                                                ),
                                              ),
                                              // : Container(
                                              //     height: double.infinity,
                                              //     child: Center(
                                              //       child: Row(
                                              //         crossAxisAlignment:
                                              //             CrossAxisAlignment
                                              //                 .center,
                                              //         mainAxisAlignment:
                                              //             MainAxisAlignment
                                              //                 .center,
                                              //         children: const [
                                              //           Text(
                                              //             'Remove',
                                              //             style: TextStyle(
                                              //               color: Colors.white,
                                              //               fontSize: 12.0,
                                              //               fontFamily:
                                              //                   'EuclidCircularA Regular',
                                              //             ),
                                              //           ),
                                              //         ],
                                              //       ),
                                              //     ),
                                              //     decoration: const BoxDecoration(
                                              //       color: Palette.secondaryColor,
                                              //       borderRadius:
                                              //           BorderRadius.only(
                                              //         topLeft:
                                              //             Radius.circular(8.0),
                                              //         topRight:
                                              //             Radius.circular(0.0),
                                              //         bottomLeft:
                                              //             Radius.circular(0.0),
                                              //         bottomRight:
                                              //             Radius.circular(10.0),
                                              //       ),
                                              //     ),
                                              //   ),
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ],
                                ),
                              );
                            },
                            itemCount: booklist.length,
                          ),
                        ),
                      ],
                    ),
                  ),
          );
  }
}
//
// class BookCard extends StatelessWidget {
//   final String name;
//   final String image;
//   final String description;
//   final double marginleft;
//   final double marginRight;
//   final String price;
//   final String id;
//   const BookCard(
//       {Key? key,
//       required this.name,
//       required this.image,
//       required this.description,
//       required this.marginleft,
//       required this.marginRight,
//       required this.price,
//       required this.id})
//       : super(key: key);
//
//   @override
//   Widget build(BuildContext context) {
//     return Container(
//       margin: EdgeInsets.fromLTRB(marginleft, 0.0, marginRight, 0.0),
//       width: 320.0,
//       // height: 400.0,
//       decoration: BoxDecoration(
//         borderRadius: BorderRadius.circular(10.0),
//         color: Colors.white,
//         boxShadow: [
//           BoxShadow(
//             color: Color(0xffFFF0D0).withOpacity(0.9),
//             blurRadius: 30.0, // soften the shadow
//             spreadRadius: 0.0, //extend the shadow
//             offset: const Offset(
//               4.0, // Move to right 10  horizontally
//               8.0, // Move to bottom 10 Vertically
//             ),
//           ),
//         ],
//       ),
//       child: Column(
//         crossAxisAlignment: CrossAxisAlignment.start,
//         mainAxisAlignment: MainAxisAlignment.start,
//         children: [
//           Expanded(
//             flex: 8,
//             child: Padding(
//               padding: const EdgeInsets.all(5.0),
//               child: ClipRRect(
//                 borderRadius: BorderRadius.circular(8.0),
//                 child: Image.network(
//                   'https://dashboard.cheftarunabirla.com${image}',
//                   // height: 140.0,
//                   fit: BoxFit.cover,
//                   width: double.infinity,
//                 ),
//               ),
//             ),
//           ),
//           Expanded(
//             flex: 5,
//             child: ClipRRect(
//               child: Padding(
//                 padding: const EdgeInsets.all(10.0),
//                 child: Column(
//                   crossAxisAlignment: CrossAxisAlignment.start,
//                   mainAxisAlignment: MainAxisAlignment.start,
//                   children: [
//                     Text(
//                       name,
//                       style: TextStyle(
//                           color: Colors.black,
//                           fontSize: 24.0,
//                           fontFamily: 'CenturyGothic'),
//                     ),
//                     SizedBox(
//                       height: 15.0,
//                     ),
//                     Text(
//                       '${description.substring(0, 250)}...',
//                       style: TextStyle(
//                           color: Colors.black38,
//                           fontSize: 16.0,
//                           fontFamily: 'EuclidCircularA Regular'),
//                     ),
//                   ],
//                 ),
//               ),
//             ),
//           ),
//           Expanded(
//             flex: 1,
//             child: Row(
//               crossAxisAlignment: CrossAxisAlignment.center,
//               mainAxisAlignment: MainAxisAlignment.end,
//               children: [
//                 Expanded(
//                   child: Center(
//                     child: GestureDetector(
//                       onTap: () {
//                         Navigator.push(
//                           context,
//                           MaterialPageRoute(
//                             builder: (context) => EachBook(),
//                           ),
//                         );
//                       },
//                       child: Text(
//                         'Rs ${price}',
//                         style: TextStyle(
//                           color: Palette.contrastColor,
//                           fontSize: 16.0,
//                           fontFamily: 'EuclidCircularA Medium',
//                         ),
//                       ),
//                     ),
//                   ),
//                 ),
//                 Expanded(
//                   child: Container(
//                     height: double.infinity,
//                     child: Center(
//                       child: Row(
//                         crossAxisAlignment: CrossAxisAlignment.center,
//                         mainAxisAlignment: MainAxisAlignment.center,
//                         children: const [
//                           Text(
//                             'Add to cart',
//                             style: TextStyle(
//                               color: Colors.white,
//                               fontSize: 14.0,
//                               fontFamily: 'EuclidCircularA Regular',
//                             ),
//                           ),
//                           // Icon(
//                           //   Icons.add,
//                           //   color: Colors.white,
//                           //   size: 16.0,
//                           // )
//                         ],
//                       ),
//                     ),
//                     decoration: const BoxDecoration(
//                       color: Palette.contrastColor,
//                       borderRadius: BorderRadius.only(
//                         topLeft: Radius.circular(8.0),
//                         topRight: Radius.circular(0.0),
//                         bottomLeft: Radius.circular(0.0),
//                         bottomRight: Radius.circular(10.0),
//                       ),
//                     ),
//                   ),
//                 ),
//               ],
//             ),
//           ),
//         ],
//       ),
//     );
//   }
// }
