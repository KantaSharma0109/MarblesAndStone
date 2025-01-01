import 'dart:async';
import 'dart:io';
import 'package:http/http.dart' as http;

import 'package:cached_network_image/cached_network_image.dart';
import 'package:carousel_slider/carousel_slider.dart';
import 'package:chef_taruna_birla/common/common.dart';
import 'package:chef_taruna_birla/pages/cart/whislist_page.dart';
import 'package:chef_taruna_birla/pages/main_container.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
// import 'package:ios_insecure_screen_detector/ios_insecure_screen_detector.dart';
import 'package:material_design_icons_flutter/material_design_icons_flutter.dart';
import 'package:path_provider/path_provider.dart';
import 'package:provider/src/provider.dart';
import 'package:share_plus/share_plus.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../api/api_functions.dart';
import '../../config/config.dart';
import '../../models/cart_item.dart';
import '../../models/course.dart';
import '../../models/review.dart';
import '../../services/mysql_db_service.dart';
import '../../utils/utility.dart';
import '../../viewmodels/deepLink.dart';
import '../../viewmodels/main_container_viewmodel.dart';
import '../../widgets/image_placeholder.dart';
import '../../widgets/text_to_html.dart';
import '../cart/cart_page.dart';
import '../common/gallery_page.dart';
import '../common/video_web_player.dart';
import '../common/webview_page.dart';
import '../image/open_image.dart';

class EachCourse extends StatefulWidget {
  final String id;
  const EachCourse({
    Key? key,
    required this.id,
  }) : super(key: key);

  @override
  _EachCourseState createState() => _EachCourseState();
}

