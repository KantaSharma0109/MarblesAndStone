import 'dart:async';
import 'dart:io';
import 'package:http/http.dart' as http;

import 'package:cached_network_image/cached_network_image.dart';
import 'package:carousel_slider/carousel_slider.dart';
// import 'package:chef_taruna_birla/pages/cart/whislist_page.dart';
import 'package:chef_taruna_birla/pages/product/product_buy_page.dart';
import 'package:chef_taruna_birla/widgets/image_placeholder.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
// import 'package:ios_insecure_screen_detector/ios_insecure_screen_detector.dart';
import 'package:material_design_icons_flutter/material_design_icons_flutter.dart';
import 'package:path_provider/path_provider.dart';
import 'package:provider/provider.dart';
import 'package:share_plus/share_plus.dart';

import '../../config/config.dart';
import '../../models/products.dart';
import '../../services/mysql_db_service.dart';
import '../../utils/utility.dart';
import '../../viewmodels/deepLink.dart';
import '../../viewmodels/main_container_viewmodel.dart';
// import '../../widgets/text_to_html.dart';
// import '../cart/cart_page.dart';
import '../common/gallery_page.dart';
import '../image/open_image.dart';
import '../main_container.dart';

class EachProduct extends StatefulWidget {
  final String id;
  const EachProduct({
    Key? key,
    required this.id,
  }) : super(key: key);

  @override
  State<EachProduct> createState() => _EachProductState();
}

