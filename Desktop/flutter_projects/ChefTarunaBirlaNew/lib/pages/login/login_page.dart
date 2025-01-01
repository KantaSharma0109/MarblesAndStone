import 'dart:io';

import 'package:chef_taruna_birla/utils/utility.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:intl_phone_field/intl_phone_field.dart';
// import 'package:ios_insecure_screen_detector/ios_insecure_screen_detector.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../config/config.dart';
import '../../services/mysql_db_service.dart';
import '../../viewmodels/login_page_view_model.dart';
import '../main_container.dart';

enum MobileVerificationState {
  SHOW_MOBILE_FROM_STATE,
  SHOW_OTP_FORM_STATE,
}

class LoginPage extends StatefulWidget {
  const LoginPage({Key? key}) : super(key: key);

  @override
  _LoginPageState createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  String isUser = 'true';
  late String databasename;
  late String type;
  late String name;
  String deviceToken = '';
  String completephonenumber = '';

  bool showLoading = false;
  bool isOtpScreen = false;
  // final IosInsecureScreenDetector _insecureScreenDetector =
  //     IosInsecureScreenDetector();
  bool _isCaptured = false;

  MobileVerificationState currentState =
      MobileVerificationState.SHOW_MOBILE_FROM_STATE;
  final phoneController = TextEditingController();
  final otpController = TextEditingController();
  late String verificationId;

  FirebaseAuth _auth = FirebaseAuth.instance;

  void signInWithPhoneAuthCredential(
      PhoneAuthCredential phoneAuthCredential) async {
    Utility.printLog('entered');
    setState(() {
      showLoading = true;
    });

    try {
      final authCredential =
          await _auth.signInWithCredential(phoneAuthCredential);

      if (authCredential.user != null) {
        _saveLogin();
      }
    } on FirebaseAuthException catch (e) {
      setState(() {
        showLoading = false;
      });

      Utility.printLog('error: ${e.message}');
    }
  }

  Future<String> _saveLogin() async {
    String url = Constants.isDevelopment
        ? Constants.devBackendUrl
        : Constants.prodBackendUrl;
    Map<String, dynamic> _saveDeviceTokenData = await MySqlDBService().runQuery(
      requestType: RequestType.POST,
      url: '$url/users/save_user_mobile',
      body: {
        'token': deviceToken,
        'phone_number':
            Provider.of<LoginPageViewModel>(context, listen: false).phoneNumber,
      },
    );

    bool _status = _saveDeviceTokenData['status'];
    var _data = _saveDeviceTokenData['data'];

    if (_status) {
      Utility.printLog(_data['message'].toString());
      if (_data['message'].toString() == 'success') {
        SharedPreferences prefs = await SharedPreferences.getInstance();
        prefs.setBool('loggedIn', true);
        prefs.setString(
            'phonenumber',
            Provider.of<LoginPageViewModel>(context, listen: false)
                .phoneNumber);
        Application.phoneNumber =
            Provider.of<LoginPageViewModel>(context, listen: false).phoneNumber;
        if (_data['user_id'].toString().isNotEmpty) {
          prefs.setString('user_id', _data['user_id'].toString());
          Application.userId = _data['user_id'].toString();
        }

        setState(() {
          showLoading = false;
        });

        Navigator.pushAndRemoveUntil(
          context,
          MaterialPageRoute(
            builder: (context) => const MainContainer(),
          ),
          (Route<dynamic> route) => false,
        );
      } else if (_data['message'].toString() == 'deviceNotMatched') {
        setState(() {
          showLoading = false;
        });

        _showMyDialog('Looks like you already have an account!');
      } else if (_data['message'].toString() == 'User_blocked_by_admin') {
        setState(() {
          showLoading = false;
        });

        Utility.authErrorPopup(
            context,
            'Looks like you are blocked by admin so you have been logged out by the application please contact support: ' +
                Application.adminPhoneNumber);
      } else {
        setState(() {
          showLoading = false;
        });

        _showMyDialog('Some error occurred!!');
      }
    } else {
      setState(() {
        showLoading = false;
      });

      Utility.printLog('Something went wrong while saving token.');
      Utility.printLog('Some error occurred');
      Utility.databaseErrorPopup(context);
    }

    return 'saved';
  }

