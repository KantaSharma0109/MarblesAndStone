import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:mobile_login/controllers/auth_service.dart';
import 'package:mobile_login/pages/admin_page.dart';
import 'package:mobile_login/pages/navbar.dart';
import 'package:http/http.dart' as http;

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;

  final TextEditingController _phoneController = TextEditingController();
  final TextEditingController _otpController = TextEditingController();

  String _role = '';
  String _userId = '';
  String _userName = ''; // Variable to hold fetched user name

  Future<void> checkNumberExists(String phoneNumber) async {
    try {
      String uri = "https://snpublicity.com/api/check_number.php";

      var res = await http.post(Uri.parse(uri), body: {
        "mobile_number": phoneNumber,
      });

      if (res.statusCode == 200) {
        var response = jsonDecode(res.body);
        if (response["success"] == true) {
          _role = response["role"];
          _userId = response["user_id"];
          _userName =
              response["user_name"]; // Capture user name // Capture user ID

          // Save the user ID and name locally
          SharedPreferences prefs = await SharedPreferences.getInstance();
          await prefs.setString('user_id', _userId);
          await prefs.setString('user_name', _userName);

          sendOtp();
        } else {
          _showAlertDialog(context, response['message']);
        }
      } else {
        print("Failed to verify number. HTTP Status Code: ${res.statusCode}");
        _showAlertDialog(context, "Failed to verify number");
      }
    } catch (e) {
      print("Error verifying number: $e");
      _showAlertDialog(context, "Error verifying number");
    }
  }

  Future<void> sendOtp() async {
    AuthService.sentOtp(
      phone: _phoneController.text,
      errorStep: () => ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
            "Error in sending OTP",
            // style: TextStyle(color: Colors.white),
          ),
          // backgroundColor: Colors.red,
        ),
      ),
      nextStep: () {
        showDialog(
          context: context,
          builder: (context) => AlertDialog(
            title: const Text("OTP verification"),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text("Enter 6 digit OTP"),
                const SizedBox(
                  height: 12,
                ),
                Form(
                  key: _formKey1,
                  child: TextFormField(
                    keyboardType: TextInputType.number,
                    controller: _otpController,
                    decoration: const InputDecoration(
                      labelText: "Enter your OTP",
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.all(Radius.circular(32)),
                      ),
                    ),
                    validator: (value) {
                      if (value!.length != 6) {
                        return "Invalid OTP";
                      }
                      return null;
                    },
                  ),
                ),
              ],
            ),
            actions: [
              TextButton(
                onPressed: () {
                  if (_formKey1.currentState!.validate()) {
                    AuthService.loginWithOtp(
                      otp: _otpController.text,
                    ).then((value) {
                      if (value == "Success") {
                        Navigator.pop(context);
                        if (_role == "admin") {
                          Navigator.pushReplacement(
                            context,
                            MaterialPageRoute(
                                builder: (context) => const AdminPage()),
                          );
                        } else if (_role == "customer") {
                          Navigator.pushReplacement(
                            context,
                            MaterialPageRoute(
                                builder: (context) =>
                                    const NavbarPage(initialIndex: 0)),
                          );
                        }
                      }
                      //else {
                      //   Navigator.pop(context);
                      //   ScaffoldMessenger.of(context).showSnackBar(
                      //     SnackBar(
                      //       content: Text(
                      //         value,
                      //         style: const TextStyle(color: Colors.white),
                      //       ),
                      //       backgroundColor: Colors.red,
                      //     ),
                      //   );
                      // }
                    });
                  }
                },
                child: const Text("Submit"),
              )
            ],
          ),
        );
      },
    );
  }

  void _showAlertDialog(BuildContext context, String message) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text("Error"),
        content: Text(message),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text("OK"),
          ),
        ],
      ),
    );
  }

  final _formKey = GlobalKey<FormState>();
  final _formKey1 = GlobalKey<FormState>();

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(vsync: this);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: LayoutBuilder(builder: (context, constraints) {
        return SingleChildScrollView(
            child: ConstrainedBox(
          constraints: BoxConstraints(
            minHeight: constraints.maxHeight,
          ),
          child: Padding(
            padding: EdgeInsets.only(
              left: 20,
              right: 20,
              bottom: MediaQuery.of(context).viewInsets.bottom,
            ),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                // Image.asset(
                //   "assets/SNPublicity.png",
                //   height: 150,
                //   width: 300,
                //   fit: BoxFit.contain,
                // ),
                Container(
                  width: 230, // Adjust width as needed
                  height: 230, // Adjust height as needed
                  decoration: BoxDecoration(
                    color: Colors.white, // Background color of the container
                    borderRadius:
                        BorderRadius.circular(180.0), // Rounded corners
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.5), // Shadow color
                        spreadRadius: 2, // How much the shadow spreads
                        blurRadius: 5, // How blurred the shadow is
                        offset: const Offset(0, 3), // Position of the shadow
                      ),
                    ],
                  ),
                  child: Center(
                    child: ClipRRect(
                      borderRadius:
                          BorderRadius.circular(180.0), // Rounded corners
                      child: Image.asset(
                        'assets/SNPublicity.png',
                        fit: BoxFit.cover,
                      ),
                    ),
                  ),
                ),
                // const SizedBox(height: 20),
                Padding(
                  padding: const EdgeInsets.all(10),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      const Text(
                        "Login an account",
                        style: TextStyle(
                            fontSize: 20, fontWeight: FontWeight.w700),
                      ),
                      const Text("Enter your phone Number to continue."),
                      const SizedBox(
                        height: 20,
                      ),
                      Form(
                        key: _formKey,
                        child: TextFormField(
                          controller: _phoneController,
                          keyboardType: TextInputType.phone,
                          decoration: InputDecoration(
                            prefixText: "+91 ",
                            labelText: "Enter your phone number",
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(32),
                            ),
                          ),
                          validator: (value) {
                            if (value!.length != 10) {
                              return "Invalid phone number";
                            }
                            return null;
                          },
                        ),
                      ),
                      const SizedBox(
                        height: 20,
                      ),
                      SizedBox(
                        height: 50,
                        width: double.infinity,
                        child: ElevatedButton(
                          onPressed: () {
                            if (_formKey.currentState!.validate()) {
                              checkNumberExists(_phoneController.text);
                            }
                          },
                          // style: ElevatedButton.styleFrom(
                          //   backgroundColor: Colors.yellow,
                          //   // foregroundColor: Colors.black,
                          // ),
                          child: const Text(
                            "Send OTP",
                            style: TextStyle(fontSize: 18),
                          ),
                        ),
                      )
                    ],
                  ),
                ),
              ],
            ),
          ),
        ));
      }),
    );
  }
}