class _EachProductState extends State<EachProduct>
    with SingleTickerProviderStateMixin {
  bool isLoading = false;
  bool isSimiliarLoading = false;
  bool isReviewLoading = false;
  List<Widget> list = [];
  List<Products> productList = [];
  List<Widget> reviewList = [];
  String remotePDFpath = "";
  String imagePath = "";
  String name = '';
  String description = '';
  String category = '';
  String price = '';
  String discount_price = '';
  String relatedProducts = '';
  String share_url = '';
  String share_text = '';
  String url = Constants.finalUrl;
  final TextEditingController _message = TextEditingController();
  // final IosInsecureScreenDetector _insecureScreenDetector =
  //     IosInsecureScreenDetector();
  bool _isCaptured = false;
  TabController? _controller;
  int _selectedIndex = 0;
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
          'Reviews',
        ),
      ),
    ),
  ];

  // void _onShare(BuildContext context) async {
  //   final box = context.findRenderObject() as RenderBox?;
  //   await Share.shareFiles(
  //     [remotePDFpath],
  //     text: share_text,
  //     sharePositionOrigin: box!.localToGlobal(Offset.zero) & box.size,
  //   );
  // }
  void _onShare(BuildContext context) async {
    final box = context.findRenderObject() as RenderBox?;

    if (remotePDFpath.isNotEmpty) {
      // If the file is remote (download from a URL)
      final response = await http.get(Uri.parse(remotePDFpath));

      // Get a temporary directory to store the file
      final tempDir = await getTemporaryDirectory();
      final tempPath = '${tempDir.path}/shared_pdf.pdf';

      // Write the response body as a file
      final file = File(tempPath);
      await file.writeAsBytes(response.bodyBytes);

      // Now create an XFile from the downloaded file path
      final xfile = XFile(file.path);

      // Share the file
      await Share.shareXFiles(
        [xfile],
        text: share_text,
        sharePositionOrigin: box!.localToGlobal(Offset.zero) & box.size,
      );
    }
  }

  Future<void> addReviewsByCategory() async {
    Utility.showProgress(true);
    Map<String, dynamic> _getNews = await MySqlDBService().runQuery(
      requestType: RequestType.POST,
      url: '$url/addReviews',
      body: {
        'user_id': Application.userId,
        'message': _message.text,
        'item_id': widget.id,
        'category': 'product'
      },
    );

    bool _status = _getNews['status'];
    var _data = _getNews['data'];
    print(_data);
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

  Future<void> getReviewsByCategory() async {
    Utility.showProgress(true);
    setState(() {
      isReviewLoading = false;
    });

    Map<String, dynamic> _getNews = await MySqlDBService().runQuery(
      requestType: RequestType.GET,
      url: '$url/getReviewsByItem/product/${widget.id}',
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

  Future<void> updateCart(id, value) async {
    Map<String, dynamic> _updateCart = await MySqlDBService().runQuery(
      requestType: RequestType.POST,
      url: value == 'add' ? '$url/addtocart' : '$url/users/removefromcart',
      body: {
        'user_id': Application.userId,
        'category': 'product',
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
        // Navigator.push(
        //   context,
        //   MaterialPageRoute(
        //     builder: (context) => const CartPage(),
        //   ),
        // );
      }
    } else {
      Utility.printLog('Something went wrong.');
      Utility.showProgress(false);
      Utility.databaseErrorPopup(context);
    }
  }

  Future<void> getSimiliarProduct() async {
    if (relatedProducts != 'null') {
      Map<String, dynamic> _getNews = await MySqlDBService().runQuery(
        requestType: RequestType.GET,
        url: '$url/relatedProducts/$relatedProducts',
      );

      bool _status = _getNews['status'];
      var _data = _getNews['data'];
      // Utility.printLog(_data);
      if (_status) {
        for (var i = 0; i < _data['data'].length; i++) {
          productList.add(
            Products(
              id: _data['data'][i]['id'].toString(),
              name: _data['data'][i]['name'].toString(),
              description: _data['data'][i]['description'].toString(),
              c_name: _data['data'][i]['c_name'].toString(),
              category_id: _data['data'][i]['category_id'].toString(),
              price: _data['data'][i]['price'].toString(),
              discount_price: _data['data'][i]['discount_price'].toString(),
              stock: _data['data'][i]['stock'],
              image_path: _data['data'][i]['image_path'].toString(),
              share_url: _data['data'][i]['share_url'].toString(),
            ),
          );
        }
        setState(() => isSimiliarLoading = true);
        // getReviewsByCategory();
      } else {
        Utility.printLog('Something went wrong.');
        Utility.showProgress(false);
        Utility.databaseErrorPopup(context);
      }
    } else {
      // getReviewsByCategory();
    }
  }

  Future<void> getProductImages() async {
    Map<String, dynamic> _getNews = await MySqlDBService().runQuery(
      requestType: RequestType.GET,
      url: '$url/getProductImages/${widget.id}',
    );

    bool _status = _getNews['status'];
    var _data = _getNews['data'];
    // Utility.printLog(_data);
    if (_status) {
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
                              _data['data'][i]['path'].toString())),
                );
              },
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
                    fit: BoxFit.cover,
                    width: double.infinity,
                    height: 300.0,
                  ),
                ),
              ),
            ),
          ),
        );
      }
      setState(() => isLoading = true);
      Utility.showProgress(false);
      getSimiliarProduct();
    } else {
      Utility.printLog('Something went wrong.');
      Utility.showProgress(false);
      Utility.databaseErrorPopup(context);
    }
  }

  Future<void> getProduct() async {
    Map<String, dynamic> _getNews = await MySqlDBService().runQuery(
      requestType: RequestType.GET,
      url:
          '$url/getUserProductById/${widget.id}/${Application.userId}?language_id=${Application.languageId}',
    );

    bool _status = _getNews['status'];
    var _data = _getNews['data'];
    // Utility.printLog(_data);
    if (_status) {
      setState(() {
        name = _data['data'][0]['name'].toString();
        description = _data['data'][0]['description'].toString();
        category = _data['data'][0]['c_name'].toString();
        price = _data['data'][0]['price'].toString();
        discount_price = _data['data'][0]['discount_price'].toString();
        relatedProducts = _data['data'][0]['related_products_array'].toString();
        share_url = _data['data'][0]['share_url'].toString();
        share_text = _data['shareText'].toString();
      });
      getProductImages();
    } else {
      Utility.printLog('Something went wrong.');
      setState(() {
        isLoading = true;
      });
      Utility.showProgress(false);
    }
  }

  _filterRetriever() async {
    try {
      final result = await InternetAddress.lookup('cheftarunabirla.com');
      if (result.isNotEmpty && result[0].rawAddress.isNotEmpty) {
        Utility.printLog('connected');
        getProduct();
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
      getProduct();
    }
    super.initState();

    _controller = TabController(vsync: this, length: 2);

    _controller?.addListener(() {
      setState(() {
        _selectedIndex = _controller?.index ?? 0;
      });
      if (_controller?.index == 1) {
        getReviewsByCategory();
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
              length: 2,
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
                            // Navigator.push(
                            //   context,
                            //   MaterialPageRoute(
                            //     builder: (context) => const WhislistPage(),
                            //   ),
                            // );
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
                            // Navigator.push(
                            //   context,
                            //   MaterialPageRoute(
                            //     builder: (context) => const CartPage(),
                            //   ),
                            // );
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
                          height: list.isEmpty
                              ? name.length >= 20
                                  ? 160
                                  : 140
                              : name.length >= 20
                                  ? 350
                                  : 330,
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
                                      height: 200.0,
                                      width: double.infinity,
                                      child: !isLoading
                                          ? const Center()
                                          : CarouselSlider(
                                              options: CarouselOptions(
                                                aspectRatio: 1 / 1,
                                                autoPlay: false,
                                                viewportFraction: 0.9,
                                                autoPlayAnimationDuration:
                                                    const Duration(
                                                        milliseconds: 1000),
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
                                      flex: 3,
                                      child: Text(
                                        name,
                                        style: const TextStyle(
                                          color: Colors.black,
                                          fontSize: 20.0,
                                          fontFamily: 'CenturyGothic',
                                        ),
                                      ),
                                    ),
                                    const SizedBox(
                                      width: 20.0,
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
                                child: Row(
                                  children: [
                                    Expanded(
                                      child: Row(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.end,
                                        children: [
                                          Text(
                                            'Rs $discount_price',
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
                                            padding: const EdgeInsets.only(
                                                bottom: 3.0),
                                            child: price == discount_price
                                                ? const Text('')
                                                : Text(
                                                    price,
                                                    style: const TextStyle(
                                                        color: Palette.black,
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
                                            padding: const EdgeInsets.only(
                                                bottom: 3.0),
                                            child: price == discount_price
                                                ? const Text('')
                                                : Text(
                                                    (((int.parse(price) -
                                                                        int.parse(
                                                                            discount_price)) /
                                                                    (int.parse(
                                                                        price))) *
                                                                100)
                                                            .toString()
                                                            .substring(0, 4) +
                                                        ' %',
                                                    style: const TextStyle(
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
                                        Navigator.push(
                                          context,
                                          MaterialPageRoute(
                                              builder: (context) =>
                                                  ProductBuyPage(
                                                    price: discount_price,
                                                    id: widget.id,
                                                  )),
                                        );
                                      },
                                      child: Container(
                                        decoration: BoxDecoration(
                                          borderRadius:
                                              BorderRadius.circular(5),
                                          // color: Palette.primaryColor,
                                          color: Palette.contrastColor,
                                          border: Border.all(
                                              color: Palette.contrastColor,
                                              width: 1.5),
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
                                        child: const Center(
                                          child: Padding(
                                            padding: EdgeInsets.all(8.0),
                                            child: Text(
                                              'Buy Now',
                                              style: TextStyle(
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
                        child: SingleChildScrollView(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const SizedBox(
                                height: 15.0,
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
                                          itemCategory: 'product',
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
                                              'Product gallery',
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
                                height: 20.0,
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
                              description.contains('<')
                                  ? Padding(
                                      padding: const EdgeInsets.symmetric(
                                          vertical: 0.0, horizontal: 24.0),
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
                                        // child: Padding(
                                        //   padding: const EdgeInsets.all(8.0),
                                        //   child: TextToHtml(
                                        //     description: description,
                                        //     textColor: Palette.black,
                                        //     fontSize: 16.0,
                                        //   ),
                                        // ),
                                      ),
                                    )
                                  : Padding(
                                      padding: const EdgeInsets.symmetric(
                                          vertical: 0.0, horizontal: 24.0),
                                      child: Container(
                                        width: double.infinity,
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
                                        child: Padding(
                                          padding: const EdgeInsets.all(8.0),
                                          child: Text(
                                            description,
                                            style: const TextStyle(
                                              color: Colors.black,
                                              fontSize: 16.0,
                                              fontFamily:
                                                  'EuclidCircularA Regular',
                                            ),
                                          ),
                                        ),
                                      ),
                                    ),
                              const SizedBox(
                                height: 20.0,
                              ),
                              !isSimiliarLoading
                                  ? Container()
                                  : productList.isEmpty
                                      ? Container()
                                      : const Padding(
                                          padding: EdgeInsets.symmetric(
                                              vertical: 00.0, horizontal: 24.0),
                                          child: Text(
                                            'People also buy',
                                            style: TextStyle(
                                                color: Colors.black,
                                                fontSize: 20.0,
                                                fontFamily:
                                                    'EuclidCircularA Medium'),
                                          ),
                                        ),
                              SizedBox(
                                height: !isSimiliarLoading
                                    ? 0.0
                                    : productList.isEmpty
                                        ? 0.0
                                        : 15.0,
                              ),
                              !isSimiliarLoading
                                  ? Container()
                                  : productList.isEmpty
                                      ? Container()
                                      : LayoutBuilder(
                                          builder: (BuildContext context,
                                              BoxConstraints constraints) {
                                            return GridView.builder(
                                              physics:
                                                  const NeverScrollableScrollPhysics(),
                                              shrinkWrap: true,
                                              gridDelegate:
                                                  SliverGridDelegateWithFixedCrossAxisCount(
                                                crossAxisCount: constraints
                                                            .maxWidth <
                                                        576
                                                    ? 2
                                                    : constraints.maxWidth < 768
                                                        ? 3
                                                        : constraints.maxWidth <
                                                                992
                                                            ? 4
                                                            : 6,
                                                childAspectRatio: constraints
                                                            .maxWidth <
                                                        576
                                                    ? 0.72
                                                    : constraints.maxWidth < 768
                                                        ? 0.8
                                                        : constraints.maxWidth <
                                                                992
                                                            ? 0.8
                                                            : constraints
                                                                        .maxWidth <
                                                                    1024
                                                                ? 0.7
                                                                : constraints
                                                                            .maxWidth <
                                                                        1220
                                                                    ? 0.7
                                                                    : 0.9,
                                                mainAxisSpacing: 0.0,
                                                crossAxisSpacing: 18.0,
                                              ),
                                              itemCount: productList.length,
                                              itemBuilder: (context, index) {
                                                return GestureDetector(
                                                  onTap: () {
                                                    Navigator.push(
                                                      context,
                                                      MaterialPageRoute(
                                                          builder: (context) =>
                                                              EachProduct(
                                                                  id: productList[
                                                                          index]
                                                                      .id)),
                                                    );
                                                  },
                                                  child: Container(
                                                    margin: EdgeInsets.fromLTRB(
                                                        index % 2 == 0
                                                            ? 24.0
                                                            : 0.0,
                                                        9.0,
                                                        index % 2 == 0
                                                            ? 0.0
                                                            : 24.0,
                                                        9.0),
                                                    decoration: BoxDecoration(
                                                      borderRadius:
                                                          BorderRadius.circular(
                                                              10.0),
                                                      color: Palette.white,
                                                      boxShadow: [
                                                        BoxShadow(
                                                          color: Palette
                                                              .shadowColor
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
                                                              CrossAxisAlignment
                                                                  .start,
                                                          mainAxisAlignment:
                                                              MainAxisAlignment
                                                                  .start,
                                                          children: [
                                                            Expanded(
                                                              flex: 3,
                                                              child: Padding(
                                                                padding:
                                                                    const EdgeInsets
                                                                        .all(
                                                                        5.0),
                                                                child:
                                                                    GestureDetector(
                                                                  onTap: () {
                                                                    Navigator
                                                                        .push(
                                                                      context,
                                                                      MaterialPageRoute(
                                                                          builder: (context) =>
                                                                              EachProduct(id: productList[index].id)),
                                                                    );
                                                                  },
                                                                  child:
                                                                      ClipRRect(
                                                                    borderRadius:
                                                                        BorderRadius.circular(
                                                                            10.0),
                                                                    child:
                                                                        CachedNetworkImage(
                                                                      imageUrl: Constants
                                                                              .imgBackendUrl +
                                                                          productList[index]
                                                                              .image_path,
                                                                      placeholder:
                                                                          (context, url) =>
                                                                              const ImagePlaceholder(),
                                                                      errorWidget: (context,
                                                                              url,
                                                                              error) =>
                                                                          const ImagePlaceholder(),
                                                                      fit: BoxFit
                                                                          .cover,
                                                                      width: double
                                                                          .infinity,
                                                                    ),
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
                                                                            .all(
                                                                            5.0),
                                                                    child: Text(
                                                                      productList[index].name.length >
                                                                              15
                                                                          ? '${productList[index].name.substring(0, 15)}...'
                                                                          : productList[index]
                                                                              .name,
                                                                      textAlign:
                                                                          TextAlign
                                                                              .center,
                                                                      maxLines:
                                                                          1,
                                                                      style:
                                                                          const TextStyle(
                                                                        color: Palette
                                                                            .black,
                                                                        fontSize:
                                                                            16.0,
                                                                        fontFamily:
                                                                            'EuclidCircularA Regular',
                                                                      ),
                                                                    ),
                                                                  ),
                                                                  Padding(
                                                                    padding:
                                                                        const EdgeInsets
                                                                            .all(
                                                                            5.0),
                                                                    child: Text(
                                                                      'Rs ${productList[index].discount_price}',
                                                                      style:
                                                                          const TextStyle(
                                                                        color: Palette
                                                                            .contrastColor,
                                                                        fontSize:
                                                                            20.0,
                                                                        fontFamily:
                                                                            'EuclidCircularA Medium',
                                                                      ),
                                                                    ),
                                                                  ),
                                                                  Padding(
                                                                    padding:
                                                                        const EdgeInsets
                                                                            .all(
                                                                            5.0),
                                                                    child: Row(
                                                                      crossAxisAlignment:
                                                                          CrossAxisAlignment
                                                                              .center,
                                                                      mainAxisAlignment:
                                                                          MainAxisAlignment
                                                                              .center,
                                                                      children: [
                                                                        Text(
                                                                          productList[index].discount_price == productList[index].price
                                                                              ? ''
                                                                              : 'Rs ${productList[index].price}',
                                                                          style:
                                                                              const TextStyle(
                                                                            color:
                                                                                Palette.grey,
                                                                            fontSize:
                                                                                16.0,
                                                                            fontFamily:
                                                                                'EuclidCircularA Regular',
                                                                            decoration:
                                                                                TextDecoration.lineThrough,
                                                                          ),
                                                                        ),
                                                                        const SizedBox(
                                                                          width:
                                                                              10.0,
                                                                        ),
                                                                        Text(
                                                                          productList[index].discount_price == productList[index].price
                                                                              ? ''
                                                                              : '${(((int.parse(productList[index].price) - int.parse(productList[index].discount_price)) / int.parse(productList[index].price)) * 100).toString().substring(0, 4)} %',
                                                                          style:
                                                                              const TextStyle(
                                                                            color:
                                                                                Palette.discount,
                                                                            fontSize:
                                                                                16.0,
                                                                            fontFamily:
                                                                                'EuclidCircularA Medium',
                                                                          ),
                                                                        ),
                                                                      ],
                                                                    ),
                                                                  ),
                                                                  const SizedBox(
                                                                    height: 5.0,
                                                                  ),
                                                                  GestureDetector(
                                                                    onTap: () {
                                                                      Navigator
                                                                          .push(
                                                                        context,
                                                                        MaterialPageRoute(
                                                                            builder: (context) =>
                                                                                ProductBuyPage(price: productList[index].discount_price, id: productList[index].id)),
                                                                      );
                                                                    },
                                                                    child:
                                                                        Container(
                                                                      width: double
                                                                          .infinity,
                                                                      decoration:
                                                                          const BoxDecoration(
                                                                        color: Palette
                                                                            .secondaryColor,
                                                                        borderRadius: BorderRadius.only(
                                                                            bottomLeft:
                                                                                Radius.circular(10.0),
                                                                            bottomRight: Radius.circular(10.0)),
                                                                      ),
                                                                      child:
                                                                          const Padding(
                                                                        padding: EdgeInsets.only(
                                                                            top:
                                                                                10.0,
                                                                            bottom:
                                                                                10.0),
                                                                        child:
                                                                            Center(
                                                                          child:
                                                                              // counter >= 1
                                                                              // ? const Text(
                                                                              //     'Remove',
                                                                              //     style:
                                                                              //         TextStyle(
                                                                              //       color: Palette
                                                                              //           .white,
                                                                              //       fontSize:
                                                                              //           14.0,
                                                                              //       fontFamily:
                                                                              //           'EuclidCircularA Medium',
                                                                              //     ),
                                                                              //   )
                                                                              // :
                                                                              Text(
                                                                            'Buy Now',
                                                                            style:
                                                                                TextStyle(
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
                                                      ],
                                                    ),
                                                  ),
                                                );
                                              },
                                            );
                                          },
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
