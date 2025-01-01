import 'dart:io';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:chef_taruna_birla/common/common.dart';
import 'package:chef_taruna_birla/models/cart_item.dart';
import 'package:chef_taruna_birla/pages/book/each_book.dart';
import 'package:chef_taruna_birla/pages/course/each_course.dart';
import 'package:chef_taruna_birla/pages/main_container.dart';
import 'package:chef_taruna_birla/pages/product/each_product.dart';
import 'package:chef_taruna_birla/utils/utility.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
// import 'package:ios_insecure_screen_detector/ios_insecure_screen_detector.dart';
import 'package:material_design_icons_flutter/material_design_icons_flutter.dart';
import 'package:provider/provider.dart';
// import 'package:razorpay_flutter/razorpay_flutter.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../api/api_functions.dart';
import '../../config/config.dart';
import '../../models/coupon.dart';
import '../../services/mysql_db_service.dart';
import '../../viewmodels/main_container_viewmodel.dart';
import '../../widgets/image_placeholder.dart';
import '../notifications/notification_page.dart';

class CartPage extends StatefulWidget {
  const CartPage({Key? key}) : super(key: key);

  @override
  State<CartPage> createState() => _CartPageState();
}

class _CartPageState extends State<CartPage> {
  bool isLoading = false;
  String address = '';
  String pinCode = '';
  List<CartItem> cartList = [];
  List<Coupon> availableCoupons = [];
  double sumTotal = 0;
  double paybleAmount = 0;
  double shippingCharges = 0;
  double wallet = 0;
  String appliedCouponId = '';
  String url = Constants.finalUrl;
  // final IosInsecureScreenDetector _insecureScreenDetector =
  //     IosInsecureScreenDetector();
  bool _isCaptured = false;
  Map<String, dynamic>? paymentParameter = {};
  // late Razorpay _razorpay;

  Future<void> updateCart(id, value, category) async {
    Map<String, dynamic> _updateCart = await MySqlDBService().runQuery(
      requestType: RequestType.POST,
      url:
          value == 'add' ? '$url/users/addtocart' : '$url/users/removefromcart',
      body: {
        'user_id': Application.userId,
        'category': category,
        'id': id,
      },
    );

    bool _status = _updateCart['status'];
    var _data = _updateCart['data'];
    // Utility.printLog(_data);
    if (_status) {
      getUserCart();
    } else {
      Utility.printLog('Something went wrong.');
    }
  }

