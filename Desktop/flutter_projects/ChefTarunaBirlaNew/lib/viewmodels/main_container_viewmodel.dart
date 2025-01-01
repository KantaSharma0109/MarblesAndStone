import 'dart:collection';

import 'package:chef_taruna_birla/api/api_functions.dart';
import 'package:chef_taruna_birla/models/gallery.dart';
import 'package:chef_taruna_birla/models/social_links.dart';
import 'package:chef_taruna_birla/models/testimonial.dart';
import 'package:flutter/material.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../common/common.dart';
import '../config/config.dart';
import '../models/book.dart';
import '../models/cart_item.dart';
import '../models/course.dart';
import '../models/course_categories.dart';
import '../models/product_categories.dart';
import '../models/products.dart';
import '../models/slider.dart';
import '../models/user.dart';
import '../pages/main_container.dart';
import '../utils/utility.dart';

class MainContainerViewModel with ChangeNotifier {
  int _index = 0;
  bool _isLoading = false;
  bool _initialized = false;
  bool _error = false;
  String _user_id = '';
  String _token = '';
  String _phoneNumber = '';
  String _languageId = '';
  List<ProductCategory> _productCategories = [];
  List<CourseCategory> _courseCategories = [];
  List<AppSlider> _appslider = [];
  List<Course> _featured_courses = [];
  List<Products> _featured_products = [];
  List<Book> _impBooks = [];
  List<UserData> _userData = [];
  List<CartItem> _cart = [];
  List<CartItem> _whislist = [];
  List<SocialLinks> _sociallinks = [];
  List<Gallery> _gallery = [];
  List<Testimonial> _testimonial = [];
  String _dynamicLinkUrl = '';
  int _notificationCount = 0;
  ListQueue<int> _navigationQueue = ListQueue();

  //Get Value Functions
  int get current_index => _index;
  ListQueue<int> get navigationQueue => _navigationQueue;
  int get notificationCount => _notificationCount;
  bool get isLoading => _isLoading;
  String get user_id => _user_id;
  String get token => _token;
  String get phoneNumber => _phoneNumber;
  String get dynamicLinkUrl => _dynamicLinkUrl;
  List<ProductCategory> get productCategories => _productCategories;
  List<CourseCategory> get courseCategories => _courseCategories;
  List<AppSlider> get appslider => _appslider;
  List<Course> get featured_courses => _featured_courses;
  List<Products> get featured_products => _featured_products;
  List<Book> get impBooks => _impBooks;
  List<CartItem> get cart => _cart;
  List<CartItem> get whislist => _whislist;
  List<SocialLinks> get sociallinks => _sociallinks;
  List<Gallery> get gallery => _gallery;
  List<Testimonial> get testimonial => _testimonial;

  void setIndex(value) {
    _index = value;
    notifyListeners();
  }

  void setLoading(bool value) {
    _isLoading = value;
    notifyListeners();
  }

  void setWhislist(List<CartItem> value) {
    _whislist = value;
    notifyListeners();
  }

  void setCart(List<CartItem> value) {
    _cart = value;
    notifyListeners();
  }

  void setNotificationCount() {
    _notificationCount = _notificationCount + 1;
    notifyListeners();
  }

