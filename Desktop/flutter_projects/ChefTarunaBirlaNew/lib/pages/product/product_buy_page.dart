import 'dart:convert';
import 'dart:io';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:http/http.dart' as http;
import 'package:image_picker/image_picker.dart';
// import 'package:ios_insecure_screen_detector/ios_insecure_screen_detector.dart';
import 'package:material_design_icons_flutter/material_design_icons_flutter.dart';
import 'package:provider/src/provider.dart';

import '../../api/api_functions.dart';
import '../../config/config.dart';
import '../../models/cart_item.dart';
import '../../services/mysql_db_service.dart';
import '../../utils/utility.dart';
import '../../viewmodels/main_container_viewmodel.dart';
import '../../widgets/image_placeholder.dart';
import '../cart/cart_page.dart';

class ProductBuyPage extends StatefulWidget {
  final String price;
  final String id;
  const ProductBuyPage({
    Key? key,
    required this.price,
    required this.id,
  }) : super(key: key);

  @override
  State<ProductBuyPage> createState() => _ProductBuyPageState();
}

class _ProductBuyPageState extends State<ProductBuyPage> {
  bool isLoading = false;
  bool isOfferLoading = false;
  int total_price = 0;
  double actual_total_price = 0;
  int number_of_courses = 0;
  String discountpercentage = '';
  String couponcode = '';
  String couponid = '';
  int counter = 0;
  List list = [];
  File? image;
  String address = '';
  String selectedImage = '';
  final quantityController = TextEditingController();
  final descriptionController = TextEditingController();
  final addressController = TextEditingController();
  final pincodeController = TextEditingController();
  // final IosInsecureScreenDetector _insecureScreenDetector =
  //     IosInsecureScreenDetector();
  bool _isCaptured = false;
  String state = "";
  int shippingCharges = 90;
  String url = Constants.finalUrl;
  // String user

  Future<void> getProductImages() async {
    setState(() {
      address = Application.address;
      addressController.text = Application.address;
      quantityController.text = '1';
      pincodeController.text = Application.pincode;
    });
    Map<String, dynamic> _getNews = await MySqlDBService().runQuery(
      requestType: RequestType.GET,
      url: '$url/getProductImages/${widget.id}',
    );

    bool _status = _getNews['status'];
    var _data = _getNews['data'];
    // Utility.printLog(_data);
    if (_status) {
      for (var i = 0; i < _data['data'].length; i++) {
        list.add(Constants.imgBackendUrl + _data['data'][i]['path'].toString());
      }
      setState(() {
        isLoading = true;
        isOfferLoading = true;
      });
      actual_total_price = double.parse(widget.price);

      // getProducts();
      // getCouponsByCategory();
      Utility.showProgress(false);
    } else {
      Utility.printLog('Something went wrong.');
      Utility.showProgress(true);
      Utility.databaseErrorPopup(context);
    }
  }

  Future<void> updateCart(id, value) async {
    Map<String, String> params = {
      'user_id': Application.userId,
      'category': 'product',
      'id': id,
      'description': descriptionController.text.isEmpty
          ? 'nothing'
          : descriptionController.text,
      'address':
          addressController.text.isEmpty ? 'nothing' : addressController.text,
      'image_path': selectedImage,
      'quantity': quantityController.text,
      'pincode': pincodeController.text,
    };
    String url = value == 'add'
        ? '${Constants.finalUrl}/users/addproducttocart'
        : '${Constants.finalUrl}/users/removefromcart';
    Map<String, dynamic> _postResult =
        await ApiFunctions.postApiResult(url, Application.deviceToken, params);

    bool _status = _postResult['status'];
    var _data = _postResult['data'];
    // Utility.printLog(_data);
    if (_status) {
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
      Utility.showProgress(false);
      Utility.databaseErrorPopup(context);
    }
  }

