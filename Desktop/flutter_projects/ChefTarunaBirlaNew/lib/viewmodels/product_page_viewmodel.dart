import 'package:chef_taruna_birla/models/products.dart';
import 'package:flutter/material.dart';

import '../common/common.dart';
import '../config/config.dart';
import '../models/slider.dart';
import '../services/mysql_db_service.dart';
import '../utils/utility.dart';

class ProductPageViewModel with ChangeNotifier {
  List<Products> _productList = [];
  bool _isLoading = false;
  bool _isEachProductLoading = false;
  bool _isVerticalLoading = false;
  bool _isSearching = false;
  int _offset = 0;
  String _userId = '';
  String _selectedCategory = '';
  String url = Constants.isDevelopment
      ? Constants.devBackendUrl
      : Constants.prodBackendUrl;
  List<AppSlider> _appslider = [];

  bool get isLoading => _isLoading;
  bool get isEachProductLoading => _isEachProductLoading;
  bool get isVerticalLoading => _isVerticalLoading;
  bool get isSearching => _isSearching;
  List<Products> get productList => _productList;
  String get selectedCategory => _selectedCategory;
  List<AppSlider> get appslider => _appslider;

  setOffset() {
    _offset = _offset + 20;
    notifyListeners();
  }

  setSelectedCategory(String value) {
    _selectedCategory = value;
    notifyListeners();
  }

  // setVerticalLoading(bool value) {
  //   _isVerticalLoading = value;
  //   notifyListeners();
  // }
  //
  // Future<void> updateCart(id, value, BuildContext context) async {
  //   Map<String, dynamic> _updateCart = await MySqlDBService().runQuery(
  //     requestType: RequestType.POST,
  //     url:
  //         value == 'add' ? '$url/users/addtocart' : '$url/users/removefromcart',
  //     body: {
  //       'user_id': _userId,
  //       'category': 'product',
  //       'id': id,
  //     },
  //   );
  //
  //   bool _status = _updateCart['status'];
  //   var _data = _updateCart['data'];
  //   // print(_data);
  //   if (_status) {
  //     // data loaded
  //     // print(_data);
  //     if (value == 'add') {
  //       Navigator.push(
  //         context,
  //         MaterialPageRoute(
  //           builder: (context) => const CartPage(),
  //         ),
  //       );
  //     }
  //   } else {
  //     Utility.printLog('Something went wrong.');
  //   }
  // }
  //
  // Future<void> updateWhislist(id, value) async {
  //   Map<String, dynamic> _updateCart = await MySqlDBService().runQuery(
  //     requestType: RequestType.POST,
  //     url: value == 'add'
  //         ? '$url/users/addtowhislist'
  //         : '$url/users/removefromwhislist',
  //     body: {
  //       'user_id': _userId,
  //       'category': 'product',
  //       'id': id,
  //     },
  //   );
  //
  //   bool _status = _updateCart['status'];
  //   var _data = _updateCart['data'];
  //   // print(_data);
  //   if (_status) {
  //   } else {
  //     Utility.printLog('Something went wrong.');
  //   }
  // }

  //Get product Images
  Future<void> getProductImages(String id, BuildContext context) async {
    _isEachProductLoading = false;
    notifyListeners();
    Utility.showProgress(true);
    Map<String, dynamic> _getNews = await MySqlDBService().runQuery(
      requestType: RequestType.GET,
      url: Constants.isDevelopment
          ? '${Constants.devBackendUrl}/getproductImages/$id'
          : '${Constants.prodBackendUrl}/getproductImages/$id',
    );

    bool _status = _getNews['status'];
    var _data = _getNews['data'];
    if (_status) {
      _isEachProductLoading = true;
      notifyListeners();
      Utility.showProgress(false);
    } else {
      _isEachProductLoading = true;
      notifyListeners();
      Utility.printLog('Some error occurred');
      Utility.databaseErrorPopup(context);
    }
  }