  void openAvailableCouponsPopup() {
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
                height: 500,
                color: Palette.white,
                child: availableCoupons.isEmpty
                    ? const Center(
                        child: Text(
                          'No Coupons available',
                          style: TextStyle(
                            color: Palette.black,
                            fontSize: 18.0,
                            fontFamily: 'EuclidCircularA Medium',
                          ),
                        ),
                      )
                    : SingleChildScrollView(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const SizedBox(
                              height: 10.0,
                            ),
                            const Padding(
                              padding: EdgeInsets.only(
                                left: 24.0,
                                right: 24.0,
                              ),
                              child: Text(
                                'Available Coupons :',
                                style: TextStyle(
                                  color: Palette.black,
                                  fontSize: 16.0,
                                  fontFamily: 'EuclidCircularA Medium',
                                ),
                                maxLines: 1,
                              ),
                            ),
                            const SizedBox(
                              height: 10.0,
                            ),
                            ListView.builder(
                              shrinkWrap: true,
                              physics: const NeverScrollableScrollPhysics(),
                              itemCount: availableCoupons.length,
                              itemBuilder: (context, index) {
                                return Padding(
                                  padding: EdgeInsets.only(
                                    top: index == 0 ? 12.0 : 8.0,
                                    left: 24.0,
                                    right: 24.0,
                                    bottom: index == availableCoupons.length - 1
                                        ? 20.0
                                        : 0.0,
                                  ),
                                  child: GestureDetector(
                                    onTap: () {
                                      Navigator.pop(context);
                                      getUserCart(
                                          couponId: availableCoupons[index].id);
                                    },
                                    child: Container(
                                      decoration: BoxDecoration(
                                        borderRadius:
                                            BorderRadius.circular(8.0),
                                        color: availableCoupons[index].id ==
                                                appliedCouponId
                                            ? Palette.shadowColorTwo
                                            : Palette.scaffoldColor,
                                        border: Border.all(
                                            color: Palette.secondaryColor,
                                            width: 2.0),
                                      ),
                                      child: Padding(
                                        padding: const EdgeInsets.symmetric(
                                            vertical: 12.0, horizontal: 10.0),
                                        child: Column(
                                          children: [
                                            Row(
                                              mainAxisAlignment:
                                                  MainAxisAlignment
                                                      .spaceBetween,
                                              children: [
                                                Text(
                                                  availableCoupons[index]
                                                          .couponName +
                                                      ' (${availableCoupons[index].category})',
                                                  style: const TextStyle(
                                                    color: Palette.black,
                                                    fontSize: 18.0,
                                                    fontFamily:
                                                        'EuclidCircularA Medium',
                                                  ),
                                                  maxLines: 1,
                                                ),
                                                const SizedBox(
                                                  width: 10.0,
                                                ),
                                                Text(
                                                  '${availableCoupons[index].discount}%',
                                                  style: const TextStyle(
                                                    color: Palette.black,
                                                    fontSize: 18.0,
                                                    fontFamily:
                                                        'EuclidCircularA Medium',
                                                  ),
                                                  maxLines: 1,
                                                ),
                                              ],
                                            ),
                                            const SizedBox(
                                              height: 15.0,
                                            ),
                                            const Divider(
                                              height: 2.0,
                                              color: Colors.black38,
                                              indent: 0.0,
                                            ),
                                            const SizedBox(
                                              height: 10.0,
                                            ),
                                            Row(
                                              mainAxisAlignment:
                                                  MainAxisAlignment
                                                      .spaceBetween,
                                              children: [
                                                const Text(
                                                  'Total Amount:',
                                                  style: TextStyle(
                                                    color: Palette.black,
                                                    fontSize: 14.0,
                                                    fontFamily:
                                                        'EuclidCircularA Medium',
                                                  ),
                                                ),
                                                Text(
                                                  'Rs ${availableCoupons[index].totalAmount}',
                                                  style: const TextStyle(
                                                    color: Palette.black,
                                                    fontSize: 14.0,
                                                    fontFamily:
                                                        'EuclidCircularA Medium',
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
                              },
                            ),
                          ],
                        ),
                      )),
          ),
        );
      },
    );
  }

  Future<void> applePayment() async {
    Map<String, dynamic> _updateCart = await MySqlDBService().runQuery(
      requestType: RequestType.GET,
      url:
          '$url/applePayment/${Application.userId}/$sumTotal/$paybleAmount/testing/$pinCode/0',
    );

    bool _status = _updateCart['status'];
    var _data = _updateCart['data'];
    // Utility.printLog(_data);
    if (_status) {
      // data loaded
      // Utility.printLog(_data);
      double newWalletPrice = wallet - paybleAmount;
      SharedPreferences prefs = await SharedPreferences.getInstance();
      prefs.setString('wallet', newWalletPrice.toString());
      Utility.showProgress(false);
      Utility.showSnacbar(context,
          'Payment Successful!! Your remaining wallet amount is Rs.$newWalletPrice');
      await Future.delayed(const Duration(milliseconds: 1000));
      Navigator.pop(context);
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (context) => const MainContainer(),
        ),
      );
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
      getUserCart();
    } else {
      Utility.printLog('Something went wrong.');
    }
  }

  Future<void> getUserCart({String couponId = ''}) async {
    Utility.showProgress(true);
    address = Application.address;
    pinCode = Application.pincode;

    String url = couponId.isEmpty
        ? '${Constants.finalUrl}/cart_api/getUserCart?user_id=${Application.userId}'
        : '${Constants.finalUrl}/cart_api/getUserCart?user_id=${Application.userId}&couponId=$couponId';
    Map<String, dynamic> _getResult =
        await ApiFunctions.getApiResult(url, Application.deviceToken);

    bool _status = _getResult['status'];
    var _data = _getResult['data'];
    // print(_data);
    if (_status) {
      cartList.clear();
      availableCoupons.clear();
      sumTotal = double.parse(_data[ApiKeys.sumTotal].toString());
      paybleAmount = double.parse(_data[ApiKeys.paybleAmount].toString());
      shippingCharges = double.parse(_data[ApiKeys.shippingCharges].toString());
      wallet = double.parse(_data[ApiKeys.wallet].toString());
      appliedCouponId = _data[ApiKeys.appliedCouponId].toString();
      _data[ApiKeys.courseCart].forEach((cart) {
        cartList.add(CartItem.fromJson(cart));
      });
      _data[ApiKeys.productCart].forEach((cart) {
        cartList.add(CartItem.fromJson(cart));
      });
      _data[ApiKeys.bookCart].forEach((cart) {
        cartList.add(CartItem.fromJson(cart));
      });
      _data[ApiKeys.bookVideosCart].forEach((cart) {
        cartList.add(CartItem.fromJson(cart));
      });
      _data[ApiKeys.availableCoupons].forEach((coupon) {
        availableCoupons.add(Coupon.fromJson(coupon));
      });
      setState(() => isLoading = true);
      context.read<MainContainerViewModel>().setCart(cartList);
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
        getUserCart();
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
    // _razorpay = Razorpay();
    // _razorpay.on(Razorpay.EVENT_PAYMENT_SUCCESS, _handlePaymentSuccess);
    // _razorpay.on(Razorpay.EVENT_PAYMENT_ERROR, _handlePaymentError);
    // _razorpay.on(Razorpay.EVENT_EXTERNAL_WALLET, _handleExternalWallet);
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
      getUserCart();
    }
    super.initState();
  }

  @override
  void dispose() {
    // _razorpay.clear();
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
                'Cart',
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
                : cartList.isEmpty
                    ? const Center(
                        child: Text(
                          'No items in cart right now!!',
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            color: Colors.black,
                            fontSize: 18.0,
                            fontFamily: 'EuclidCircularA Medium',
                          ),
                        ),
                      )
                    : SingleChildScrollView(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const SizedBox(
                              height: 20.0,
                            ),
                            Padding(
                              padding: const EdgeInsets.symmetric(
                                  vertical: 00.0, horizontal: 24.0),
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.end,
                                children: [
                                  GestureDetector(
                                    onTap: () {
                                      Navigator.pop(context);
                                    },
                                    child: const Text(
                                      'Add More +',
                                      style: TextStyle(
                                        color: Palette.secondaryColor,
                                        fontSize: 16.0,
                                        fontFamily: 'EuclidCircularA Medium',
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            const SizedBox(
                              height: 10.0,
                            ),
                            Padding(
                              padding: const EdgeInsets.symmetric(
                                  vertical: 00.0, horizontal: 24.0),
                              child: ListView.builder(
                                shrinkWrap: true,
                                physics: const NeverScrollableScrollPhysics(),
                                itemCount: cartList.length,
                                itemBuilder: (BuildContext context, int index) {
                                  return Padding(
                                    padding: const EdgeInsets.symmetric(
                                      vertical: 5.0,
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
                                      child: Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        mainAxisAlignment:
                                            MainAxisAlignment.start,
                                        children: [
                                          SizedBox(
                                            height: 80.0,
                                            child: GestureDetector(
                                              onTap: () {
                                                if (cartList[index]
                                                        .item_category
                                                        .toString() ==
                                                    'course') {
                                                  Navigator.push(
                                                    context,
                                                    MaterialPageRoute(
                                                      builder: (context) =>
                                                          EachCourse(
                                                        id: cartList[index]
                                                            .item_id
                                                            .toString(),
                                                      ),
                                                    ),
                                                  );
                                                } else if (cartList[index]
                                                        .item_category
                                                        .toString() ==
                                                    'product') {
                                                  Navigator.push(
                                                    context,
                                                    MaterialPageRoute(
                                                      builder: (context) =>
                                                          EachProduct(
                                                        id: cartList[index]
                                                            .item_id
                                                            .toString(),
                                                      ),
                                                    ),
                                                  );
                                                } else if (cartList[index]
                                                            .item_category
                                                            .toString() ==
                                                        'book' ||
                                                    cartList[index]
                                                            .item_category
                                                            .toString() ==
                                                        'book-videos') {
                                                  Navigator.push(
                                                    context,
                                                    MaterialPageRoute(
                                                      builder: (context) =>
                                                          EachBook(
                                                        id: cartList[index]
                                                            .item_id
                                                            .toString(),
                                                      ),
                                                    ),
                                                  );
                                                }
                                              },
                                              child: Row(
                                                crossAxisAlignment:
                                                    CrossAxisAlignment.start,
                                                children: [
                                                  Expanded(
                                                    flex: 2,
                                                    child: Padding(
                                                      padding:
                                                          const EdgeInsets.all(
                                                              5.0),
                                                      child: ClipRRect(
                                                        borderRadius:
                                                            BorderRadius
                                                                .circular(8.0),
                                                        child:
                                                            CachedNetworkImage(
                                                          imageUrl: Constants
                                                                  .imgBackendUrl +
                                                              cartList[index]
                                                                  .image_path,
                                                          placeholder: (context,
                                                                  url) =>
                                                              const ImagePlaceholder(),
                                                          errorWidget: (context,
                                                                  url, error) =>
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
                                                    child: Padding(
                                                      padding:
                                                          const EdgeInsets.all(
                                                              0.0),
                                                      child: Column(
                                                        crossAxisAlignment:
                                                            CrossAxisAlignment
                                                                .start,
                                                        mainAxisAlignment:
                                                            MainAxisAlignment
                                                                .start,
                                                        children: [
                                                          const SizedBox(
                                                            height: 10.0,
                                                          ),
                                                          Padding(
                                                            padding:
                                                                const EdgeInsets
                                                                    .symmetric(
                                                                    vertical:
                                                                        0.0,
                                                                    horizontal:
                                                                        10.0),
                                                            child: Column(
                                                              crossAxisAlignment:
                                                                  CrossAxisAlignment
                                                                      .start,
                                                              mainAxisAlignment:
                                                                  MainAxisAlignment
                                                                      .start,
                                                              children: [
                                                                Row(
                                                                  crossAxisAlignment:
                                                                      CrossAxisAlignment
                                                                          .start,
                                                                  mainAxisAlignment:
                                                                      MainAxisAlignment
                                                                          .spaceBetween,
                                                                  children: [
                                                                    Expanded(
                                                                      child:
                                                                          Padding(
                                                                        padding: const EdgeInsets
                                                                            .only(
                                                                            right:
                                                                                8.0),
                                                                        child:
                                                                            Text(
                                                                          cartList[index]
                                                                              .name
                                                                              .toString(),
                                                                          maxLines:
                                                                              2,
                                                                          style: const TextStyle(
                                                                              color: Colors.black,
                                                                              fontSize: 14.0,
                                                                              fontFamily: 'EuclidCircularA Medium'),
                                                                        ),
                                                                      ),
                                                                    ),
                                                                    SizedBox(
                                                                      width: cartList[index].item_category.toString() ==
                                                                              'product'
                                                                          ? 10.0
                                                                          : 0.0,
                                                                    ),
                                                                    Text(
                                                                      cartList[index].item_category.toString() ==
                                                                              'product'
                                                                          ? ''
                                                                          : '',
                                                                      style: TextStyle(
                                                                          color: Colors
                                                                              .blue,
                                                                          fontSize: cartList[index].item_category.toString() == 'product'
                                                                              ? 14.0
                                                                              : 0.0,
                                                                          fontFamily:
                                                                              'EuclidCircularA Regular'),
                                                                    )
                                                                  ],
                                                                ),
                                                                const SizedBox(
                                                                  height: 5.0,
                                                                ),
                                                                Text(
                                                                  cartList[
                                                                          index]
                                                                      .item_category,
                                                                  style: const TextStyle(
                                                                      color: Palette
                                                                          .contrastColor,
                                                                      fontSize:
                                                                          14.0,
                                                                      fontFamily:
                                                                          'EuclidCircularA Regular'),
                                                                ),
                                                              ],
                                                            ),
                                                          ),
                                                          const SizedBox(
                                                            height: 5.0,
                                                          ),
                                                        ],
                                                      ),
                                                    ),
                                                  ),
                                                ],
                                              ),
                                            ),
                                          ),
                                          Padding(
                                            padding: const EdgeInsets.all(5.0),
                                            child: cartList[index]
                                                        .isPlusMinus ??
                                                    false
                                                ? Row(
                                                    children: [
                                                      Expanded(
                                                        child: Text(
                                                          'Rs. ${double.parse(cartList[index].price.toString()) * cartList[index].quantity}',
                                                          style: const TextStyle(
                                                              color:
                                                                  Colors.black,
                                                              fontSize: 18.0,
                                                              fontFamily:
                                                                  'EuclidCircularA Medium'),
                                                        ),
                                                      ),
                                                      GestureDetector(
                                                        onTap: () {
                                                          setState(() {
                                                            isLoading = false;
                                                          });
                                                          if (cartList[index]
                                                                  .quantity <=
                                                              1) {
                                                            // Provider.of<MainContainerViewModel>(
                                                            //         context,
                                                            //         listen: false)
                                                            //     .cart
                                                            //     .removeWhere((element) =>
                                                            //         element.item_id ==
                                                            //             cartList[
                                                            //                     index]
                                                            //                 .item_id &&
                                                            //         element.item_category ==
                                                            //             cartList[
                                                            //                     index]
                                                            //                 .item_category);
                                                            // context
                                                            //     .read<
                                                            //         MainContainerViewModel>()
                                                            //     .setCart(Provider.of<
                                                            //                 MainContainerViewModel>(
                                                            //             context,
                                                            //             listen: false)
                                                            //         .cart);
                                                            updateCart(
                                                                cartList[index]
                                                                    .item_id,
                                                                'remove',
                                                                cartList[index]
                                                                    .item_category);
                                                          } else {
                                                            updateCartQuantity(
                                                                cartList[index]
                                                                    .cart_id,
                                                                'subtract');
                                                          }
                                                        },
                                                        child: Container(
                                                          height: 30.0,
                                                          width: 30.0,
                                                          decoration:
                                                              BoxDecoration(
                                                            color: Palette
                                                                .secondaryColor,
                                                            borderRadius:
                                                                BorderRadius
                                                                    .circular(
                                                                        50.0),
                                                          ),
                                                          child: Center(
                                                            child: Icon(
                                                              MdiIcons.minus,
                                                              color:
                                                                  Colors.white,
                                                              size: 20.0,
                                                            ),
                                                          ),
                                                        ),
                                                      ),
                                                      const SizedBox(
                                                        width: 10.0,
                                                      ),
                                                      Text(
                                                        cartList[index]
                                                            .quantity
                                                            .toString(),
                                                        style: const TextStyle(
                                                            color: Colors.black,
                                                            fontSize: 16.0,
                                                            fontFamily:
                                                                'EuclidCircularA Medium'),
                                                      ),
                                                      const SizedBox(
                                                        width: 10.0,
                                                      ),
                                                      GestureDetector(
                                                        onTap: () {
                                                          setState(() {
                                                            isLoading = false;
                                                          });
                                                          updateCartQuantity(
                                                              cartList[index]
                                                                  .cart_id,
                                                              'add');
                                                        },
                                                        child: Container(
                                                          height: 30.0,
                                                          width: 30.0,
                                                          decoration:
                                                              BoxDecoration(
                                                            color: Palette
                                                                .secondaryColor,
                                                            borderRadius:
                                                                BorderRadius
                                                                    .circular(
                                                                        50.0),
                                                          ),
                                                          child: const Center(
                                                            child: Icon(
                                                              Icons.add,
                                                              color:
                                                                  Colors.white,
                                                              size: 20.0,
                                                            ),
                                                          ),
                                                        ),
                                                      )
                                                    ],
                                                  )
                                                : Row(
                                                    children: [
                                                      Expanded(
                                                        child: Text(
                                                          'Rs. ${cartList[index].price * cartList[index].quantity}',
                                                          style: const TextStyle(
                                                              color:
                                                                  Colors.black,
                                                              fontSize: 18.0,
                                                              fontFamily:
                                                                  'EuclidCircularA Medium'),
                                                        ),
                                                      ),
                                                      GestureDetector(
                                                        onTap: () {
                                                          setState(() {
                                                            // Provider.of<MainContainerViewModel>(
                                                            //         context,
                                                            //         listen: false)
                                                            //     .cart
                                                            //     .removeWhere((element) =>
                                                            //         element.item_id ==
                                                            //             cartList[
                                                            //                     index]
                                                            //                 .item_id &&
                                                            //         element.item_category ==
                                                            //             cartList[
                                                            //                     index]
                                                            //                 .item_category);
                                                            // context
                                                            //     .read<
                                                            //         MainContainerViewModel>()
                                                            //     .setCart(Provider.of<
                                                            //                 MainContainerViewModel>(
                                                            //             context,
                                                            //             listen: false)
                                                            //         .cart);
                                                            updateCart(
                                                                cartList[index]
                                                                    .item_id,
                                                                'remove',
                                                                cartList[index]
                                                                    .item_category);
                                                            isLoading = false;
                                                          });
                                                        },
                                                        child: Container(
                                                          decoration: BoxDecoration(
                                                              color: Palette
                                                                  .secondaryColor,
                                                              borderRadius:
                                                                  BorderRadius
                                                                      .circular(
                                                                          5.0)),
                                                          child: const Padding(
                                                            padding: EdgeInsets
                                                                .symmetric(
                                                                    vertical:
                                                                        5.0,
                                                                    horizontal:
                                                                        8.0),
                                                            child: Text(
                                                              'Remove',
                                                              style: TextStyle(
                                                                  color: Colors
                                                                      .white,
                                                                  fontSize:
                                                                      14.0,
                                                                  fontFamily:
                                                                      'EuclidCircularA Regular'),
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
                                  );
                                },
                              ),
                            ),
                            const SizedBox(
                              height: 15.0,
                            ),
                            Padding(
                              padding: const EdgeInsets.only(
                                  left: 24.0, right: 24.0),
                              child: GestureDetector(
                                onTap: () {
                                  openAvailableCouponsPopup();
                                },
                                child: Container(
                                  decoration: BoxDecoration(
                                    borderRadius: BorderRadius.circular(8.0),
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
                                  child: Padding(
                                    padding: const EdgeInsets.only(
                                      left: 10.0,
                                      right: 10.0,
                                      top: 12.0,
                                      bottom: 12.0,
                                    ),
                                    child: Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.spaceBetween,
                                      children: const [
                                        Text(
                                          'Available coupons',
                                          style: TextStyle(
                                            color: Palette.black,
                                            fontSize: 16.0,
                                            fontFamily:
                                                'EuclidCircularA Medium',
                                          ),
                                        ),
                                        Icon(
                                          Icons.arrow_forward_ios_outlined,
                                          color: Palette.black,
                                          size: 20.0,
                                        )
                                      ],
                                    ),
                                  ),
                                ),
                              ),
                            ),
                            const SizedBox(
                              height: 15.0,
                            ),
                            const Padding(
                              padding: EdgeInsets.only(left: 24.0, right: 24.0),
                              child: Divider(
                                height: 2.0,
                                color: Colors.black38,
                                indent: 0.0,
                              ),
                            ),
                            const SizedBox(
                              height: 10.0,
                            ),
                            Padding(
                              padding: const EdgeInsets.only(
                                  left: 24.0, right: 24.0),
                              child: Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  const Text(
                                    'Total',
                                    style: TextStyle(
                                      color: Palette.black,
                                      fontSize: 14.0,
                                      fontFamily: 'EuclidCircularA Medium',
                                    ),
                                  ),
                                  Text(
                                    'Rs. $sumTotal',
                                    style: const TextStyle(
                                      color: Palette.black,
                                      fontSize: 14.0,
                                      fontFamily: 'EuclidCircularA Medium',
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            const SizedBox(
                              height: 5.0,
                            ),
                            Padding(
                              padding: const EdgeInsets.only(
                                  left: 24.0, right: 24.0),
                              child: Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  const Text(
                                    'Applied Coupon',
                                    style: TextStyle(
                                      color: Palette.black,
                                      fontSize: 14.0,
                                      fontFamily: 'EuclidCircularA Medium',
                                    ),
                                  ),
                                  GestureDetector(
                                    onTap: () {
                                      openAvailableCouponsPopup();
                                    },
                                    child: Text(
                                      appliedCouponId.isEmpty
                                          ? 'Available Coupons'
                                          : availableCoupons
                                              .firstWhere((element) =>
                                                  element.id == appliedCouponId)
                                              .couponName,
                                      style: const TextStyle(
                                        color: Colors.blue,
                                        fontSize: 14.0,
                                        fontFamily: 'EuclidCircularA Medium',
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            const SizedBox(
                              height: 5.0,
                            ),
                            appliedCouponId.isEmpty
                                ? const SizedBox()
                                : Padding(
                                    padding: const EdgeInsets.only(
                                        left: 24.0, right: 24.0),
                                    child: Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.spaceBetween,
                                      children: [
                                        const Text(
                                          'Discount price',
                                          style: TextStyle(
                                            color: Palette.black,
                                            fontSize: 14.0,
                                            fontFamily:
                                                'EuclidCircularA Medium',
                                          ),
                                        ),
                                        GestureDetector(
                                          onTap: () {
                                            openAvailableCouponsPopup();
                                          },
                                          child: Text(
                                            appliedCouponId.isEmpty
                                                ? 'Available Coupons'
                                                : 'Rs. ${availableCoupons.firstWhere((element) => element.id == appliedCouponId).totalAmount}',
                                            style: const TextStyle(
                                              color: Palette.black,
                                              fontSize: 14.0,
                                              fontFamily:
                                                  'EuclidCircularA Medium',
                                            ),
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                            SizedBox(
                              height: appliedCouponId.isEmpty ? 0.0 : 5.0,
                            ),
                            Padding(
                              padding: const EdgeInsets.only(
                                  left: 24.0, right: 24.0),
                              child: Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  const Text(
                                    'Shipping Charges',
                                    style: TextStyle(
                                      color: Palette.black,
                                      fontSize: 14.0,
                                      fontFamily: 'EuclidCircularA Medium',
                                    ),
                                  ),
                                  Text(
                                    'Rs. $shippingCharges',
                                    style: const TextStyle(
                                      color: Palette.black,
                                      fontSize: 14.0,
                                      fontFamily: 'EuclidCircularA Medium',
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            const SizedBox(
                              height: 15.0,
                            ),
                            Container(
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
                                    color: Palette.shadowColor.withOpacity(0.0),
                                    blurRadius: 30.0, // soften the shadow
                                    spreadRadius: 0.0, //extend the shadow
                                    offset: const Offset(
                                      0.0, // Move to right 10  horizontally
                                      0.0, // Move to bottom 10 Vertically
                                    ),
                                  ),
                                ],
                              ),
                              child: cartList.isEmpty
                                  ? const Center()
                                  : Padding(
                                      padding: const EdgeInsets.symmetric(
                                          vertical: 10.0, horizontal: 24.0),
                                      child: GestureDetector(
                                        onTap: () async {
                                          if (Application.phoneNumber.isEmpty) {
                                            Provider.of<MainContainerViewModel>(
                                                    context,
                                                    listen: false)
                                                .setIndex(4);
                                            Navigator.pop(context);
                                          } else {
                                            // if (Platform.isAndroid) {
                                            _initiatePayment(paybleAmount);
                                            // Navigator.push(
                                            //   context,
                                            //   MaterialPageRoute(
                                            //     builder: (context) =>
                                            //         CartPaymentPage(
                                            //             url:
                                            //                 '$url/subscription_api/cartsubscription?total_price=$sumTotal&actual_total_price=$paybleAmount&user_id=${Application.userId}&coupon_id=$appliedCouponId'),
                                            //   ),
                                            // );
                                            // } else {
                                            //   if (paybleAmount > wallet) {
                                            //     Utility.showSnacbar(context,
                                            //         'Not Enough money in wallet !! please add money');
                                            //     await Future.delayed(
                                            //         const Duration(
                                            //             milliseconds: 1000));
                                            //     Navigator.push(
                                            //       context,
                                            //       MaterialPageRoute(
                                            //         builder: (context) =>
                                            //             const WalletPage(),
                                            //       ),
                                            //     );
                                            //   } else {
                                            //     Utility.showProgress(true);
                                            //     applePayment();
                                            //   }
                                            // }
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
                                                const Expanded(
                                                  child: Center(
                                                    child: Text(
                                                      'Proceed to pay',
                                                      style: TextStyle(
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
                                                    child: Text(
                                                      'Rs $paybleAmount',
                                                      style: const TextStyle(
                                                        color: Colors.white,
                                                        fontSize: 16.0,
                                                        fontFamily:
                                                            'EuclidCircularA Medium',
                                                      ),
                                                    ),
                                                  ),
                                                ),
                                              ],
                                            ),
                                          ),
                                        ),
                                      ),
                                    ),
                            ),
                          ],
                        ),
                      ),
          );
  }

  Future _initiatePayment(double value) async {
    Utility.showProgress(true);
    Map<String, String> params = {
      "total": value.toString(),
    };
    String url = '${Constants.finalUrl}/subscription_api/paymentInitiate';
    Map<String, dynamic> initiatePayment =
        await ApiFunctions.postApiResult(url, Application.deviceToken, params);
    bool status = initiatePayment['status'];
    var data = initiatePayment['data'];
    if (status) {
      Utility.showProgress(false);
      try {
        // _razorpay.open(data!);
      } catch (e) {
        Utility.printLog("Payment Payment error $e");
      }
    } else {
      Utility.printLog('Something went wrong while saving token.');
      Utility.printLog('Some error occurred');
      Utility.showProgress(false);
      Utility.showSnacbar(context, 'Some error occurred!!');
    }
  }

  // void _handlePaymentSuccess(PaymentSuccessResponse response) async {
  //   Utility.printLog("Payment Checkout Success ${response.paymentId}");
  //   // _razorpay.clear();
  //   Utility.showProgress(true);
  //   Map<String, String> params = {};
  //   String url =
  //       '${Constants.finalUrl}/subscription_api/complete_payment_mobile/${Application.userId}/$sumTotal/$paybleAmount/$appliedCouponId';
  //   Map<String, dynamic> paymentSuccess =
  //       await ApiFunctions.postApiResult(url, Application.deviceToken, params);
  //   bool status = paymentSuccess['status'];
  //   var data = paymentSuccess['data'];
  //   if (status) {
  //     // print(data);
  //     if (data[ApiKeys.message].toString() == 'payment_success') {
  //       Utility.showProgress(false);
  //       Provider.of<MainContainerViewModel>(context, listen: false).setCart([]);
  //       Provider.of<MainContainerViewModel>(context, listen: false)
  //           .setNotificationCount();
  //       Navigator.pushAndRemoveUntil(
  //         context,
  //         MaterialPageRoute(
  //           builder: (context) => const MainContainer(),
  //         ),
  //         (Route<dynamic> route) => false,
  //       );
  //       Utility.showSnacbar(
  //         context,
  //         'Your purchase is successful!!, please click here to check',
  //         onClicked: () {
  //           Navigator.push(
  //             context,
  //             MaterialPageRoute(builder: (context) => const NotificationPage()),
  //           );
  //         },
  //         duration: 2,
  //       );
  //     } else if (data[ApiKeys.message].toString() == 'payment_failed' ||
  //         data[ApiKeys.message].toString() == 'Database_connection_error') {
  //       Utility.showProgress(false);
  //       Utility.showSnacbar(context, 'Payment Failed!!');
  //     }
  //   } else {
  //     Utility.printLog('Something went wrong while saving token.');
  //     Utility.printLog('Some error occurred');
  //     Utility.showProgress(false);
  //     Utility.showSnacbar(context, 'Some error occurred!!');
  //   }
  // }

  // void _handlePaymentError(PaymentFailureResponse response) {
  //   Utility.printLog(
  //       "Payment Checkout Failure ${response.code} ${response.message}");
  //   // _razorpay.clear();
  //   Utility.showSnacbar(context, 'Payment Failed!!');
  // }

  // void _handleExternalWallet(ExternalWalletResponse response) async {
  //   Utility.printLog("Payment Checkout Wallet ${response.walletName}");
  //   // _razorpay.clear();
  //   Utility.showProgress(true);
  //   Map<String, String> params = {};
  //   String url =
  //       '${Constants.finalUrl}/subscription_api/complete_payment_mobile/${Application.userId}/$sumTotal/$paybleAmount/$appliedCouponId';
  //   Map<String, dynamic> paymentSuccess =
  //       await ApiFunctions.postApiResult(url, Application.deviceToken, params);
  //   bool status = paymentSuccess['status'];
  //   var data = paymentSuccess['data'];
  //   if (status) {
  //     if (data[ApiKeys.message].toString() == 'payment_success') {
  //       Utility.showProgress(false);
  //       Provider.of<MainContainerViewModel>(context, listen: false).setCart([]);
  //       Provider.of<MainContainerViewModel>(context, listen: false)
  //           .setNotificationCount();
  //       Navigator.pushAndRemoveUntil(
  //         context,
  //         MaterialPageRoute(
  //           builder: (context) => const MainContainer(),
  //         ),
  //         (Route<dynamic> route) => false,
  //       );
  //       Utility.showSnacbar(
  //         context,
  //         'Your purchase is successful!!, please click here to check',
  //         onClicked: () {
  //           Navigator.push(
  //             context,
  //             MaterialPageRoute(builder: (context) => const NotificationPage()),
  //           );
  //         },
  //         duration: 2,
  //       );
  //     } else if (data[ApiKeys.message].toString() == 'payment_failed' ||
  //         data[ApiKeys.message].toString() == 'Database_connection_error') {
  //       Utility.showProgress(false);
  //       Utility.showSnacbar(context, 'Payment Failed!!');
  //     }
  //   } else {
  //     Utility.printLog('Something went wrong while saving token.');
  //     Utility.printLog('Some error occurred');
  //     Utility.showProgress(false);
  //     Utility.showSnacbar(context, 'Some error occurred!!');
  //   }
  // }
}