class _EachCourseState extends State<EachCourse>
    with SingleTickerProviderStateMixin {
  List<Review> reviewList = [];
  List<Videos> videosList = [];
  List<Pdf> pdfList = [];
  Course? courseData;
  bool isLoading = false;
  bool isReviewLoading = false;
  bool isSubscribed = false;
  bool isShowPopup = false;
  String shareText = '';
  int subscribedDays = 0;
  String remotePDFpath = '';
  int counter = 0;
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

  Future<void> addReviewsByCategory() async {
    Utility.showProgress(true);
    Map<String, dynamic> _getNews = await MySqlDBService().runQuery(
      requestType: RequestType.POST,
      url: '${Constants.finalUrl}/addReviews',
      body: {
        'user_id': Application.userId,
        'message': _message.text,
        'item_id': widget.id,
        'category': 'course'
      },
    );

    bool _status = _getNews['status'];
    var _data = _getNews['data'];
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

  // void _onShare(BuildContext context) async {
  //   final box = context.findRenderObject() as RenderBox?;
  //   await Share.shareFiles(
  //     [remotePDFpath],
  //     text: shareText,
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
        text: shareText,
        sharePositionOrigin: box!.localToGlobal(Offset.zero) & box.size,
      );
    }
  }

  // ADD OR REMOVE ITEM FROM CART
  Future<void> updateCart(id, value, imagePath) async {
    Utility.showProgress(true);
    Map<String, String> params = {
      'user_id': Application.userId,
      'id': id,
      'image_path': imagePath,
    };
    String url = value == 'add'
        ? '${Constants.finalUrl}/courses_api/addToCart'
        : '${Constants.finalUrl}/courses_api/removeFromCart';
    Map<String, dynamic> _postResult =
        await ApiFunctions.postApiResult(url, Application.deviceToken, params);

    bool _status = _postResult['status'];
    var _data = _postResult['data'];
    if (_status) {
      Utility.showProgress(false);
      if (_data['message'] == 'success') {
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
      } else if (_data['message'] == 'Auth_token_failure') {
        Utility.authErrorPopup(
            context,
            'Sorry for inconvenience. Their is some authentication problem regarding your account contact support: ' +
                Application.adminPhoneNumber);
      } else {
        Utility.showSnacbar(context, 'Some error occurred!!');
      }
    } else {
      Utility.printLog('Something went wrong.');
    }
  }

  Future<void> getReviewsByCategory() async {
    Utility.showProgress(true);
    setState(() {
      isReviewLoading = false;
    });
    Map<String, dynamic> _getNews = await MySqlDBService().runQuery(
      requestType: RequestType.GET,
      url: '${Constants.finalUrl}/getReviewsByItem/course/${widget.id}',
    );

    bool _status = _getNews['status'];
    var _data = _getNews['data'];
    // print(_data);
    if (_status) {
      // data loaded
      reviewList.clear();
      var jsonResult = _data[ApiKeys.data];
      if (jsonResult != null && jsonResult.toString().isNotEmpty) {
        jsonResult.forEach((review) => {
              reviewList.add(
                Review.fromJson(review),
              )
            });
      }
      setState(() => isReviewLoading = true);
      Utility.showProgress(false);
    } else {
      Utility.printLog('Something went wrong.');
      Utility.showProgress(false);
    }
  }

  Future<void> getCourse() async {
    Utility.showProgress(true);
    String url =
        '${Constants.finalUrl}/courses_api/getEachCourse?language_id=${Application.languageId}&course_id=${widget.id}&user_id=${Application.userId}';
    Map<String, dynamic> _getResult =
        await ApiFunctions.getApiResult(url, Application.deviceToken);

    bool _status = _getResult['status'];
    var _data = _getResult['data'];
    if (_status) {
      if (_data['message'] == 'no_subscription_available' ||
          _data['message'] == 'subscription_available') {
        courseData = Course.fromJson(_data[ApiKeys.course][0]);
        shareText = _data[ApiKeys.shareText].toString();
        subscribedDays = _data[ApiKeys.subscribedDays];
        isSubscribed = _data[ApiKeys.issubscribed];
        isShowPopup = _data[ApiKeys.show_popup];
        videosList.clear();
        pdfList.clear();
        _data[ApiKeys.videos].forEach((video) {
          videosList.add(Videos.fromJson(video));
        });
        _data[ApiKeys.pdf].forEach((pdf) {
          pdfList.add(Pdf.fromJson(pdf));
        });
        if (isShowPopup) {
          Utility.subscriptionEndedPopup(context);
          getCourse();
        }
      } else if (_data['message'] == 'Auth_token_failure') {
        Utility.authErrorPopup(
            context,
            'Sorry for inconvenience. Their is some authentication problem regarding your account contact support: ' +
                Application.adminPhoneNumber);
      } else {
        Utility.showSnacbar(context, 'Some error occurred!!');
      }
      setState(() {
        isLoading = true;
      });
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
        getCourse();
      }
    } on SocketException catch (_) {
      Utility.printLog('not connected');
      Utility.noInternetPopup(context);
      Utility.showProgress(false);
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
      getCourse();
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
      if (element.item_id == widget.id &&
          element.item_category == 'course' &&
          element.cart_category == 'cart') {
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
              print('each news poped');
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
                      color: Palette.black,
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
                        Utility.showSnacbar(
                            context, "Generating sharing link, Please wait!!");
                        if (remotePDFpath.isEmpty) {
                          Application.createFileOfPdfUrl(
                                  Constants.imgBackendUrl +
                                      (courseData?.image_path ?? ''))
                              .then((f) {
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
                body: !isLoading
                    ? const SizedBox()
                    : NestedScrollView(
                        headerSliverBuilder:
                            (BuildContext context, bool innerBoxIsScrolled) {
                          return <Widget>[
                            SliverToBoxAdapter(
                              child: Container(
                                color: Palette.scaffoldColor,
                                height: 350,
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    const SizedBox(
                                      height: 20.0,
                                    ),
                                    (courseData?.image_path ?? "").isEmpty &&
                                            (courseData?.promo_video ?? "")
                                                .isEmpty
                                        ? const SizedBox()
                                        : SizedBox(
                                            height: 200.0,
                                            width: double.infinity,
                                            child: !isLoading
                                                ? const Center()
                                                : CarouselSlider.builder(
                                                    options: CarouselOptions(
                                                      aspectRatio: 1 / 1,
                                                      autoPlay: false,
                                                      viewportFraction: 0.9,
                                                      autoPlayAnimationDuration:
                                                          const Duration(
                                                        milliseconds: 1000,
                                                      ),
                                                      enlargeCenterPage: false,
                                                      enableInfiniteScroll:
                                                          (courseData?.image_path ??
                                                                          "")
                                                                      .isNotEmpty &&
                                                                  (courseData?.promo_video ??
                                                                          "")
                                                                      .isNotEmpty
                                                              ? true
                                                              : false,
                                                    ),
                                                    itemCount: (courseData
                                                                        ?.image_path ??
                                                                    "")
                                                                .isNotEmpty &&
                                                            (courseData?.promo_video ??
                                                                    "")
                                                                .isNotEmpty
                                                        ? 2
                                                        : (courseData?.image_path ??
                                                                        "")
                                                                    .isNotEmpty ||
                                                                (courseData?.promo_video ??
                                                                        "")
                                                                    .isNotEmpty
                                                            ? 1
                                                            : 0,
                                                    itemBuilder: (context,
                                                        index, secondindex) {
                                                      if (index == 0) {
                                                        return Padding(
                                                          padding:
                                                              const EdgeInsets
                                                                  .only(
                                                            left: 8.0,
                                                            right: 8.0,
                                                          ),
                                                          child: ClipRRect(
                                                            borderRadius:
                                                                BorderRadius
                                                                    .circular(
                                                                        10.0),
                                                            child:
                                                                GestureDetector(
                                                              onTap: () {
                                                                if ((courseData
                                                                            ?.promo_video ??
                                                                        "")
                                                                    .isEmpty) {
                                                                  Navigator
                                                                      .push(
                                                                    context,
                                                                    MaterialPageRoute(
                                                                      builder:
                                                                          (context) =>
                                                                              OpenImage(
                                                                        url: Constants.imgBackendUrl +
                                                                            (courseData?.image_path ??
                                                                                "/"),
                                                                      ),
                                                                    ),
                                                                  );
                                                                }
                                                              },
                                                              child: Container(
                                                                decoration:
                                                                    BoxDecoration(
                                                                  borderRadius:
                                                                      BorderRadius
                                                                          .circular(
                                                                              10.0),
                                                                ),
                                                                child: (courseData?.promo_video ??
                                                                            "")
                                                                        .isEmpty
                                                                    ? CachedNetworkImage(
                                                                        imageUrl:
                                                                            Constants.imgBackendUrl +
                                                                                (courseData?.image_path ?? "/"),
                                                                        placeholder:
                                                                            (context, url) =>
                                                                                const ImagePlaceholder(),
                                                                        errorWidget: (context,
                                                                                url,
                                                                                error) =>
                                                                            const ImagePlaceholder(),
                                                                        fit: BoxFit
                                                                            .cover,
                                                                        height:
                                                                            200.0,
                                                                        width: double
                                                                            .infinity,
                                                                        alignment:
                                                                            Alignment.center,
                                                                      )
                                                                    : VideoWebPage(
                                                                        url: courseData?.promo_video ??
                                                                            "",
                                                                        isFullscreen:
                                                                            false,
                                                                      ),
                                                              ),
                                                            ),
                                                          ),
                                                        );
                                                      } else {
                                                        return Padding(
                                                          padding:
                                                              const EdgeInsets
                                                                  .only(
                                                            left: 8.0,
                                                            right: 8.0,
                                                          ),
                                                          child: ClipRRect(
                                                            borderRadius:
                                                                BorderRadius
                                                                    .circular(
                                                                        10.0),
                                                            child:
                                                                GestureDetector(
                                                              onTap: () {
                                                                Navigator.push(
                                                                  context,
                                                                  MaterialPageRoute(
                                                                    builder:
                                                                        (context) =>
                                                                            OpenImage(
                                                                      url: Constants
                                                                              .imgBackendUrl +
                                                                          (courseData?.image_path ??
                                                                              "/"),
                                                                    ),
                                                                  ),
                                                                );
                                                              },
                                                              child: Container(
                                                                decoration:
                                                                    BoxDecoration(
                                                                  borderRadius:
                                                                      BorderRadius
                                                                          .circular(
                                                                              10.0),
                                                                ),
                                                                child:
                                                                    CachedNetworkImage(
                                                                  imageUrl: Constants
                                                                          .imgBackendUrl +
                                                                      (courseData
                                                                              ?.image_path ??
                                                                          "/"),
                                                                  placeholder: (context,
                                                                          url) =>
                                                                      const ImagePlaceholder(),
                                                                  errorWidget: (context,
                                                                          url,
                                                                          error) =>
                                                                      const ImagePlaceholder(),
                                                                  fit: BoxFit
                                                                      .cover,
                                                                  height: 200.0,
                                                                  width: double
                                                                      .infinity,
                                                                  alignment:
                                                                      Alignment
                                                                          .center,
                                                                ),
                                                              ),
                                                            ),
                                                          ),
                                                        );
                                                      }
                                                    },
                                                  ),
                                          ),
                                    const SizedBox(
                                      height: 20.0,
                                    ),
                                    Padding(
                                      padding: const EdgeInsets.symmetric(
                                          vertical: 00.0, horizontal: 24.0),
                                      child: Text(
                                        courseData?.category == 'free'
                                            ? courseData?.title ?? ''
                                            : '${courseData?.title} (${courseData?.days} days)',
                                        style: const TextStyle(
                                          color: Colors.black,
                                          fontSize: 20.0,
                                          fontFamily: 'CenturyGothic',
                                        ),
                                        maxLines: 2,
                                      ),
                                    ),
                                    SizedBox(
                                      height: courseData?.category == 'free'
                                          ? 0.0
                                          : 15.0,
                                    ),
                                    courseData?.category == 'free'
                                        ? Container()
                                        : Padding(
                                            padding: const EdgeInsets.symmetric(
                                                vertical: 00.0,
                                                horizontal: 24.0),
                                            child: subscribedDays != 0
                                                ? Text(
                                                    subscribedDays != 0
                                                        ? '$subscribedDays days left'
                                                        : '',
                                                    style: TextStyle(
                                                        color: subscribedDays !=
                                                                0
                                                            ? subscribedDays > 7
                                                                ? Colors.green
                                                                : Colors
                                                                    .redAccent
                                                            : Colors.black,
                                                        fontSize:
                                                            subscribedDays != 0
                                                                ? 16.0
                                                                : 0.0,
                                                        fontFamily:
                                                            'EuclidCircularA Medium'),
                                                  )
                                                : Row(
                                                    children: [
                                                      Expanded(
                                                        child: Row(
                                                          crossAxisAlignment:
                                                              CrossAxisAlignment
                                                                  .end,
                                                          children: [
                                                            Text(
                                                              subscribedDays !=
                                                                      0
                                                                  ? ''
                                                                  : 'Rs ${courseData?.discount_price}',
                                                              style:
                                                                  const TextStyle(
                                                                color: Palette
                                                                    .black,
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
                                                                  const EdgeInsets
                                                                      .only(
                                                                      bottom:
                                                                          3.0),
                                                              child: courseData
                                                                          ?.price ==
                                                                      courseData
                                                                          ?.discount_price
                                                                  ? const Text(
                                                                      '')
                                                                  : Text(
                                                                      courseData
                                                                              ?.price ??
                                                                          '0',
                                                                      style: const TextStyle(
                                                                          color: Palette
                                                                              .black,
                                                                          fontSize:
                                                                              16.0,
                                                                          fontFamily:
                                                                              'EuclidCircularA Regular',
                                                                          decoration:
                                                                              TextDecoration.lineThrough),
                                                                    ),
                                                            ),
                                                            const SizedBox(
                                                              width: 10.0,
                                                            ),
                                                            Padding(
                                                              padding:
                                                                  const EdgeInsets
                                                                      .only(
                                                                      bottom:
                                                                          3.0),
                                                              child: courseData
                                                                          ?.price ==
                                                                      courseData
                                                                          ?.discount_price
                                                                  ? const Text(
                                                                      '')
                                                                  : Text(
                                                                      (((int.parse(courseData?.price ?? '0') - int.parse(courseData?.discount_price ?? '0')) / (int.parse(courseData?.price ?? '0'))) * 100).toString().substring(
                                                                              0,
                                                                              4) +
                                                                          ' %',
                                                                      style:
                                                                          const TextStyle(
                                                                        color: Colors
                                                                            .green,
                                                                        fontSize:
                                                                            16.0,
                                                                        fontFamily:
                                                                            'EuclidCircularA Medium',
                                                                      ),
                                                                    ),
                                                            ),
                                                          ],
                                                        ),
                                                      ),
                                                      subscribedDays != 0
                                                          ? const SizedBox()
                                                          : GestureDetector(
                                                              onTap: () {
                                                                setState(() {
                                                                  if (counter >=
                                                                      1) {
                                                                    Provider.of<MainContainerViewModel>(context, listen: false).cart.removeWhere((element) =>
                                                                        element.item_id ==
                                                                            widget
                                                                                .id &&
                                                                        element.item_category ==
                                                                            'course' &&
                                                                        element.cart_category ==
                                                                            'cart');
                                                                    context
                                                                        .read<
                                                                            MainContainerViewModel>()
                                                                        .setCart(Provider.of<MainContainerViewModel>(context,
                                                                                listen: false)
                                                                            .cart);
                                                                    counter = 0;
                                                                    updateCart(
                                                                        widget
                                                                            .id,
                                                                        'remove',
                                                                        '');
                                                                  } else {
                                                                    var newItem =
                                                                        CartItem(
                                                                      cart_id:
                                                                          '',
                                                                      item_id:
                                                                          widget
                                                                              .id,
                                                                      name: courseData
                                                                              ?.title ??
                                                                          '',
                                                                      price: int.parse(
                                                                          courseData?.discount_price ??
                                                                              '0'),
                                                                      cart_category:
                                                                          'cart',
                                                                      image_path:
                                                                          '',
                                                                      quantity:
                                                                          0,
                                                                      item_category:
                                                                          'course',
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
                                                                        .setCart(Provider.of<MainContainerViewModel>(context,
                                                                                listen: false)
                                                                            .cart);
                                                                    counter = 1;
                                                                    updateCart(
                                                                        widget
                                                                            .id,
                                                                        'add',
                                                                        courseData?.image_path ??
                                                                            '');
                                                                  }
                                                                });
                                                              },
                                                              child: Container(
                                                                decoration:
                                                                    BoxDecoration(
                                                                  borderRadius:
                                                                      BorderRadius
                                                                          .circular(
                                                                              5),
                                                                  // color: Palette.primaryColor,
                                                                  color: Palette
                                                                      .contrastColor,
                                                                  border: Border.all(
                                                                      color: Palette
                                                                          .contrastColor,
                                                                      width:
                                                                          1.5),
                                                                  boxShadow: [
                                                                    BoxShadow(
                                                                      color: const Color(
                                                                              0xffFFF0D0)
                                                                          .withOpacity(
                                                                              0.0),
                                                                      blurRadius:
                                                                          30.0, // soften the shadow
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
                                                                child: Center(
                                                                  child:
                                                                      Padding(
                                                                    padding:
                                                                        const EdgeInsets
                                                                            .all(
                                                                            8.0),
                                                                    child: Text(
                                                                      counter ==
                                                                              0
                                                                          ? 'Add to cart'
                                                                          : 'Remove',
                                                                      style:
                                                                          const TextStyle(
                                                                        // color: Palette.contrastColor,
                                                                        color: Colors
                                                                            .white,
                                                                        fontSize:
                                                                            16.0,
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
                                  isScrollable: false,
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
                                    const SizedBox(
                                      height: 10.0,
                                    ),
                                    const Padding(
                                      padding: EdgeInsets.symmetric(
                                          vertical: 00.0, horizontal: 24.0),
                                      child: Text(
                                        'Gallery',
                                        style: TextStyle(
                                            color: Colors.black,
                                            fontSize: 20.0,
                                            fontFamily:
                                                'EuclidCircularA Medium'),
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
                                                itemCategory: 'course',
                                                itemId: widget.id,
                                              ),
                                            ),
                                          );
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
                                                    'Course gallery',
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
                                                      vertical: 0.0,
                                                      horizontal: 0.0),
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
                                            fontFamily:
                                                'EuclidCircularA Medium'),
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
                                                vertical: 23.0,
                                                horizontal: 15.0),
                                            child: Row(
                                              children: [
                                                Expanded(
                                                  child: Text(
                                                    'Course details',
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
                                                      vertical: 0.0,
                                                      horizontal: 0.0),
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
                                      height: pdfList.isEmpty ? 0.0 : 20.0,
                                    ),
                                    Padding(
                                      padding: const EdgeInsets.symmetric(
                                          vertical: 00.0, horizontal: 24.0),
                                      child: pdfList.isEmpty
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
                                    const SizedBox(
                                      height: 10.0,
                                    ),
                                    ListView.builder(
                                      shrinkWrap: true,
                                      physics:
                                          const NeverScrollableScrollPhysics(),
                                      itemCount: pdfList.length,
                                      itemBuilder: (context, index) {
                                        return GestureDetector(
                                          onTap: () async {
                                            if (isSubscribed) {
                                              Utility.printLog(
                                                  Constants.imgBackendUrl +
                                                      pdfList[index].path);
                                              if (Platform.isIOS) {
                                                if (await canLaunchUrl(
                                                    Uri.parse(Constants
                                                            .imgBackendUrl +
                                                        pdfList[index].path))) {
                                                  await launchUrl(Uri.parse(
                                                      Constants.imgBackendUrl +
                                                          pdfList[index].path));
                                                } else {
                                                  Utility.showSnacbar(context,
                                                      "Not able to download");
                                                }
                                              } else {
                                                // Application.openPdf(
                                                //     Constants.imgBackendUrl +
                                                //         pdfList[index].path,
                                                //     context);
                                                // AndroidDeviceInfo androidInfo =
                                                //     await DeviceInfoPlugin()
                                                //         .androidInfo;
                                                // if (androidInfo.version.sdkInt! <=
                                                //     29) {
                                                if (await canLaunchUrl(
                                                    Uri.parse(Constants
                                                            .imgBackendUrl +
                                                        pdfList[index].path))) {
                                                  await launchUrl(Uri.parse(
                                                      Constants.imgBackendUrl +
                                                          pdfList[index].path));
                                                } else {
                                                  Utility.showSnacbar(context,
                                                      "Not able to download");
                                                }
                                                // } else {
                                                //   Navigator.push(
                                                //     context,
                                                //     MaterialPageRoute(
                                                //       builder: (context) =>
                                                //           PdfViewPage(
                                                //         path:
                                                //             Constants.imgBackendUrl +
                                                //                 pdfList[index].path,
                                                //         filename: pdfList[index].path,
                                                //         coursename:
                                                //             courseData?.title ??
                                                //                 "course",
                                                //         isHorizontal: false,
                                                //         isCourseScreen: true,
                                                //       ),
                                                //     ),
                                                //   );
                                                // }
                                              }
                                            } else {
                                              Utility.showSnacbar(context,
                                                  'Purchase the course first');
                                            }
                                          },
                                          child: Padding(
                                            padding: const EdgeInsets.only(
                                              top: 8.0,
                                              left: 24.0,
                                              right: 24.0,
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
                                                    CrossAxisAlignment.center,
                                                mainAxisAlignment:
                                                    MainAxisAlignment
                                                        .spaceBetween,
                                                children: [
                                                  Expanded(
                                                    child: Padding(
                                                      padding:
                                                          const EdgeInsets.only(
                                                              top: 23.0,
                                                              left: 15.0,
                                                              right: 15.0,
                                                              bottom: 23.0),
                                                      child: Row(
                                                        children: [
                                                          Expanded(
                                                            child: Text(
                                                              'Course PDF ${pdfList.length > 1 ? index + 1 : ''}',
                                                              style:
                                                                  const TextStyle(
                                                                color: Colors
                                                                    .black,
                                                                fontSize: 16.0,
                                                                fontFamily:
                                                                    'EuclidCircularA Medium',
                                                              ),
                                                              maxLines: 2,
                                                            ),
                                                          ),
                                                        ],
                                                      ),
                                                    ),
                                                  ),
                                                  Padding(
                                                    padding:
                                                        EdgeInsets.symmetric(
                                                            vertical: 20.0,
                                                            horizontal: 10.0),
                                                    child: Icon(
                                                      MdiIcons
                                                          .fileDocumentOutline,
                                                      size: 24.0,
                                                    ),
                                                  ),
                                                ],
                                              ),
                                            ),
                                          ),
                                        );
                                      },
                                    ),
                                    SizedBox(
                                      height: videosList.isEmpty ? 0.0 : 20.0,
                                    ),
                                    Padding(
                                      padding: const EdgeInsets.symmetric(
                                          vertical: 00.0, horizontal: 24.0),
                                      child: videosList.isEmpty
                                          ? Container()
                                          : const Text(
                                              'Videos',
                                              style: TextStyle(
                                                  color: Colors.black,
                                                  fontSize: 20.0,
                                                  fontFamily:
                                                      'EuclidCircularA Medium'),
                                            ),
                                    ),
                                    const SizedBox(
                                      height: 10.0,
                                    ),
                                    ListView.builder(
                                      shrinkWrap: true,
                                      physics:
                                          const NeverScrollableScrollPhysics(),
                                      itemCount: videosList.length,
                                      itemBuilder: (context, index) {
                                        return GestureDetector(
                                          onTap: () {
                                            if (isSubscribed) {
                                              Navigator.push(
                                                context,
                                                MaterialPageRoute(
                                                  builder: (context) =>
                                                      VideoWebPage(
                                                    url: videosList[index].path,
                                                    isFullscreen:
                                                        videosList[index]
                                                            .isFullScreen,
                                                  ),
                                                ),
                                              );
                                            } else {
                                              Utility.showSnacbar(context,
                                                  'Purchase the course first');
                                            }
                                          },
                                          child: Padding(
                                            padding: const EdgeInsets.symmetric(
                                              vertical: 8.0,
                                              horizontal: 24.0,
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
                                                    CrossAxisAlignment.center,
                                                mainAxisAlignment:
                                                    MainAxisAlignment
                                                        .spaceBetween,
                                                children: [
                                                  Expanded(
                                                    child: Padding(
                                                      padding: const EdgeInsets
                                                          .symmetric(
                                                          vertical: 23.0,
                                                          horizontal: 15.0),
                                                      child: Row(
                                                        children: [
                                                          Expanded(
                                                            child: Text(
                                                              videosList[index]
                                                                  .name,
                                                              style:
                                                                  const TextStyle(
                                                                color: Colors
                                                                    .black,
                                                                fontSize: 16.0,
                                                                fontFamily:
                                                                    'EuclidCircularA Medium',
                                                              ),
                                                              maxLines: 2,
                                                            ),
                                                          ),
                                                        ],
                                                      ),
                                                    ),
                                                  ),
                                                  const Padding(
                                                    padding:
                                                        EdgeInsets.symmetric(
                                                            vertical: 20.0,
                                                            horizontal: 10.0),
                                                    child: Icon(
                                                      Icons.play_circle_outline,
                                                      size: 24.0,
                                                    ),
                                                  ),
                                                ],
                                              ),
                                            ),
                                          ),
                                        );
                                      },
                                    ),
                                    const SizedBox(
                                      height: 15.0,
                                    ),
                                    const Padding(
                                      padding: EdgeInsets.symmetric(
                                          vertical: 00.0, horizontal: 24.0),
                                      child: Text(
                                        'Terms & Conditions',
                                        style: TextStyle(
                                            color: Colors.black,
                                            fontSize: 20.0,
                                            fontFamily:
                                                'EuclidCircularA Medium'),
                                      ),
                                    ),
                                    const SizedBox(
                                      height: 15.0,
                                    ),
                                    Padding(
                                      padding: const EdgeInsets.symmetric(
                                        vertical: 5.0,
                                        horizontal: 24.0,
                                      ),
                                      child: GestureDetector(
                                        onTap: () {
                                          Navigator.push(
                                            context,
                                            MaterialPageRoute(
                                              builder: (context) =>
                                                  const WebviewPage(
                                                url:
                                                    'http://www.cheftarunabirla.com/tnc/',
                                                title: 'Terms & Conditions',
                                              ),
                                            ),
                                          );
                                        },
                                        child: Container(
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
                                          child: Row(
                                            crossAxisAlignment:
                                                CrossAxisAlignment.center,
                                            children: [
                                              Expanded(
                                                flex: 2,
                                                child: Padding(
                                                  padding: EdgeInsets.symmetric(
                                                      vertical: 10.0,
                                                      horizontal: 0.0),
                                                  child: CircleAvatar(
                                                    backgroundColor:
                                                        Palette.secondaryColor,
                                                    // backgroundImage: AssetImage('assets/images/blog.jpeg'),
                                                    radius: 25.0,
                                                    child: Icon(
                                                      MdiIcons
                                                          .shieldLockOutline,
                                                      color: Palette.white,
                                                    ),
                                                  ),
                                                ),
                                              ),
                                              Expanded(
                                                flex: 5,
                                                child: Padding(
                                                  padding: const EdgeInsets
                                                      .symmetric(
                                                      vertical: 0.0,
                                                      horizontal: 5.0),
                                                  child: Row(
                                                    children: const [
                                                      Text(
                                                        'Terms & Conditions',
                                                        style: TextStyle(
                                                            color: Colors.black,
                                                            fontSize: 16.0,
                                                            fontFamily:
                                                                'EuclidCircularA Medium'),
                                                      ),
                                                    ],
                                                  ),
                                                ),
                                              ),
                                              const Expanded(
                                                flex: 1,
                                                child: Padding(
                                                  padding: EdgeInsets.all(5.0),
                                                  child: Icon(
                                                    Icons.arrow_forward_ios,
                                                    size: 18.0,
                                                  ),
                                                ),
                                              ),
                                            ],
                                          ),
                                        ),
                                      ),
                                    ),
                                    const SizedBox(
                                      height: 20.0,
                                    )
                                  ],
                                ),
                              ),
                            ),
                            Container(
                              child: (courseData?.description ?? '')
                                      .contains('<')
                                  ? SingleChildScrollView(
                                      child: Column(
                                        children: [
                                          Padding(
                                            padding: const EdgeInsets.symmetric(
                                                vertical: 0.0,
                                                horizontal: 10.0),
                                            child: TextToHtml(
                                              description:
                                                  courseData?.description ?? '',
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
                                                vertical: 0.0,
                                                horizontal: 10.0),
                                            child: Text(
                                              courseData?.description ?? '',
                                              style: const TextStyle(
                                                color: Colors.black,
                                                fontSize: 16.0,
                                                fontFamily:
                                                    'EuclidCircularA Regular',
                                              ),
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                            ),
                            !isReviewLoading
                                ? const SizedBox()
                                : SingleChildScrollView(
                                    child: Column(
                                      children: [
                                        ListView.builder(
                                          shrinkWrap: true,
                                          physics:
                                              const NeverScrollableScrollPhysics(),
                                          itemCount: reviewList.length,
                                          itemBuilder: (context, index) {
                                            return Padding(
                                              padding: const EdgeInsets.only(
                                                  top: 5.0,
                                                  left: 10.0,
                                                  right: 10.0,
                                                  bottom: 5.0),
                                              child: Container(
                                                width: double.infinity,
                                                decoration: BoxDecoration(
                                                  color: Colors.white,
                                                  borderRadius:
                                                      BorderRadius.circular(
                                                          10.0),
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
                                                  padding:
                                                      const EdgeInsets.all(8.0),
                                                  child: Column(
                                                    mainAxisAlignment:
                                                        MainAxisAlignment.start,
                                                    crossAxisAlignment:
                                                        CrossAxisAlignment
                                                            .start,
                                                    children: [
                                                      Text(
                                                        reviewList[index].name,
                                                        style: const TextStyle(
                                                          color: Colors.black,
                                                          fontSize: 16.0,
                                                          fontFamily:
                                                              'EuclidCircularA Medium',
                                                        ),
                                                      ),
                                                      const SizedBox(
                                                        height: 10.0,
                                                      ),
                                                      Text(
                                                        reviewList[index]
                                                            .message,
                                                        style: const TextStyle(
                                                          color: Colors.black,
                                                          fontSize: 14.0,
                                                          fontFamily:
                                                              'EuclidCircularA Regular',
                                                        ),
                                                      ),
                                                      const SizedBox(
                                                        height: 10.0,
                                                      ),
                                                      Row(
                                                        mainAxisAlignment:
                                                            MainAxisAlignment
                                                                .end,
                                                        children: [
                                                          Text(
                                                            reviewList[index]
                                                                .date,
                                                            maxLines: 1,
                                                            textAlign:
                                                                TextAlign.end,
                                                            style:
                                                                const TextStyle(
                                                              color: Colors
                                                                  .black54,
                                                              fontSize: 12.0,
                                                              fontFamily:
                                                                  'EuclidCircularA Regular',
                                                            ),
                                                          ),
                                                        ],
                                                      ),
                                                    ],
                                                  ),
                                                ),
                                              ),
                                            );
                                          },
                                        ),
                                        Padding(
                                          padding: const EdgeInsets.only(
                                              top: 10.0,
                                              left: 10.0,
                                              right: 10.0,
                                              bottom: 5.0),
                                          child: GestureDetector(
                                            onTap: () {
                                              openMessagePopup();
                                            },
                                            child: Container(
                                              width: double.infinity,
                                              decoration: BoxDecoration(
                                                color: Colors.white,
                                                borderRadius:
                                                    BorderRadius.circular(10.0),
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
                                                padding:
                                                    const EdgeInsets.symmetric(
                                                        vertical: 10.0,
                                                        horizontal: 8.0),
                                                child: Row(
                                                  crossAxisAlignment:
                                                      CrossAxisAlignment.start,
                                                  children: [
                                                    Icon(
                                                      MdiIcons
                                                          .plusCircleOutline,
                                                      color: Palette
                                                          .secondaryColor,
                                                    ),
                                                    SizedBox(
                                                      width: 10.0,
                                                    ),
                                                    Text(
                                                      'Write a review',
                                                      style: TextStyle(
                                                        color: Colors.black,
                                                        fontSize: 16.0,
                                                        fontFamily:
                                                            'EuclidCircularA Medium',
                                                      ),
                                                    ),
                                                  ],
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
