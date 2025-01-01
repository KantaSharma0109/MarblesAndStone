import 'package:flutter/material.dart';
import 'package:chef_taruna_birla/pages/login/signin.dart';
import 'package:chef_taruna_birla/pages/login/signup.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen>
    with TickerProviderStateMixin {
  late AnimationController animationController;
  late AnimationController slideAnimation;
  late Animation<Offset> offsetAnimation;
  late Animation<Offset> textAnimation;

  // Future<void> getAppData() async {
  //   Provider.of<MainContainerViewModel>(context, listen: false)
  //       .getAppData(context);

  //   // Future.delayed(const Duration(seconds: 3), () {
  //   //   Navigator.pushReplacement(
  //   //     context,
  //   //     MaterialPageRoute(
  //   //       builder: (context) => const MainContainer(),
  //   //     ),
  //   //   );
  //   // });
  // }

  @override
  void initState() {
    animationController = AnimationController(
      vsync: this,
      lowerBound: 0,
      upperBound: 60,
      animationBehavior: AnimationBehavior.normal,
      duration: const Duration(milliseconds: 700),
    );

    animationController.forward();

    slideAnimation = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 700),
    );

    offsetAnimation = Tween<Offset>(
      begin: Offset.zero,
      end: const Offset(0.0, 0.0),
    ).animate(
      CurvedAnimation(
        parent: slideAnimation,
        curve: Curves.easeInToLinear,
      ),
    );

    textAnimation = Tween<Offset>(
      begin: const Offset(-0.5, 0.0),
      end: const Offset(0.2, 0.0),
    ).animate(
      CurvedAnimation(
        parent: slideAnimation,
        curve: Curves.fastOutSlowIn,
      ),
    );

    animationController.addStatusListener((status) {
      if (status == AnimationStatus.completed) {
        slideAnimation.forward();
      }
    });
    // getAppData();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body:
          //   Container(
          //     color: Palette.black,
          //     width: double.infinity,
          //     height: double.infinity,
          //     child: Center(
          //       child: AnimatedBuilder(
          //         animation: animationController,
          //         builder: (_, child) {
          //           return SlideTransition(
          //             position: offsetAnimation,
          //             child: Image.asset(
          //               'assets/images/tb_splash_img.png',
          //               height: double.infinity,
          //               fit: BoxFit.cover,
          //               alignment: Alignment.center,
          //             ),
          //           );
          //         },
          //       ),
          //     ),
          //   ),
          // );
          Stack(
        children: [
          // Background Image
          Positioned.fill(
            child: AnimatedBuilder(
              animation: animationController,
              builder: (_, child) {
                return SlideTransition(
                  position: offsetAnimation,
                  child: Image.asset(
                    'assets/images/tb_splash_img.png',
                    height: double.infinity,
                    fit: BoxFit.cover,
                    alignment: Alignment.center,
                  ),
                );
              },
            ),
          ),
          // Sign In Button and Text at the Bottom
          Positioned(
            bottom: 40.0,
            left: 16.0, // Add padding on the left
            right: 16.0, // Add padding on the right
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(builder: (context) => SignInScreen()),
                      );
                      // Navigate to sign-in screen or perform sign-in action
                      print("Sign In button pressed");
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor:
                          const Color(0xFFD68D54), // Set button color to D68D54
                      padding: const EdgeInsets.symmetric(vertical: 12.0),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(30.0),
                      ),
                    ),
                    child: const Text(
                      "Sign In",
                      style: TextStyle(
                        fontSize: 16.0,
                        fontWeight: FontWeight.bold,
                        color: Colors
                            .white, // Set text color to white for contrast
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 16.0),
                // "Don't have an account? Sign Up" Text
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Text(
                      "Don’t have an account?",
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 14.0,
                      ),
                    ),
                    const SizedBox(width: 5.0),
                    GestureDetector(
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                              builder: (context) => SignUpScreen()),
                        );
                        // Navigate to sign-in screen or perform sign-in action
                        print("Sign In button pressed");
                      },
                      child: const Text(
                        "Sign Up",
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
        ],
      ),
    );
  }
}
