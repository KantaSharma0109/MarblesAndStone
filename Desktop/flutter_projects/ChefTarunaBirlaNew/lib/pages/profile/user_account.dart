import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
// import 'package:ios_insecure_screen_detector/ios_insecure_screen_detector.dart';
import 'package:material_design_icons_flutter/material_design_icons_flutter.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../config/config.dart';
import '../../services/mysql_db_service.dart';
import '../../utils/utility.dart';

class UserAccount extends StatefulWidget {
  const UserAccount({Key? key}) : super(key: key);

  @override
  _UserAccountState createState() => _UserAccountState();
}

class _UserAccountState extends State<UserAccount> {
  String phoneNumber = '';
  bool isLoading = false;
  final nameController = TextEditingController();
  final addressController = TextEditingController();
  final emailController = TextEditingController();
  final pincodeController = TextEditingController();
  final countryController = TextEditingController();
  final stateController = TextEditingController();
  final cityController = TextEditingController();
  final phoneController = TextEditingController();
  String countryValue = "";
  String stateValue = "";
  String cityValue = "";
  String url = Constants.isDevelopment
      ? Constants.devBackendUrl
      : Constants.prodBackendUrl;
  // final IosInsecureScreenDetector _insecureScreenDetector =
  //     IosInsecureScreenDetector();
  bool _isCaptured = false;

  Future<void> getUserDetails() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    final phonenumber = prefs.getString('phonenumber') ?? '';
    // Utility.printLog();
    setState(() {
      phoneNumber = phonenumber;
      phoneController.text = phonenumber;
    });
    Map<String, dynamic> _getNews = await MySqlDBService().runQuery(
      requestType: RequestType.GET,
      url: '$url/users/getUserDetails/$phoneNumber',
    );

