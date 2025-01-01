import 'package:chef_taruna_birla/pages/login/otp_signup.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;

import '../startup/splash.dart';

class SignUpScreen extends StatefulWidget {
  const SignUpScreen({super.key});

  @override
  _SignUpScreenState createState() => _SignUpScreenState();
}

class _SignUpScreenState extends State<SignUpScreen> {
  final nameController = TextEditingController();
  final addressController = TextEditingController();
  final emailController = TextEditingController();

  final phoneController = TextEditingController();
  final passwordController = TextEditingController();

  static const double textBoxHeight = 55.0;

  String countryCode = "+91";

  // void _sendOTP() {
  //   final phoneNumber = "$countryCode${phoneController.text.trim()}";
  //   print("Sending OTP to: $phoneNumber");
  //   // Add your Firebase OTP function here
  // }

  // final FirebaseAuth _auth = FirebaseAuth.instance;
  // String verificationId = '';
  Future<void> _checkPhoneNumberAndSendOTP() async {
    final phoneNumber = phoneController.text.trim();
    if (phoneNumber.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Please enter your mobile number.")),
      );
      return;
    }

    try {
      // Replace with your actual PHP API endpoint
      final url =
          "http://192.168.29.202:8080/taruna_birla_api/check_number.php";
      final response = await http.post(Uri.parse(url), body: {
        'mobileNumber': phoneNumber,
      });

      if (response.statusCode == 200) {
        final result = json.decode(response.body);
        // if (result['exists'] == "true") {
        //   ScaffoldMessenger.of(context).showSnackBar(
        //     SnackBar(content: Text(result['message'])),
        //   );
        //   // Navigate to the splash screen
        //   Navigator.pushReplacementNamed(context, '/SplashScreen');
        // }
        if (result['exists'] == "true") {
          showDialog(
            context: context,
            builder: (BuildContext context) {
              return AlertDialog(
                title: Text("Account Exists"),
                content: Text(result['message']),
                actions: [
                  TextButton(
                    onPressed: () {
                      // Navigate to Splash Screen
                      Navigator.pushReplacement(
                        context,
                        MaterialPageRoute(builder: (context) => SplashScreen()),
                      );
                    },
                    child: Text("OK"),
                  ),
                ],
              );
            },
          );
        } else {
          // Proceed with OTP verification
          await FirebaseAuth.instance.verifyPhoneNumber(
            phoneNumber: "$countryCode$phoneNumber",
            verificationCompleted: (PhoneAuthCredential credential) {},
            verificationFailed: (FirebaseAuthException ex) {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text("Error: ${ex.message}")),
              );
            },
            codeSent: (String verificationId, int? resendToken) {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => OtpUpScreen(
                    name: nameController.text,
                    address: addressController.text,
                    email: emailController.text,
                    password: passwordController.text,
                    mobileNumber: phoneController.text,
                    verificationId: verificationId,
                  ),
                ),
              );
            },
            codeAutoRetrievalTimeout: (String verificationId) {},
          );
        }
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("Server error. Please try again later.")),
        );
      }
    } catch (e) {
      debugPrint("Error: $e");
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("An error occurred. Please try again.")),
      );
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
              height: MediaQuery.of(context).size.height * 0.2,
              width: double.infinity,
              decoration: BoxDecoration(
                image: DecorationImage(
                  image: AssetImage('assets/images/signup.png'),
                  fit: BoxFit.cover,
                ),
              ),
            ),
            SingleChildScrollView(
              child: Container(
                height: MediaQuery.of(context).size.height * 0.8,
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: SingleChildScrollView(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        SizedBox(height: 10),
                        Text(
                          "Register",
                          style: TextStyle(
                            fontSize: 24.0,
                            fontWeight: FontWeight.bold,
                            color: Color(0xFFD68D54),
                          ),
                        ),
                        SizedBox(height: 20),

                        // Name Input Field
                        SizedBox(
                          child: _buildInputField(
                            controller: nameController,
                            label: "Name",
                            icon: Icons.person,
                          ),
                        ),

                        SizedBox(height: 20),

                        // Phone Number Input Field
                        SizedBox(
                          child: _buildInputField(
                            controller: phoneController,
                            label: "Mobile Number",
                            icon: Icons.call,
                            keyboardType: TextInputType.phone,
                            inputFormatters: [
                              FilteringTextInputFormatter.digitsOnly,
                              LengthLimitingTextInputFormatter(10),
                            ],
                          ),
                        ),

                        SizedBox(height: 20),

                        // Email Input Field
                        SizedBox(
                          child: _buildInputField(
                            controller: emailController,
                            label: "Email",
                            icon: Icons.email,
                            keyboardType: TextInputType.emailAddress,
                          ),
                        ),

                        SizedBox(height: 20),

                        // Address Input Field
                        SizedBox(
                          child: _buildInputField(
                            controller: addressController,
                            label: "Address",
                            icon: Icons.location_on,
                          ),
                        ),

                        SizedBox(height: 20),

                        // Password Input Field
                        SizedBox(
                          child: _buildInputField(
                            controller: passwordController,
                            label: "Password",
                            icon: Icons.lock,
                            obscureText: true,
                          ),
                        ),

                        SizedBox(height: 20),

                        SizedBox(
                          width: double.infinity,
                          child: ElevatedButton(
                            onPressed: _checkPhoneNumberAndSendOTP,

                            // onPressed: () async {
                            //   if (nameController.text.isEmpty ||
                            //       phoneController.text.isEmpty ||
                            //       emailController.text.isEmpty ||
                            //       addressController.text.isEmpty ||
                            //       passwordController.text.isEmpty) {
                            //     ScaffoldMessenger.of(context).showSnackBar(
                            //         SnackBar(
                            //             content: Text(
                            //                 "Please fill in all the fields.")));
                            //     return;
                            //   }

                            //   String phoneNumber =
                            //       countryCode + phoneController.text.trim();

                            //   await FirebaseAuth.instance.verifyPhoneNumber(
                            //     phoneNumber: phoneNumber,
                            //     verificationCompleted:
                            //         (PhoneAuthCredential credential) {},
                            //     verificationFailed: (FirebaseAuthException ex) {
                            //       debugPrint(
                            //           "FirebaseAuthException: ${ex.code} - ${ex.message}");
                            //       ScaffoldMessenger.of(context)
                            //           .showSnackBar(SnackBar(
                            //         content: Text("Error: ${ex.message}"),
                            //       ));
                            //     },
                            //     codeSent:
                            //         (String verificationId, int? resendToken) {
                            //       Navigator.push(
                            //         context,
                            //         MaterialPageRoute(
                            //           builder: (context) => OtpUpScreen(
                            //             name: nameController.text,
                            //             address: addressController.text,
                            //             email: emailController.text,
                            //             password: passwordController.text,
                            //             mobileNumber: phoneController.text,
                            //             verificationId: verificationId,
                            //           ),
                            //         ),
                            //       );
                            //     },
                            //     codeAutoRetrievalTimeout:
                            //         (String verificationId) {},
                            //   );
                            // },
                            style: ElevatedButton.styleFrom(
                              backgroundColor: const Color(0xFFD68D54),
                              padding:
                                  const EdgeInsets.symmetric(vertical: 12.0),
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
                            Text("Already have an account?"),
                            GestureDetector(
                              onTap: () {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                      builder: (context) => SignUpScreen()),
                                );
                              },
                              child: Text(
                                " Login",
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
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildInputField({
    required TextEditingController controller,
    required String label,
    required IconData icon,
    TextInputType keyboardType = TextInputType.text,
    List<TextInputFormatter>? inputFormatters,
    bool obscureText = false,
  }) {
    return Container(
      height: textBoxHeight, // Set the height here
      decoration: BoxDecoration(
        border: Border.all(color: Color(0xFFD68D54)),
        borderRadius: BorderRadius.circular(30.0),
      ),
      child: Row(
        children: [
          Container(
            padding: EdgeInsets.symmetric(horizontal: 13.0),
            child: Icon(icon, color: Color(0xFFD68D54)),
          ),
          Expanded(
            child: TextField(
              controller: controller,
              keyboardType: keyboardType,
              inputFormatters: inputFormatters,
              obscureText: obscureText,
              decoration: InputDecoration(
                hintText: label, // Use hintText instead of labelText
                border: InputBorder.none,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