  //Get Search product Data Function
  Future<void> getSearchedProducts(String value, BuildContext context) async {
    _isSearching = true;
    _isLoading = false;
    _offset = 0;
    _productList.clear();
    notifyListeners();
    // Utility.showProgress(true);
    Map<String, dynamic> _getNews = await MySqlDBService().runQuery(
      requestType: RequestType.GET,
      url:
          '$url/getSearchedProduct/$value/${Application.userId}?language_id=${Application.languageId}',
    );

    bool _status = _getNews['status'];
    var _data = _getNews['data'];
    if (_status) {
      _data[ApiKeys.data].forEach((product) => {
            _productList.add(
              Products(
                id: product[ApiKeys.id].toString(),
                name: product[ApiKeys.name].toString(),
                description: product[ApiKeys.description].toString(),
                c_name: product[ApiKeys.c_name].toString(),
                category_id: product[ApiKeys.category_id].toString(),
                price: product[ApiKeys.price].toString(),
                discount_price: product[ApiKeys.discount_price].toString(),
                stock: int.parse(product[ApiKeys.stock].toString()),
                image_path: product[ApiKeys.image_path].toString(),
                share_url: product[ApiKeys.share_url].toString(),
                // count: int.parse(product[ApiKeys.count].toString()),
                // whislistcount:
                //     int.parse(product[ApiKeys.whislistcount].toString()),
              ),
            ),
          });
      _isLoading = true;
      notifyListeners();
      // Utility.showProgress(false);
    } else {
      _isLoading = true;
      notifyListeners();
      Utility.printLog('Some error occurred');
      Utility.databaseErrorPopup(context);
    }
  }

  //Get More product Data Function
  Future<void> getMoreProductData(BuildContext context) async {
    _isSearching = false;
    _isVerticalLoading = true;
    notifyListeners();
    Map<String, dynamic> _getNews = await MySqlDBService().runQuery(
      requestType: RequestType.GET,
      url: _selectedCategory == 'All'
          ? '$url/getUserProduct/${Application.userId}/$_offset?language_id=${Application.languageId}'
          : '$url/getCategoryProduct/$_selectedCategory/${Application.userId}/$_offset?language_id=${Application.languageId}',
    );

    bool _status = _getNews['status'];
    var _data = _getNews['data'];
    if (_status) {
      var jsonResult = _data[ApiKeys.data];
      jsonResult.forEach((product) => {
            _productList.add(
              Products.fromJson(product),
            ),
          });

      _isVerticalLoading = false;
      notifyListeners();
    } else {
      notifyListeners();
      Utility.printLog('Some error occurred');
      Utility.databaseErrorPopup(context);
    }
  }

  //Get product Data Function
  Future<void> getProductData(BuildContext context) async {
    // SharedPreferences prefs = await SharedPreferences.getInstance();
    // _userId = prefs.getString('user_id') ?? "";
    _isSearching = false;
    _isLoading = false;
    _offset = 0;
    _appslider.clear();
    Utility.showProgress(true);
    Map<String, dynamic> _getNews = await MySqlDBService().runQuery(
      requestType: RequestType.GET,
      url: _selectedCategory == 'All' || _selectedCategory.isEmpty
          ? '$url/getUserProduct/${Application.userId}/$_offset?language_id=${Application.languageId}'
          : '$url/getCategoryProduct/$_selectedCategory/${Application.userId}/$_offset?language_id=${Application.languageId}',
    );

    bool _status = _getNews['status'];
    var _data = _getNews['data'];
    if (_status) {
      _productList.clear();
      var jsonResult = _data[ApiKeys.data];
      jsonResult.forEach((product) => {
            _productList.add(
              Products.fromJson(product),
            ),
          });

      _data[ApiKeys.slider].forEach((slider) => {
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
      _isLoading = true;
      notifyListeners();
      Utility.showProgress(false);
    } else {
      _isLoading = true;
      notifyListeners();
      Utility.printLog('Some error occurred');
      Utility.databaseErrorPopup(context);
    }
  }
}
