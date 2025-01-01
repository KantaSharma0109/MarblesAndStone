import 'dart:io';

import 'package:chef_taruna_birla/common/common.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
// import 'package:ios_insecure_screen_detector/ios_insecure_screen_detector.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../config/config.dart';
import '../../models/live.dart';
import '../../services/mysql_db_service.dart';
import '../../utils/utility.dart';

class EachLive extends StatefulWidget {
  final String id;
  const EachLive({
    Key? key,
    required this.id,
  }) : super(key: key);

  @override
  State<EachLive> createState() => _EachLiveState();
}

class _EachLiveState extends State<EachLive> {
  List<Live> liveList = [];
  bool isLoading = false;
  String user_id = '';
  String url = Constants.isDevelopment
      ? Constants.devBackendUrl
      : Constants.prodBackendUrl;
  // final IosInsecureScreenDetector _insecureScreenDetector =
  //     IosInsecureScreenDetector();
  bool _isCaptured = false;

  Future<void> getLive() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    final userId = prefs.getString('user_id') ?? '';
    setState(() {
      user_id = userId;
    });
    // Utility.printLog(user_id);
    Map<String, dynamic> _getNews = await MySqlDBService().runQuery(
      requestType: RequestType.GET,
      url: '$url/getUserLive/$user_id/${widget.id}',
    );

    bool _status = _getNews['status'];
    var _data = _getNews['data'];
    // Utility.printLog(_data);
    if (_status) {
      liveList.clear();
      for (var i = 0; i < _data['data'].length; i++) {
        liveList.add(
          Live(
            id: _data['data'][i]['id'].toString(),
            title: _data['data'][i]['title'].toString(),
            description: _data['data'][i]['description'].toString(),
            promo_video: _data['data'][i]['promo_video'].toString(),
            price: _data['data'][i]['price'].toString(),
            discount_price: _data['data'][i]['discount_price'].toString(),
            image_path: _data['data'][i]['image_path'].toString(),
            subscribed: _data['data'][i]['subscribed'],
            live_date: _data['data'][i]['live_date'].toString(),
            url: _data['data'][i]['url'].toString(),
            created_at: _data['data'][i]['created_at'].toString(),
            share_url: _data['data'][i]['share_url'].toString(),
            liveUsersCount: _data['data'][i][ApiKeys.live_users_count],
          ),
        );
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
      final result = await InternetAddress.lookup('cheftarunabirla.com');
      if (result.isNotEmpty && result[0].rawAddress.isNotEmpty) {
        Utility.printLog('connected');
        getLive();
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
    if (Platform.isIOS) {
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
    }
    Utility.showProgress(true);
    if (!kIsWeb) {
      _filterRetriever();
    } else {
      getLive();
    }
    super.initState();
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
        : Container();
  }
}
