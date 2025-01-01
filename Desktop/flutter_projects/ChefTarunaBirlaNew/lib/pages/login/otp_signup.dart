import 'dart:convert';

import 'package:chef_taruna_birla/pages/main_container.dart';
import 'package:chef_taruna_birla/viewmodels/main_container_viewmodel.dart';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';

import 'package:provider/provider.dart';
import 'package:http/http.dart' as http;
import '../../utils/utility.dart';

class OtpUpScreen extends StatefulWidget {
  final String mobileNumber;
  final String name;
  final String address;
  final String email;
  final String password;
  String verificationId;

  OtpUpScreen(
      {super.key,
      required this.mobileNumber,
      required this.verificationId,
      required this.name,
      required this.address,
      required this.password,
      required this.email});

  @override
  OtpUpScreenState createState() => OtpUpScreenState();
}

class OtpUpScreenState extends State<OtpUpScreen> {
  // TextEditingControllers for OtpIn input fields
  final FirebaseAuth _auth = FirebaseAuth.instance;
  List<TextEditingController> OtpInControllers =
      List.generate(6, (_) => TextEditingController());
  bool showLoading = false;
  String deviceToken = '';

  List<FocusNode> focusNodes = List.generate(6, (_) => FocusNode());

  void _onOtpInChanged(String value, int index) {
    if (value.isNotEmpty) {
      if (index < 5) {
        FocusScope.of(context).requestFocus(focusNodes[index + 1]);
      }
    }
  }