  Future<void> getCouponsByCategory() async {
    Map<String, dynamic> _getNews = await MySqlDBService().runQuery(
      requestType: RequestType.GET,
      url: '$url/getCouponsByCategory/product/single',
    );

    bool _status = _getNews['status'];
    var _data = _getNews['data'];
    // Utility.printLog(_data);
    if (_status) {
      if (_data['data'].length != 0) {
        var discount = int.parse(_data['data'][0]['dis'].toString());
        if (pincodeController.text == '311001') {
          actual_total_price = (int.parse(widget.price) -
              ((int.parse(widget.price) * discount) / 100));
        } else {
          actual_total_price = (int.parse(widget.price) -
                  ((int.parse(widget.price) * discount) / 100)) +
              shippingCharges;
        }
        discountpercentage = _data['data'][0]['dis'].toString();
        couponcode = _data['data'][0]['ccode'].toString();
        couponid = _data['data'][0]['id'].toString();
      } else {
        if (pincodeController.text == '311001') {
          actual_total_price = double.parse(widget.price);
        } else {
          actual_total_price = (double.parse(widget.price) + shippingCharges);
        }
        discountpercentage = '0';
        couponid = '';
        couponcode = '';
      }
      setState(() => isOfferLoading = true);
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
        getProductImages();
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
    Utility.showProgress(true);
    if (!kIsWeb) {
      _filterRetriever();
    } else {
      getProductImages();
    }
    super.initState();

    Provider.of<MainContainerViewModel>(context, listen: false)
        .cart
        .forEach((element) {
      if (element.item_id == widget.id && element.item_category == 'product') {
        counter++;
      }
    });
  }

  @override
  void dispose() {
    super.dispose();
  }

  Future pickImage() async {
    try {
      final image = await ImagePicker().pickImage(source: ImageSource.gallery);
      if (image == null) return;
      final imageTemporary = File(image.path);
      var res = await uploadImage(image.path, '$url/saveUserOrderImage');
      setState(() {
        this.image = imageTemporary;
        state = res!;
        selectedImage = res;
      });
    } on PlatformException catch (e) {
      Utility.printLog('Failed to pick image $e');
    }
  }

  Future<String?> uploadImage(filename, url) async {
    // var dio = Dio();
    // var formData = FormData.fromMap({
    //   'file': await http.MultipartFile.fromPath('picture', filename),
    // });
    var request = http.MultipartRequest('POST', Uri.parse(url));
    request.files.add(await http.MultipartFile.fromPath('picture', filename));
    var res = await request.send();
    final responseData = await res.stream.toBytes();
    final responseString = String.fromCharCodes(responseData);
    // Utility.printLog(json.decode(responseString)['files'].toString());
    // var response = await dio.post(url, data: request);
    // Utility.printLog(response);
    // Utility.printLog(res.toString());
    return json.decode(responseString)['files'].toString();
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
                '',
                style: TextStyle(
                  color: Palette.white,
                  fontSize: 18.0,
                  fontFamily: 'EuclidCircularA Medium',
                ),
              ),
              backgroundColor: Palette.appBarColor,
              elevation: 10.0,
              shadowColor: Palette.shadowColor.withOpacity(0.1),
              centerTitle: true,
            ),
            body: !isLoading
                ? Container()
                : Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Expanded(
                        child: SingleChildScrollView(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const SizedBox(
                                height: 20.0,
                              ),
                              const Padding(
                                padding: EdgeInsets.symmetric(
                                    vertical: 00.0, horizontal: 24.0),
                                child: Text(
                                  'Select image from our gallery',
                                  style: TextStyle(
                                    color: Colors.black,
                                    fontSize: 16.0,
                                    fontFamily: 'EuclidCircularA Medium',
                                  ),
                                ),
                              ),
                              Container(
                                margin:
                                    EdgeInsets.fromLTRB(24.0, 20.0, 0.0, 0.0),
                                height: 150.0,
                                child: ListView.builder(
                                  scrollDirection: Axis.horizontal,
                                  itemCount: list.length,
                                  itemBuilder:
                                      (BuildContext context, int index) {
                                    return GestureDetector(
                                      onTap: () {
                                        // Utility.printLog(image);
                                        setState(() {
                                          selectedImage = list[index];
                                          image = null;
                                        });
                                      },
                                      child: Container(
                                        margin: EdgeInsets.fromLTRB(
                                            0.0, 0.0, 20.0, 0.0),
                                        decoration: BoxDecoration(
                                          border: Border.all(
                                            width: selectedImage == list[index]
                                                ? 3.0
                                                : 0.0,
                                            color: Colors.green,
                                          ),
                                          borderRadius:
                                              BorderRadius.circular(8.0),
                                        ),
                                        child: ClipRRect(
                                          borderRadius:
                                              BorderRadius.circular(8.0),
                                          child: CachedNetworkImage(
                                            imageUrl: list[index],
                                            placeholder: (context, url) =>
                                                const ImagePlaceholder(),
                                            errorWidget:
                                                (context, url, error) =>
                                                    const ImagePlaceholder(),
                                            fit: BoxFit.cover,
                                            height: double.infinity,
                                          ),
                                        ),
                                      ),
                                    );
                                  },
                                ),
                              ),
                              const SizedBox(
                                height: 20.0,
                              ),
                              const Padding(
                                padding: EdgeInsets.symmetric(
                                    vertical: 00.0, horizontal: 24.0),
                                child: Center(
                                  child: Text(
                                    'OR',
                                    textAlign: TextAlign.center,
                                    style: TextStyle(
                                      color: Colors.black,
                                      fontSize: 18.0,
                                      fontFamily: 'EuclidCircularA Medium',
                                    ),
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
                                  'Upload your own image',
                                  style: TextStyle(
                                    color: Colors.black,
                                    fontSize: 16.0,
                                    fontFamily: 'EuclidCircularA Medium',
                                  ),
                                ),
                              ),
                              const SizedBox(
                                height: 20.0,
                              ),
                              Padding(
                                padding: const EdgeInsets.symmetric(
                                    vertical: 00.0, horizontal: 24.0),
                                child: GestureDetector(
                                  onTap: () {
                                    pickImage();
                                  },
                                  child: Container(
                                    height: 50.0,
                                    decoration: BoxDecoration(
                                      borderRadius: BorderRadius.circular(10),
                                      color: Palette.appBarColor,
                                      boxShadow: [
                                        BoxShadow(
                                          color: Palette.shadowColor
                                              .withOpacity(0.0),
                                          blurRadius: 5.0, // soften the shadow
                                          spreadRadius: 0.0, //extend the shadow
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
                                        children: const [
                                          Expanded(
                                            child: Center(
                                              child: Text(
                                                'Pick an image',
                                                style: TextStyle(
                                                  color: Palette.white,
                                                  fontSize: 16.0,
                                                  fontFamily:
                                                      'EuclidCircularA Regular',
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
                              SizedBox(
                                height: image != null ? 10.0 : 0.0,
                              ),
                              Padding(
                                padding: EdgeInsets.symmetric(
                                    vertical: 00.0,
                                    horizontal: image != null ? 24.0 : 0.0),
                                child: image != null
                                    ? Center(
                                        child: Container(
                                          height: 150.0,
                                          margin: const EdgeInsets.fromLTRB(
                                              0.0, 0.0, 20.0, 0.0),
                                          child: image != null
                                              ? Stack(children: [
                                                  ClipRRect(
                                                    borderRadius:
                                                        BorderRadius.circular(
                                                            8.0),
                                                    child: Image.file(
                                                      image!,
                                                      fit: BoxFit.cover,
                                                      height: double.infinity,
                                                    ),
                                                  ),
                                                  Positioned(
                                                    top: 10,
                                                    right: 10,
                                                    child: GestureDetector(
                                                      onTap: () {
                                                        setState(() {
                                                          image = null;
                                                          state = '';
                                                          selectedImage = '';
                                                        });
                                                      },
                                                      child: Container(
                                                        height: 24.0,
                                                        width: 24.0,
                                                        decoration:
                                                            BoxDecoration(
                                                          color:
                                                              Colors.redAccent,
                                                          borderRadius:
                                                              BorderRadius
                                                                  .circular(
                                                                      50.0),
                                                        ),
                                                        child: const Center(
                                                          child: Icon(
                                                            Icons.close_rounded,
                                                            size: 18.0,
                                                            color: Colors.white,
                                                          ),
                                                        ),
                                                      ),
                                                    ),
                                                  )
                                                ])
                                              : Container(),
                                        ),
                                      )
                                    : Center(),
                              ),
                              const SizedBox(
                                height: 20.0,
                              ),
                              Padding(
                                padding: const EdgeInsets.symmetric(
                                    vertical: 0.0, horizontal: 24.0),
                                child: Container(
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
                                  child: TextField(
                                    onChanged: (value) {
                                      if (value.isNotEmpty) {
                                        setState(() {
                                          actual_total_price = ((int.parse(
                                                          widget.price) -
                                                      ((int.parse(widget
                                                                  .price) *
                                                              int.parse(
                                                                  discountpercentage)) /
                                                          100)) +
                                                  shippingCharges) *
                                              int.parse(value);
                                        });
                                      }
                                    },
                                    keyboardType: TextInputType.phone,
                                    minLines: 1,
                                    maxLines: 1,
                                    controller: quantityController,
                                    textInputAction: TextInputAction.done,
                                    style: const TextStyle(
                                      fontFamily: 'EuclidCircularA Regular',
                                    ),
                                    autofocus: false,
                                    decoration: InputDecoration(
                                      // prefixIcon: const Icon(
                                      //   MdiIcons.formatTextVariant,
                                      // ),
                                      prefixIcon: const Padding(
                                        padding: EdgeInsets.symmetric(
                                            vertical: 12.0, horizontal: 15.0),
                                        child: Text(
                                          'Q',
                                          style: TextStyle(
                                            fontFamily:
                                                'EuclidCircularA Medium',
                                            fontSize: 18.0,
                                            color: Color(0xff828282),
                                          ),
                                        ),
                                      ),
                                      counterText: "",
                                      hintText: "Enter Quantity",
                                      focusColor: Palette.contrastColor,
                                      focusedBorder: OutlineInputBorder(
                                          borderSide: const BorderSide(
                                            color: Palette.white,
                                            width: 1.3,
                                          ),
                                          borderRadius:
                                              BorderRadius.circular(10.0)),
                                      enabledBorder: OutlineInputBorder(
                                          borderSide: const BorderSide(
                                              color: Palette.white, width: 1.0),
                                          borderRadius:
                                              BorderRadius.circular(10.0)),
                                      contentPadding:
                                          const EdgeInsets.symmetric(
                                              vertical: 8.0, horizontal: 16.0),
                                      filled: true,
                                      fillColor: Palette.white,
                                    ),
                                  ),
                                ),
                              ),
                              const SizedBox(
                                height: 20.0,
                              ),
                              Padding(
                                padding: const EdgeInsets.symmetric(
                                    vertical: 0.0, horizontal: 24.0),
                                child: Container(
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
                                  child: TextField(
                                    onChanged: (value) {},
                                    keyboardType: TextInputType.multiline,
                                    minLines: 1,
                                    maxLines: 5,
                                    controller: descriptionController,
                                    style: const TextStyle(
                                      fontFamily: 'EuclidCircularA Regular',
                                    ),
                                    autofocus: false,
                                    textInputAction: TextInputAction.done,
                                    decoration: InputDecoration(
                                      prefixIcon: Icon(
                                        MdiIcons.formatParagraph,
                                      ),
                                      counterText: "",
                                      hintText: "Enter message",
                                      focusColor: Palette.contrastColor,
                                      focusedBorder: OutlineInputBorder(
                                          borderSide: const BorderSide(
                                            color: Palette.white,
                                            width: 1.3,
                                          ),
                                          borderRadius:
                                              BorderRadius.circular(10.0)),
                                      enabledBorder: OutlineInputBorder(
                                          borderSide: const BorderSide(
                                              color: Palette.white, width: 1.0),
                                          borderRadius:
                                              BorderRadius.circular(10.0)),
                                      contentPadding:
                                          const EdgeInsets.symmetric(
                                              vertical: 8.0, horizontal: 16.0),
                                      filled: true,
                                      fillColor: Palette.white,
                                    ),
                                  ),
                                ),
                              ),
                              const SizedBox(
                                height: 20.0,
                              ),
                              Padding(
                                padding: const EdgeInsets.symmetric(
                                    vertical: 0.0, horizontal: 24.0),
                                child: Container(
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
                                  child: TextField(
                                    onChanged: (value) {},
                                    keyboardType: TextInputType.multiline,
                                    minLines: 1,
                                    maxLines: 5,
                                    controller: addressController,
                                    style: const TextStyle(
                                      fontFamily: 'EuclidCircularA Regular',
                                    ),
                                    autofocus: false,
                                    textInputAction: TextInputAction.done,
                                    decoration: InputDecoration(
                                      prefixIcon: Icon(
                                        MdiIcons.mapMarkerOutline,
                                      ),
                                      counterText: "",
                                      hintText: "Enter your address",
                                      focusColor: Palette.contrastColor,
                                      focusedBorder: OutlineInputBorder(
                                          borderSide: const BorderSide(
                                            color: Palette.white,
                                            width: 1.3,
                                          ),
                                          borderRadius:
                                              BorderRadius.circular(10.0)),
                                      enabledBorder: OutlineInputBorder(
                                          borderSide: const BorderSide(
                                              color: Palette.white, width: 1.0),
                                          borderRadius:
                                              BorderRadius.circular(10.0)),
                                      contentPadding:
                                          const EdgeInsets.symmetric(
                                              vertical: 8.0, horizontal: 16.0),
                                      filled: true,
                                      fillColor: Palette.white,
                                    ),
                                  ),
                                ),
                              ),
                              const SizedBox(
                                height: 20.0,
                              ),
                              Padding(
                                padding: const EdgeInsets.symmetric(
                                    vertical: 0.0, horizontal: 24.0),
                                child: Container(
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
                                  child: TextField(
                                    onChanged: (value) {
                                      if (value.length >= 6) {
                                        setState(() {
                                          if (value == '311001') {
                                            shippingCharges = 0;
                                            actual_total_price = (int.parse(
                                                    widget.price) -
                                                ((int.parse(widget.price) *
                                                        int.parse(
                                                            discountpercentage)) /
                                                    100));
                                          } else {
                                            shippingCharges = 90;
                                            actual_total_price = (int.parse(
                                                        widget.price) -
                                                    ((int.parse(widget.price) *
                                                            int.parse(
                                                                discountpercentage)) /
                                                        100)) +
                                                shippingCharges;
                                          }
                                        });
                                      } else {
                                        setState(() {
                                          shippingCharges = 90;
                                        });
                                        actual_total_price = (int.parse(
                                                    widget.price) -
                                                ((int.parse(widget.price) *
                                                        int.parse(
                                                            discountpercentage)) /
                                                    100)) +
                                            shippingCharges;
                                      }
                                    },
                                    keyboardType: TextInputType.multiline,
                                    minLines: 1,
                                    maxLines: 5,
                                    controller: pincodeController,
                                    style: const TextStyle(
                                      fontFamily: 'EuclidCircularA Regular',
                                    ),
                                    autofocus: false,
                                    textInputAction: TextInputAction.done,
                                    decoration: InputDecoration(
                                      prefixIcon: Icon(
                                        MdiIcons.formTextboxPassword,
                                      ),
                                      counterText: "",
                                      hintText: "Enter your pincode",
                                      focusColor: Palette.contrastColor,
                                      focusedBorder: OutlineInputBorder(
                                          borderSide: const BorderSide(
                                            color: Palette.white,
                                            width: 1.3,
                                          ),
                                          borderRadius:
                                              BorderRadius.circular(10.0)),
                                      enabledBorder: OutlineInputBorder(
                                          borderSide: const BorderSide(
                                              color: Palette.white, width: 1.0),
                                          borderRadius:
                                              BorderRadius.circular(10.0)),
                                      contentPadding:
                                          const EdgeInsets.symmetric(
                                              vertical: 8.0, horizontal: 16.0),
                                      filled: true,
                                      fillColor: Palette.white,
                                    ),
                                  ),
                                ),
                              ),
                              const SizedBox(
                                height: 20.0,
                              ),
                              const SizedBox(
                                height: 10.0,
                              ),
                              Container(
                                height: couponid.isEmpty ? 50.0 : 50.0,
                                decoration: BoxDecoration(
                                  color: Colors.white,
                                  gradient: LinearGradient(
                                    colors: [
                                      Palette.primaryColor.withOpacity(0.0),
                                      Palette.primaryColor.withOpacity(0.0),
                                    ],
                                    begin: Alignment.topCenter,
                                    end: Alignment.bottomCenter,
                                    tileMode: TileMode.clamp,
                                  ),
                                  boxShadow: [
                                    BoxShadow(
                                      color:
                                          Palette.shadowColor.withOpacity(0.0),
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
                                      vertical: 0.0, horizontal: 24.0),
                                  child: Center(
                                    child: !isOfferLoading
                                        ? Container()
                                        : Column(
                                            children: [
                                              // Container(
                                              //   child: couponid.isEmpty
                                              //       ? Container()
                                              //       : Row(
                                              //           mainAxisAlignment:
                                              //               MainAxisAlignment.end,
                                              //           crossAxisAlignment:
                                              //               CrossAxisAlignment.center,
                                              //           children: [
                                              //             const Text(
                                              //               'Applied Offer:',
                                              //               style: TextStyle(
                                              //                 color: Colors.black,
                                              //                 fontSize: 14.0,
                                              //                 fontFamily:
                                              //                     'EuclidCircularA Medium',
                                              //               ),
                                              //             ),
                                              //             SizedBox(
                                              //               width: 10.0,
                                              //             ),
                                              //             Text(
                                              //               '$couponcode $discountpercentage%',
                                              //               style: TextStyle(
                                              //                 color: Palette
                                              //                     .secondaryColor,
                                              //                 fontSize: 14.0,
                                              //                 fontFamily:
                                              //                     'EuclidCircularA Medium',
                                              //               ),
                                              //             ),
                                              //           ],
                                              //         ),
                                              // ),
                                              // const SizedBox(
                                              //   height: 5.0,
                                              // ),
                                              // Row(
                                              //   mainAxisAlignment:
                                              //       MainAxisAlignment.end,
                                              //   crossAxisAlignment:
                                              //       CrossAxisAlignment.center,
                                              //   children: [
                                              //     const Text(
                                              //       'Shipping Charges',
                                              //       style: TextStyle(
                                              //         color: Colors.black,
                                              //         fontSize: 14.0,
                                              //         fontFamily:
                                              //             'EuclidCircularA Medium',
                                              //       ),
                                              //     ),
                                              //     SizedBox(
                                              //       width: 10.0,
                                              //     ),
                                              //     Text(
                                              //       'Rs. $shippingCharges',
                                              //       style: TextStyle(
                                              //         color: Palette.secondaryColor,
                                              //         fontSize: 14.0,
                                              //         fontFamily:
                                              //             'EuclidCircularA Medium',
                                              //       ),
                                              //     ),
                                              //   ],
                                              // ),
                                              const SizedBox(
                                                height: 10.0,
                                              ),
                                              const Divider(
                                                height: 2.0,
                                                color: Colors.black38,
                                                indent: 0.0,
                                              ),
                                              const SizedBox(
                                                height: 5.0,
                                              ),
                                              Row(
                                                mainAxisAlignment:
                                                    MainAxisAlignment.end,
                                                crossAxisAlignment:
                                                    CrossAxisAlignment.center,
                                                children: [
                                                  const Text(
                                                    'Total',
                                                    style: TextStyle(
                                                      color: Colors.black,
                                                      fontSize: 16.0,
                                                      fontFamily:
                                                          'EuclidCircularA Medium',
                                                    ),
                                                  ),
                                                  const SizedBox(
                                                    width: 10.0,
                                                  ),
                                                  Text(
                                                    'Rs. $actual_total_price',
                                                    style: const TextStyle(
                                                      color: Palette
                                                          .secondaryColor,
                                                      fontSize: 16.0,
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
                              const SizedBox(
                                height: 10.0,
                              ),
                              Container(
                                height: 70.0,
                                decoration: BoxDecoration(
                                  color: Colors.white,
                                  gradient: LinearGradient(
                                    colors: [
                                      Palette.primaryColor.withOpacity(0.0),
                                      Palette.primaryColor.withOpacity(0.0),
                                    ],
                                    begin: Alignment.topCenter,
                                    end: Alignment.bottomCenter,
                                    tileMode: TileMode.clamp,
                                  ),
                                  boxShadow: [
                                    BoxShadow(
                                      color:
                                          Palette.shadowColor.withOpacity(0.0),
                                      blurRadius: 30.0, // soften the shadow
                                      spreadRadius: 0.0, //extend the shadow
                                      offset: const Offset(
                                        0.0, // Move to right 10  horizontally
                                        0.0, // Move to bottom 10 Vertically
                                      ),
                                    ),
                                  ],
                                ),
                                child: !isOfferLoading
                                    ? Container()
                                    : Padding(
                                        padding: const EdgeInsets.symmetric(
                                            vertical: 10.0, horizontal: 24.0),
                                        child: Row(
                                          children: [
                                            Expanded(
                                              child: GestureDetector(
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
                                                                  'product');
                                                      context
                                                          .read<
                                                              MainContainerViewModel>()
                                                          .setCart(Provider.of<
                                                                      MainContainerViewModel>(
                                                                  context,
                                                                  listen: false)
                                                              .cart);
                                                      updateCart(
                                                          widget.id, 'remove');
                                                      counter = 0;
                                                    } else {
                                                      if (selectedImage
                                                          .isEmpty) {
                                                        Utility.showSnacbar(
                                                            context,
                                                            'Select or upload an image first!');
                                                      } else if (quantityController
                                                          .text.isEmpty) {
                                                        Utility.showSnacbar(
                                                            context,
                                                            'Enter the quantity!');
                                                      } else if (pincodeController
                                                          .text.isEmpty) {
                                                        Utility.showSnacbar(
                                                            context,
                                                            'Enter the pincode!');
                                                      } else if (addressController
                                                          .text.isEmpty) {
                                                        Utility.showSnacbar(
                                                            context,
                                                            'Enter the address!');
                                                      } else {
                                                        var newItem = CartItem(
                                                          cart_id: '',
                                                          item_id: widget.id,
                                                          name: '',
                                                          price: int.parse(
                                                              widget.price),
                                                          cart_category: 'cart',
                                                          image_path: '',
                                                          quantity: 0,
                                                          item_category:
                                                              'product',
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
                                                                    listen:
                                                                        false)
                                                                .cart);
                                                        updateCart(
                                                            widget.id, 'add');
                                                        counter = 1;
                                                      }
                                                    }
                                                  });
                                                },
                                                child: Container(
                                                  decoration: BoxDecoration(
                                                    borderRadius:
                                                        BorderRadius.circular(
                                                            10),
                                                    // color: Palette.primaryColor,
                                                    color:
                                                        Palette.contrastColor,
                                                    border: Border.all(
                                                        width: 1.5,
                                                        color: Palette
                                                            .contrastColor),
                                                    boxShadow: [
                                                      BoxShadow(
                                                        color: Palette
                                                            .shadowColor
                                                            .withOpacity(0.0),
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
                                                  child: Center(
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
                              ),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
          );
  }
}
