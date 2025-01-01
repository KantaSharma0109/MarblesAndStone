import 'package:chef_taruna_birla/models/blog.dart';
import 'package:flutter/material.dart';

import '../common/common.dart';
import '../config/config.dart';
import '../services/mysql_db_service.dart';
import '../utils/utility.dart';

class BlogPageViewModel with ChangeNotifier {
  List<Blogs> _bloglist = [];
  late Blogs _firstBlog;
  bool _isLoading = false;
  bool _isEachBlogLoading = false;
  bool _isVerticalLoading = false;
  bool _isSearching = false;
  int _offset = 0;

  bool get isLoading => _isLoading;
  bool get isEachBlogLoading => _isEachBlogLoading;
  bool get isVerticalLoading => _isVerticalLoading;
  bool get isSearching => _isSearching;
  Blogs? get firstBlog => _firstBlog;
  List<Blogs> get bloglist => _bloglist;

  setOffset() {
    _offset = _offset + 20;
    notifyListeners();
  }

  // setVerticalLoading(bool value) {
  //   _isVerticalLoading = value;
  //   notifyListeners();
  // }

  //Get Blog Images
  Future<void> getBlogImages(String id, BuildContext context) async {
    _isEachBlogLoading = false;
    notifyListeners();
    Utility.showProgress(true);
    Map<String, dynamic> _getNews = await MySqlDBService().runQuery(
      requestType: RequestType.GET,
      url: Constants.isDevelopment
          ? '${Constants.devBackendUrl}/getBlogImages/$id'
          : '${Constants.prodBackendUrl}/getBlogImages/$id',
    );

    bool _status = _getNews['status'];
    var _data = _getNews['data'];
    if (_status) {
      _isEachBlogLoading = true;
      notifyListeners();
      Utility.showProgress(false);
    } else {
      _isEachBlogLoading = true;
      notifyListeners();
      Utility.printLog('Some error occurred');
      Utility.databaseErrorPopup(context);
    }
  }

  //Get Search Blog Data Function
  Future<void> getSearchedBlogs(String value, BuildContext context) async {
    _isSearching = true;
    _isLoading = false;
    _offset = 0;
    _bloglist.clear();
    notifyListeners();
    // Utility.showProgress(true);
    Map<String, dynamic> _getNews = await MySqlDBService().runQuery(
      requestType: RequestType.GET,
      url: Constants.isDevelopment
          ? '${Constants.devBackendUrl}/getSearchedBlogs/$value?language_id=${Application.languageId}'
          : '${Constants.prodBackendUrl}/getSearchedBlogs/$value?language_id=${Application.languageId}',
    );

    bool _status = _getNews['status'];
    var _data = _getNews['data'];
    if (_status) {
      _data[ApiKeys.data].forEach((blog) => {
            _bloglist.add(
              Blogs(
                id: blog[ApiKeys.id].toString(),
                title: blog[ApiKeys.title].toString(),
                description: blog[ApiKeys.description].toString(),
                image_path: blog[ApiKeys.path].toString(),
                pdflink: blog[ApiKeys.pdf].toString(),
                created_at: blog[ApiKeys.created_at].toString(),
                share_url: blog[ApiKeys.share_url].toString(),
              ),
            ),
          });
      _firstBlog = _bloglist[0];
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

  //Get More Blog Data Function
  Future<void> getMoreBlogData(BuildContext context) async {
    _isSearching = false;
    _isVerticalLoading = true;
    notifyListeners();
    Map<String, dynamic> _getNews = await MySqlDBService().runQuery(
      requestType: RequestType.GET,
      url: Constants.isDevelopment
          ? '${Constants.devBackendUrl}/getBlogs/$_offset?language_id=${Application.languageId}'
          : '${Constants.prodBackendUrl}/getBlogs/$_offset?language_id=${Application.languageId}',
    );

    bool _status = _getNews['status'];
    var _data = _getNews['data'];
    if (_status) {
      _data[ApiKeys.data].forEach((blog) => {
            _bloglist.add(Blogs(
              id: blog[ApiKeys.id].toString(),
              title: blog[ApiKeys.title].toString(),
              description: blog[ApiKeys.description].toString(),
              image_path: blog[ApiKeys.path].toString(),
              pdflink: blog[ApiKeys.pdf].toString(),
              created_at: blog[ApiKeys.created_at].toString(),
              share_url: blog[ApiKeys.share_url].toString(),
            ))
          });
      _isVerticalLoading = false;
      notifyListeners();
    } else {
      notifyListeners();
      Utility.printLog('Some error occurred');
      Utility.databaseErrorPopup(context);
    }
  }

  //Get Blog Data Function
  Future<void> getBlogData(BuildContext context) async {
    _isSearching = false;
    _isLoading = false;
    notifyListeners();
    Utility.showProgress(true);
    Map<String, dynamic> _getNews = await MySqlDBService().runQuery(
      requestType: RequestType.GET,
      url: Constants.isDevelopment
          ? '${Constants.devBackendUrl}/getBlogs/$_offset?language_id=${Application.languageId}'
          : '${Constants.prodBackendUrl}/getBlogs/$_offset?language_id=${Application.languageId}',
    );

    bool _status = _getNews['status'];
    var _data = _getNews['data'];
    if (_status) {
      _bloglist.clear();
      _data[ApiKeys.data].forEach((blog) => {
            _bloglist.add(Blogs(
              id: blog[ApiKeys.id].toString(),
              title: blog[ApiKeys.title].toString(),
              description: blog[ApiKeys.description].toString(),
              image_path: blog[ApiKeys.path].toString(),
              pdflink: blog[ApiKeys.pdf].toString(),
              created_at: blog[ApiKeys.created_at].toString(),
              share_url: blog[ApiKeys.share_url].toString(),
            ))
          });
      _firstBlog = _bloglist[0];
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