  Future<void> _showMyDialog(message) async {
    return showDialog<void>(
      context: context,
      barrierDismissible: false, // user must tap button!
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text(message),
          content: SingleChildScrollView(
            child: ListBody(
              children: <Widget>[
                const Text('Contact Support for this !!'),
                Text('Call on: ' + Application.adminPhoneNumber),
              ],
            ),
          ),
          actions: <Widget>[
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('Ok'),
            ),
          ],
        );
      },
    );
  }

  getMobileFromWidget(context) {
    return Padding(
      padding: MediaQuery.of(context).viewInsets,
      child: SingleChildScrollView(
        child: SizedBox(
          width: double.infinity,
          // height: 800.0,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Image.asset(
                'assets/images/logo.png',
                width: 200.0,
              ),
              const Text(
                'Welcome 👋',
                style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 26.0,
                    color: Palette.contrastColor,
                    fontFamily: "EuclidCircularA Medium"),
              ),
              const SizedBox(
                height: 10.0,
              ),
              const Text(
                'We are glad to have you back !!',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontWeight: FontWeight.w500,
                  color: Color(0xffAAAEB0),
                  // fontFamily: GoogleFonts.montserrat().fontFamily,
                ),
              ),
              const SizedBox(
                height: 20.0,
              ),
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: Row(
                  children: [
                    Expanded(
                      child: Container(
                        decoration: BoxDecoration(
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
                          color: Palette.white,
                          borderRadius: BorderRadius.circular(10.0),
                        ),
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(10.0),
                          child: IntlPhoneField(
                            initialCountryCode: 'IN',
                            controller: phoneController,
                            keyboardType: TextInputType.number,
                            inputFormatters: <TextInputFormatter>[
                              FilteringTextInputFormatter.digitsOnly
                            ],
                            textInputAction: TextInputAction.done,
                            dropdownDecoration:
                                const BoxDecoration(color: Palette.white),
                            decoration: InputDecoration(
                              counterText: "",
                              hintText: "Enter 10-digit The Phone Number",
                              focusedBorder: OutlineInputBorder(
                                  borderSide: const BorderSide(
                                    color: Palette.secondaryColor,
                                    width: 0.0,
                                  ),
                                  borderRadius: BorderRadius.circular(8.0)),
                              enabledBorder: OutlineInputBorder(
                                  borderSide: const BorderSide(
                                      color: Color(0xffffffff), width: 0.0),
                                  borderRadius: BorderRadius.circular(8.0)),
                              contentPadding: const EdgeInsets.symmetric(
                                  vertical: 8.0, horizontal: 16.0),
                              filled: true,
                              fillColor: const Color(0xffffffff),
                            ),
                            onChanged: (phone) {
                              setState(() {
                                completephonenumber = phone.completeNumber;
                              });
                            },
                            onCountryChanged: (phone) {
                              Utility.printLog('Country code changed to: ');
                            },
                          ),
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
                padding:
                    const EdgeInsets.symmetric(vertical: 0.0, horizontal: 8.0),
                child: ElevatedButton(
                  onPressed: () async {
                    if (completephonenumber.length > 10) {
                      Utility.printLog(completephonenumber);
                      Provider.of<LoginPageViewModel>(context, listen: false)
                          .setPhoneNumber(phoneController.text);
                      setState(() {
                        showLoading = true;
                      });

                      if (kIsWeb) {
                        //   await _auth
                        //       .signInWithPhoneNumber(
                        //     completephonenumber,
                        //     RecaptchaVerifier(
                        //       container: null,
                        //       size: RecaptchaVerifierSize.compact,
                        //       theme: RecaptchaVerifierTheme.dark,
                        //       onSuccess: () {
                        //         setState(() {
                        //           showLoading = false;
                        //         });
                        //       },
                        //       onError: (FirebaseAuthException error) async {
                        //         Utility.printLog("error");
                        //         Utility.printLog(error.message ?? "");
                        //         setState(() {
                        //           showLoading = false;
                        //         });
                        //       },
                        //       onExpired: () async {
                        //         Utility.printLog('reCAPTCHA Expired!');
                        //         setState(() {
                        //           showLoading = false;
                        //         });
                        //       },
                        //     ),
                        //   )
                        //       .then((confirmationResult) {
                        //     // SMS sent. Prompt user to type the code from the message, then sign the
                        //     // user in with confirmationResult.confirm(code).
                        //     setState(() {
                        //       currentState =
                        //           MobileVerificationState.SHOW_OTP_FORM_STATE;
                        //       verificationId = confirmationResult.verificationId;
                        //     });
                        //   }).catchError((error) {
                        //     Utility.printLog(error);
                        //   });
                      } else {
                        await _auth.verifyPhoneNumber(
                          // timeout: const Duration(seconds: 60),
                          phoneNumber: completephonenumber,
                          verificationCompleted:
                              (PhoneAuthCredential phoneAuthCredential) async {
                            User? user;
                            bool error = false;
                            setState(() {
                              showLoading = false;
                            });
                            try {
                              user = (await _auth.signInWithCredential(
                                      phoneAuthCredential))
                                  .user!;
                            } catch (e) {
                              Utility.printLog(
                                  "Failed to sign in: " + e.toString());
                              error = true;
                            }
                          },
                          verificationFailed:
                              (FirebaseAuthException verificationFailed) async {
                            setState(() {
                              showLoading = false;
                            });
                            if (verificationFailed.code ==
                                'invalid-phone-number') {
                              Utility.printLog(
                                  'The provided phone number is not valid.');
                              Utility.showSnacbar(context,
                                  'Please enter a correct phone number!!');
                            }
                            Utility.printLog(
                                'verification error: ${verificationFailed.message}');
                            Utility.printLog(
                                'verification error: ${verificationFailed.code}');
                            Utility.showSnacbar(context,
                                'Some error occurred, Please try after some time!!');
                          },
                          codeSent: (verificationId, resendingCode) async {
                            Utility.printLog('code has sent');
                            setState(() {
                              showLoading = false;
                              currentState =
                                  MobileVerificationState.SHOW_OTP_FORM_STATE;
                              this.verificationId = verificationId;
                              isOtpScreen = true;
                            });
                            Utility.printLog(
                                'Verification id= ' + verificationId);
                            Utility.printLog(
                                'Phone Number = ' + phoneController.text);
                            Utility.printLog(
                                'Code Sent = ' + resendingCode.toString());
                            // Provider.of<LoginPageViewModel>(context,
                            //         listen: false)
                            //     .setOptScreen(true);
                            Provider.of<LoginPageViewModel>(context,
                                    listen: false)
                                .setBoth(true, verificationId);
                          },
                          codeAutoRetrievalTimeout: (verificationId) async {},
                        );
                      }
                    }
                  },
                  child: Padding(
                    padding: const EdgeInsets.symmetric(
                        vertical: 12.0, horizontal: 0.0),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: const [
                        Text('Get OTP'),
                        SizedBox(
                          width: 10.0,
                        ),
                        Icon(
                          Icons.arrow_forward_ios_rounded,
                          size: 18.0,
                        )
                      ],
                    ),
                  ),
                  style: ElevatedButton.styleFrom(
                      backgroundColor: Palette.secondaryColor,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8.0),
                      ),
                      shadowColor: Colors.black.withOpacity(0.5),
                      elevation: 20.0),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  getOtpFromWidget(context) {
    return SingleChildScrollView(
      child: SizedBox(
        width: double.infinity,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Image.asset(
              'assets/images/logo.png',
              width: 200.0,
            ),
            const Text(
              'Welcome 👋',
              style: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 26.0,
                  color: Palette.contrastColor,
                  fontFamily: 'EuclidCircularA Medium'),
            ),
            const SizedBox(
              height: 10.0,
            ),
            const Text(
              'You will recieve an OTP via text message !!',
              textAlign: TextAlign.center,
              style: TextStyle(
                  fontWeight: FontWeight.w500,
                  color: Color(0xffAAAEB0),
                  fontFamily: 'EuclidCircularA Regular'),
            ),
            const SizedBox(
              height: 20.0,
            ),
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: Container(
                decoration: BoxDecoration(
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
                  color: Palette.white,
                  borderRadius: BorderRadius.circular(10.0),
                ),
                child: TextField(
                  maxLength: 6,
                  keyboardType: TextInputType.number,
                  inputFormatters: <TextInputFormatter>[
                    FilteringTextInputFormatter.digitsOnly
                  ],
                  controller: otpController,
                  style: const TextStyle(fontFamily: 'EuclidCircularA Regular'),
                  autofocus: false,
                  textInputAction: TextInputAction.done,
                  decoration: InputDecoration(
                    counterText: "",
                    hintText: "Enter 6-digit OTP",
                    focusedBorder: OutlineInputBorder(
                        borderSide: const BorderSide(
                          color: Palette.secondaryColor,
                          width: 0.0,
                        ),
                        borderRadius: BorderRadius.circular(8.0)),
                    enabledBorder: OutlineInputBorder(
                        borderSide: const BorderSide(
                            color: Color(0xffffffff), width: 0.0),
                        borderRadius: BorderRadius.circular(8.0)),
                    contentPadding: const EdgeInsets.symmetric(
                        vertical: 8.0, horizontal: 16.0),
                    filled: true,
                    fillColor: const Color(0xffffffff),
                  ),
                ),
              ),
            ),
            const SizedBox(
              height: 10.0,
            ),
            Padding(
              padding:
                  const EdgeInsets.symmetric(vertical: 0.0, horizontal: 8.0),
              child: ElevatedButton(
                onPressed: () async {
                  if (otpController.text.length == 6) {
                    // print('OTP Entered');
                    PhoneAuthCredential phoneAuthCredential =
                        PhoneAuthProvider.credential(
                            verificationId: Provider.of<LoginPageViewModel>(
                                    context,
                                    listen: false)
                                .verificationId,
                            smsCode: otpController.text);
                    // await _auth.signInWithCredential(phoneAuthCredential);
                    signInWithPhoneAuthCredential(phoneAuthCredential);
                  } else {
                    Utility.showSnacbar(context, 'OTP must be of 6 digit');
                  }
                },
                child: Padding(
                  padding: const EdgeInsets.symmetric(
                      vertical: 12.0, horizontal: 0.0),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: const [
                      Text('Submit'),
                      SizedBox(
                        width: 10.0,
                      ),
                      Icon(
                        Icons.arrow_forward_ios_rounded,
                        size: 18.0,
                      )
                    ],
                  ),
                ),
                style: ElevatedButton.styleFrom(
                    backgroundColor: Palette.secondaryColor,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8.0),
                    ),
                    shadowColor: Colors.black.withOpacity(0.5),
                    elevation: 20.0),
              ),
            ),
          ],
        ),
      ),
    );
  }

  _loginStatus() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    final String token = prefs.getString('token') ?? '';

    setState(() {
      deviceToken = token;
    });
  }

  @override
  void initState() {
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
    super.initState();
    _loginStatus();
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
        : Padding(
            padding:
                const EdgeInsets.symmetric(vertical: 8.0, horizontal: 24.0),
            child: showLoading
                ? const Center(
                    child: CircularProgressIndicator(),
                  )
                : !context.watch<LoginPageViewModel>().isOtpScreen
                    ? getMobileFromWidget(context)
                    : getOtpFromWidget(context),
          );
  }
}
