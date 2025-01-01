import 'package:chef_taruna_birla/pages/login/otp_signIn.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;

class SignInScreen extends StatefulWidget {
  const SignInScreen({super.key});

  @override
  SignInScreenState createState() => SignInScreenState();
}

class SignInScreenState extends State<SignInScreen> {
  String isUser = 'true';
  late String databasename;
  late String type;
  late String name;
  String deviceToken = '';
  String completephonenumber = '';
  bool showLoading = false;
  bool isOtpScreen = false;

  final TextEditingController phoneController = TextEditingController();
  String countryCode = "+91"; // Country code is set to +91
  final FirebaseAuth _auth = FirebaseAuth.instance;
  String verificationId = '';

  Future<void> checkPhoneNumber() async {
    String phoneNumber =
        phoneController.text.trim(); // Do not add the country code here

    print('Phone number being sent to database: $phoneNumber');

    var url = Uri.parse(
        'http://192.168.29.202:8080/taruna_birla_api/login_check.php'); // Update with your PHP file URL

    var response = await http.post(url, body: {
      'phone_number':
          phoneNumber, // Send only the phone number without the country code
    });

    var responseData = json.decode(response.body);

    if (responseData['status'] == 'success') {
      var userData = responseData['user_data'];

      // Firebase OTP verification logic
      String fullPhoneNumber = "+91" +
          phoneController.text
              .trim(); // Assuming country code is always +91 for India

      await FirebaseAuth.instance.verifyPhoneNumber(
        phoneNumber: fullPhoneNumber,
        verificationCompleted: (PhoneAuthCredential credential) async {
          // You can auto-sign in here with the credential if needed
          await _auth.signInWithCredential(credential);
        },
        verificationFailed: (FirebaseAuthException ex) {
          // Print error to console
          debugPrint("FirebaseAuthException: ${ex.code} - ${ex.message}");

          // Show user-friendly message
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text("Error: ${ex.message}")),
          );
        },
        codeSent: (String verificationId, int? resendToken) {
          // Once the OTP code is sent, navigate to the OTP screen
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => OtpInScreen(
                mobileNumber: phoneController.text,
                verificationId: verificationId,
                userData: userData, // Pass the user data to OTP page
              ),
            ),
          );
        },
        codeAutoRetrievalTimeout: (String verificationId) {},
      );
    } else {
      // Show error message if user not found
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: Text(responseData['message']),
      ));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () {
            Navigator.pop(context);
          },
        ),
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            Container(
              height: MediaQuery.of(context).size.height * 0.5,
              width: double.infinity,
              decoration: BoxDecoration(
                image: DecorationImage(
                  image: AssetImage('assets/images/signimg.png'),
                  fit: BoxFit.cover,
                ),
              ),
            ),
            Container(
              height: MediaQuery.of(context).size.height * 0.5,
              child: SingleChildScrollView(
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      SizedBox(height: 10),
                      Text(
                        "Login",
                        style: TextStyle(
                          fontSize: 24.0,
                          fontWeight: FontWeight.bold,
                          color: Color(0xFFD68D54),
                        ),
                      ),
                      SizedBox(height: 20),
                      Container(
                        decoration: BoxDecoration(
                          border: Border.all(color: Color(0xFFD68D54)),
                          borderRadius: BorderRadius.circular(30.0),
                        ),
                        child: Row(
                          children: [
                            Container(
                              padding: EdgeInsets.symmetric(horizontal: 13.0),
                              decoration: BoxDecoration(
                                border: Border(
                                    right:
                                        BorderSide(color: Color(0xFFD68D54))),
                              ),
                              child: Text(
                                countryCode,
                                style: TextStyle(
                                  fontSize: 16.0,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                            Expanded(
                              child: TextField(
                                controller: phoneController,
                                keyboardType: TextInputType.number,
                                inputFormatters: [
                                  FilteringTextInputFormatter.digitsOnly,
                                  LengthLimitingTextInputFormatter(10),
                                ],
                                decoration: InputDecoration(
                                  labelText: "Mobile Number",
                                  prefixIcon: Icon(
                                    Icons.call,
                                    color: Color(0xFFD68D54),
                                  ),
                                  border: InputBorder.none,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                      SizedBox(height: 20),
                      Text(
                        "By signing in you are agreed to our Terms & Conditions and Privacy Policy",
                        style: TextStyle(fontSize: 12, color: Colors.grey[600]),
                        textAlign: TextAlign.center,
                      ),
                      SizedBox(height: 20),
                      SizedBox(
                        width: double.infinity,
                        child: ElevatedButton(
                          // onPressed: () async {
                          //   String phoneNumber =
                          //       countryCode + phoneController.text.trim();
                          //   await FirebaseAuth.instance.verifyPhoneNumber(
                          //     phoneNumber: phoneNumber,
                          //     verificationCompleted:
                          //         (PhoneAuthCredential credential) {},
                          //     verificationFailed: (FirebaseAuthException ex) {
                          //       // Print error to console
                          //       debugPrint(
                          //           "FirebaseAuthException: ${ex.code} - ${ex.message}");

                          //       // Show user-friendly message
                          //       ScaffoldMessenger.of(context).showSnackBar(
                          //         SnackBar(
                          //             content: Text("Error: ${ex.message}")),
                          //       );
                          //     },
                          //     codeSent:
                          //         (String verificationId, int? resendToken) {
                          //       Navigator.push(
                          //         context,
                          //         MaterialPageRoute(
                          //           builder: (context) => OtpInScreen(
                          //             mobileNumber: phoneController.text,
                          //             verificationId: verificationId,
                          //             userData: userData,
                          //           ),
                          //         ),
                          //       );
                          //     },
                          //     codeAutoRetrievalTimeout:
                          //         (String verificationId) {},
                          //   );
                          // },
                          onPressed: checkPhoneNumber,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: const Color(0xFFD68D54),
                            padding: const EdgeInsets.symmetric(vertical: 12.0),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(30.0),
                            ),
                          ),
                          child: Text(
                            "Get OTP",
                            style: TextStyle(
                              fontSize: 16.0,
                              fontWeight: FontWeight.bold,
                              color: Colors.white,
                            ),
                          ),
                        ),
                      ),
                      SizedBox(height: 20),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text("Don't have an account?"),
                          GestureDetector(
                            onTap: () {
                              Navigator.pushNamed(context, '/signup');
                            },
                            child: Text(
                              " Sign Up",
                              style: TextStyle(
                                color: Color(0xFFD68D54),
                                fontSize: 14.0,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