  Future<void> setAppData(var data, BuildContext context) async {
    _productCategories.clear();
    _courseCategories.clear();
    _appslider.clear();
    _featured_courses.clear();
    _featured_products.clear();
    _impBooks.clear();
    _userData.clear();
    _cart.clear();
    _whislist.clear();
    _sociallinks.clear();
    _gallery.clear();
    _testimonial.clear();
    notifyListeners();
    SharedPreferences prefs = await SharedPreferences.getInstance();
    prefs.setString('user_id', data[ApiKeys.user][0][ApiKeys.id].toString());
    Application.userId = data[ApiKeys.user][0][ApiKeys.id].toString();
    prefs.setString('wallet', data[ApiKeys.user][0][ApiKeys.wallet].toString());
    // _userData.add(
    //   UserData(
    //     id: data[ApiKeys.user][0][ApiKeys.id].toString(),
    //     name: data[ApiKeys.user][0][ApiKeys.name].toString(),
    //     phone_number: data[ApiKeys.user][0][ApiKeys.phone_number].toString(),
    //     email_id: data[ApiKeys.user][0][ApiKeys.email_id].toString(),
    //     address: data[ApiKeys.user][0][ApiKeys.address].toString(),
    //     pincode: data[ApiKeys.user][0][ApiKeys.pincode].toString(),
    //     wallet: int.parse(data[ApiKeys.user][0][ApiKeys.wallet].toString()),
    //   ),
    // );
    _notificationCount = data[ApiKeys.notificationCount];
    data[ApiKeys.cart].forEach((cartItem) => {
          if (cartItem[ApiKeys.cart_category] == 'whislist')
            {
              _whislist.add(
                CartItem(
                  cart_id: cartItem[ApiKeys.id].toString(),
                  item_id: cartItem[ApiKeys.category].toString() == 'product'
                      ? cartItem[ApiKeys.product_id].toString()
                      : cartItem[ApiKeys.category].toString() == 'course'
                          ? cartItem[ApiKeys.course_id].toString()
                          : cartItem[ApiKeys.category].toString() == 'book' ||
                                  cartItem[ApiKeys.category].toString() ==
                                      'book-videos'
                              ? cartItem[ApiKeys.book_id].toString()
                              : '',
                  name: cartItem[ApiKeys.name].toString(),
                  price: 0,
                  cart_category: 'whislist',
                  image_path: cartItem[ApiKeys.image_path].toString(),
                  quantity: int.parse(cartItem[ApiKeys.quantity].toString()),
                  item_category: cartItem[ApiKeys.category].toString(),
                ),
              )
            }
          else
            {
              _cart.add(
                CartItem(
                  cart_id: cartItem[ApiKeys.id].toString(),
                  item_id: cartItem[ApiKeys.category].toString() == 'product'
                      ? cartItem[ApiKeys.product_id].toString()
                      : cartItem[ApiKeys.category].toString() == 'course'
                          ? cartItem[ApiKeys.course_id].toString()
                          : cartItem[ApiKeys.category].toString() == 'book' ||
                                  cartItem[ApiKeys.category].toString() ==
                                      'book-videos'
                              ? cartItem[ApiKeys.book_id].toString()
                              : '',
                  name: cartItem[ApiKeys.name].toString(),
                  price: 0,
                  cart_category: 'cart',
                  image_path: cartItem[ApiKeys.image_path].toString(),
                  quantity: int.parse(cartItem[ApiKeys.quantity].toString()),
                  item_category: cartItem[ApiKeys.category].toString(),
                ),
              )
            }
        });
    data[ApiKeys.product_categories].forEach((productCategory) => {
          _productCategories.add(
            ProductCategory(
              id: productCategory[ApiKeys.id].toString(),
              name: productCategory[ApiKeys.name].toString(),
            ),
          )
        });
    data[ApiKeys.course_categories].forEach((courseCategory) => {
          _courseCategories.add(CourseCategory(
              id: courseCategory[ApiKeys.id].toString(),
              name: courseCategory[ApiKeys.name].toString(),
              image_path: courseCategory[ApiKeys.path].toString(),
              imp: courseCategory[ApiKeys.imp].toString()))
        });
    data[ApiKeys.slider].forEach((slider) => {
          _appslider.add(
            AppSlider(
              id: slider[ApiKeys.id].toString(),
              category: slider[ApiKeys.category].toString(),
              image_path: slider[ApiKeys.path].toString(),
              thumbnail: slider[ApiKeys.thumbnail].toString(),
              linked_category: slider[ApiKeys.linked_category].toString(),
              linked_array: slider[ApiKeys.linked_array].toString(),
            ),
          )
        });
    data[ApiKeys.featured_courses].forEach((featuredCourse) => {
          _featured_courses.add(
            Course(
              id: featuredCourse[ApiKeys.id].toString(),
              title: featuredCourse[ApiKeys.title].toString(),
              description: featuredCourse[ApiKeys.description].toString(),
              promo_video: featuredCourse[ApiKeys.promo_video].toString(),
              price: featuredCourse[ApiKeys.price].toString(),
              discount_price: featuredCourse[ApiKeys.discount_price].toString(),
              days: int.parse(featuredCourse[ApiKeys.days].toString()),
              category: featuredCourse[ApiKeys.category].toString(),
              image_path: featuredCourse[ApiKeys.image_path].toString(),
              share_url: featuredCourse[ApiKeys.share_url].toString(),
              subscribed: featuredCourse[ApiKeys.subscribed],
            ),
          ),
        });
    data[ApiKeys.featured_products].forEach((featuredProducts) => {
          _featured_products.add(
            Products(
              id: featuredProducts[ApiKeys.id].toString(),
              name: featuredProducts[ApiKeys.name].toString(),
              description: featuredProducts[ApiKeys.description].toString(),
              c_name: featuredProducts[ApiKeys.c_name].toString(),
              category_id: featuredProducts[ApiKeys.category_id].toString(),
              price: featuredProducts[ApiKeys.price].toString(),
              discount_price:
                  featuredProducts[ApiKeys.discount_price].toString(),
              stock: int.parse(featuredProducts[ApiKeys.stock].toString()),
              image_path: featuredProducts[ApiKeys.image_path].toString(),
              share_url: featuredProducts[ApiKeys.share_url].toString(),
            ),
          ),
        });
    data[ApiKeys.social_links].forEach((socialLink) => {
          _sociallinks.add(
            SocialLinks(
              id: socialLink[ApiKeys.id].toString(),
              name: socialLink[ApiKeys.name].toString(),
              url: socialLink[ApiKeys.url].toString(),
              image_path: socialLink[ApiKeys.image].toString(),
              show_category: socialLink[ApiKeys.show_category].toString(),
              linked_category: socialLink[ApiKeys.linked_category].toString(),
              linked_array: socialLink[ApiKeys.linked_array].toString(),
            ),
          ),
        });
    data[ApiKeys.gallery].forEach((gal) => {
          _gallery.add(Gallery(
            id: gal[ApiKeys.id].toString(),
            image_path: gal[ApiKeys.path].toString(),
          )),
        });
    data[ApiKeys.impBooks].forEach((impBook) => {
          _impBooks.add(
            Book(
              id: impBook[ApiKeys.id].toString(),
              title: impBook[ApiKeys.title].toString(),
              description: impBook[ApiKeys.description].toString(),
              price: impBook[ApiKeys.price].toString(),
              discount_price: impBook[ApiKeys.discount_price].toString(),
              days: int.parse(impBook[ApiKeys.days].toString()),
              category: impBook[ApiKeys.category].toString(),
              image_path: impBook[ApiKeys.image_path].toString(),
              pdflink: impBook[ApiKeys.pdflink].toString(),
              count: 0,
              price_with_video: impBook['price_with_video'].toString() == 'null'
                  ? ''
                  : impBook['price_with_video'].toString(),
              discount_price_with_video:
                  impBook['discount_price_with_video'].toString() == 'null'
                      ? ''
                      : impBook['discount_price_with_video'].toString(),
              video_days: impBook['video_days'].toString() == 'null'
                  ? 0
                  : impBook['video_days'],
              only_video_price: impBook['only_video_price'].toString() == 'null'
                  ? ''
                  : impBook['only_video_price'].toString(),
              only_video_discount_price:
                  impBook['only_video_discount_price'].toString() == 'null'
                      ? ''
                      : impBook['only_video_discount_price'].toString(),
              share_url: impBook['share_url'].toString() == 'null'
                  ? ''
                  : impBook['share_url'].toString(),
              include_videos: impBook['include_videos'].toString() == 'null'
                  ? ''
                  : impBook['include_videos'].toString(),
            ),
          ),
        });
    data[ApiKeys.testimonial].forEach((testimonial) => {
          _testimonial.add(
            Testimonial(
              id: testimonial[ApiKeys.id].toString(),
              name: testimonial[ApiKeys.name].toString(),
              message: testimonial[ApiKeys.message].toString(),
              image_path: testimonial[ApiKeys.image].toString(),
              profile_image: testimonial[ApiKeys.profile_image].toString(),
            ),
          ),
        });
    _isLoading = true;
    notifyListeners();
    if (!context.mounted) return;
    Future.delayed(const Duration(milliseconds: 800), () {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (context) => const MainContainer(),
        ),
      );
    });
  }

  //Get App Data Function
  Future<void> getAppData(BuildContext context) async {
    final PackageInfo info = await PackageInfo.fromPlatform();
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String savedPhoneNumber = prefs.getString('phonenumber') ?? '';
    String savedName = prefs.getString('name') ?? '';
    String savedLanguageId = prefs.getString('language_id') ?? '';
    String savedDate = prefs.getString('date') ?? '';
    String savedAddress = prefs.getString('address') ?? '';
    String savedPincode = prefs.getString('pincode') ?? '311001';
    Utility.printLog('saved language Id = $savedLanguageId');
    Utility.printLog('saved Phone Number = $savedPhoneNumber');
    Application.phoneNumber = savedPhoneNumber;
    Application.pincode = savedPincode;
    if (savedLanguageId.isEmpty) {
      prefs.setString("language_id", '1');
      Application.languageId = '1';
    } else {
      Application.languageId = savedLanguageId;
    }
    if (savedDate.isEmpty) {
      prefs.setString("date", DateTime.now().toString());
    }
    Utility.printLog(
        'SAVED FCM token in main view model ${Application.deviceToken}');
    String url =
        '${Constants.finalUrl}/api/app_data?language_id=${Application.languageId}';
    Map<String, dynamic> _getResult = await ApiFunctions.getApiResult(
        url, Application.deviceToken,
        version: info.version);
    bool _status = _getResult['status'];
    var _data = _getResult['data'];
    // print(_data);
    if (_status) {
      if (_data[ApiKeys.message] == 'User_Authenticated_successfully' ||
          _data["message"] == 'User_created_successfully') {
        Application.isShowPopup = _data[ApiKeys.show_popup];
        Application.adminPhoneNumber = _data[ApiKeys.phoneNumber].toString();
        Application.shareText = _data['share_text'];
        if (savedAddress.isNotEmpty) {
          Application.address = savedAddress;
        } else {
          prefs.setString(
              "address",
              _data[ApiKeys.user][0][ApiKeys.address].toString() != 'null'
                  ? _data[ApiKeys.user][0][ApiKeys.address].toString()
                  : '');
          Application.address =
              _data[ApiKeys.user][0][ApiKeys.address].toString() != 'null'
                  ? _data[ApiKeys.user][0][ApiKeys.address].toString()
                  : '';
        }
        if (savedName.isNotEmpty) {
          Application.userName = savedName;
        } else {
          prefs.setString(
              "name",
              _data[ApiKeys.user][0][ApiKeys.name].toString() != 'null'
                  ? _data[ApiKeys.user][0][ApiKeys.name].toString()
                  : '');
          Application.userName =
              _data[ApiKeys.user][0][ApiKeys.name].toString() != 'null'
                  ? _data[ApiKeys.user][0][ApiKeys.name].toString()
                  : '';
        }
        if (savedPhoneNumber.isNotEmpty) {
          if (_data[ApiKeys.user][0][ApiKeys.phone_number].toString() !=
              savedPhoneNumber) {
            _isLoading = true;
            notifyListeners();
            Utility.logoutUser(context);
            Application.isShowLogoutPopup = true;
            setAppData(_data, context);
          } else {
            setAppData(_data, context);
          }
        } else {
          setAppData(_data, context);
        }
      } else if (_data[ApiKeys.message] == 'Auth_token_failure') {
        _isLoading = true;
        notifyListeners();
        Application.isShowAuthPopup = true;
        // Utility.authErrorPopup(context);
      } else if (_data[ApiKeys.message] == 'User_blocked_by_admin') {
        Application.isShowPopup = _data[ApiKeys.show_popup];
        Application.adminPhoneNumber = _data[ApiKeys.phoneNumber].toString();
        _isLoading = true;
        notifyListeners();
        Application.isShowBlockedPopup =
            savedPhoneNumber.isNotEmpty ? true : true;
        Application.isShowLogoutPopup = false;
        Utility.logoutUser(context);
        setAppData(_data, context);
        // Utility.authErrorPopup(context);
      } else {
        _isLoading = true;
        notifyListeners();
        Application.isShowDatabasePopup = true;
        // Utility.databaseErrorPopup(context);
      }
    } else {
      _isLoading = true;
      notifyListeners();
      Utility.printLog('Some error occurred');
      Utility.databaseErrorPopup(context);
    }
  }
}