  void _resendOtpIn() {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('OtpIn has been resent to ${widget.mobileNumber}'),
      ),
    );
  }

  Future<void> insert_user() async {
    const String url =
        "http://192.168.29.202:8080/taruna_birla_api/user_data.php"; // Replace with your server URL

    final Map<String, String> body = {
      'mobileNumber': widget.mobileNumber,
      'name': widget.name,
      'email': widget.email,
      'address': widget.address,
      'password': widget.password,
    };

    try {
      final response = await http.post(
        Uri.parse(url),
        body: body,
      );
      print("Request Body: $body"); // Log the request
      print("Response: ${response.body}"); // Log the response
      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        if (data['success'] == "true") {
          print("User inserted successfully");
        } else {
          print("Failed to insert user: ${data['error']}");
        }
      } else {
        print("Server error: ${response.statusCode}");
      }
    } catch (e) {
      print("Error while inserting user: $e");
    }
  }

  Future<void> getAppData() async {
    await Provider.of<MainContainerViewModel>(context, listen: false)
        .getAppData(context);
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
            SizedBox(
              height: MediaQuery.of(context).size.height * 0.5,
              child: SingleChildScrollView(
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      SizedBox(height: 10),

                      Text(
                        "Enter Otp",
                        style: TextStyle(
                          fontSize: 24.0,
                          fontWeight: FontWeight.bold,
                          color: Color(0xFFD68D54),
                        ),
                      ),
                      SizedBox(height: 20),

                      Text(
                        "Sent on: ${widget.mobileNumber}",
                        style: TextStyle(
                          color: Colors.grey,
                          fontSize: 14.0,
                          fontWeight: FontWeight.bold,
                        ),
                      ),

                      SizedBox(height: 20),

                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: List.generate(6, (index) {
                          return Container(
                            width: 40.0,
                            margin: EdgeInsets.symmetric(horizontal: 5.0),
                            child: TextField(
                              controller: OtpInControllers[index],
                              focusNode: focusNodes[index],
                              textAlign: TextAlign.center,
                              keyboardType: TextInputType.phone,
                              maxLength: 1,
                              decoration: InputDecoration(
                                counterText: "", // Hide the counter
                                border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(10.0),
                                ),
                              ),
                              // Move to the next box when a digit is entered
                              onChanged: (value) =>
                                  _onOtpInChanged(value, index),
                              onEditingComplete: () {
                                // Move focus to the next field when done
                                if (index < 5) {
                                  FocusScope.of(context)
                                      .requestFocus(focusNodes[index + 1]);
                                }
                              },
                            ),
                          );
                        }),
                      ),

                      SizedBox(height: 20),

                      // Resend OtpIn Button
                      TextButton(
                        onPressed: _resendOtpIn,
                        child: Text(
                          "Resend Otp",
                          style: TextStyle(
                            color: Color(0xFFD68D54),
                            fontSize: 16.0,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),

                      SizedBox(height: 20),

                      // Login Button
                      SizedBox(
                        width: double.infinity,
                        child: ElevatedButton(
                          // onPressed: () async {
                          //   String OtpInCode = OtpInControllers.map(
                          //       (controller) => controller.text).join();
                          //   PhoneAuthCredential credential =
                          //       PhoneAuthProvider.credential(
                          //     verificationId: widget.verificationId,
                          //     smsCode: OtpInCode,
                          //   );

                          //   try {
                          //     await FirebaseAuth.instance
                          //         .signInWithCredential(credential);
                          //     await getAppData();
                          //     insert_user(); // Ensure app data is loaded
                          //     Navigator.pushAndRemoveUntil(
                          //       context,
                          //       MaterialPageRoute(
                          //           builder: (context) =>
                          //               const MainContainer()),
                          //       (Route<dynamic> route) => false,
                          //     );
                          //   } catch (e) {
                          //     Utility.printLog(
                          //         'Error during sign-in or navigation: $e');
                          //   }
                          // },
                          // onPressed: () async {
                          //   String OtpInCode = OtpInControllers.map(
                          //       (controller) => controller.text).join();

                          //   PhoneAuthCredential credential =
                          //       PhoneAuthProvider.credential(
                          //     verificationId: widget.verificationId,
                          //     smsCode: OtpInCode,
                          //   );

                          //   try {
                          //     await FirebaseAuth.instance
                          //         .signInWithCredential(credential);
                          //     await insert_user(); // Call to insert user data

                          //     Navigator.pushAndRemoveUntil(
                          //       context,
                          //       MaterialPageRoute(
                          //           builder: (context) =>
                          //               const MainContainer()),
                          //       (Route<dynamic> route) => false,
                          //     );
                          //   } catch (e) {
                          //     Utility.printLog(
                          //         'Error during sign-in or navigation: $e');
                          //   }
                          // },
                          onPressed: () async {
                            // Join the OTP inputs into a single string
                            String OtpInCode = OtpInControllers.map(
                                (controller) => controller.text).join();

                            // Create PhoneAuthCredential with the OTP
                            PhoneAuthCredential credential =
                                PhoneAuthProvider.credential(
                              verificationId: widget.verificationId,
                              smsCode: OtpInCode,
                            );

                            try {
                              // Sign in the user with the OTP credential
                              await FirebaseAuth.instance
                                  .signInWithCredential(credential);

                              // Call insert_user to insert user data into the server
                              await insert_user();

                              // Ensure that app data is loaded
                              await getAppData();

                              // Navigate to MainContainer after user data is inserted and app data is fetched
                              Navigator.pushAndRemoveUntil(
                                context,
                                MaterialPageRoute(
                                  builder: (context) => const MainContainer(),
                                ),
                                (Route<dynamic> route) => false,
                              );
                            } catch (e) {
                              // Log error if any occurs during sign-in, data insertion, or navigation
                              Utility.printLog(
                                  'Error during sign-in or navigation: $e');
                            }
                          },

                          style: ElevatedButton.styleFrom(
                            backgroundColor:
                                const Color(0xFFD68D54), // Button color
                            padding: const EdgeInsets.symmetric(vertical: 12.0),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(30.0),
                            ),
                          ),
                          child: Text(
                            "Login",
                            style: TextStyle(
                                fontSize: 16.0,
                                fontWeight: FontWeight.bold,
                                color: Colors.white),
                          ),
                        ),
                      ),
                      SizedBox(height: 20),
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