    bool _status = _getNews['status'];
    var _data = _getNews['data'];
    // Utility.printLog(_data);
    if (_status) {
      // data loaded
      SharedPreferences prefs = await SharedPreferences.getInstance();
      if (_data['data'][0]['email_id'].toString() != 'null') {
        emailController.text = _data['data'][0]['email_id'].toString();
        prefs.setString('email', _data['data'][0]['email_id'].toString());
      }
      if (_data['data'][0]['name'].toString() != 'null') {
        nameController.text = _data['data'][0]['name'].toString();
        prefs.setString('name', _data['data'][0]['name'].toString());
        Application.userName = _data['data'][0]['name'].toString();
      }
      if (_data['data'][0]['address'].toString() != 'null') {
        addressController.text = _data['data'][0]['address'].toString();
        prefs.setString('address', _data['data'][0]['address'].toString());
      }
      if (_data['data'][0]['pincode'].toString() != 'null') {
        pincodeController.text = _data['data'][0]['pincode'].toString();
        prefs.setString('address', _data['data'][0]['pincode'].toString());
      }
      setState(() => isLoading = true);
      Utility.showProgress(false);
    } else {
      Utility.printLog('Something went wrong.');
      Utility.showProgress(false);
      Utility.databaseErrorPopup(context);
    }
  }

  Future<void> saveUserDetails() async {
    Utility.showProgress(true);
    Map<String, dynamic> _getNews = await MySqlDBService().runQuery(
        requestType: RequestType.POST,
        url: '$url/users/saveUserDetails/$phoneNumber',
        body: {
          'name': nameController.text,
          'email_id': emailController.text,
          'address': addressController.text,
          'pincode': pincodeController.text
        });

    bool _status = _getNews['status'];
    var _data = _getNews['data'];
    // Utility.printLog(_data);
    if (_status) {
      // data loaded
      if (_data['message'].toString() == 'success') {
        SharedPreferences prefs = await SharedPreferences.getInstance();
        prefs.setString('email', emailController.text);
        prefs.setString('name', nameController.text);
        prefs.setString('address', addressController.text);
        prefs.setString('pincode', pincodeController.text);
        Application.userName = nameController.text;
        Utility.showProfileEditSuccessMessage(
            'Updated successfully', 'Your data is updated!!', context);
      } else {
        Utility.showProfileEditSuccessMessage(
            'Some error occured', 'Try again in some time!!', context);
      }
      setState(() => isLoading = true);
      Future.delayed(const Duration(milliseconds: 1000), () {
        Navigator.pop(context);
        Navigator.pop(context);
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
        getUserDetails();
      }
    } on SocketException catch (_) {
      Utility.printLog('not connected');
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
      getUserDetails();
    }
    super.initState();
  }

  @override
  void dispose() {
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
                  color: Palette.white,
                  size: 18.0,
                ),
                onPressed: () => Navigator.of(context).pop(),
              ),
              title: const Text(
                'Account',
                style: TextStyle(
                  color: Palette.white,
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
                : SingleChildScrollView(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.start,
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        const SizedBox(
                          height: 30.0,
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
                              // enabled: false,
                              readOnly: true,
                              onChanged: (value) {},
                              // keyboardType: TextInputType.multiline,
                              // minLines: 1,
                              // maxLines: 1,
                              controller: phoneController,
                              style: const TextStyle(
                                fontFamily: 'EuclidCircularA Regular',
                              ),
                              autofocus: false,
                              decoration: InputDecoration(
                                prefixIcon: Icon(
                                  MdiIcons.phoneOutline,
                                ),
                                counterText: "",
                                hintText: "",
                                focusColor: Palette.contrastColor,
                                focusedBorder: OutlineInputBorder(
                                    borderSide: const BorderSide(
                                      color: Color(0xffffffff),
                                      width: 1.3,
                                    ),
                                    borderRadius: BorderRadius.circular(10.0)),
                                enabledBorder: OutlineInputBorder(
                                    borderSide: const BorderSide(
                                        color: Color(0xffffffff), width: 1.0),
                                    borderRadius: BorderRadius.circular(10.0)),
                                contentPadding: const EdgeInsets.symmetric(
                                    vertical: 8.0, horizontal: 16.0),
                                filled: true,
                                fillColor: const Color(0xffffffff),
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
                              onChanged: (value) {},
                              keyboardType: TextInputType.multiline,
                              minLines: 1,
                              maxLines: 1,
                              controller: nameController,
                              style: const TextStyle(
                                fontFamily: 'EuclidCircularA Regular',
                              ),
                              autofocus: false,
                              decoration: InputDecoration(
                                prefixIcon: Icon(
                                  MdiIcons.formatTextVariant,
                                ),
                                counterText: "",
                                hintText: "Enter your full name",
                                focusColor: Palette.contrastColor,
                                focusedBorder: OutlineInputBorder(
                                    borderSide: const BorderSide(
                                      color: Color(0xffffffff),
                                      width: 1.3,
                                    ),
                                    borderRadius: BorderRadius.circular(10.0)),
                                enabledBorder: OutlineInputBorder(
                                    borderSide: const BorderSide(
                                        color: Color(0xffffffff), width: 1.0),
                                    borderRadius: BorderRadius.circular(10.0)),
                                contentPadding: const EdgeInsets.symmetric(
                                    vertical: 8.0, horizontal: 16.0),
                                filled: true,
                                fillColor: const Color(0xffffffff),
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
                              onChanged: (value) {},
                              keyboardType: TextInputType.multiline,
                              minLines: 1,
                              maxLines: 1,
                              controller: emailController,
                              style: const TextStyle(
                                fontFamily: 'EuclidCircularA Regular',
                              ),
                              autofocus: false,
                              decoration: InputDecoration(
                                prefixIcon: Icon(
                                  MdiIcons.emailOutline,
                                ),
                                counterText: "",
                                hintText: "Enter your email",
                                focusColor: Palette.contrastColor,
                                focusedBorder: OutlineInputBorder(
                                    borderSide: const BorderSide(
                                      color: Color(0xffffffff),
                                      width: 1.3,
                                    ),
                                    borderRadius: BorderRadius.circular(10.0)),
                                enabledBorder: OutlineInputBorder(
                                    borderSide: const BorderSide(
                                        color: Color(0xffffffff), width: 1.0),
                                    borderRadius: BorderRadius.circular(10.0)),
                                contentPadding: const EdgeInsets.symmetric(
                                    vertical: 8.0, horizontal: 16.0),
                                filled: true,
                                fillColor: const Color(0xffffffff),
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
                              onChanged: (value) {},
                              keyboardType: TextInputType.multiline,
                              minLines: 1,
                              maxLines: 5,
                              controller: addressController,
                              style: const TextStyle(
                                fontFamily: 'EuclidCircularA Regular',
                              ),
                              autofocus: false,
                              decoration: InputDecoration(
                                prefixIcon: Icon(
                                  MdiIcons.mapMarkerOutline,
                                ),
                                counterText: "",
                                hintText: "Enter your address",
                                focusColor: Palette.contrastColor,
                                focusedBorder: OutlineInputBorder(
                                    borderSide: const BorderSide(
                                      color: Color(0xffffffff),
                                      width: 1.3,
                                    ),
                                    borderRadius: BorderRadius.circular(10.0)),
                                enabledBorder: OutlineInputBorder(
                                    borderSide: const BorderSide(
                                        color: Color(0xffffffff), width: 1.0),
                                    borderRadius: BorderRadius.circular(10.0)),
                                contentPadding: const EdgeInsets.symmetric(
                                    vertical: 8.0, horizontal: 16.0),
                                filled: true,
                                fillColor: const Color(0xffffffff),
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
                              onChanged: (value) {},
                              keyboardType: TextInputType.multiline,
                              minLines: 1,
                              maxLines: 5,
                              controller: pincodeController,
                              style: const TextStyle(
                                fontFamily: 'EuclidCircularA Regular',
                              ),
                              autofocus: false,
                              decoration: InputDecoration(
                                prefixIcon: Icon(
                                  MdiIcons.formTextboxPassword,
                                ),
                                counterText: "",
                                hintText: "Enter your pincode",
                                focusColor: Palette.contrastColor,
                                focusedBorder: OutlineInputBorder(
                                    borderSide: const BorderSide(
                                      color: Color(0xffffffff),
                                      width: 1.3,
                                    ),
                                    borderRadius: BorderRadius.circular(10.0)),
                                enabledBorder: OutlineInputBorder(
                                    borderSide: const BorderSide(
                                        color: Color(0xffffffff), width: 1.0),
                                    borderRadius: BorderRadius.circular(10.0)),
                                contentPadding: const EdgeInsets.symmetric(
                                    vertical: 8.0, horizontal: 16.0),
                                filled: true,
                                fillColor: const Color(0xffffffff),
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
                          child: GestureDetector(
                            onTap: () {
                              // if(addressController.text.isNotEmpty)
                              setState(() {
                                isLoading = false;
                              });
                              saveUserDetails();
                            },
                            child: Container(
                              height: 48.0,
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(10),
                                color: Palette.contrastColor,
                                boxShadow: [
                                  BoxShadow(
                                    color: const Color(0xffFFF0D0)
                                        .withOpacity(0.0),
                                    blurRadius: 30.0, // soften the shadow
                                    spreadRadius: 0.0, //extend the shadow
                                    offset: const Offset(
                                      0.0, // Move to right 10  horizontally
                                      0.0, // Move to bottom 10 Vertically
                                    ),
                                  ),
                                ],
                              ),
                              child: const Center(
                                child: Text(
                                  'Save',
                                  style: TextStyle(
                                    color: Colors.white,
                                    fontSize: 16.0,
                                    fontFamily: 'EuclidCircularA Medium',
                                  ),
                                ),
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ));
  }
}
