import 'dart:async';
import 'dart:io';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:carousel_slider/carousel_slider.dart';
import 'package:chef_taruna_birla/pages/cart/whislist_page.dart';
import 'package:chef_taruna_birla/viewmodels/main_container_viewmodel.dart';
import 'package:chef_taruna_birla/widgets/image_placeholder.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
// import 'package:ios_insecure_screen_detector/ios_insecure_screen_detector.dart';
import 'package:material_design_icons_flutter/material_design_icons_flutter.dart';
import 'package:provider/provider.dart';
import 'package:share_plus/share_plus.dart';

import '../../config/config.dart';
import '../../models/cart_item.dart';
import '../../services/mysql_db_service.dart';
import '../../utils/utility.dart';
import '../../viewmodels/deepLink.dart';
import '../../widgets/text_to_html.dart';
import '../cart/cart_page.dart';
import '../common/gallery_page.dart';
import '../common/pdf_view_page.dart';
import '../image/open_image.dart';
import '../main_container.dart';
import 'book_videos_page.dart';

class EachBook extends StatefulWidget {
  final String id;
  const EachBook({
    Key? key,
    required this.id,
  }) : super(key: key);

  @override
  _EachBookState createState() => _EachBookState();
}

class _EachBookState extends State<EachBook>
    with SingleTickerProviderStateMixin {
  List<Widget> list = [];
  List<Widget> reviewList = [];
  bool isLoading = false;
  bool isReviewLoading = false;
  bool isSubscriptionLoading = false;
  bool isPDFLoading = false;
  int subscribed = 0;
  int number_of_pdf = 0;
  String pdf_url = '';
  int counter = 0;
  String remotePDFpath = "";
  String imagePath = "";
  String name = '';
  String description = '';
  String price = '';
  String discount_price = '';
  String category = '';
  String pdflink = '';
  String daysLeft = '';
  String share_url = '';
  int days = 0;
  int count = 0;
  String price_with_video = '';
  String discount_price_with_video = '';
  int video_days = 0;
  String only_video_price = '';
  String only_video_discount_price = '';
  String include_videos = '';
  String share_text = '';
  String url = Constants.finalUrl;
  final TextEditingController _message = TextEditingController();
  final TextEditingController _address = TextEditingController();
  final TextEditingController _pincode = TextEditingController();
  final TextEditingController _quantity = TextEditingController();
  TabController? _controller;
  int _selectedIndex = 0;
  // final IosInsecureScreenDetector _insecureScreenDetector =
  //     IosInsecureScreenDetector();
  bool _isCaptured = false;
  final List<Tab> myTabs = <Tab>[
    const Tab(
      child: Center(
        child: Text(
          'Content',
        ),
      ),
    ),
    const Tab(
      child: Center(
        child: Text(
          'Description',
        ),
      ),
    ),
    const Tab(
      child: Center(
        child: Text(
          'Reviews',
        ),
      ),
    ),
  ];
  // final GlobalKey<ExpansionTile> expansionTile = new GlobalKey();

  Future<void> addReviewsByCategory() async {
    Utility.showProgress(true);
    Map<String, dynamic> _getNews = await MySqlDBService().runQuery(
      requestType: RequestType.POST,
      url: '$url/addReviews',
      body: {
        'user_id': Application.userId,
        'message': _message.text,
        'item_id': widget.id,
        'category': 'book'
      },
    );

    bool _status = _getNews['status'];
    var _data = _getNews['data'];
    // print(_data);
    if (_status) {
      // data loaded
      setState(() {
        _message.text = '';
      });
      getReviewsByCategory();
      Utility.showProgress(false);
    } else {
      Utility.printLog('Something went wrong.');
      Utility.showProgress(false);
    }
  }

  Future<void> getReviewsByCategory() async {
    Utility.showProgress(true);
    setState(() {
      isReviewLoading = false;
    });
    Map<String, dynamic> _getNews = await MySqlDBService().runQuery(
      requestType: RequestType.GET,
      url:
          '$url/getReviewsByItem/book/${widget.id}?language_id=${Application.languageId}',
    );

    bool _status = _getNews['status'];
    var _data = _getNews['data'];
    // print(_data);
    if (_status) {
      // data loaded
      reviewList.clear();
      for (var i = 0; i < _data['data'].length; i++) {
        reviewList.add(
          Padding(
            padding: const EdgeInsets.only(
                top: 5.0, left: 10.0, right: 10.0, bottom: 5.0),
            child: Container(
              width: double.infinity,
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(10.0),
                boxShadow: [
                  BoxShadow(
                    color: Palette.shadowColor.withOpacity(0.1),
                    blurRadius: 5.0, // soften the shadow
                    spreadRadius: 0.0, //extend the shadow
                    offset: const Offset(
                      0.0, // Move to right 10  horizontally
                      0.0, // Move to bottom 10 Vertically
                    ),
                  ),
                ],
              ),
              child: Padding(
                padding: const EdgeInsets.all(8.0),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.start,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      _data['data'][i]['username'].toString() != 'null'
                          ? _data['data'][i]['username'].toString()
                          : 'User',
                      style: const TextStyle(
                        color: Colors.black,
                        fontSize: 16.0,
                        fontFamily: 'EuclidCircularA Medium',
                      ),
                    ),
                    const SizedBox(
                      height: 10.0,
                    ),
                    Text(
                      _data['data'][i]['message'].toString(),
                      style: const TextStyle(
                        color: Colors.black,
                        fontSize: 14.0,
                        fontFamily: 'EuclidCircularA REgular',
                      ),
                    ),
                    const SizedBox(
                      height: 10.0,
                    ),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: [
                        Text(
                          _data['data'][i]['date'].toString().substring(0, 10),
                          textAlign: TextAlign.end,
                          style: const TextStyle(
                            color: Colors.black54,
                            fontSize: 12.0,
                            fontFamily: 'EuclidCircularA REgular',
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ),
        );
      }
      reviewList.add(
        Padding(
          padding: const EdgeInsets.only(
              top: 10.0, left: 10.0, right: 10.0, bottom: 5.0),
          child: GestureDetector(
            onTap: () {
              openMessagePopup();
            },
            child: Container(
              width: double.infinity,
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(10.0),
                boxShadow: [
                  BoxShadow(
                    color: Palette.shadowColor.withOpacity(0.1),
                    blurRadius: 5.0, // soften the shadow
                    spreadRadius: 0.0, //extend the shadow
                    offset: const Offset(
                      0.0, // Move to right 10  horizontally
                      0.0, // Move to bottom 10 Vertically
                    ),
                  ),
                ],
              ),
              child: Padding(
                padding:
                    const EdgeInsets.symmetric(vertical: 10.0, horizontal: 8.0),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Icon(
                      MdiIcons.plusCircleOutline,
                      color: Palette.secondaryColor,
                    ),
                    SizedBox(
                      width: 10.0,
                    ),
                    Text(
                      'Write a review',
                      style: TextStyle(
                        color: Colors.black,
                        fontSize: 16.0,
                        fontFamily: 'EuclidCircularA Medium',
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      );
      setState(() => isReviewLoading = true);
      Utility.showProgress(false);
    } else {
      Utility.printLog('Something went wrong.');
      Utility.showProgress(false);
    }
  }

  void openCartPopup() {
    showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.black.withOpacity(0.0),
      enableDrag: false,
      builder: (BuildContext context) {
        return Padding(
          padding: MediaQuery.of(context).viewInsets,
          child: SingleChildScrollView(
            child: Container(
              height: 330,
              color: Palette.white,
              child: Column(
                children: [
                  Padding(
                    padding: const EdgeInsets.symmetric(
                        vertical: 10.0, horizontal: 10.0),
                    child: Column(
                      children: [
                        const SizedBox(
                          height: 10.0,
                        ),
                        Container(
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(10.0),
                            color: Palette.scaffoldColor,
                            boxShadow: [
                              BoxShadow(
                                color: Palette.shadowColor.withOpacity(0.1),
                                blurRadius: 5.0, // soften the shadow
                                spreadRadius: 0.0, //extend the shadow
                                offset: const Offset(
                                  0.0, // Move to right 10  horizontally
                                  0.0, // Move to bottom 10 Vertically
                                ),
                              ),
                            ],
                          ),
                          child: TextField(
                            controller: _quantity,
                            style: const TextStyle(
                              fontFamily: 'EuclidCircularA Regular',
                              color: Palette.black,
                            ),
                            autofocus: false,
                            maxLines: 1,
                            textInputAction: TextInputAction.done,
                            keyboardType: TextInputType.phone,
                            decoration: InputDecoration(
                              counterText: "",
                              prefixIcon: const Padding(
                                padding: EdgeInsets.symmetric(
                                    vertical: 12.0, horizontal: 15.0),
                                child: Text(
                                  'Q',
                                  style: TextStyle(
                                    fontFamily: 'EuclidCircularA Medium',
                                    fontSize: 18.0,
                                    color: Color(0xff828282),
                                  ),
                                ),
                              ),
                              hintText: "Enter Quantity..",
                              hintStyle: const TextStyle(
                                color: Palette.black,
                              ),
                              labelStyle: const TextStyle(
                                color: Palette.black,
                              ),
                              focusColor: Palette.contrastColor,
                              focusedBorder: OutlineInputBorder(
                                  borderSide: const BorderSide(
                                    color: Palette.black,
                                    width: 1.3,
                                  ),
                                  borderRadius: BorderRadius.circular(10.0)),
                              enabledBorder: OutlineInputBorder(
                                  borderSide: const BorderSide(
                                      color: Palette.black, width: 1.0),
                                  borderRadius: BorderRadius.circular(10.0)),
                              contentPadding: const EdgeInsets.symmetric(
                                  vertical: 8.0, horizontal: 16.0),
                              filled: true,
                              fillColor: Palette.scaffoldColor,
                            ),
                          ),
                        ),
                        const SizedBox(
                          height: 10.0,
                        ),
                        Container(
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(10.0),
                            color: Palette.scaffoldColor,
                            boxShadow: [
                              BoxShadow(
                                color: Palette.shadowColor.withOpacity(0.1),
                                blurRadius: 5.0, // soften the shadow
                                spreadRadius: 0.0, //extend the shadow
                                offset: const Offset(
                                  0.0, // Move to right 10  horizontally
                                  0.0, // Move to bottom 10 Vertically
                                ),
                              ),
                            ],
                          ),
                          child: TextField(
                            controller: _address,
                            style: const TextStyle(
                              fontFamily: 'EuclidCircularA Regular',
                              color: Palette.black,
                            ),
                            autofocus: false,
                            maxLines: 5,
                            textInputAction: TextInputAction.done,
                            decoration: InputDecoration(
                              counterText: "",
                              prefixIcon: Icon(
                                MdiIcons.mapMarkerOutline,
                              ),
                              hintText: "Type your address..",
                              hintStyle: const TextStyle(
                                color: Palette.black,
                              ),
                              labelStyle: const TextStyle(
                                color: Palette.black,
                              ),
                              focusColor: Palette.contrastColor,
                              focusedBorder: OutlineInputBorder(
                                  borderSide: const BorderSide(
                                    color: Palette.black,
                                    width: 1.3,
                                  ),
                                  borderRadius: BorderRadius.circular(10.0)),
                              enabledBorder: OutlineInputBorder(
                                  borderSide: const BorderSide(
                                      color: Palette.black, width: 1.0),
                                  borderRadius: BorderRadius.circular(10.0)),
                              contentPadding: const EdgeInsets.symmetric(
                                  vertical: 8.0, horizontal: 16.0),
                              filled: true,
                              fillColor: Palette.scaffoldColor,
                            ),
                          ),
                        ),
                        const SizedBox(
                          height: 10.0,
                        ),
                        Container(
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(10.0),
                            color: Palette.scaffoldColor,
                            boxShadow: [
                              BoxShadow(
                                color: Palette.shadowColor.withOpacity(0.1),
                                blurRadius: 5.0, // soften the shadow
                                spreadRadius: 0.0, //extend the shadow
                                offset: const Offset(
                                  0.0, // Move to right 10  horizontally
                                  0.0, // Move to bottom 10 Vertically
                                ),
                              ),
                            ],
                          ),
                          child: TextField(
                            controller: _pincode,
                            style: const TextStyle(
                              fontFamily: 'EuclidCircularA Regular',
                              color: Palette.black,
                            ),
                            autofocus: false,
                            maxLines: 1,
                            textInputAction: TextInputAction.done,
                            decoration: InputDecoration(
                              counterText: "",
                              prefixIcon: Icon(
                                MdiIcons.formTextboxPassword,
                              ),
                              hintText: "Type your pincode..",
                              hintStyle: const TextStyle(
                                color: Palette.black,
                              ),
                              labelStyle: const TextStyle(
                                color: Palette.black,
                              ),
                              focusColor: Palette.contrastColor,
                              focusedBorder: OutlineInputBorder(
                                  borderSide: const BorderSide(
                                    color: Palette.black,
                                    width: 1.3,
                                  ),
                                  borderRadius: BorderRadius.circular(10.0)),
                              enabledBorder: OutlineInputBorder(
                                  borderSide: const BorderSide(
                                      color: Palette.black, width: 1.0),
                                  borderRadius: BorderRadius.circular(10.0)),
                              contentPadding: const EdgeInsets.symmetric(
                                  vertical: 8.0, horizontal: 16.0),
                              filled: true,
                              fillColor: Palette.scaffoldColor,
                            ),
                          ),
                        ),
                        const SizedBox(
                          height: 10.0,
                        ),
                        GestureDetector(
                          onTap: () {
                            setState(() {
                              if (_quantity.text.isEmpty) {
                                Utility.showSnacbar(
                                    context, 'Enter the quantity!');
                              } else if (_pincode.text.isEmpty) {
                                Utility.showSnacbar(
                                    context, 'Enter the pincode!');
                              } else if (_address.text.isEmpty) {
                                Utility.showSnacbar(
                                    context, 'Enter the address!');
                              } else {
                                var newItem = CartItem(
                                  cart_id: '',
                                  item_id: widget.id,
                                  name: name,
                                  price: int.parse(discount_price),
                                  cart_category: 'cart',
                                  image_path: '',
                                  quantity: 0,
                                  item_category: 'book',
                                );
                                Provider.of<MainContainerViewModel>(context,
                                        listen: false)
                                    .cart
                                    .add(newItem);
                                context.read<MainContainerViewModel>().setCart(
                                    Provider.of<MainContainerViewModel>(context,
                                            listen: false)
                                        .cart);
                                updateCart(widget.id, 'add');
                                counter = 1;
                              }
                            });
                            Navigator.pop(context);
                          },
                          child: Container(
                            height: 45.0,
                            decoration: BoxDecoration(
                                color: Palette.contrastColor,
                                borderRadius: BorderRadius.circular(8.0)),
                            child: const Center(
                              child: Text(
                                'Add to cart',
                                style: TextStyle(
                                  // color: Palette.contrastColor,
                                  color: Colors.white,
                                  fontSize: 16.0,
                                  fontFamily: 'EuclidCircularA Medium',
                                ),
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(
                          height: 10.0,
                        ),
                      ],
                    ),
                  )
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  void openMessagePopup() {
    showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.black.withOpacity(0.0),
      enableDrag: false,
      builder: (BuildContext context) {
        return Padding(
          padding: MediaQuery.of(context).viewInsets,
          child: SingleChildScrollView(
            child: Container(
              height: 150,
              color: Palette.white,
              child: Column(
                children: [
                  Padding(
                    padding: const EdgeInsets.symmetric(
                        vertical: 10.0, horizontal: 10.0),
                    child: Row(
                      children: [
                        Expanded(
                          child: Container(
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(10.0),
                              color: Palette.scaffoldColor,
                              boxShadow: [
                                BoxShadow(
                                  color: Palette.shadowColor.withOpacity(0.1),
                                  blurRadius: 5.0, // soften the shadow
                                  spreadRadius: 0.0, //extend the shadow
                                  offset: const Offset(
                                    0.0, // Move to right 10  horizontally
                                    0.0, // Move to bottom 10 Vertically
                                  ),
                                ),
                              ],
                            ),
                            child: TextField(
                              controller: _message,
                              style: const TextStyle(
                                fontFamily: 'EuclidCircularA Regular',
                                color: Palette.black,
                              ),
                              autofocus: false,
                              maxLines: 5,
                              textInputAction: TextInputAction.done,
                              decoration: InputDecoration(
                                counterText: "",
                                hintText: "Type your message..",
                                hintStyle: const TextStyle(
                                  color: Palette.black,
                                ),
                                labelStyle: const TextStyle(
                                  color: Palette.black,
                                ),
                                focusColor: Palette.contrastColor,
                                focusedBorder: OutlineInputBorder(
                                    borderSide: const BorderSide(
                                      color: Palette.black,
                                      width: 1.3,
                                    ),
                                    borderRadius: BorderRadius.circular(10.0)),
                                enabledBorder: OutlineInputBorder(
                                    borderSide: const BorderSide(
                                        color: Palette.black, width: 1.0),
                                    borderRadius: BorderRadius.circular(10.0)),
                                contentPadding: const EdgeInsets.symmetric(
                                    vertical: 8.0, horizontal: 16.0),
                                filled: true,
                                fillColor: Palette.scaffoldColor,
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(
                          width: 10.0,
                        ),
                        GestureDetector(
                          onTap: () {
                            addReviewsByCategory();
                            Navigator.pop(context);
                          },
                          child: Container(
                            height: 45.0,
                            width: 45.0,
                            decoration: BoxDecoration(
                                color: Palette.contrastColor,
                                borderRadius: BorderRadius.circular(50.0)),
                            child: Center(
                              child: Icon(
                                MdiIcons.send,
                                size: 24.0,
                                color: Palette.white,
                              ),
                            ),
                          ),
                        )
                      ],
                    ),
                  )
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  void _onShare(BuildContext context) async {
    // final box = context.findRenderObject() as RenderBox?;
    // await Share.shareFiles(
    //   [remotePDFpath],
    //   text: share_text,
    //   sharePositionOrigin: box!.localToGlobal(Offset.zero) & box.size,
    // );
  }

  Future<void> updateCart(id, value) async {
    Utility.showProgress(true);
    Map<String, dynamic> _updateCart = await MySqlDBService().runQuery(
      requestType: RequestType.POST,
      url: value == 'add'
          ? '$url/users/addbooktocart'
          : '$url/users/removefromcart',
      body: {
        'user_id': Application.userId,
        'category': 'book',
        'id': id,
        'address': _address.text.isEmpty ? '' : _address.text,
        'pincode': _pincode.text.isEmpty ? '' : _pincode.text,
        'quantity': _quantity.text,
      },
    );

    bool _status = _updateCart['status'];
    var _data = _updateCart['data'];
    // Utility.printLog(_data);
    if (_status) {
      Utility.showProgress(false);
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
      url:
          '$url/users/updateBookSubscription/${widget.id}/${Application.userId}',
    );

    bool _status = _getNews['status'];
    var _data = _getNews['data'];
    // Utility.printLog(_data);
    if (_status) {
      setState(() => isSubscriptionLoading = true);
    } else {
      Utility.printLog('Something went wrong.');
    }
  }

  Future<void> getBookSubscription() async {
    Map<String, dynamic> _getNews = await MySqlDBService().runQuery(
      requestType: RequestType.GET,
      url: '$url/users/getBookSubscription/${widget.id}/${Application.userId}',
    );

    bool _status = _getNews['status'];
    var _data = _getNews['data'];
    // Utility.printLog(_data);
    if (_status) {
      if (_data['data'].length != 0) {
        var start_date = DateTime.now();
        var end_date = DateTime.parse(_data['data'][0]['end_date'].toString());
        var diff = end_date.difference(start_date);
        // Utility.printLog(diff.inDays);
        if (diff.inDays <= 0) {
          subscribed = 0;
          updateBookSubscription();
        } else if (diff.inDays > 0) {
          subscribed = 1;
          number_of_pdf = 1;
          pdf_url = pdflink;
          daysLeft = diff.inDays.toString();
          setState(() => isSubscriptionLoading = true);
        }
      } else {
        subscribed = 0;
        setState(() => isSubscriptionLoading = true);
      }
      Utility.showProgress(false);
      // getReviewsByCategory();
    } else {
      Utility.printLog('Something went wrong.');
      Utility.showProgress(false);
      Utility.databaseErrorPopup(context);
    }
  }

  Future<void> getBookImages() async {
    Map<String, dynamic> _getNews = await MySqlDBService().runQuery(
      requestType: RequestType.GET,
      url: '$url/getImages/${widget.id}',
    );

    bool _status = _getNews['status'];
    var _data = _getNews['data'];
    // Utility.printLog(_data);
    if (_status) {
      // data loaded
      if (_data['data'].length != 0) {
        imagePath =
            Constants.imgBackendUrl + _data['data'][0]['path'].toString();
      }
      for (var i = 0; i < _data['data'].length; i++) {
        list.add(
          Container(
            margin: const EdgeInsets.symmetric(vertical: 0.0, horizontal: 8.0),
            child: GestureDetector(
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
                borderRadius: BorderRadius.circular(10.0),
                child: SizedBox(
                  width: double.infinity,
                  height: 200.0,
                  child: CachedNetworkImage(
                    imageUrl: Constants.imgBackendUrl +
                        _data['data'][0]['path'].toString(),
                    placeholder: (context, url) => const ImagePlaceholder(),
                    errorWidget: (context, url, error) =>
                        const ImagePlaceholder(),
                    // fit: BoxFit.fill,
                    height: double.infinity,
                    alignment: Alignment.center,
                  ),
                ),
              ),
            ),
          ),
        );
      }
      setState(() => isLoading = true);
      getBookSubscription();
    } else {
      Utility.printLog('Something went wrong.');
      Utility.showProgress(false);
      Utility.databaseErrorPopup(context);
    }
  }

  Future<void> getBook() async {
    Utility.showProgress(true);
    setState(() {
      _address.text = Application.address;
      _quantity.text = '1';
      _pincode.text = Application.pincode;
    });
    Map<String, dynamic> _getNews = await MySqlDBService().runQuery(
      requestType: RequestType.GET,
      url:
          '$url/getUserBookbyId/${widget.id}/${Application.userId}?language_id=${Application.languageId}',
    );

    bool _status = _getNews['status'];
    var _data = _getNews['data'];
    // Utility.printLog(_data);
    if (_status) {
      setState(() {
        name = _data['data'][0]['title'].toString();
        description = _data['data'][0]['description'].toString();
        category = _data['data'][0]['category'].toString();
        price = _data['data'][0]['price'].toString();
        discount_price = _data['data'][0]['discount_price'].toString();
        pdflink = _data['data'][0]['pdf'].toString() == 'null'
            ? ''
            : _data['data'][0]['pdf'].toString();
        share_url = _data['data'][0]['share_url'].toString();
        days = _data['data'][0]['days'];
        count = _data['data'][0]['count'];
        price_with_video = _data['data'][0]['price_with_video'].toString();
        discount_price_with_video =
            _data['data'][0]['discount_price_with_video'].toString();
        video_days = _data['data'][0]['video_days'];
        only_video_price = _data['data'][0]['only_video_price'].toString();
        only_video_discount_price =
            _data['data'][0]['only_video_discount_price'].toString();
        include_videos = _data['data'][0]['include_videos'].toString();
        share_text = _data['shareText'].toString();
      });
      getBookImages();
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
        getBook();
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
      getBook();
    }
    super.initState();

    _controller = TabController(vsync: this, length: 3);

    _controller?.addListener(() {
      setState(() {
        _selectedIndex = _controller?.index ?? 0;
      });
      if (_controller?.index == 2) {
        getReviewsByCategory();
      }
    });

    Provider.of<MainContainerViewModel>(context, listen: false)
        .cart
        .forEach((element) {
      if (element.item_id == widget.id && element.item_category == 'book') {
        counter++;
      }
    });
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
            child: DefaultTabController(
              length: 3,
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
                                      borderRadius:
                                          BorderRadius.circular(50.0)),
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
                                      borderRadius:
                                          BorderRadius.circular(50.0)),
                                )
                              : const Center(),
                        )
                      ],
                    ),
                    IconButton(
                      onPressed: () {
                        // _saveFilter();
                        Utility.showSnacbar(
                            context, "Generating sharing link, Please wait!!");
                        if (remotePDFpath.isEmpty) {
                          Application.createFileOfPdfUrl(imagePath).then((f) {
                            setState(() {
                              remotePDFpath = f.path;
                            });
                            _onShare(context);
                          });
                        } else {
                          _onShare(context);
                        }
                      },
                      icon: Icon(
                        MdiIcons.shareVariant,
                        color: Palette.white,
                      ),
                    ),
                  ],
                ),
                body: NestedScrollView(
                  headerSliverBuilder:
                      (BuildContext context, bool innerBoxIsScrolled) {
                    return <Widget>[
                      SliverToBoxAdapter(
                        child: Container(
                          color: Palette.scaffoldColor,
                          height: 550,
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const SizedBox(
                                height: 20.0,
                              ),
                              list.isEmpty
                                  ? Container(
                                      height: 0.0,
                                    )
                                  : SizedBox(
                                      height: 400.0,
                                      width: double.infinity,
                                      child: !isLoading
                                          ? const Center()
                                          : CarouselSlider(
                                              options: CarouselOptions(
                                                aspectRatio: 1 / 1,
                                                autoPlay: true,
                                                viewportFraction: 0.8,
                                                autoPlayAnimationDuration:
                                                    const Duration(
                                                        milliseconds: 1500),
                                                enlargeCenterPage: false,
                                                enableInfiniteScroll:
                                                    list.length == 1
                                                        ? false
                                                        : true,
                                              ),
                                              items: list
                                                  .map(
                                                    (item) => item,
                                                  )
                                                  .toList(),
                                            ),
                                    ),
                              const SizedBox(
                                height: 20.0,
                              ),
                              Padding(
                                padding: const EdgeInsets.symmetric(
                                    vertical: 00.0, horizontal: 24.0),
                                child: Row(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Expanded(
                                      child: Text(
                                        category == 'physical'
                                            ? name
                                            : '$name ($days days)',
                                        style: const TextStyle(
                                          color: Colors.black,
                                          fontSize: 20.0,
                                          fontFamily: 'CenturyGothic',
                                        ),
                                      ),
                                    ),
                                    const SizedBox(
                                      width: 10.0,
                                    ),
                                    Container(
                                      decoration: BoxDecoration(
                                        color: Palette.secondaryColor,
                                        borderRadius:
                                            BorderRadius.circular(50.0),
                                      ),
                                      child: Padding(
                                        padding: const EdgeInsets.symmetric(
                                            vertical: 5.0, horizontal: 10.0),
                                        child: Text(
                                          category,
                                          style: const TextStyle(
                                              color: Colors.white,
                                              fontSize: 14.0,
                                              fontFamily:
                                                  'EuclidCircularA Regular'),
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              const SizedBox(
                                height: 15.0,
                              ),
                              Padding(
                                padding: const EdgeInsets.symmetric(
                                    vertical: 00.0, horizontal: 24.0),
                                child: subscribed != 0
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
                                            fontSize:
                                                subscribed != 0 ? 16.0 : 0.0,
                                            fontFamily:
                                                'EuclidCircularA Medium'),
                                      )
                                    : Row(
                                        children: [
                                          Expanded(
                                            child: Row(
                                              crossAxisAlignment:
                                                  CrossAxisAlignment.end,
                                              children: [
                                                Text(
                                                  subscribed != 0
                                                      ? ''
                                                      : 'Rs $discount_price',
                                                  style: const TextStyle(
                                                    color: Palette.black,
                                                    fontSize: 24.0,
                                                    fontFamily:
                                                        'EuclidCircularA Medium',
                                                  ),
                                                ),
                                                const SizedBox(
                                                  width: 10.0,
                                                ),
                                                Padding(
                                                  padding:
                                                      const EdgeInsets.only(
                                                          bottom: 3.0),
                                                  child: price == discount_price
                                                      ? const Text('')
                                                      : Text(
                                                          price,
                                                          style: const TextStyle(
                                                              color:
                                                                  Palette.black,
                                                              fontSize: 16.0,
                                                              fontFamily:
                                                                  'EuclidCircularA Regular',
                                                              decoration:
                                                                  TextDecoration
                                                                      .lineThrough),
                                                        ),
                                                ),
                                                const SizedBox(
                                                  width: 10.0,
                                                ),
                                                Padding(
                                                  padding:
                                                      const EdgeInsets.only(
                                                          bottom: 3.0),
                                                  child: price == discount_price
                                                      ? const Text('')
                                                      : Text(
                                                          (((int.parse(price) - int.parse(discount_price)) /
                                                                          (int.parse(
                                                                              price))) *
                                                                      100)
                                                                  .toString()
                                                                  .substring(
                                                                      0, 4) +
                                                              ' %',
                                                          style:
                                                              const TextStyle(
                                                            color: Colors.green,
                                                            fontSize: 16.0,
                                                            fontFamily:
                                                                'EuclidCircularA Medium',
                                                          ),
                                                        ),
                                                ),
                                              ],
                                            ),
                                          ),
                                          GestureDetector(
                                            onTap: () {
                                              setState(() {
                                                if (counter >= 1) {
                                                  Provider.of<MainContainerViewModel>(
                                                          context,
                                                          listen: false)
                                                      .cart
                                                      .removeWhere((element) =>
                                                          element.item_id ==
                                                              widget.id &&
                                                          element.item_category ==
                                                              'book' &&
                                                          element.cart_category ==
                                                              'cart');
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
                                                      widget.id, 'remove');
                                                } else {
                                                  if (category == 'physical') {
                                                    openCartPopup();
                                                  } else {
                                                    var newItem = CartItem(
                                                      cart_id: '',
                                                      item_id: widget.id,
                                                      name: name,
                                                      price: int.parse(
                                                          discount_price),
                                                      cart_category: 'cart',
                                                      image_path: '',
                                                      quantity: 0,
                                                      item_category: 'book',
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
                                                        widget.id, 'add');
                                                  }
                                                }
                                              });
                                            },
                                            child: Container(
                                              decoration: BoxDecoration(
                                                borderRadius:
                                                    BorderRadius.circular(5),
                                                // color: Palette.primaryColor,
                                                color: Palette.contrastColor,
                                                border: Border.all(
                                                    color:
                                                        Palette.contrastColor,
                                                    width: 1.5),
                                                boxShadow: [
                                                  BoxShadow(
                                                    color:
                                                        const Color(0xffFFF0D0)
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
                                                child: Padding(
                                                  padding:
                                                      const EdgeInsets.all(8.0),
                                                  child: Text(
                                                    counter == 0
                                                        ? 'Add to cart'
                                                        : 'Remove',
                                                    style: const TextStyle(
                                                      // color: Palette.contrastColor,
                                                      color: Colors.white,
                                                      fontSize: 16.0,
                                                      fontFamily:
                                                          'EuclidCircularA Medium',
                                                    ),
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
                        ),
                      ),
                      SliverPersistentHeader(
                        delegate: _SliverAppBarDelegate(
                          TabBar(
                            controller: _controller,
                            tabs: myTabs,
                            indicatorColor: Palette.secondaryColor,
                            // isScrollable: true,
                            unselectedLabelColor: Palette.white,
                            indicatorPadding: const EdgeInsets.symmetric(
                                vertical: 5.0, horizontal: 5.0),
                            indicatorWeight: 1.0,
                            indicatorSize: TabBarIndicatorSize.tab,
                            indicator: BoxDecoration(
                              borderRadius: BorderRadius.circular(5),
                              color: Palette.white,
                            ),
                            labelColor: Palette.contrastColor,
                            labelPadding: const EdgeInsets.only(top: 0.0),
                            onTap: (index) {
                              if (index == 2) {
                                getReviewsByCategory();
                              }
                            },
                          ),
                        ),
                        pinned: true,
                      ),
                    ];
                  },
                  body: TabBarView(
                    controller: _controller,
                    children: [
                      Container(
                        color: Palette.scaffoldColor,
                        child: SingleChildScrollView(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            mainAxisAlignment: MainAxisAlignment.start,
                            children: [
                              SizedBox(
                                height: list.isEmpty ? 0.0 : 10.0,
                              ),
                              const Padding(
                                padding: EdgeInsets.symmetric(
                                    vertical: 00.0, horizontal: 24.0),
                                child: Text(
                                  'Gallery',
                                  style: TextStyle(
                                      color: Colors.black,
                                      fontSize: 20.0,
                                      fontFamily: 'EuclidCircularA Medium'),
                                ),
                              ),
                              const SizedBox(
                                height: 15.0,
                              ),
                              Padding(
                                padding: const EdgeInsets.symmetric(
                                    vertical: 00.0, horizontal: 24.0),
                                child: GestureDetector(
                                  onTap: () {
                                    Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                        builder: (context) => GalleryPage(
                                          isItemGallery: true,
                                          itemCategory: 'book',
                                          itemId: widget.id,
                                        ),
                                      ),
                                    );
                                  },
                                  child: Container(
                                    width: double.infinity,
                                    child: Padding(
                                      padding: const EdgeInsets.symmetric(
                                          vertical: 23.0, horizontal: 15.0),
                                      child: Row(
                                        children: [
                                          Expanded(
                                            child: Text(
                                              'Book gallery',
                                              style: TextStyle(
                                                color: Colors.black,
                                                fontSize: 16.0,
                                                fontFamily:
                                                    'EuclidCircularA Medium',
                                              ),
                                            ),
                                          ),
                                          Padding(
                                            padding: EdgeInsets.symmetric(
                                                vertical: 0.0, horizontal: 0.0),
                                            child: Icon(
                                              MdiIcons.imageOutline,
                                              size: 24.0,
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
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
                                        ]),
                                  ),
                                ),
                              ),
                              const SizedBox(
                                height: 15.0,
                              ),
                              const Padding(
                                padding: EdgeInsets.symmetric(
                                    vertical: 00.0, horizontal: 24.0),
                                child: Text(
                                  'Description',
                                  style: TextStyle(
                                      color: Colors.black,
                                      fontSize: 20.0,
                                      fontFamily: 'EuclidCircularA Medium'),
                                ),
                              ),
                              const SizedBox(
                                height: 15.0,
                              ),
                              Padding(
                                padding: const EdgeInsets.symmetric(
                                    vertical: 00.0, horizontal: 24.0),
                                child: GestureDetector(
                                  onTap: () {
                                    setState(() {
                                      _controller?.index = 1;
                                    });
                                  },
                                  child: Container(
                                    width: double.infinity,
                                    child: Padding(
                                      padding: const EdgeInsets.symmetric(
                                          vertical: 23.0, horizontal: 15.0),
                                      child: Row(
                                        children: [
                                          Expanded(
                                            child: Text(
                                              'Book details',
                                              style: TextStyle(
                                                color: Colors.black,
                                                fontSize: 16.0,
                                                fontFamily:
                                                    'EuclidCircularA Medium',
                                              ),
                                            ),
                                          ),
                                          Padding(
                                            padding: EdgeInsets.symmetric(
                                                vertical: 0.0, horizontal: 0.0),
                                            child: Icon(
                                              MdiIcons.text,
                                              size: 24.0,
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
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
                                        ]),
                                  ),
                                ),
                              ),
                              SizedBox(
                                height: pdflink.isEmpty ? 0.0 : 20.0,
                              ),
                              Padding(
                                padding: const EdgeInsets.symmetric(
                                    vertical: 00.0, horizontal: 24.0),
                                child: pdflink.isEmpty
                                    ? Container()
                                    : const Text(
                                        'PDF',
                                        style: TextStyle(
                                            color: Colors.black,
                                            fontSize: 20.0,
                                            fontFamily:
                                                'EuclidCircularA Medium'),
                                      ),
                              ),
                              SizedBox(
                                height: pdflink.isEmpty ? 0.0 : 15.0,
                              ),
                              Padding(
                                padding: const EdgeInsets.symmetric(
                                    vertical: 00.0, horizontal: 24.0),
                                child: pdflink.isEmpty
                                    ? Container()
                                    : GestureDetector(
                                        onTap: () {
                                          if (subscribed != 0) {
                                            Utility.printLog(
                                                Constants.imgBackendUrl +
                                                    pdflink);
                                            Navigator.push(
                                              context,
                                              MaterialPageRoute(
                                                builder: (context) =>
                                                    PdfViewPage(
                                                  path:
                                                      Constants.imgBackendUrl +
                                                          pdflink,
                                                  isHorizontal: true,
                                                ),
                                              ),
                                            );
                                          } else {
                                            Utility.showSnacbar(context,
                                                "Purchase the book first");
                                          }
                                        },
                                        child: Container(
                                          width: double.infinity,
                                          child: Padding(
                                            padding: const EdgeInsets.symmetric(
                                                vertical: 23.0,
                                                horizontal: 15.0),
                                            child: Row(
                                              children: [
                                                Expanded(
                                                  child: Text(
                                                    'Book PDF',
                                                    style: TextStyle(
                                                      color: Palette.black,
                                                      fontSize: 16.0,
                                                      fontFamily:
                                                          'EuclidCircularA Medium',
                                                    ),
                                                  ),
                                                ),
                                                Padding(
                                                  padding: EdgeInsets.symmetric(
                                                      vertical: 0.0,
                                                      horizontal: 0.0),
                                                  child: Icon(
                                                    MdiIcons
                                                        .fileDocumentOutline,
                                                    size: 24.0,
                                                  ),
                                                ),
                                              ],
                                            ),
                                          ),
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
                                              ]),
                                        ),
                                      ),
                              ),
                              const SizedBox(
                                height: 20.0,
                              ),
                              const Padding(
                                padding: EdgeInsets.symmetric(
                                    vertical: 00.0, horizontal: 24.0),
                                child: Text(
                                  'Videos',
                                  style: TextStyle(
                                      color: Colors.black,
                                      fontSize: 20.0,
                                      fontFamily: 'EuclidCircularA Medium'),
                                ),
                              ),
                              const SizedBox(
                                height: 15.0,
                              ),
                              Padding(
                                padding: const EdgeInsets.symmetric(
                                    vertical: 00.0, horizontal: 24.0),
                                child: GestureDetector(
                                  onTap: () {
                                    Utility.printLog('videos pressed');
                                    Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                        builder: (context) => BookVideosPage(
                                          book_id: widget.id,
                                          name: name,
                                          book_subscribed: counter,
                                          only_video_price: only_video_price,
                                          only_video_discount_price:
                                              only_video_discount_price,
                                        ),
                                      ),
                                    );
                                  },
                                  child: Container(
                                    width: double.infinity,
                                    child: Padding(
                                      padding: const EdgeInsets.symmetric(
                                          vertical: 23.0, horizontal: 15.0),
                                      child: Row(
                                        children: const [
                                          Expanded(
                                            child: Text(
                                              'Videos',
                                              style: TextStyle(
                                                color: Colors.black,
                                                fontSize: 16.0,
                                                fontFamily:
                                                    'EuclidCircularA Medium',
                                              ),
                                            ),
                                          ),
                                          Padding(
                                            padding: EdgeInsets.symmetric(
                                                vertical: 0.0, horizontal: 0.0),
                                            child: Icon(
                                              Icons.play_circle_outline,
                                              size: 24.0,
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                    decoration: BoxDecoration(
                                      borderRadius: BorderRadius.circular(10.0),
                                      color: Colors.white,
                                      boxShadow: [
                                        BoxShadow(
                                          color: Palette.shadowColor
                                              .withOpacity(0.1),
                                          blurRadius: 5.0, // soften the shadow
                                          spreadRadius: 0.0, //extend the shadow
                                          offset: const Offset(
                                            0.0, // Move to right 10  horizontally
                                            0.0, // Move to bottom 10 Vertically
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                      Container(
                        child: description.contains('<')
                            ? SingleChildScrollView(
                                child: Column(
                                  children: [
                                    Padding(
                                      padding: const EdgeInsets.symmetric(
                                          vertical: 0.0, horizontal: 10.0),
                                      child: TextToHtml(
                                        description: description,
                                        textColor: Palette.black,
                                        fontSize: 16.0,
                                      ),
                                    ),
                                    const SizedBox(
                                      height: 20.0,
                                    )
                                  ],
                                ),
                              )
                            : SingleChildScrollView(
                                child: Column(
                                  children: [
                                    Padding(
                                      padding: const EdgeInsets.symmetric(
                                          vertical: 0.0, horizontal: 10.0),
                                      child: Text(
                                        description,
                                        style: const TextStyle(
                                          color: Colors.black,
                                          fontSize: 16.0,
                                          fontFamily: 'EuclidCircularA Regular',
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                      ),
                      Container(
                        child: !isReviewLoading
                            ? const Center()
                            : ListView.builder(
                                itemCount: reviewList.length,
                                itemBuilder: (context, index) {
                                  return reviewList[index];
                                },
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

class _SliverAppBarDelegate extends SliverPersistentHeaderDelegate {
  _SliverAppBarDelegate(this._tabBar);

  final TabBar _tabBar;

  @override
  double get minExtent => 65.0;
  @override
  double get maxExtent => 65.0;

  @override
  Widget build(
      BuildContext context, double shrinkOffset, bool overlapsContent) {
    return Container(
      color: Palette.scaffoldColor,
      child: Padding(
        padding: const EdgeInsets.only(
            top: 10.0, left: 10.0, right: 10.0, bottom: 10.0),
        child: Container(
          height: 50.0,
          decoration: BoxDecoration(
            color: Palette.contrastColor,
            borderRadius: BorderRadius.circular(8.0),
          ),
          child: _tabBar,
        ),
      ),
    );
  }

  @override
  bool shouldRebuild(_SliverAppBarDelegate oldDelegate) {
    return false;
  }
}
